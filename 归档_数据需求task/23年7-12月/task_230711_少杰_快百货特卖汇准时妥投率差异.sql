 select left(PayTime,7) pay_month ,ms.Department 
 		,count(distinct case when OrderStatus <> '作废' then PlatOrderNumber end) 未作废订单数
 		,sum(case when OrderStatus <> '作废' then TotalGross/ExchangeUSD end ) 销售额
        ,round( sum(case when OrderStatus <> '作废' then TotalGross/ExchangeUSD end )/count(distinct case when OrderStatus <> '作废' then PlatOrderNumber end),4) `平均客单价`
        ,round( count(distinct case when OrderStatus = '作废' then PlatOrderNumber end)/count(distinct  PlatOrderNumber ),4) `作废订单率`

from import_data.wt_orderdetails wo
join import_data.mysql_store  ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0  and ms.Department  regexp '快百货|特卖汇'
group by left(PayTime,7) ,ms.Department 
order by  pay_month ,ms.Department 