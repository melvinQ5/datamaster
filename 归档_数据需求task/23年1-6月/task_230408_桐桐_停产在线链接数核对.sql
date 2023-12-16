with 
ta as (
select memo as boxsku ,c2 as `备注` from manual_table mt 
)

,t_list as ( -- 在线链接
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,WEEKOFYEAR( PublicationDate) pub_week
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from wt_listing wl -- 因为最终输出落到具体sku,所以不需要使用erp表
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
)

, t_list_stat as (
select BoxSKU 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `快百货在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次元-泉州销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='快次方-泉州销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2` 
from t_list
group by BoxSKU  
)

,t_orde as (  -- 每周出单明细
select 
	OrderNumber ,PlatOrderNumber ,wo.Market	
	,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin,BoxSku ,PurchaseCosts
	,paytime ,OrderStatus 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
-- 	and paytime >= '2023-02-01'
	and paytime >= '2022-04-09'and paytime < '2023-04-09'
	and ms.Department = '快百货' and OrderStatus != '作废'
	and wo.IsDeleted=0
)

,t_od_stat as (
select boxsku , sum(salecount) `近一年销量`
from t_orde where OrderStatus != '作废' and TotalGross > 0 
group by boxsku 
)

,t_stock as (
select BoxSku ,sum(TotalInventory) `0408库存`
from daily_WarehouseInventory dwi 
where CreatedTime = '2023-04-08'
group by BoxSku 
)


select ta.*
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as `0408产品状态查询`
	,tb.* 
	, `近一年销量`
	, `0408库存`
from ta 
left join t_list_stat tb on ta.boxsku = tb.boxsku 
left join erp_product_products wp on ta.boxsku = wp.BoxSKU 
left join t_od_stat  on ta.boxsku = t_od_stat.BoxSKU 
left join t_stock  on ta.boxsku = t_stock.BoxSKU 
order by `快百货在线链接数` desc 