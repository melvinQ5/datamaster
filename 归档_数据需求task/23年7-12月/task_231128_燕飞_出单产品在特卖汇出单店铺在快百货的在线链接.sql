select eaal.ShopCode ,eaal.SellerSKU ,eaal.sku  ,eaal.PublicationDate
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode=ms.Code and ms.Department='快百货' and ShopStatus='正常'
join erp_product_products epp on epp.sku =eaal.sku and epp.IsMatrix=0 and epp.ProjectTeam='特卖汇' and epp.IsDeleted=0
where eaal.ListingStatus = 1