-- 背景：跟卖要转一些账号给我们。但是他们的店铺里 会存在跟卖自己的SKU，能不能帮我们提取一份那个店铺里存在哪些SKU是属于跟卖的，我们要把那部分链接都删掉
-- 可以就只提取特卖汇的SKU和渠道SKU，账号简码，账号编码。这样给我哈。。。。。组织架构那边不知道改完了没
with a as (
select distinct  CompanyCode ,eaal.sku ,ProjectTeam ERP产品归属
     ,SellerSKU  ,asin,site
    ,ShopCode ,Department 店铺归属部门 ,ShopStatus 店铺状态
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode = ms.Code
    and ms.CompanyCode in (
        'ZY',
        'ZX',
        'ZU',
        'ZR',
        'ZK',
        'ZI',
        'ZH',
        'ZE',
        'YY',
        'YX',
        'YU',
        'YT',
        'YL',
        'YK',
        'YH',
        'XS',
        'A17'
        )
left join wt_products wp on eaal.sku = wp.sku and wp.IsDeleted=0
where ListingStatus = 1
order by CompanyCode ,eaal.sku
)

-- select count(distinct CompanyCode) from a
-- select count(*) from a
select * from a
