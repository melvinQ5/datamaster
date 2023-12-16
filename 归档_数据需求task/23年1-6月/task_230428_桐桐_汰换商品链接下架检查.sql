with 
ta as (
select memo as sku ,*
from manual_table mt
where c1 = '商品淘汰产品在线链接核对' and handletime='2023-05-03')

,t_list as ( -- 在线链接
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from erp_amazon_amazon_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join ta on ta.sku = wl.SKU 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
)

,t_list_stat as ( -- 表1 刊登计算
select sku 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉3` 
	,min(PublicationDate) `首次刊登时间`
from t_list
group by sku  
)

-- 明细
-- select 
-- 	t_list.BoxSku 
-- 	,t_list.sku  
-- 	,t_list.shopcode  
-- 	,t_list.sellersku `渠道sku` 
-- 	,t_list.ASIN 
-- 	,t_list.dep2  
-- 	,t_list.NodePathName  
-- 	,t_list.SellUserName `首选业务员` 
-- from t_list 
-- join t_list_stat tb on t_list.sku = tb.sku and tb.`在线链接数` > 0 

-- 统计
select ta.* ,tb.*
from ta 
left join t_list_stat tb on ta.sku = tb.sku

