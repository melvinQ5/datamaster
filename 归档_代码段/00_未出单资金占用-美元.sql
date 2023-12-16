-- δ����SKU�ʽ�ռ��
-- ��Ԫ
select round(sku_noorder_amount/usdratio) as `δ����SKU�ʽ�ռ��` from
(
	select  sum(TotalPrice) sku_noorder_amount from import_data.WarehouseInventory
	where  Monday >= '2022-11-14' and Monday < '2022-11-20' and ReportType = '�ܱ�' and WarehouseName = '��ݸ��'
	and BoxSku not in
	(
	select distinct(BoxSku) from import_data.OrderDetails od
	join import_data.mysql_store s on s.code = od.ShopIrobotId
	where TransactionType = '����'
	and OrderStatus <> '����' and OrderTotalPrice > 0
	and PayTime >= '2022-11-14' and PayTime < '2022-11-20'
	)
) a
,(select usdratio from import_data.Basedata 
where firstday ='2022-11-14' and reporttype = '�ܱ�' limit 1) b
