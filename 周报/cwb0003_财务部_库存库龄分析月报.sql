-- �ִ��룬4�¼�֮��ʹ�ã���Ҫ�Ķ������ո��������ܸ���棬�ո����������¸����㣩
-- ����4�� '${NextStartDay}' = '2023-05-01' , '${StartDay}' = '2023-04-01'
select dwi.boxsku,wp.ProjectTeam`����`,SUM(dwi.InventoryAge270)+SUM(dwi.InventoryAge365)+SUM(dwi.InventoryAgeOver)`����180��������`,a.salesvolun6month `��6��������`,a.daily180 `��180���վ�����`
	, round((SUM(dwi.InventoryAge270)+SUM(dwi.InventoryAge365)+SUM(dwi.InventoryAgeOver))/a.daily180,0) `��������` 
from import_data.daily_WarehouseInventory dwi  
left join 
	( select boxsku,ProjectTeam from import_data.wt_products where isdeleted = 0 ) wp  on dwi.BoxSku = wp.boxsku 
left join 
	( select op.boxsku,sum(op.SaleCount) salesvolun6month,round(sum(op.SaleCount)/180,2) daily180 
	from import_data.wt_orderdetails op 
-- 	where SettlementTime >=date_add('2023-04-01',interval -5 month) and SettlementTime<'2023-05-01' and isdeleted = 0 
	where SettlementTime >=date_add('${StartDay}',interval -5 month) and SettlementTime<'${NextStartDay}' and isdeleted = 0 
	and ShipWarehouse='��ݸ��'
	group by op.boxsku ) a
	on dwi.boxsku=a.boxsku
where dwi.CreatedTime = date_add('${NextStartDay}',interval - 1 day) -- ʹ�õ������һ��Ŀ���
	and WarehouseName = '��ݸ��' 
group by dwi.boxsku,wp.ProjectTeam,a.salesvolun6month,a.daily180 having `����180��������`>0


-- ԭ�ο����루3�¼���ǰ����ʹ�ã�
-- select wi.boxsku,list.ProjectTeam`����`,SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver)`����180��������`,a.salesvolun6month `��6��������`,a.daily180 `��180���վ�����`
-- 	, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver))/a.daily180,0) `��������` 
-- from import_data.WarehouseInventory  wi
-- 
-- left join 
-- (select boxsku,ProjectTeam from import_data.wt_products ) list on list.boxsku=wi.boxsku
-- 
-- left join 
-- 	(select op.boxsku,sum(op.SaleCount) salesvolun6month,round(sum(op.SaleCount)/180,2) daily180 
-- 	from import_data.OrderProfitSettle op
-- 	where op.SettlementTime>=date_add('2023-04-01',interval -5 month) and op.SettlementTime<'2023-05-01'
-- 	and op.ShipWarehouse='��ݸ��' 
-- 	group by op.boxsku
-- 	) a on wi.boxsku=a.boxsku
-- where  wi.ReportType='�±�' and wi.monday='2023-04-01' 
-- group by wi.boxsku,list.ProjectTeam,a.salesvolun6month,a.daily180 having `����180��������`>0