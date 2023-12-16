-- 帮我拉一下表1的产品，支付时间在7.1号至今的单量，销售额，出单天数[比心]取PM团队的业绩. 根据业绩情况，我们安排美工换图

select tmp_epp.BoxSku
	, count(distinct PlatOrderNumber) `订单量`
	, count(distinct to_date(PayTime)) `出单天数`
	, sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD) as AfterTax_TotalGross
from import_data.OrderDetails od 
join (select BoxSku from import_data.JinqinSku js where Monday='2022-11-10') tmp_epp on od.BoxSku =tmp_epp.BoxSKU
join import_data.mysql_store ms on ms.Code = od.ShopIrobotId and ms.Department in ('销售二部', '销售三部')
left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
left join 
	( 
	select OrderNumber from (select OrderNumber, GROUP_CONCAT(TransactionType) alltype 
		FROM import_data.OrderDetails od
		where ShipmentStatus = '未发货' and OrderStatus = '作废' and SettlementTime >= '2021-01-01'
		group by OrderNumber) a
	where alltype = '付款'
	) b 
	on b.OrderNumber = od.OrderNumber
where b.OrderNumber is null  
	and od.PayTime >= '2022-07-01' and od.PayTime <='2022-11-09'
	and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0
group by tmp_epp.BoxSku


