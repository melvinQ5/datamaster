-- 元素 x 终审年月 x 广告周
with
ele as ( -- 夏季
select eppaea.sku ,Name as ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,Name
)



select
    '2023' 广告年
    ,week+1 广告周
    ,ele_name  元素
    ,dev_month 终审年月
    ,round( sum(AdSales) ,2) 广告销售额
    ,sum(AdExposure) 广告曝光量
    ,sum(AdClicks) 广告点击量
    ,sum(AdSaleUnits) 广告销量
    ,round( sum(AdSpend) ,2)  广告花费
    ,round( sum(AdSkuSale7DayUSD)) 广告SKU销售额
from wt_adserving_amazon_weekly waaw
join ( -- 元素品链接
    select wl.id , left(wp.DevelopLastAuditTime,7) dev_month , ele_name
    from wt_listing wl
    join mysql_store ms on wl.ShopCode = ms.Code and ms.Department='快百货'
    join  ele on wl.sku = ele.sku -- 元素产品对应的链接
    left join wt_products wp on wl.sku = wp.sku
    ) wl  on wl.Id = waaw.ListingId
where waaw.Year =2023
group by week ,ele_name,dev_month
order by week ,ele_name,dev_month ;


-- 站点 x 广告周
select
    '2023' 广告年
    ,week+1 广告周
    ,right(ShopCode,2) 站点
    ,round( sum(AdSales) ,2) 广告销售额
    ,sum(AdExposure) 广告曝光量
    ,sum(AdClicks) 广告点击量
    ,sum(AdSaleUnits) 广告销量
    ,round( sum(AdSpend) ,2)  广告花费
    ,round( sum(AdSkuSale7DayUSD)) 广告SKU销售额
from wt_adserving_amazon_weekly waaw
where waaw.Year =2023
group by week ,right(ShopCode,2)
order by week ,right(ShopCode,2) ;
