-- 帮忙拉一个系统标签为清凉季的所有品去年4-6月及今年3-4月，到月间的销量，销额，毛利
with 
t_black_list as (
select sku from JinqinSku js where Monday = '2023-04-07' group by sku 
)

,dim_new as ( -- 新品
select boxsku,sku  from wt_products where DevelopLastAuditTime >= '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProjectTeam = '快百货'
)

,dim_old as ( -- 老品
select boxsku,sku  from wt_products where DevelopLastAuditTime < '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProjectTeam = '快百货'
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,eppea.Name  ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,eppea.Name 
)

,t_prod as (
select wp.sku ,wp.BoxSku , '清凉季' ele_name  ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `产品终审时间`
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as `产品状态`
	,TortType `侵权状态`
	,DevelopUserName `开发人员`
	,vr.NodePathName `开发状态`
	,wp.CategoryPathByChineseName ,Cat1
from import_data.wt_products wp
join (select sku from t_elem where ele_name = '清凉季' group by sku ) ele on wp.sku = ele.sku 
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '开发'
where IsDeleted = 0 
)

,t_orde_stat as (
select wo.BoxSku 
	,sum(case when left(SettlementTime,7)='2022-04' then SaleCount end ) as 销量2204
	,sum(case when left(SettlementTime,7)='2022-05' then SaleCount end ) as 销量2205
	,sum(case when left(SettlementTime,7)='2022-06' then SaleCount end ) as 销量2206
	,sum(case when left(SettlementTime,7)='2023-03' then SaleCount end ) as 销量2303
	,sum(case when left(SettlementTime,7)='2023-04' then SaleCount end ) as 销量2304
	
	,sum(case when left(SettlementTime,7)='2022-04' then totalgross end ) as 销售额2204
	,sum(case when left(SettlementTime,7)='2022-05' then totalgross end ) as 销售额2205
	,sum(case when left(SettlementTime,7)='2022-06' then totalgross end ) as 销售额2206
	,sum(case when left(SettlementTime,7)='2023-03' then totalgross end ) as 销售额2303
	,sum(case when left(SettlementTime,7)='2023-04' then totalgross end ) as 销售额2304
	
	,sum(case when left(SettlementTime,7)='2022-04' then totalprofit end ) as 利润额2204
	,sum(case when left(SettlementTime,7)='2022-05' then totalprofit end ) as 利润额2205
	,sum(case when left(SettlementTime,7)='2022-06' then totalprofit end ) as 利润额2206
	,sum(case when left(SettlementTime,7)='2023-03' then totalprofit end ) as 利润额2303
	,sum(case when left(SettlementTime,7)='2023-04' then totalprofit end ) as 利润额2304
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on  t_prod.boxsku = wo.BoxSku 
where wo.IsDeleted = 0 and OrderStatus != '作废'  and ms.Department = '快百货'
	and SettlementTime > '2022-01-01'
group by wo.BoxSku 
)

-- 库存加链接数
, t_mearge_stock as (
select t.* ,dwi.ifnull(TotalInventory,0) `0413库存数量`
from t_prod	t 
left join import_data.daily_WarehouseInventory dwi on t.boxsku = dwi.boxsku and dwi.CreatedTime = '2023-04-13'
)


,t_list as ( -- 在线链接
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,WEEKOFYEAR( PublicationDate) pub_week
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from wt_listing wl -- 因为最终输出落到具体sku,所以不需要使用erp表
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join (select sku from t_mearge_stock group by sku ) ta on ta.sku = wl.SKU 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
)

, t_list_stat as (
select BoxSKU 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉3` 
from t_list
group by BoxSKU  
)

select a.* , b.* ,c. `0413库存数量` 
	, `在线链接数_成1` 
	, `在线链接数_成2` 
	, `在线链接数_泉1` 
	, `在线链接数_泉2`  
	, `在线链接数_泉3`  
from t_prod a 
left join t_orde_stat b on a.boxsku = b.boxsku 
left join t_mearge_stock c on a.boxsku =c.boxsku 
left join t_list_stat d on a.boxsku = d.boxsku 
