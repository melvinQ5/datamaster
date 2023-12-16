
select  count(1) from (
-- 5天前未发货 无包裹号 
) tmp 


-- 第一类推送  客户订单超5天未发货且SKU无采购下单记录
-- 	筛选：订单支付时间距今5天以前(2023年开始统计），且客户订单未发货，且对应SKU无采购在途记录
daily_orderdetails_final
select dod.*
from (
	select id ,BoxSku ,OrderNumber ,NodePathNameFull ,SellUserName ,PayTime
	from import_data.daily_OrderDetails_Test d
	join import_data.mysql_store ws on d.ShopIrobotId = ws.Code 
	where TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 
		and PayTime >= '2023-01-01'
		and PayTime < date_add(CURRENT_DATE(),interval -5 day ) and ShipmentStatus = '未发货' 
	) dod
left join import_data.daily_OrderDelete od on dod.id =od.id 
left join 
	(
	select BoxSku 
	from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '否' group by BoxSku
	) dpo 
on dod.BoxSku = dpo.BoxSku 
where od.id is null  and  dpo.BoxSku is null 







-- 采购已下单超2天无收货记录
-- 	筛选：下单时间在2023年1月，入库状态为未完结的，截至当前无收货表信息的记录
-- 	字段：下单号 | 快递单号 | 采购人员 | 采购时间 | BoxSku | 最早客户订单支付时间  

	
CREATE VIEW `ads_purchase_tracking_list` as 
select a.* ,b.min_paytime
from (
	select dpo.OrderNumber as purc_OrderNumber ,OrderPerson as purc_OrderPerson 
		,dpo.ordertime as purc_OrderTime ,dpo.PurchaseOrderNo ,dpo.Quantity
		,BoxSku ,dpo.DeliveryNumber
	from import_data.daily_PurchaseOrder dpo 
	left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber 
	where dpr.OrderNumber is null and OrderTime >= '2023-01-01' and IsComplete = '否' 
		and OrderTime < date_add(CURRENT_DATE(),interval -2 day )
	) a 
left join (
	select BoxSku , min(PayTime) as min_paytime 
	from import_data.daily_OrderDetails dod 
	where TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0   
		and ShipTime = '2000-01-01 00:00:00' 
	group by BoxSku
	) b 
on a.BoxSku = b.BoxSku
