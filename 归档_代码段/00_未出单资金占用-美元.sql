-- 未出单SKU资金占用
-- 美元
select round(sku_noorder_amount/usdratio) as `未出单SKU资金占用` from
(
	select  sum(TotalPrice) sku_noorder_amount from import_data.WarehouseInventory
	where  Monday >= '2022-11-14' and Monday < '2022-11-20' and ReportType = '周报' and WarehouseName = '东莞仓'
	and BoxSku not in
	(
	select distinct(BoxSku) from import_data.OrderDetails od
	join import_data.mysql_store s on s.code = od.ShopIrobotId
	where TransactionType = '付款'
	and OrderStatus <> '作废' and OrderTotalPrice > 0
	and PayTime >= '2022-11-14' and PayTime < '2022-11-20'
	)
) a
,(select usdratio from import_data.Basedata 
where firstday ='2022-11-14' and reporttype = '周报' limit 1) b
