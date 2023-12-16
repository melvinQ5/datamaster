-- 现代码，4月及之后使用（主要改动是用日更库存代替周更库存，日更订单代替月更结算）
-- 计算4月 '${NextStartDay}' = '2023-05-01' , '${StartDay}' = '2023-04-01'
select dwi.boxsku,wp.ProjectTeam`分组`,SUM(dwi.InventoryAge270)+SUM(dwi.InventoryAge365)+SUM(dwi.InventoryAgeOver)`超过180天库存总数`,a.salesvolun6month `近6个月销量`,a.daily180 `近180天日均销量`
	, round((SUM(dwi.InventoryAge270)+SUM(dwi.InventoryAge365)+SUM(dwi.InventoryAgeOver))/a.daily180,0) `可售天数` 
from import_data.daily_WarehouseInventory dwi  
left join 
	( select boxsku,ProjectTeam from import_data.wt_products where isdeleted = 0 ) wp  on dwi.BoxSku = wp.boxsku 
left join 
	( select op.boxsku,sum(op.SaleCount) salesvolun6month,round(sum(op.SaleCount)/180,2) daily180 
	from import_data.wt_orderdetails op 
-- 	where SettlementTime >=date_add('2023-04-01',interval -5 month) and SettlementTime<'2023-05-01' and isdeleted = 0 
	where SettlementTime >=date_add('${StartDay}',interval -5 month) and SettlementTime<'${NextStartDay}' and isdeleted = 0 
	and ShipWarehouse='东莞仓'
	group by op.boxsku ) a
	on dwi.boxsku=a.boxsku
where dwi.CreatedTime = date_add('${NextStartDay}',interval - 1 day) -- 使用当月最后一天的快照
	and WarehouseName = '东莞仓' 
group by dwi.boxsku,wp.ProjectTeam,a.salesvolun6month,a.daily180 having `超过180天库存总数`>0


-- 原参考代码（3月及以前数据使用）
-- select wi.boxsku,list.ProjectTeam`分组`,SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver)`超过180天库存总数`,a.salesvolun6month `近6个月销量`,a.daily180 `近180天日均销量`
-- 	, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver))/a.daily180,0) `可售天数` 
-- from import_data.WarehouseInventory  wi
-- 
-- left join 
-- (select boxsku,ProjectTeam from import_data.wt_products ) list on list.boxsku=wi.boxsku
-- 
-- left join 
-- 	(select op.boxsku,sum(op.SaleCount) salesvolun6month,round(sum(op.SaleCount)/180,2) daily180 
-- 	from import_data.OrderProfitSettle op
-- 	where op.SettlementTime>=date_add('2023-04-01',interval -5 month) and op.SettlementTime<'2023-05-01'
-- 	and op.ShipWarehouse='东莞仓' 
-- 	group by op.boxsku
-- 	) a on wi.boxsku=a.boxsku
-- where  wi.ReportType='月报' and wi.monday='2023-04-01' 
-- group by wi.boxsku,list.ProjectTeam,a.salesvolun6month,a.daily180 having `超过180天库存总数`>0