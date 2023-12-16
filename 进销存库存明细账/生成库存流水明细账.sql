
select *
from dep_purchase_sales_inventory_log
where start_time >= '2023-06-01' and end_time <= '2023-07-01'

-- 清空表
TRUNCATE table  dep_purchase_sales_inventory_log

-- 生成调整单记录
insert into  dep_purchase_sales_inventory_log ( id ,boxsku ,isdeleted ,purchase_source ,department ,event_type 
,start_time_type ,start_time ,reach_place ,start_quantity ,end_quantity  ,memo ,wttime )
select  concat('NS',2000000+ROW_NUMBER() over(order by c11)) as id
	,c1 as boxsku ,c2 as isdeleted ,c3 as purchase_source  , c5 as department  , c6 as event_type ,c10 as start_time_type 
	,c11 as start_time  ,c17 as reach_place ,c14 as start_quantity ,c19 as end_quantity ,c20 as memo ,now()
from manual_table mt where handlename = '全流程库存_人工校对单' and handletime = '2023-07-06';

-- 生成系统记录 
insert into  dep_purchase_sales_inventory_log ( id ,boxsku ,isdeleted ,purchase_source ,department ,event_type ,event_id_type ,event_id,line
,start_time_type ,start_time ,from_place ,from_place_detail ,start_quantity 
,end_time_type ,end_time ,reach_place ,reach_place_detail ,end_quantity ,memo ,wttime )

with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇' )

, od_1 as ( -- 销售出库-未合并订单, 需要同步3个月的最新销售订单记录来判断发货
select 
	ooa.DeliverProductSku as boxsku 
	,'销售出库' event_type ,PlatOrderNumber event_id ,'平台订单号' event_id_type
	, ShipTime as start_time ,'发货时间' as start_time_type
	, '-' as end_time ,'妥投时间' as end_time_type
     , case when ShipWarehouse regexp 'FBA' THEN 'FBA'
         when ShipWarehouse regexp '谷仓' THEN '谷仓'
         when ShipWarehouse regexp '出口易' THEN '出口易'
         when ShipWarehouse regexp '万德' THEN '万德'
         when ShipWarehouse regexp '邮差小马' THEN '邮差小马'
         else ShipWarehouse
         end as from_place
     , ShipWarehouse from_place_detail
     , '客户' as reach_place 
     , '客户' as reach_place_detail     
     , ProductCount as start_quantity -- 发货数量
     , '-' as end_quantity -- 妥投数量 
     , '' as memo 
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
where ShipTime >= '2023-01-01'  and ShipmentStatus = '全部发货' and DeliverProductSku not regexp ','
and ReportType = '月报' and FirstDay = '2023-06-01'
)
-- select * from od; 


,od_2 as ( -- 销售出库-合并订单
select unnest as boxsku 
	,'销售出库' event_type ,PlatOrderNumber event_id ,'平台订单号' event_id_type
	, ShipTime as start_time ,'发货时间' as start_time_type
	, '-' as end_time ,'妥投时间' as end_time_type
     , case when ShipWarehouse regexp 'FBA' THEN 'FBA'
         when ShipWarehouse regexp '谷仓' THEN '谷仓'
         when ShipWarehouse regexp '出口易' THEN '出口易'
         when ShipWarehouse regexp '万德' THEN '万德'
         when ShipWarehouse regexp '邮差小马' THEN '邮差小马'
         else ShipWarehouse
         end as from_place
     , ShipWarehouse from_place_detail
     , '客户' as reach_place 
     , '客户' as reach_place_detail     
     , 1 as start_quantity -- 合并订单记录，DeliverProductSku每个SKU出现1次，数量为1，eg: 114-9940133-1299455
     , '-' as end_quantity -- 妥投数量
     , '' as memo 
from (
select split(DeliverProductSku,',') arr ,*
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
where ShipTime >= '2023-01-01'  and ShipmentStatus = '全部发货' and DeliverProductSku regexp ','
and ReportType = '月报' and FirstDay = '2023-06-01'  
) t,unnest(arr) 
)


