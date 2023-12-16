-- 付款时间为近30天的订单，状态=作废且匹配退款原因种不是客户主动取消的订单
SELECT  
	round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `作废订单率`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0 
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) 
	and PayTime < '${FristDay}'