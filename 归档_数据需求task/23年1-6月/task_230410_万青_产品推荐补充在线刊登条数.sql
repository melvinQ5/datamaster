with ta as (
select *
from import_data.manual_table mt 
where c1 = '产品推荐_第14周_P1'
)


,t_list_cnt as ( 
select wl.sku 
	,count(distinct concat(SellerSKU,ShopCode)) `在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(SellerSKU,ShopCode) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次元-泉州销售组' then concat(SellerSKU,ShopCode) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(SellerSKU,ShopCode) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='快次方-泉州销售组' then concat(SellerSKU,ShopCode) end ) `在线链接数_泉2` 
from wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code 
join  ta on wl.sku = ta.c3
where wl.ListingStatus =1 and ms.ShopStatus = '正常' and ms.Department = '快百货'
group by wl.sku
)

select ta.c3 ,tb.*
from ta 
left join t_list_cnt tb on ta.c3 = tb.sku 