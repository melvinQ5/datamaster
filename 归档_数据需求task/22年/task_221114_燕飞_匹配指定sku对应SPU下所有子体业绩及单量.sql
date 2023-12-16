-- ���������ص��Ʒsku, ������2000��sku��ӦSPU��1800������1800��spu��Χ������sku��2230����Ҫ��2230��sku�ĳ����ܣ���ҵ�����ܵ���������������
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

-- ��SKUȥ�ض���
SELECT  tmp_sku.input_sku , tmp.* 
FROM (
select ask.SPU, ask.SKU, od.BoxSku , WEEKOFYEAR(PayTime)+1 `�ܴ�`
	, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD)) as `���۶�`
	, count(distinct PlatOrderNumber) `������`
from import_data.OrderDetails od 
join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and ms.Department in ('���۶���','��������')
left join import_data.TaxRatio tr on right(od.ShopIrobotId,2) = tr.site  
join all_sku ask on od.BoxSku =ask.BoxSku
where TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 
group by ask.SPU, ask.SKU, od.BoxSku , WEEKOFYEAR(PayTime)+1
) tmp
left join tmp_sku on tmp.SKU = tmp_sku.input_sku



-- ��SPUȥ�ض���
-- select ask.SPU, WEEKOFYEAR(PayTime)+1 `�ܴ�`
-- 	, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD)) as `���۶�`
-- 	, count(distinct PlatOrderNumber) `������`
-- from import_data.OrderDetails od
-- join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and ms.Department in ('���۶���','��������')
-- left join import_data.TaxRatio tr on right(od.ShopIrobotId,2) = tr.site  
-- join all_sku ask on od.BoxSku =ask.BoxSku
-- where TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 
-- group by ask.SPU, WEEKOFYEAR(PayTime)+1



