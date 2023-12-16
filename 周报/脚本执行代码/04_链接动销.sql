

with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union select '商厨汇' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)


,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '成都' then '快百货一部'  else '快百货二部' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '快'
)

,t_elem as ( -- 元素维度
select eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime
	,t_prod.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products t_prod on eppaea.sku = t_prod.sku and t_prod.ismatrix = 0 and t_prod.IsDeleted =0 
group by eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime,t_prod.ProjectTeam
)

,t_copy_new_pp as ( -- 2月复制产品非新品
select eppcr.NewProdId, null spu ,epp.sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =0 and eppcr.IsDeleted = 0
group by eppcr.NewProdId, epp.sku
union 
select eppcr.NewProdId, epp.spu ,null sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =1 and eppcr.IsDeleted = 0 
group by eppcr.NewProdId, epp.spu
)

,t_orde as (
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend
	,ExchangeUSD,TransactionType,OrderStatus,SellerSku,RefundAmount,AdvertisingCosts ,wo.shopcode ,wo.Asin 
-- 	,pp.Spu
	,ms.*
	,elem.ele_boxsku
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
-- left join wt_products pp on wo.BoxSku=pp.BoxSku
left join ( select spu ,BoxSku as ele_boxsku ,DevelopLastAuditTime from t_elem group by spu ,BoxSku ,DevelopLastAuditTime ) elem 
	on wo.BoxSku = elem.ele_boxsku -- 筛选元素品
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
)

,t_new_list as ( -- 新刊登链接维度
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.*
from import_data.wt_listing  eaal
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0 
)


-- step2 派生指标 = 统计期+叠加维度+原子指标
,t_ware_sku as (
select case when department is null then '公司' else department end as dep
	, count(distinct tmp.BoxSku ) `库存产品SKU数` -- 上个统计期末在仓sku U 本统计期末在仓sku U 期间采购过的SKU
from (
	select BoxSku -- 本期在仓sku
	from import_data.daily_WarehouseInventory dwi 
	where CreatedTime = DATE_ADD('${NextStartDay}', -1) and WarehouseName = '东莞仓' 
	group by BoxSku 
	union 
	select BoxSku -- 上期在仓sku
	from import_data.daily_WarehouseInventory dwi 
	where CreatedTime = DATE_ADD('${StartDay}', -1) and WarehouseName = '东莞仓' 
	group by BoxSku 
	union 
	select BoxSku -- 期间采购sku
	from wt_purchaseorder wp 
	where ordertime  <  '${NextStartDay}'  and ordertime >= '${StartDay}' and WarehouseName = '东莞仓' 
	) tmp 
join (select BoxSku , ProjectTeam as department from import_data.wt_products where IsDeleted = 0 ) wp2 
	on tmp.BoxSku =wp2.BoxSku 
group by grouping sets ((),(department))
)

,t_erp_sku as (
select case when ProjectTeam is null then '公司' else ProjectTeam end as dep
	,count(distinct SKU) `产品库SKU数`
	,count(distinct SPU) `产品库SPU数`
from import_data.erp_product_products epp 
where IsDeleted = 0 and ProductStatus != 2 and DevelopLastAuditTime is not null 
group by grouping sets ((),(ProjectTeam))
)

,t_sale_sku as ( 
select case when ms.department is null then '公司' else ms.department end as dep
	, count(distinct boxsku) `出单sku数`
	, count(distinct Product_SPU) `出单spu数`
	, count(distinct shopcode) `出单店铺数`	
from wt_orderdetails wo 
join t_mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0
where PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' 
	and TransactionType ='付款' and OrderStatus <> '作废' and TotalGross>0 
group by grouping sets ((),(ms.department))
union 
select '快百货' as department
	, count(distinct boxsku) `出单sku数`
	, count(distinct Product_SPU) `出单spu数`
	, count(distinct shopcode) `出单店铺数`	
from wt_orderdetails wo 
join t_mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0
where PayTime < '${NextStartDay}' and PayTime >= '${StartDay}'  and ms.department regexp '快' 
	and TransactionType ='付款' and OrderStatus <> '作废' and TotalGross>0 
)

