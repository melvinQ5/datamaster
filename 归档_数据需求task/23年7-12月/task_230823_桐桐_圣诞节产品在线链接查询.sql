

with
ta as (
select [
] arr
)

,tb as (
select distinct arr 
from (select unnest as arr
	from ta ,unnest(arr)
	) tmp
)
-- select * from tb


,od as (
select sellersku ,shopcode
     ,count (distinct PlatOrderNumber) as `22年8至12月订单量`
     ,round (sum(TotalGross/ExchangeUSD),2) as `22年8至12月销售额`
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.code and ms.department = '快百货'
join tb on tb.arr = wo.product_spu and wo.IsDeleted = 0 and orderstatus != '作废' 
-- and paytime >= date_add('${NextStartDay}',interval - 1 year)
and paytime >= '2022-08-01' and PayTime  < '2023-01-01'
group by sellersku ,shopcode
)
-- select * from od 


select * from (
select 
	concat(wl.sku,wl.sellersku,ms.code) id
	,wl.sku
    ,wl.spu ,wp.boxsku
     ,wp.DevelopLastAuditTime
     ,wp.productname
     ,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
     ,ms.code ,ms.NodePathName ,ms.SellUserName ,ms.accountcode ,wl.sellersku
     ,wl.price
	,case when ms.shopstatus = '正常' and wl.listingstatus = 1  then '在线' else '未在线或店铺异常' end 在线状态
	,ifnull(`22年8至12月订单量`,0) 22年8至12月订单量
	,ifnull(22年8至12月销售额,0) 22年8至12月销售额
from wt_listing wl
join tb on tb.arr = wl.spu and wl.isdeleted = 0 
join wt_products wp on wp.sku =wl.sku and projectteam = '快百货' and ProductStatus !=2 and wp.IsDeleted  = 0 
join mysql_store ms on wl.shopcode = ms.code and department = '快百货'
join erp_amazon_amazon_listing eaal on wl.id = eaal.id 
left join od on od.sellersku = wl.SellerSKU and od.shopcode = wl.ShopCode
) t
order by id 
