select
createdtime 快照时间
,WarehouseName 仓库
,WarehouseID 仓库ID
,BoxSku 产品sku
,CustomSku 自定义sku
,ProductName 产品名称
,IsPackage 是否包材
,AverageUnitPrice 平均单价
,TotalInventory 库存总数量
,TotalPrice 库存总金额
,InventoryAge45 `0-45天库龄`
,InventoryAge90 `46-90天库龄`
,InventoryAge180 `91-180天库龄`
,InventoryAge270 `181-270天库龄`
,InventoryAge365 `271-365天库龄`
,InventoryAgeOver `大于365天库龄`
,InventoryAgeAmount45 `0-45天库龄金额`
,InventoryAgeAmount90 `46-90天库龄金额`
,InventoryAgeAmount180 `91-180天库龄金额`
,InventoryAgeAmount270 `181-270天库龄金额`
,InventoryAgeAmount365 `271-365天库龄金额`
,InventoryAgeAmountOver `大于365天库龄金额`
,Trade 品牌
,Buyer 采购人员
from daily_WarehouseInventory where CreatedTime='${lastday}'
