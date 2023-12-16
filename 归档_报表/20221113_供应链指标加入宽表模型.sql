-- sku采购产品金额

select BoxSku, sum(Price - DiscountedPrice) SkuPurchaseAmount
from import_data.PurchaseOrder 
where ordertime >= 'StartDay' and ordertime < 'EndDay' 
and WarehouseName = '东莞仓' and GenerateTime < 'EndDay' and GenerateTime >= 'StartDay'
and !(IsComplete = '是' and InstockQuantity = 0)
group by BoxSku

-- sku采购分摊运费

select BoxSku, round(sum((Price - DiscountedPrice)/(PayPrice-Freight)*Freight),2)  as  SkuFreight
from import_data.PurchaseOrder 
where ordertime >= 'StartDay' and ordertime < 'EndDay' 
and WarehouseName = '东莞仓' and GenerateTime < 'EndDay' and GenerateTime >= 'StartDay'
and !(IsComplete = '是' and InstockQuantity = 0)
group by BoxSku


-- sku采购单数
select BoxSku, count(distinct(OrderNumber))  as  PurchaseOrderCounts
from import_data.daily_PurchaseOrder  
where ordertime >= 'StartDay' and ordertime < 'EndDay' 
and WarehouseName = '东莞仓' and GenerateTime < 'EndDay' and GenerateTime >= 'StartDay'
and !(IsComplete = '是' and InstockQuantity = 0)
group by BoxSku


-- sku发货订单采购金额
select od.BoxSku,round(sum(abs(od.PurchaseCosts/ExchangeUSD)),2) skuPurchaseCost 
from import_data.daily_PackageDetail pd 
join import_data.daily_OrderDetails od on od.OrderNumber = pd.OrderNumber
where pd.weighttime < 'EndDay' and pd.weighttime >= 'StartDay'
group by od.BoxSku


-- sku在仓产品金额
SELECT CustomSku as Sku, sum(TotalPrice) as inLocalWarehouseAmount
FROM import_data.daily_WarehouseInventory 
where WarehouseName = '东莞仓' and CreatedTime  = '${EndDay}' 
group by CustomSku
-- sku在仓产品件数
SELECT CustomSku as Sku, sum(TotalInventory) as inLocalWarehouseCounts
FROM import_data.daily_WarehouseInventory 
where WarehouseName = '东莞仓' and CreatedTime  = '${EndDay}' 
group by CustomSku


/*库存周转
=平均本地仓库存/期间销售成本＊统计期天数
=（本期本地仓产品金额+上期本地仓产品金额）/2/发货订单采购金额＊统计期天数*/
update wt_products_stat set 
DaysofInventory = (inLocalWarehouseAmount_Sun + inLocalWarehouseAmount_Mon)/2/skuPurchaseCost*7

/*sku本地资金占用 = 在仓产品金额 + 采购在途产品金额 + 采购分摊运费*/
update wt_products_stat set 
LocalTakeUpMoney = inLocalWarehouseAmount + SkuPurchaseAmount + SkuFreight


 -- 库存产品动销率 = 去重(本周在仓出单SKU+本周采购出单SKU) / 去重(本周在仓SKU+本周采购SKU+本周在仓出单SKU+本周采购出单SKU)
select wi.BoxSKU, count(distinct od.BoxSku )/count(distinct wi.BoxSKU)  
from 
( 
select BoxSKU from import_data.daily_WarehouseInventory where WarehouseName = '东莞仓' and CreatedTime  = '${EndDay}'
union 
select BoxSKU from importpy_data.daily_PurchaseOrder dpo where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day)

) wi 
left join 
( select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
and PayTime < 'EndDay' and PayTime >= 'StartDay' ) od
on wi.BoxSKU = od.BoxSku

-- 在仓未出单本周刊登链接数
SELECT al.SKU , count(*) unSelledListingCnt  
FROM import_data.erp_amazon_amazon_listing al 
join 
(
select distinct dwi.CustomSku
join import_data.daily_WarehouseInventory dwi 
left join ( select BoxSku from import_data.daily_OrderDetails where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
and PayTime < 'EndDay' and PayTime >= 'StartDay' ) od
on dwi.BoxSKU = od.BoxSku
where dwi.CreatedTime  = '${EndDay}' AND dwi.TotalInventory > 0 AND od.BoxSku is null 
) tmp
on tmp.CustomSku = al.SKU
where PublicationDate < 'EndDay' and PublicationDate >= 'StartDay' and ListingStatus = 1
group by al.SKU











