select eaal.ShopCode ,eaal.SellerSKU ,eaal.sku  ,eaal.PublicationDate
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode=ms.Code and ms.Department='��ٻ�' and ShopStatus='����'
join erp_product_products epp on epp.sku =eaal.sku and epp.IsMatrix=0 and epp.ProjectTeam='������' and epp.IsDeleted=0
where eaal.ListingStatus = 1