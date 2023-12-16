


select ta.sku ,ProductStatus `产品状态`,tb.`在线链接数`
from 
(
select Sku ,boxsku 
	, case when ProductStatus =  0 then '正常'
			when ProductStatus = 2 then '停产'
			when ProductStatus = 3 then '停售'
			when ProductStatus = 4 then '暂时缺货'
			when ProductStatus = 5 then '清仓'
		end as ProductStatus
from import_data.wt_products wp 
where ProjectTeam = '快百货' and isdeleted= 0 and sku = 1042622.01
group by Sku ,boxsku,ProductStatus
) ta 
left join 
(select sku ,count(distinct ShopCode ,SellerSKU,asin) `在线链接数`
	from wt_listing wl 
-- 	join import_data.mysql_store ms 
-- 	on wl.ShopCode = ms.Code 
-- 		 and ms.ShopStatus = '正常'
-- 		and department = '快百货'
	where  wl.IsDeleted = 0 and ListingStatus = 1 
	group by sku
) tb 
on ta.sku =tb.sku
