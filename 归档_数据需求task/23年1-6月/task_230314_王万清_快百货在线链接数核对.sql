-- select shopcode
-- 	,count(1) `在线链接数`
-- from (select shopcode,SellerSKU ,ASIN 
-- 	from wt_listing wl 
-- 	join import_data.mysql_store ms 
-- 	on wl.ShopCode = ms.Code 
-- 		and wl.IsDeleted = 0 and ListingStatus = 1 and ms.ShopStatus = '正常'
-- 		and department <> '特卖汇'
-- 	where shopcode in ('RO-UK','NO-DE','EI-FR')
-- 	group by shopcode,SellerSku,Asin
-- 	) tmp1
-- group by ShopCode

-- 快百货店铺
select shopcode
	,count(1) `在线链接数`
from (select shopcode,SellerSKU ,ASIN 
	from erp_amazon_amazon_listing  wl 
	join import_data.mysql_store ms 
	on wl.ShopCode = ms.Code 
		and wl.IsDeleted = 0 and ListingStatus = 1 and ms.ShopStatus = '正常'
		and ms.Department = '快百货'
-- 	where shopcode in ('RO-UK','NO-DE','EI-FR','ET-NL','NF-SE')
	group by shopcode,SellerSku,Asin
	) tmp1
group by ShopCode