, purc as ( -- 采购入库
select dp.BoxSku , '采购入库' event_type ,OrderNumber event_id ,'采购下单号' event_id_type 
	, GenerateTime  ,'生单时间' as start_time_type
	, InstockTime  ,'入库时间' as end_time_type
	, '供应商' as from_place 
	, SupplierName  as from_place_detail   
	,WarehouseName as reach_place 
	,WarehouseName as reach_place_detail
    ,Quantity as start_quantity -- 下单数量
    ,InstockQuantity as end_quantity -- 入库数量
    , '' as memo 
from import_data.daily_PurchaseOrder dp join prod on dp.boxsku = prod.boxsku WHERE OrderTime >= '2023-01-01' 
)


, HeadwayDelivery as ( -- 备库订单数据源: -- 头程运费表
select 
	dh.BoxSku
	,'头程发货' event_type
	,dh.PackageNumber as event_id
	,'包裹号' event_id_type
	,deliveryTme
	,'发货时间' as start_time_type
	,'-' as ReceiveTime
	,'到货时间' as end_time_type 
    ,ShipWarehouse as from_place 
    ,ShipWarehouse as from_place_detail 
    ,case when ReceiveWarehouse regexp 'FBA' THEN 'FBA'
         when ReceiveWarehouse regexp '谷仓' THEN '谷仓'
         when ReceiveWarehouse regexp '出口易' THEN '出口易'
         when ReceiveWarehouse regexp '万德' THEN '万德'
         when ReceiveWarehouse regexp '邮差小马' THEN '邮差小马'
         else ReceiveWarehouse
         end as reach_place
	, ReceiveWarehouse as reach_place_detail 
	, ifnull(Quantity,0) as start_quantity -- 发货数量
	, Quantity - ifnull(在途数,0) as end_quantity -- 到货数量
	, case when ms.Department then concat('亿川帮发货,SKU归属为：',prod.projectteam, ',发货店铺为：',dh.ShopCode) end  as memo 
--        PurchaseFee as 采购成本,
--        Freight     as 头程运费
from import_data.daily_HeadwayDelivery dh
left join prod on dh.BoxSku  = prod.boxsku 
left join ( select c5 as PackageNumber , c7 as boxsku
	,c1 as 在途数 , c2 as 到仓数 , c3 as 入仓日期
	from manual_table mt where handlename ='全流程库存_在途查询0704v1' ) mt 
	on dh.BoxSku  = mt.boxsku and dh.PackageNumber = mt.PackageNumber -- 头程在途人工数据
left join (select BoxSku ,projectteam from wt_products ) wp on dh.BoxSku  = wp.BoxSku  
left join wt_store ms on dh.ShopCode = ms.code  
where deliveryTme >= '2023-01-01'
)
-- select * from HeadwayDelivery   

, inventory_log as (
select boxsku 
	,event_type ,event_id_type ,event_id  
	,concat( from_place_detail ,' 发往 ',reach_place_detail) line
	,start_time_type ,start_time  ,from_place ,from_place_detail ,start_quantity -- 出发情况
	,end_time_type ,end_time  ,reach_place  ,reach_place_detail ,end_quantity -- 抵达情况 
	,memo 
from (
	select * from od_1 
	union all select * from od_2 
	union all select * from purc
	union all select * from HeadwayDelivery
	)  t 
order by boxsku asc , start_time 
)

select concat('NS',1000000+ROW_NUMBER() over(order by start_time)) as id 
	,boxsku 
	,0 as isdeleted 
	,'奈思自采' as purchase_source 
	,'商厨汇' department ,event_type ,event_id_type ,event_id,line
	,start_time_type ,start_time ,from_place ,from_place_detail ,start_quantity 
	,end_time_type ,end_time ,reach_place ,reach_place_detail ,end_quantity ,memo , now() wttime 
from inventory_log ;
-- where memo regexp '亿川'