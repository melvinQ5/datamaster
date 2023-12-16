
-- FBA库存统计
select wp.ProjectTeam 
,dfb.boxsku ,Shopcode  ,Warehouse  ,Asin ,CustomSku 
,CurrentInventory ,LocalInventory
,OnlineStatus ,ActivityStatus  ,Sales  ,OnlineDate ,ProductChineseName 
,PurchasePrice ,Transporting , InventoryAmount ,InventoryAge 
, dfb.CurrentInventory  当前库存
from daily_FBAInventory_Box dfb
left join wt_products wp on dfb.BoxSku  =wp.BoxSku 
where GenerateDate = '${NextStartDay}'

  -- and  dfb.BoxSku = 4474967


-- 采购明细
select 
	'奈思自采' as 备货来源
	,PurchaseOrderNo 采购单号
	,OrderNumber 下单号
	,SupplierName 供应商名称
	,dp.BoxSku 
	,Quantity 数量
	,UnitPrice 单价
	, 0 as  单个头程
	,Quantity*UnitPrice 金额
	,GenerateTime 生单时间
	,OrderTime 下单时间
	,WarehouseName as 入库仓库 
	,case when InstockTime > '2023-07-01' then 0 else InstockQuantity end as 入库数量
	,case when InstockTime > '2023-07-01' then null else  InstockTime end  as 入库时间
	,case when InstockTime > '2023-07-01' then '否' else IsComplete end as 是否完结
from import_data.daily_PurchaseOrder dp 
-- join ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇' ) prod on dp.boxsku = prod.boxsku 
join ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = 'MRO孵化部' ) prod on dp.boxsku = prod.boxsku 
WHERE GenerateTime >= '2023-06-01' and  GenerateTime < '2023-07-01' 
-- and dp.boxsku = 4474967 
-- and PurchaseOrderNo =20002491085;


-- 
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


-- 商厨汇 销售明细 
with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇' )

, od as ( -- 销售出库-未合并订单, 需要同步3个月的最新销售订单记录来判断发货
select DeliverProductSku as  boxsku ,OrderChannelSource ,PlatOrderNumber ,ShipTime ,DeliverProductSku ,ProductCount ,ShipWarehouse
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
join prod on prod.boxsku = ooa.DeliverProductSku 
where ShipTime >= '2023-06-01' and  ShipTime < '2023-07-02' and ShipmentStatus = '全部发货' and DeliverProductSku not regexp ','
-- where ShipTime >= '2023-05-01' and  ShipTime < '2023-06-01' and ShipmentStatus = '全部发货' and DeliverProductSku not regexp ','
and ReportType = '周报' and FirstDay = '2023-07-10'  
-- and ReportType = '月报' and FirstDay = '2023-06-01'
union all
select unnest as boxsku ,OrderChannelSource ,PlatOrderNumber ,ShipTime ,DeliverProductSku 
, 1 as ProductCount -- 合并订单记录，DeliverProductSku每个SKU出现1次，数量为1，eg: 114-9940133-1299455
,ShipWarehouse
from (
select split(DeliverProductSku,',') arr ,*
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
join prod on prod.boxsku = ooa.DeliverProductSku 
where ShipTime >= '2023-07-01' and  ShipTime < '2023-07-02' and ShipmentStatus = '全部发货' and DeliverProductSku regexp ','
-- where ShipTime >= '2023-06-01' and  ShipTime < '2023-06-01' and ShipmentStatus = '全部发货' and DeliverProductSku regexp ','
and ReportType = '周报' and FirstDay = '2023-07-10'  
-- and ReportType = '月报' and FirstDay = '2023-06-01'  
) t,unnest(arr) 
)

-- select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇'  and boxsku =4332620


select OrderChannelSource 账号
,PlatOrderNumber 平台订单号
,ShipTime 订单发货时间
,boxsku 
,ProductCount 销售数量
,ShipWarehouse 发货仓库
,date(ShipTime) 时间
,left(ShipTime,7) 月份
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '谷仓' THEN '谷仓'
	 when ShipWarehouse regexp '出口易' THEN '出口易'
	 when ShipWarehouse regexp '万德' THEN '万德'
	 when ShipWarehouse regexp '邮差小马' THEN '邮差小马'
	 else ShipWarehouse
	 end as 发货仓库2
from od 
-- where boxsku = 3547351
order by ShipTime ; 


-- MRO 销售明细
select 
 ms.Department
,ms.Code  账号
,PlatOrderNumber 平台订单号
,ShipTime 订单发货时间
,boxsku 
,SaleCount  销售数量
,ShipWarehouse 发货仓库
,date(ShipTime) 时间
,left(ShipTime,7) 月份
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '谷仓' THEN '谷仓'
	 when ShipWarehouse regexp '出口易' THEN '出口易'
	 when ShipWarehouse regexp '万德' THEN '万德'
	 when ShipWarehouse regexp '邮差小马' THEN '邮差小马'
	 else ShipWarehouse
	 end as 发货仓库2
from wt_orderdetails wo 
join mysql_store ms on wo.shopcode = ms.Code and ms.Department = 'MRO孵化部' and ShipWarehouse regexp 'FBA' and TransactionType = '付款'
-- join mysql_store ms on wo.shopcode = ms.Code and ms.Department = '快百货' and ShipWarehouse regexp 'FBA' and TransactionType = '付款'
where wo.IsDeleted =0 and OrderStatus != '作废' and  ShipTime >= '2023-07-01' and  ShipTime < '2023-07-10' and ShipmentStatus = '全部发货' 
and BoxSku =4474979
order by ShipTime ; 



-- 转仓明细
select 
	'' 建单日期
	,deliveryTme 发货日期
	,ShipWarehouse 转仓仓库
	,ReceiveWarehouse 目的仓库
	,'' 备库单号产品SKU
	,dh.BoxSku
	,dh.BoxSku 进货产品编码
	,Quantity
	,'' 转出时库龄天数
	,PurchaseFee 采购成本
	,Freight 头程运费
	,在途数
	,到仓数
	,入仓日期
	,'' 占位到仓数
	,'' 占位入仓日期
	,Quantity*PurchaseFee 产品总采购成本
	,Quantity*Freight 产品总头程运费
	,'' 备库单号
	,'奈思自采' 拿货方式
	, case when prod.projectteam = '商厨汇' and ms.Department != '商厨汇' then '亿川帮发货' else '奈思自采' end as 发货方式
	, '' 备注
	, dh.PackageNumber 包裹号
	,TransportMode 运输方式
from import_data.daily_HeadwayDelivery dh
join  ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇' ) prod on dh.BoxSku  = prod.boxsku 
-- join  ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '快百货' ) prod on dh.BoxSku  = prod.boxsku 
-- join  ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = 'MRO孵化部' ) prod on dh.BoxSku  = prod.boxsku 
left join ( select c5 as PackageNumber , c7 as boxsku
	,c1 as 在途数 , c2 as 到仓数 , c3 as 入仓日期
	from manual_table mt where handlename ='全流程库存_在途查询0704v1' ) mt 
	on dh.BoxSku  = mt.boxsku and dh.PackageNumber = mt.PackageNumber -- 头程在途人工数据
left join (select BoxSku ,projectteam from wt_products ) wp on dh.BoxSku  = wp.BoxSku  
left join wt_store ms on dh.ShopCode = ms.code  
where deliveryTme >= '2023-01-01' and  deliveryTme < '2023-07-01' 
	and dh.BoxSku =4624640
-- 	and dh.PackageNumber = 'D38292089' 
-- where deliveryTme >= '2023-07-01'
order by deliveryTme 