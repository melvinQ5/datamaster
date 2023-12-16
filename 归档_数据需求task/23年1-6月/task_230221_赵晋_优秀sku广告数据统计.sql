-- 4429435这个SPU的点击率和曝光能不能帮我导一下？做优秀案例展示使用1条回复As14:43

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
		and GenerateDate>=date_add('${StartDay}',interval -1 day)/*时间维度*/
		and GenerateDate<date_add('${NextStartDay}',interval -1 day)
join art_sku t on eaal.sku = t.SKU 
-- join import_data.mysql_store s on ad.ShopCode=s.Code  and department = '快百货'
)


select round(sum(AdClicks)/sum(AdExposure),10) `广告点击率`
,sum(AdExposure) `广告曝光量`
from adserving 

