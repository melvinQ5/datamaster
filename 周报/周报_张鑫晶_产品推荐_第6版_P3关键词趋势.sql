/*
 * 关键词趋势产品推荐刊登
母亲节 新品所有+老品去年3-5月有销量
新品：母亲节 美国国旗日 开斋节 复活节
*/


-- 表头差禁售平台，P1 和 P3 统一 

with 
t_black_list as (
select sku from JinqinSku js where Monday = '2023-04-07' group by sku 
union 
select c3 as sku from manual_table mt where c1 REGEXP '产品推荐_第14周'
)

,dim_new as ( -- 新品
select boxsku,sku  from wt_products where DevelopLastAuditTime >= '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProjectTeam = '快百货'
)

,dim_old as ( -- 老品
select boxsku,sku  from wt_products where DevelopLastAuditTime < '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
and ProductName regexp '
可伸缩晾衣绳|防晒霜涂抹器|户外地毯|挂钩|挂钩用于晾衣绳|软管喷枪|太阳能伙伴|太阳能花园灯|野餐毯|园艺手套|蹦床|男士太阳镜|烧烤罩|花园椅|
带锁钱包|床垫保护垫 180x200|纯棉地毯放松现代蓬松短绒地毯|
手持风扇|旅行包|LED 野营灯|女士透明包|互动狗狗玩具|防打鼾|鱼饵|淋浴门挂钩|派对灯|狗便便袋'
and ProjectTeam = '快百货'
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,eppea.Name  ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,eppea.Name 
)



, t_sku_stat as ( -- '母亲节|美国国旗日|开斋节|复活节'
-- select *
-- from (
-- select 'A_23年内终审' `新老品` ,ele_name ,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `产品终审时间`
-- 	,DevelopUserName ,vr.NodePathName 
-- 	,wp.CategoryPathByChineseName ,Cat1 ,'新品' `销量规则`
-- from wt_products wp 
-- join t_elem on wp.sku = t_elem .sku and ele_name regexp '母亲节|美国国旗日|开斋节|复活节'
-- join dim_new on wp.boxsku = dim_new.boxsku -- 新品
-- left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '开发'

-- union all 
select 'B_23年以前终审' `新老品` 
	,ele_name 
	,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `产品终审时间`
	,DevelopUserName ,vr.NodePathName 
	,cat1`一级类目` 
	,cat2`二级类目` 
	,cat3`三级类目` 
	,cat4`四级类目` 	
	,wp.TortType `侵权类型` 
	,salecount as `近2个月销量`
from wt_products wp 
join dim_old on wp.boxsku = dim_old.boxsku -- 老品
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '开发'
left join (select sku ,group_concat(ele_name) ele_name from t_elem group by sku ) ele on wp.sku = ele.sku 
join 
	(
	select wo.product_sku  ,sum(SaleCount) as salecount  
	from wt_orderdetails wo
	left join t_black_list on wo.product_sku = t_black_list.sku 
	where paytime >= date_add('${NextStartDay}', interval - 60 day ) and paytime <'${NextStartDay}'
		and wo.Department='快百货' 
		and wo.isdeleted = 0 
		and t_black_list.sku is null 
	group by wo.product_sku  having sum(SaleCount) > 0
	) wo 
	on wo.product_sku = wp.sku 
) 


-- 库存加链接数
, t_mearge_stock as (
select t.* ,dwi.ifnull(TotalInventory,0) `库存件数`
from t_sku_stat	t 
left join import_data.daily_WarehouseInventory dwi on t.boxsku = dwi.boxsku and dwi.CreatedTime = date_add('${NextStartDay}', interval -1 day )
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
-- 	and SellerSku not regexp 'bJ|Bj|bj|BJ'
)

, t_list_stat as (
select BoxSKU 
	,count(distinct concat(SellerSKU,ShopCode)) `在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(shopcode,SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(shopcode,SellerSku) end ) `在线链接数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(shopcode,SellerSku) end ) `在线链接数_泉3` 
	,min(PublicationDate) `首次刊登时间`
from t_list
group by BoxSKU  
)

, t_mearge_list as (
select 'P3-元素品-关键词趋势' `规则编号` 
	,ta.* 
	, `在线链接数` 
	, `在线链接数_成1` 
	, `在线链接数_成2` 
	, `在线链接数_泉1` 
	, `在线链接数_泉2` 
	, `在线链接数_泉3` 
from t_mearge_stock ta 
left join t_list_stat tb on ta.boxsku = tb.boxsku 
)

select * ,'' `是or否确定刊登（回填以便统计效果）`
from t_mearge_list
order by  `近2个月销量` desc  , `库存件数` desc 
limit 200 