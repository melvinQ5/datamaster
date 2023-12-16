-- 4429435���SPU�ĵ���ʺ��ع��ܲ��ܰ��ҵ�һ�£������㰸��չʾʹ��1���ظ�As14:43

with art_sku as (
select SPU ,SKU 
from import_data.erp_product_products epp 
where BoxSKU = 4429435 
)

, adserving as (
select ad.*  ,eaal.SKU 
from import_data.erp_amazon_amazon_listing eaal 
join import_data.wt_adserving_amazon_daily ad
	on eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 
		and eaal.ListingStatus = 1 
		and GenerateDate>=date_add('${StartDay}',interval -1 day)/*ʱ��ά��*/
		and GenerateDate<date_add('${NextStartDay}',interval -1 day)
join art_sku t on eaal.sku = t.SKU 
-- join import_data.mysql_store s on ad.ShopCode=s.Code  and department = '��ٻ�'
)


select round(sum(AdClicks)/sum(AdExposure),10) `�������`
,sum(AdExposure) `����ع���`
from adserving 

