-- 近14天对比前14天订单增长≥2，按订单降序排列（去掉停产和缺货的产品）

with 
t_black_list as (
select sku from JinqinSku js where Monday = '2023-04-07' group by sku 
union 
select c3 as sku from manual_table mt where c1 REGEXP '产品推荐_第14周|产品推荐_第15周'
)


,dim_new as ( -- 新品
select boxsku,sku  from wt_products where DevelopLastAuditTime >= '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
)

,dim_old as ( -- 老品
select boxsku,sku  from wt_products where DevelopLastAuditTime < '2023-01-01' and IsDeleted = 0 and ProductStatus not in ('2','4')
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,eppea.Name  ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku ,eppea.Name 
)

,new_list as ( -- 新品推荐
select  'A_23年内终审' `新老品` ,ele_name ,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime)  as `产品终审时间` 
	,DevelopUserName ,vr.NodePathName 
	,cat1`一级类目` 
	,cat2`二级类目` 
	,cat3`三级类目` 
	,cat4`四级类目` 	
	,wp.TortType `侵权类型` ,dwi.ifnull(TotalInventory,0) `库存件数`
	,number1 as '近14天产品订单数' ,number2 as '前14天产品订单数' ,number1-number2 as '订单增量' 
from
	(select a.BoxSKU,number1 ,number2 
	from
		(select wo.BoxSKU ,count(distinct platordernumber ) as number1 
		from wt_orderdetails wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='快百货'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >= date_add('${NextStartday}',interval -14 day ) and paytime <'${NextStartday}'
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as a
	left join
		(select wo.BoxSKU ,count(distinct platordernumber )  as number2 
		from wt_orderdetails as wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='快百货'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >=date_add('${NextStartday}',interval -28 day ) and paytime <date_add('${NextStartday}',interval -14 day )
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as b
	on a.BoxSKU=b.BoxSKU 
	) as c
join wt_products wp on c.BoxSKU = wp.BoxSKU and IsDeleted=0 and ProductStatus not in ('2','4')
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '开发'
join dim_new on c.boxsku = dim_new.boxsku -- 新品
left join (select sku ,group_concat(ele_name) ele_name from t_elem group by sku ) ele on wp.sku = ele.sku 
left join import_data.daily_WarehouseInventory dwi on c.boxsku = dwi.boxsku and dwi.CreatedTime = date_add('${NextStartday}',interval -1 day )
where number1 - ifnull(number2,0) >= 2 -- 前14天可以无订单
)

,old_list as ( -- 老品推荐
select 'B_23年以前终审' `新老品` ,ele_name ,wp.SKU ,wp.SPU ,wp.BoxSKU ,wp.ProductName ,to_date(wp.DevelopLastAuditTime) as `产品终审时间`
	,DevelopUserName ,vr.NodePathName 
	,cat1 `一级类目` 
	,cat2 `二级类目` 
	,cat3 `三级类目` 
	,cat4 `四级类目` 
	,wp.TortType ,dwi.ifnull(TotalInventory,0) `库存件数`
	,number1 as '近14天产品订单数' ,number2 as '前14天产品订单数' ,number1-number2 as '订单增量' 
from
	(select a.BoxSKU,number1 ,number2 
	from
		(select wo.BoxSKU ,count(distinct platordernumber ) as number1 
		from wt_orderdetails wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='快百货'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >= date_add('${NextStartday}',interval -14 day ) and paytime <'${NextStartday}'
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as a
	join
		(select wo.BoxSKU ,count(distinct platordernumber ) as number2 
		from wt_orderdetails as wo
		join mysql_store as s on wo.ShopCode=s.Code and s.Department='快百货'
		left join t_black_list on wo.product_sku = t_black_list.sku 
		where paytime >=date_add('${NextStartday}',interval -28 day ) and paytime <date_add('${NextStartday}',interval -14 day )
			and wo.isdeleted = 0 and t_black_list.sku is null 
		group by wo.BoxSKU
		) as b
	on a.BoxSKU=b.BoxSKU 
	) as c
join wt_products wp on c.BoxSKU = wp.BoxSKU and IsDeleted=0 and ProductStatus not in ('2','4')
left join view_roles vr on wp.DevelopUserName = vr.name and vr.ProductRole = '开发'
join dim_old on c.boxsku = dim_old.boxsku -- 老品
left join (select sku ,group_concat(ele_name) ele_name from t_elem group by sku ) ele on wp.sku = ele.sku 
left join import_data.daily_WarehouseInventory dwi on c.boxsku = dwi.boxsku and dwi.CreatedTime = date_add('${NextStartday}',interval -1 day )
where number1 - number2 >= 2 -- 前14天有销量，且近14天对比前14天增长>=2
)

,t_merage as ( -- 总共推荐300款 , 优先满足新品推荐数量，不够再用老品补足
select * from new_list 
union all 
select * from old_list 
)

,t_list_cnt as ( 
select wl.sku 
	,count(distinct concat(SellerSKU,ShopCode)) `在线链接数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(shopcode,SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(shopcode,SellerSku) end ) `在线链接数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(shopcode,SellerSku) end ) `在线链接数_泉3` 
from wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code 
join (select sku from t_merage group by sku ) tb on wl.sku = tb.sku 
where wl.ListingStatus =1 and ms.ShopStatus = '正常' and ms.Department = '快百货'
group by wl.sku
)

select 'P1-产品库商品' `规则编号` 
	,ta.* ,`在线链接数` ,`在线链接数_成1` ,`在线链接数_成2` ,`在线链接数_泉1` ,`在线链接数_泉2` ,`在线链接数_泉3` 
from t_merage ta 
left join t_list_cnt tb on ta.sku = tb.sku  
order by `新老品` ASC ,订单增量 DESC limit 400
