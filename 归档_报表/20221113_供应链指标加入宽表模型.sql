-- sku�ɹ���Ʒ���

select BoxSku, sum(Price - DiscountedPrice) SkuPurchaseAmount
from import_data.PurchaseOrder 
where ordertime >= 'StartDay' and ordertime < 'EndDay' 
and WarehouseName = '��ݸ��' and GenerateTime < 'EndDay' and GenerateTime >= 'StartDay'
and !(IsComplete = '��' and InstockQuantity = 0)
group by BoxSku

-- sku�ɹ���̯�˷�

select BoxSku, round(sum((Price - DiscountedPrice)/(PayPrice-Freight)*Freight),2)  as  SkuFreight
from import_data.PurchaseOrder 
where ordertime >= 'StartDay' and ordertime < 'EndDay' 
and WarehouseName = '��ݸ��' and GenerateTime < 'EndDay' and GenerateTime >= 'StartDay'
and !(IsComplete = '��' and InstockQuantity = 0)
group by BoxSku


-- sku�ɹ�����
select BoxSku, count(distinct(OrderNumber))  as  PurchaseOrderCounts
from import_data.daily_PurchaseOrder  
where ordertime >= 'StartDay' and ordertime < 'EndDay' 
and WarehouseName = '��ݸ��' and GenerateTime < 'EndDay' and GenerateTime >= 'StartDay'
and !(IsComplete = '��' and InstockQuantity = 0)
group by BoxSku


-- sku���������ɹ����
select od.BoxSku,round(sum(abs(od.PurchaseCosts/ExchangeUSD)),2) skuPurchaseCost 
from import_data.daily_PackageDetail pd 
join import_data.daily_OrderDetails od on od.OrderNumber = pd.OrderNumber
where pd.weighttime < 'EndDay' and pd.weighttime >= 'StartDay'
group by od.BoxSku


-- sku�ڲֲ�Ʒ���
SELECT CustomSku as Sku, sum(TotalPrice) as inLocalWarehouseAmount
FROM import_data.daily_WarehouseInventory 
where WarehouseName = '��ݸ��' and CreatedTime  = '${EndDay}' 
group by CustomSku
-- sku�ڲֲ�Ʒ����
SELECT CustomSku as Sku, sum(TotalInventory) as inLocalWarehouseCounts
FROM import_data.daily_WarehouseInventory 
where WarehouseName = '��ݸ��' and CreatedTime  = '${EndDay}' 
group by CustomSku


/*�����ת
=ƽ�����زֿ��/�ڼ����۳ɱ���ͳ��������
=�����ڱ��زֲ�Ʒ���+���ڱ��زֲ�Ʒ��/2/���������ɹ���ͳ��������*/
update wt_products_stat set 
DaysofInventory = (inLocalWarehouseAmount_Sun + inLocalWarehouseAmount_Mon)/2/skuPurchaseCost*7

/*sku�����ʽ�ռ�� = �ڲֲ�Ʒ��� + �ɹ���;��Ʒ��� + �ɹ���̯�˷�*/
update wt_products_stat set 
LocalTakeUpMoney = inLocalWarehouseAmount + SkuPurchaseAmount + SkuFreight


 -- ����Ʒ������ = ȥ��(�����ڲֳ���SKU+���ܲɹ�����SKU) / ȥ��(�����ڲ�SKU+���ܲɹ�SKU+�����ڲֳ���SKU+���ܲɹ�����SKU)
select wi.BoxSKU, count(distinct od.BoxSku )/count(distinct wi.BoxSKU)  
from 
( 
select BoxSKU from import_data.daily_WarehouseInventory where WarehouseName = '��ݸ��' and CreatedTime  = '${EndDay}'
union 
select BoxSKU from importpy_data.daily_PurchaseOrder dpo where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day)

) wi 
left join 
( select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
and PayTime < 'EndDay' and PayTime >= 'StartDay' ) od
on wi.BoxSKU = od.BoxSku

-- �ڲ�δ�������ܿ���������
SELECT al.SKU , count(*) unSelledListingCnt  
FROM import_data.erp_amazon_amazon_listing al 
join 
(
select distinct dwi.CustomSku
join import_data.daily_WarehouseInventory dwi 
left join ( select BoxSku from import_data.daily_OrderDetails where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
and PayTime < 'EndDay' and PayTime >= 'StartDay' ) od
on dwi.BoxSKU = od.BoxSku
where dwi.CreatedTime  = '${EndDay}' AND dwi.TotalInventory > 0 AND od.BoxSku is null 
) tmp
on tmp.CustomSku = al.SKU
where PublicationDate < 'EndDay' and PublicationDate >= 'StartDay' and ListingStatus = 1
group by al.SKU