-- 出单链接明细
-- select t_orde.department ,t_orde.ShopCode ,t_orde.Asin ,t_orde.SellerSku 
-- from t_orde
-- join (
-- 	select department,shopcode,SellerSku,Asin 
-- 	from t_new_list where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
-- 	group by department,shopcode,SellerSku,Asin 
-- 	) t_new_list 
-- 	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
-- 	where t_orde.department  regexp '快'
	

,t_new_pub as (  -- 新刊登链接
select case when t_orde.department is null then '公司' else t_orde.department end as dep
	,round(sum(TotalGross/ExchangeUSD)) `新刊登链接销售额`
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `新刊登出单链接数`
from t_orde
join (
	select department,shopcode,SellerSku,Asin 
	from t_new_list 
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) t_new_list 
	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(t_orde.department))
union
select '快百货' as department
	,round(sum(TotalGross/ExchangeUSD)) `新刊登链接销售额`
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `新刊登出单链接数`
from t_orde
join ( 
	select shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '快' 
	group by shopcode,SellerSku,Asin 
	) t_new_list 
	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
where t_orde.department regexp '快' 
union
select t_orde.NodePathName 
	,round(sum(TotalGross/ExchangeUSD)) `新刊登链接销售额`
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `新刊登出单链接数`
from t_orde
join (
	select NodePathName,shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '快' 
	group by NodePathName,shopcode,SellerSku,Asin 
	) t_new_list 
	on t_orde.ShopCode =t_new_list.ShopCode and t_orde.Asin =t_new_list.ASIN and t_orde.SellerSku = t_new_list.SellerSku 
where t_orde.department regexp '快' 
group by t_orde.NodePathName
)

,t_ord_lst as (
select case when t_orde.department is null then '公司' else t_orde.department end as dep
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `出单链接数`
from t_orde where TransactionType ='付款' and OrderStatus <> '作废' and TotalGross>0
group by grouping sets ((),(t_orde.department))
union 
select  '快百货' as department
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `出单链接数`
from t_orde where TransactionType ='付款' and OrderStatus <> '作废' and TotalGross>0 and department regexp '快' 
union 
select t_orde.NodePathName 
	,count(distinct concat(t_orde.shopcode,t_orde.SellerSku,t_orde.Asin)) `出单链接数`
from t_orde where TransactionType ='付款' and OrderStatus <> '作废' and TotalGross>0  and department regexp '快' 
group by t_orde.NodePathName
)

,t_online_list_spu as ( 
select case when department is null then '公司' else department end as dep
	,count( distinct spu ) `在线SPU数`
from (select ShopCode ,SellerSKU ,ASIN ,ms.department ,spu
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code and ListingStatus = 1 and ms.ShopStatus = '正常'
	group by department,shopcode,SellerSku,Asin,spu
	) tmp1
group by grouping sets ((),(department))
union 
select  '快百货' as department ,count(distinct spu) `在线SPU数`
from (select ShopCode ,SellerSKU ,ASIN ,spu
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
		on eaal.ShopCode = ms.Code and ListingStatus = 1 and ms.ShopStatus = '正常'
	where department regexp '快' 
	group by shopcode,SellerSku,Asin,spu
	) tmp1
)

,t_online_list as (
select case when department is null then '公司' else department end as dep
	,count(1) `在线链接数`
from (select ShopCode ,SellerSKU ,ASIN ,ms.department 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常'
		and department <> '特卖汇' -- 特卖汇是以店铺+国家确定一条链接，有另外的数据表
	group by department,shopcode,SellerSku,Asin
	) tmp1
group by grouping sets ((),(department))
union	
select '快百货' as department ,count(1) `在线链接数`
from (select ShopCode ,SellerSKU ,ASIN 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常'
	where department regexp '快' 
	group by shopcode,SellerSku,Asin
	) tmp1
union	
select NodePathName ,count(1) `在线链接数`
from ( select ShopCode ,SellerSKU ,ASIN ,ms.NodePathName 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常'
	where department regexp '快' 
	group by NodePathName,shopcode,SellerSku,Asin
	) tmp1
group by NodePathName
)

