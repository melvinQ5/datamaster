-- 需求1 5天未发货订单（SQL）

-- 目前问题：
-- Q1 mysql_store 部分店铺没有销售人员.比如PS-CA，查SQL无销售人员，但查塞盒页面该销售是 TMH销售1组 樊黛鑫
-- A1 查找并修复mysql_store表数据源问题，无需修改SQL

-- 表记录数 56011 （23/02/11 10:00查询）
select count(1) from import_data.daily_WeightOrders dwo 

-- 筛选：订单支付时间距今5天以前(2023年开始统计），且无包裹单号，且SKU无采购下单记录

-- 代码
select dod.*, dpo.BoxSku as NoBoxSku,dpo.BoxSku as NoPurchaseBoxSku,wi.TotalInventory 
from ( 
	select BoxSku ,SUBSTR(shopcode,instr(shopcode,'-')+1) as ShopIrobotId ,ordernumber ,paytime 
		,NodePathNameFull as SellerDepartment,SellUserName
	from import_data.daily_WeightOrders dwo 
	join import_data.mysql_store ms on dwo.SUBSTR(shopcode,instr(shopcode,'-')+1) = ms.code
	where CreateDate = CURRENT_DATE()
		and PayTime >= '2023-01-01' and PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 
	) dod 
left join( select BoxSku,TotalInventory from import_data.daily_WarehouseInventory where CreatedTime='2023-02-07' ) wi 
	on dod.BoxSku=wi.BoxSku 
left join( select BoxSku  from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '否' and InstockQuantity = 0  group by BoxSku ) dpo  
	on dod.BoxSku = dpo.BoxSku 
) 
select memo
from daily_WeightOrders dwo2 
group by memo

-- 校验1 统计订单数
select count(1) from (

select dod.*
	, dpo.BoxSku as NoBoxSku,dpo.BoxSku as NoPurchaseBoxSku,wi.TotalInventory 
from ( 
	select BoxSku ,SUBSTR(shopcode,instr(shopcode,'-')+1) as ShopIrobotId ,ordernumber ,paytime 
		,NodePathNameFull as SellerDepartment,SellUserName
	from import_data.daily_WeightOrders dwo 
	join import_data.mysql_store ms on dwo.SUBSTR(shopcode,instr(shopcode,'-')+1) = ms.code
	where CreateDate = CURRENT_DATE()
		and PayTime >= '2023-01-01' and  PayTime <  date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 
	) dod 
left join( select BoxSku,TotalInventory from import_data.daily_WarehouseInventory where CreatedTime='2023-02-07' ) wi 
	on dod.BoxSku=wi.BoxSku 
left join( select BoxSku  from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '否' and InstockQuantity = 0  group by BoxSku ) dpo  
	on dod.BoxSku = dpo.BoxSku 
	
) tmp 

select OrderStatus ,count(distinct OrderNumber) ,count(1)
from import_data.daily_WeightOrders dwo 
	join import_data.mysql_store ms on dwo.SUBSTR(shopcode,instr(shopcode,'-')+1) = ms.code
	where CreateDate = CURRENT_DATE()
		and PayTime >= '2023-01-01' and  PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 
group by OrderStatus


-- 校验数据2 排除作废订单（通过匹配5天前所有作废订单来检测）
select a.* from a
join (select ordernumber ,boxsku from import_data.ods_orderdetails d
		where PayTime >= '2023-01-01'     
		and PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and OrderStatus = '作废' and IsDeleted=0  ) passorder
	on a.ordernumber = passorder.ordernumber 
	and a.boxsku=passorder.boxsku
	
-- 校验数据3 合并订单
-- select * from a where  OrderNumber = 20230102181841565070
-- select * from a where  OrderNumber = 20230102181841565072
-- select * from a where  OrderNumber = 20230102050041561552
-- select * from a where  OrderNumber = 20230101011941552754
	



-- 历史备份
-- 换表前 5天未发
with a as (
select dod.*,od.id as DeleteId, dpo.BoxSku as NoBoxSku,dpo.BoxSku as NoPurchaseBoxSku,wi.TotalInventory 
from (   select id ,BoxSku,ShopIrobotId,OrderNumber ,NodePathNameFull as SellerDepartment,SellUserName ,PayTime   
	from import_data.daily_OrderDetails_Test d 
	join import_data.mysql_store ws on d.ShopIrobotId = ws.Code    
	where TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0     
	and PayTime >= '2023-01-01'     
	and PayTime < date_add(CURRENT_DATE(),interval -5 day ) and ShipmentStatus = '未发货'    
	) dod 
left join import_data.daily_OrderDelete od on dod.id =od.id  
left join( select BoxSku,TotalInventory from import_data.daily_WarehouseInventory where  CreatedTime='2023-02-06' ) wi 
	on dod.BoxSku=wi.BoxSku 
left join( select BoxSku  from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '否' group by BoxSku ) dpo  
	on dod.BoxSku = dpo.BoxSku and dod.PayTime>='2023-01-01' where od.id is null 
) 

select count(distinct ordernumber) from a


-- -------------------------------------------------------------------
-- -- 需求2 采购单追踪
-- 视图1 采购已下单超2天无收货记录  ads_purchase_tracking_list
--   筛选：下单时间在2023年1月，入库状态为未完结的，截至昨日（大数据更新为T-1）无收货表信息的记录
--   字段：下单号 | 快递单号 | 采购人员 | 采购时间 | BoxSku | 最早客户订单支付时间
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
  from import_data.ods_OrderDetails dod 
  join import_data.daily_WeightOrders dwo 
 	on dod.OrderNumber =dwo.OrderNumber and dod.BoxSku =dwo.BoxSku 
 	and dwo.IsDeleted=0 and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0   
  group by BoxSku
  ) b 
on a.BoxSku = b.BoxSku
	
