-- 通过对比未删除记录占比的剧烈波动，来感知标记失败
with a as (
select date(PayTime) pay_date
 ,count( case when IsDeleted = 1 then 1 end ) 已删除记录数
 ,count( case when IsDeleted = 0 then 1 end ) 未删除记录数
 ,count( 1 ) 总记录数

from import_data.ods_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.ShopIrobotId=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
  -- and wo.IsDeleted=0
group by date(PayTime)
order by date(PayTime) desc)

select
    case when round( 未删除记录数 / lag(未删除记录数,1) over ( order by pay_date ) ,2 ) >1.5 then '未删除记录猛增' else '' end as 监控结果
    ,round( 未删除记录数 / lag(未删除记录数,1) over ( order by pay_date ) ,2 ) 环比
    ,*
from a
order by pay_date desc ;

-- 删除表中已有订单数据，是否全部标记上了？
select * from ods_orderdetails
where IsDeleted=0
and id in ( select id from daily_OrderDelete );


-- 异常案例 1 ，
-- 删除表的最大DorisImportTime是每天早上的8点（包含了今日）
-- 最大删除日期是 2023-10-05
select max(DeleteTime) from daily_OrderDelete c where c.DorisImportTime >= '2023-09-01'
and c.DorisImportTime <= '2023-10-06';
-- 最大删除日期是 2023-09-23
select max(DeleteTime) from daily_OrderDelete c where c.DorisImportTime >= '2023-09-01'
and c.DorisImportTime <= '2023-10-05';


-- 通过计算销售额来看 异常是否得到解决（当删除标记失败时，销售额异常升高）
select
     '${StartDay}' ,'${ReportType}' ,a.team ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round(gross_include_refunds - ifnull(refunds,0),2) TotalGross
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) /
	        (gross_include_refunds - ifnull(refunds,0)) ,4) ProfitRate
    ,`运费收入占比`
    ,`出单店铺数`
    ,`出单链接数`
    ,round( ori_profit / ori_gross ,4 ) `挂单利润率`
from (
    select
        ifnull(ms.dep2,'快百货') team
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
        ,round( sum(FeeGross)/sum(TotalGross),4) `运费收入占比`
        ,count(distinct shopcode) `出单店铺数`
        ,count(distinct concat(shopcode,SellerSku)) `出单链接数`
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a

left join (
select ifnull(ms.dep2,'快百货') team
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=wo.shopcode and ms.department='快百货'
where wo.IsDeleted = 0 and TransactionType = '退款' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
group by grouping sets ((),(ms.dep2))
) b on  a.team = b.team

left join (
    select  ifnull(ms.dep2,'快百货') team  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.team = c.team;