, t_new_list_cnt as (
select case when department is null then '公司' else department end as dep
	,count(1) `新刊登链接数`
from (select department,shopcode,SellerSku,Asin from t_new_list 
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) tmp1 
group by grouping sets ((),(department))
union 
select '快百货' as department ,count(1) `新刊登链接数`
from (select shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '快' 
	group by shopcode,SellerSku,Asin 
	) tmp2 
union 
select NodePathName ,count(1) `新刊登链接数`
from (select NodePathName,shopcode,SellerSku,Asin from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'  and department regexp '快' 
	group by NodePathName,shopcode,SellerSku,Asin 
	) tmp3 
group by NodePathName
)

,t_new_list_in30d as ( -- 近30天刊登
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.*
from import_data.wt_listing  eaal
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= date_add('${NextStartDay}',interval - 30 day)  and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0 
)

, t_new_list_in30d_cnt as (
select case when department is null then '公司' else department end as dep
	,count(1) `近30天刊登链接数`
from (select department,shopcode,SellerSku,Asin from t_new_list_in30d 
	where t_new_list_in30d.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) tmp1 
group by grouping sets ((),(department))
union 
select '快百货' as department ,count(1) `近30天刊登链接数`
from (select shopcode,SellerSku,Asin 
	from t_new_list_in30d
	where t_new_list_in30d.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '快' 
	group by shopcode,SellerSku,Asin 
	) tmp2 
union 
select NodePathName ,count(1) `近30天刊登链接数`
from (select NodePathName,shopcode,SellerSku,Asin from t_new_list_in30d
	where t_new_list_in30d.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'  and department regexp '快' 
	group by NodePathName,shopcode,SellerSku,Asin 
	) tmp3 
group by NodePathName
)


-- step3 派生指标数据集
, t_merge as (
select t_key.dep `团队`
	,t_new_pub.`新刊登链接销售额` ,t_new_pub.`新刊登出单链接数`
	,t_sale_sku.`出单sku数`
	,t_sale_sku.`出单spu数`
	,t_sale_sku.`出单店铺数`
	,t_ware_sku.`库存产品SKU数`
	,t_new_list_cnt.`新刊登链接数`
	,t_new_list_in30d_cnt.`近30天刊登链接数`
	,t_online_list.`在线链接数`
	,t_ord_lst.`出单链接数`
	,t_erp_sku.`产品库SKU数`
	,t_erp_sku.`产品库SPU数`
	,t_online_list_spu.`在线SPU数`
from t_key
left join t_new_pub on t_key.dep = t_new_pub.dep
left join t_sale_sku on t_key.dep = t_sale_sku.dep
left join t_ware_sku on t_key.dep = t_ware_sku.dep
left join t_new_list_cnt on t_key.dep = t_new_list_cnt.dep
left join t_online_list on t_key.dep = t_online_list.dep
left join t_ord_lst on t_key.dep = t_ord_lst.dep
left join t_erp_sku on t_key.dep = t_erp_sku.dep
left join t_online_list_spu on t_key.dep = t_online_list_spu.dep
left join t_new_list_in30d_cnt on t_key.dep = t_new_list_in30d_cnt.dep
)

-- step4 复合指标 = 派生指标叠加计算
select 
	'${NextStartDay}' `统计日期`
	,t_merge.*
	, round(`出单sku数`/`库存产品SKU数`,4) as `库存SKU动销率`
	, round(`出单spu数`/`产品库SPU数`,4) as `产品库SPU动销率`
	, round(`新刊登出单链接数`/`新刊登链接数`,4 ) `新刊登链接动销率`
	, round(`出单链接数`/`在线链接数`,4 ) `链接动销率`
from t_merge
order by `团队` desc 