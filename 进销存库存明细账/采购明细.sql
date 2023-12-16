select
    ProjectTeam 部门
	,PurchaseOrderNo 采购单号
	,OrderNumber 下单号
    ,'奈思自采' as 备货来源
    ,PayMethod 付款方式
	,SupplierName 供应商名称
	,dp.BoxSku as 产品SKU
	,Quantity 数量
	,UnitPrice 单价
	, 0 as  单个头程
	,Quantity*UnitPrice 金额
	,GenerateTime 生单时间
	,OrderTime 下单时间
	,WarehouseName as 入库仓库
    ,InstockQuantity 入库数量
    ,InstockTime 入库时间
    ,IsComplete 是否完结
    ,case when UnitPrice >  100 then '大件' else '小件' end  as 是否大件 -- 从9月月报开始大小件由付款方式改为单价
from import_data.daily_PurchaseOrder dp
join ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam regexp '${department}'  ) prod on dp.boxsku = prod.boxsku
WHERE GenerateTime >= '${StartDay}' and  GenerateTime < '${NextStartDay}'
-- and dp.boxsku = 4747583
-- and PurchaseOrderNo in ( ) -- 查询历史月份未完结状态
order by 部门,GenerateTime


