-- 给定部分重点产品sku, 假设这2000个sku对应SPU有1800个，这1800个spu范围内所有sku有2230个，要这2230个sku的出单周，周业绩，周单量。这样理解对吗
with tmp_sku as (
select Sku as input_sku from import_data.JinqinSku WHERE Monday = '2022-12-06'
)

, all_sku as (
select distinct epp.SPU, epp.SKU ,epp.BoxSKU 
from import_data.erp_product_products epp
join 
	(
	select distinct epp.SPU 
	from import_data.erp_product_products epp
	join tmp_sku ts on epp.SKU = ts.input_sku
	) tmp
on epp.SPU = tmp.SPU
)

-- 按SKU去重订单
SELECT  tmp_sku.input_sku , tmp.* 
FROM (
select ask.SPU, ask.SKU, od.BoxSku , WEEKOFYEAR(PayTime)+1 `周次`
	, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD)) as `销售额`
	, count(distinct PlatOrderNumber) `订单数`
from import_data.OrderDetails od 
join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and ms.Department in ('销售二部','销售三部')
left join import_data.TaxRatio tr on right(od.ShopIrobotId,2) = tr.site  
join all_sku ask on od.BoxSku =ask.BoxSku
where TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 
group by ask.SPU, ask.SKU, od.BoxSku , WEEKOFYEAR(PayTime)+1
) tmp
left join tmp_sku on tmp.SKU = tmp_sku.input_sku



-- 按SPU去重订单
-- select ask.SPU, WEEKOFYEAR(PayTime)+1 `周次`
-- 	, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD)) as `销售额`
-- 	, count(distinct PlatOrderNumber) `订单数`
-- from import_data.OrderDetails od
-- join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and ms.Department in ('销售二部','销售三部')
-- left join import_data.TaxRatio tr on right(od.ShopIrobotId,2) = tr.site  
-- join all_sku ask on od.BoxSku =ask.BoxSku
-- where TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 
-- group by ask.SPU, WEEKOFYEAR(PayTime)+1



