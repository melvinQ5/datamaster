with
ta as (
select ['UK-01','DE-02','FR-03','US-04','CA-05','AU-06','MX-07','ES-08','IT-09','NL-10','SE-11','BE-12'] arr
)

,tb as (
select *
from (select unnest as arr
	from ta ,unnest(arr)
	) tmp
)

, res as (
select
     a.dep2 ,a.site ,right(arr,2) sort
	,round( (gross_include_refunds - ifnull(expend_include_ads,0)  ) /
	        (gross_include_refunds) ,4) TotalProfit
from (
    select

        ifnull(ms.dep2,'快百货') dep2
        ,ms.site
        ,round( sum((TotalGross )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(-1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) ),2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code 
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and FeeGross = 0 and OrderStatus <> '作废'
      and TransactionType = '付款'
    group by grouping sets ((ms.site),(dep2,ms.site))
) a
left join tb on a.site = left(tb.arr,2)
order by right(arr,2)
)

select
    concat(dep2,site,'挂单利润率') as 匹配列
    ,dep2 as 团队
    ,concat(site,'挂单利润率') as 关键指标
    ,TotalProfit as value
from res


