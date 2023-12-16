-- 3月30日 16:14
-- 新品listing有效曝光率（X）=新品listing刊登7天内曝光量大于1的链接数/当月刊登7天以上的总链接数
with
t_prod as ( -- 新品
select SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,spu ,CreationTime ,boxsku ,SkuSource ,Status 
from import_data.erp_product_products
where IsDeleted =0 and IsMatrix = 0 and DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}'
)

,t_list as ( -- 新品刊登链接
select ListingStatus ,eaal.SKU ,PublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,eaal.SPU ,ProductSalesName
	,ms.*
from wt_listing eaal
join t_prod on eaal.SKU = t_prod.sku 
join mysql_store ms on eaal.ShopCode = ms.Code and ListingStatus != 4 and ms.Department = '快百货'
where PublicationDate >= '${StartDay}' and PublicationDate < '${NextStartDay}'
-- where PublicationDate = '2023-03-06' 
)

,t_list_adse as ( -- 所有链接 left JOIN 广告
select 
	eaal.SKU ,eaal.ProductSalesName ,eaal.PublicationDate
	,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	,Clicks as AdClicks ,Exposure as AdExposure ,ad.CreatedTime 
from t_list eaal 
left join import_data.AdServing_Amazon ad
	on eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 	
)

,t_list_adse_stat as (
select SKU ,ShopCode , SellerSKU , Asin ,ProductSalesName ,PublicationDate 
	,ifnull(sum(case when timestampdiff(second,PublicationDate,CreatedTime) <= 86400 * 7 then AdExposure end ),0) `刊登7天曝光量` 
	,ifnull(sum(AdExposure ),0) `截至0329曝光量` 
	,min(case when AdExposure >=1 then CreatedTime end) `首次曝光时间`
from t_list_adse
group by SKU ,ShopCode , SellerSKU , Asin ,ProductSalesName ,PublicationDate 
)

-- select count(1) from (

select 
	replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `终审时间范围`
	,t_prod.sku 
	,ShopCode `店铺`
	,SellerSKU `渠道SKU`
	,Asin 
	,ProductSalesName `销售人员`
	,ms.NodePathName  `团队`
	,to_date(date_add(t_prod.DevelopLastAuditTime,interval -8 hour)) `产品终审时间`
	,to_date(PublicationDate) `刊登时间`
	,`首次曝光时间`
	,`刊登7天曝光量` 
	,`截至0329曝光量` 
from t_list_adse_stat
left join t_prod on t_list_adse_stat.sku = t_prod.sku 
left join mysql_store ms on ms.Code = t_list_adse_stat.ShopCode


-- ) tmp 