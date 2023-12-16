
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `TotalGross`,
  `TotalProfit`,
  `ProfitRate`,
  `FeeGrossRate`,
  SaleShopCnt,
  SaleLstCnt,
OriProfitRate
  )
with
od_pay as (   -- 销售额不含退款数据，利润额不含退款不含广告
select ifnull(dep2,'快百货') team
    ,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
	,round( sum(FeeGross)/sum(TotalGross),4) `运费收入占比`
    ,count(distinct shopcode) `出单店铺数`
    ,count(distinct concat(shopcode,SellerSku)) `出单链接数`
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by grouping sets ((),(dep2))
)


,od_refund as ( -- 销售额对应退款额，利润额对应退款额
select ifnull(dep2,'快百货') team
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款'
group by grouping sets ((),(dep2))
)

,ad_stat as (
    select  ifnull(ms.dep2,'快百货') team  ,sum(AdSpend) AdSpend
    from import_data.wt_adserving_amazon_daily ad
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code
    where ad.GenerateDate >=date_add('${StartDay}',interval -1 day) and ad.GenerateDate <date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
)

select '${StartDay}' ,'${ReportType}' ,a.team ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,week_num_in_year
, sales_undeduct_refunds - ifnull(sales_refund,0) as sales
, round(profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0),2) as profit
,round( (profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0)) / (sales_undeduct_refunds - ifnull(sales_refund,0)) ,4) profit_rate
,运费收入占比 ,出单店铺数 ,出单链接数 ,round( ori_profit / ori_gross ,4 ) `挂单利润率`
from od_pay a
left join od_refund b on a.team  = b.team
left join ad_stat c on a.team = c.team
join dim_date dd on dd.full_date = '${StartDay}';




insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `TotalGross`,
  `TotalProfit`,
  `ProfitRate`,
  `FeeGrossRate`,
  SaleShopCnt,
  SaleLstCnt,
OriProfitRate)
with
od_pay as (   -- 销售额不含退款数据，利润额不含退款不含广告
select nodepathname
    ,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
	,round( sum(FeeGross)/sum(TotalGross),4) `运费收入占比`
    ,count(distinct shopcode) `出单店铺数`
    ,count(distinct concat(shopcode,SellerSku)) `出单链接数`
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by nodepathname
)


,od_refund as ( -- 销售额对应退款额，利润额对应退款额
select nodepathname
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款'
group by nodepathname
)

,ad_stat as (
    select  nodepathname ,sum(AdSpend) AdSpend
    from import_data.wt_adserving_amazon_daily ad
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code
    where ad.GenerateDate >=date_add('${StartDay}',interval -1 day) and ad.GenerateDate <date_add('${NextStartDay}',interval -1 day)
    group by nodepathname
)

select '${StartDay}' ,'${ReportType}' ,a.nodepathname ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,week_num_in_year
, sales_undeduct_refunds - ifnull(sales_refund,0) as sales
, round(profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0),2) as profit
,round( (profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0)) / (sales_undeduct_refunds - ifnull(sales_refund,0)) ,4) profit_rate
,运费收入占比 ,出单店铺数 ,出单链接数 ,round( ori_profit / ori_gross ,4 ) `挂单利润率`
from od_pay a
left join od_refund b on a.nodepathname  = b.nodepathname
left join ad_stat c on a.nodepathname = c.nodepathname
join dim_date dd on dd.full_date = '${StartDay}';



-- 团队人数 利润率人效
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`
  ,`NumberOfTeam` , `ProfitPerformance`)
select  '${StartDay}' ,'${ReportType}' ,b.EmpCount ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,EmpCount -- 团队人数
    ,round(case when '${ReportType}' = '周报' then TotalProfit / 7 * day( date_add( date_format( date_add('${StartDay}', interval 1 month ) , '%Y-%m-01') ,-1) ) /b.EmpCount
        when '${ReportType}' = '月报' then TotalProfit / day(date_add('${NextStartDay}',interval -1 day)) * day( date_add( date_format( date_add('${StartDay}', interval 1 month ) , '%Y-%m-01') ,-1) ) /b.EmpCount
    end,0) as ProfitPerformance
        -- 利润额人效
from ads_ag_kbh_report_weekly a
join (
    select department  , EmpCount from ads_staff_stat where ReportType = '月报' and department='快百货' and FirstDay = (select max(FirstDay) from ads_staff_stat )
) b on a.Team = b.department
where a.FirstDay = '${StartDay}' and a.ReportType= '${ReportType}' ;


