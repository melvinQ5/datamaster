
-- 销售额 利润额 
select 
sum(if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) / ExchangeUSD) sale_amount_aftertax
,sum(if (TaxGross > 0, TotalProfit, TotalProfit * (1 - ifnull(TaxRatio, 0))) / ExchangeUSD) profit_amount_aftertax
from import_data.OrderDetails od
left join import_data.Basedata b on b.ReportType = '周报' and b.FirstDay = '2022-12-19' and b.DepSite = od.right(ShopIrobotId ,2)
where PayTime >= '2022-12-19' and PayTime < '2022-12-26'
and  left(ShopIrobotId,2) in ('VK','QV')
and od.OrderNumber not in
	(
	select OrderNumber from (
	SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
	where
	ShipmentStatus = '未发货' and OrderStatus = '作废'
	and PayTime >= '2022-12-19' and PayTime < '2022-12-26'
	group by OrderNumber
	) a
	where alltype = '付款'
	)

-- 退款金额

SELECT  sum(ro.RefundUSDPrice) refund_amount 
FROM import_data.RefundOrders ro
where RefundDate >= '2022-12-19' and RefundDate < '2022-12-26'
and  left(OrderSource,2) in ('VK','QV')


-- 发货退款

SELECT  sum(ro.RefundUSDPrice) refund_amount 
FROM import_data.RefundOrders ro
where RefundDate >= '2022-12-19' and RefundDate < '2022-12-26'
and  left(OrderSource,2) in ('VK','QV')
and ShipDate > '2000-01-01 00:00:00'


