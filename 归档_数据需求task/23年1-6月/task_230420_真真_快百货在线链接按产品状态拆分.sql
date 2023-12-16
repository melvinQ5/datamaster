-- 在线链接数
with 
list as ( -- 
select 
	count(distinct concat(shopcode,SellerSku)) as `快百货在线链接数`
	,count(distinct case when wp.ProductStatus = 0 then concat(shopcode,SellerSku) end ) as `快百货在线链接数(产品正常)`
	,count(distinct case when wp.ProductStatus = 2 then concat(shopcode,SellerSku) end ) as `快百货在线链接数(产品停产)`
	,count(distinct case when wp.ProductStatus = 3 then concat(shopcode,SellerSku) end ) as `快百货在线链接数(产品停售)`
	,count(distinct case when wp.ProductStatus = 4 then concat(shopcode,SellerSku) end ) as `快百货在线链接数(产品暂时缺货)`
	,count(distinct case when wp.ProductStatus = 5 then concat(shopcode,SellerSku) end ) as `快百货在线链接数(产品清仓)`
from import_data.wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '快百货' and ms.ShopStatus = '正常'
join import_data.wt_products wp  on wl.BoxSku = wp.boxsku and wl.IsDeleted = 0 
and ListingStatus = 1 
and wp.projectteam = '快百货'and wp.IsDeleted = 0 
)

,al as (
select s.Department,
     Count( distinct case when ListingStatus=1 and ShopStatus='正常' then concat(ShopCode,SellerSKU,ASIN) end ) '在线链接数',
     Count( distinct case when ListingStatus=1 then concat(ShopCode,SellerSKU,ASIN) end ) '在线链接数_不考虑店铺状态',
     count(distinct concat(ShopCode,SellerSKU,ASIN))   '总链接数'   
from erp_amazon_amazon_listing al
inner join mysql_store s
on al.ShopCode=s.Code
and s.Department  = '快百货'
where IsDeleted=0
group by s.Department 
)

select  count(1)
from import_data.wt_products wp 
left join list on list.BoxSku = wp.boxsku
where wp.projectteam = '快百货'
	and wp.DevelopLastAuditTime is not null and wp.BoxSku is not null 
	

-- 总在线链接数：包括
SELECT case when ListingStatus = 1 then '在线'
	when ListingStatus = 3 then '下架'
	when ListingStatus = 4 then '创建未上架'
	when ListingStatus = 5 then '删除'
	when ListingStatus is null then '汇总合计'
	end as ListingStatus
	,count(1)
from erp_amazon_amazon_listing al 
inner join mysql_store s on al.ShopCode=s.Code and  s.Department  = '快百货'
group by grouping sets ((),(ListingStatus ))

	
	
	

