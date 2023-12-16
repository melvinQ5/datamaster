
select  
	sum(case when RefundReason1 ='仓储部原因' then RefundUSDPrice/ord_gross end) `仓储原因退款率`
	,sum(case when RefundReason1 ='物流原因' then RefundUSDPrice/ord_gross end) `物流原因退款率`
	,sum(case when RefundReason1 ='订单问题' then RefundUSDPrice/ord_gross end) `订单问题退款率`
-- 	,sum(case when RefundReason1 ='产品原因' then RefundUSDPrice/ord_gross end)`产品原因退款率`
	,sum(case when RefundReason1 ='缺货' then RefundUSDPrice/ord_gross end) `缺货原因退款率`
	,sum(case when RefundReason1 ='售后' then RefundUSDPrice/ord_gross end) `售后原因退款率`
-- 	,sum(case when RefundReason1 ='客户原因' then RefundUSDPrice/ord_gross end) `非无理由客户原因退款率`
from 
(select ro.RefundReason1 ,ro.RefundUSDPrice
FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource and s.ShopStatus = '正常'
where RefundDate >= DATE_ADD('${FristDay}', interval -30 day) 
	and RefundDate < '${FristDay}' 
	and RefundReason2  not in ('客户个人原因', '无理由取消订单') 
-- 	and IsShipment ='否'  -- 不管是否发货
) A
,(SELECT sum(TotalGross/ExchangeUSD ) ord_gross
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0 
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) and PayTime < '${FristDay}' 
) B 

