
with 
-- step1 数据源处理
t_prod as (
select SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,spu ,CreationTime ,boxsku ,SkuSource ,Status 
from import_data.erp_product_products
where IsDeleted =0 
)

,t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union select '商厨汇' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)

,t_mysql_store as (  -- 组织架构临时改变前
select 
	Code 
	,case when NodePathName regexp '泉州' then '快百货二部' 
		when NodePathName regexp '成都' then '快百货一部'  else department 
		end as department
	,NodePathName
	,department as department_old
from import_data.mysql_store
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime
	,t_prod.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join t_prod on eppaea.sku = t_prod.sku 
where t_prod.ismatrix = 0 and t_prod.status != 20 
group by eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime,t_prod.ProjectTeam
)

,t_copy_new_pp as ( -- 2月复制产品非新品
select epp.spu , epp.sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =0 and eppcr.IsDeleted = 0
group by epp.spu , epp.sku
)

-- step2 派生指标 = 统计期+叠加维度+原子指标
,t_elem_cnt as (
select dep 
	,count(distinct name) `元素数量` 
	,count(distinct Spu)   `产品库元素SPU数`	
from ( select name ,ProjectTeam as dep ,spu from t_elem where ProjectTeam = '快百货' 
	group by name ,dep ,spu) tmp 
group by dep
)


,t_new_spu as (
select CASE WHEN ProjectTeam  IS NULL THEN '公司' ELSE ProjectTeam  END AS dep
	,count(distinct t_prod.spu ) `新品SPU数` 
	,count(distinct case when tag.spu is not null then tag.spu end) `元素新品SPU数`
from t_prod
left join (select spu from t_elem group by spu ) tag on t_prod.spu = tag.spu 
left join t_copy_new_pp on t_prod.spu = t_copy_new_pp.spu
where IsMatrix = 0 and DevelopLastAuditTime  < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}' 
	and t_copy_new_pp.spu is null 
group by grouping sets ((),(ProjectTeam))
)

,t_new_sku_sale_in7d as (
select entire_sku.ProjectTeam as dep
	, round(count(part_SKU.SKU)/count(entire_sku.SKU),4) `新品7天SKU动销率`
from ( -- 开发SKU
	select wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	from import_data.wt_products wp 
	left join t_copy_new_pp on wp.sku = t_copy_new_pp.sku
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) 
		and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
		and IsDeleted = 0 and t_copy_new_pp.sku is null and wp.ProjectTeam = '快百货'
	group by wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	) entire_sku 
left join ( -- 出单SKU
	select SKU ,ProjectTeam  
	from import_data.wt_orderdetails wo  
	join import_data.wt_products wp on wp.BoxSku = wo.BoxSku 
	where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
		and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}'
		and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SKU ,ProjectTeam   
	) part_SKU 
	on entire_sku.SKU = part_SKU.SKU
group by entire_sku.ProjectTeam
)

,t_new_sku_sale_in14d as (
select entire_sku.ProjectTeam as dep
	, round(count(part_SKU.SKU)/count(entire_sku.SKU),4) `新品14天SKU动销率`
from ( -- 开发SKU
	select wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	from import_data.wt_products wp 
	left join t_copy_new_pp on wp.sku = t_copy_new_pp.sku
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) 
		and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
		and IsDeleted = 0 and t_copy_new_pp.sku is null and wp.ProjectTeam = '快百货'
	group by wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	) entire_sku 
left join ( -- 出单SKU
	select SKU ,ProjectTeam  
	from import_data.wt_orderdetails wo  
	join import_data.wt_products wp on wp.BoxSku = wo.BoxSku 
	where  wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
		and wo.Department = '快百货'
		and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}'
		and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SKU ,ProjectTeam   
	) part_SKU 
	on entire_sku.SKU = part_SKU.SKU
group by entire_sku.ProjectTeam
)


,t_new_sku_sale_in30d as (
select entire_sku.ProjectTeam as dep
	, round(count(part_SKU.SKU)/count(entire_sku.SKU),4) `新品30天SKU动销率`
from ( -- 开发SKU
	select wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	from import_data.wt_products wp 
	left join t_copy_new_pp on wp.sku = t_copy_new_pp.sku
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) 
		and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
		and IsDeleted = 0 and t_copy_new_pp.sku is null and wp.ProjectTeam = '快百货'
	group by wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	) entire_sku 
left join ( -- 出单SKU
	select SKU ,ProjectTeam  
	from import_data.wt_orderdetails wo  
	join import_data.wt_products wp on wp.BoxSku = wo.BoxSku 
	where  wo.Department = '快百货' and  DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
		and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}'
		and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SKU ,ProjectTeam   
	) part_SKU 
	on entire_sku.SKU = part_SKU.SKU
group by entire_sku.ProjectTeam
)


,t_last_aduit_InNd as (  -- 产品添加N天内终审数量 除 产品添加数量
select 
	'快百货' dep
	,count(case when is_in5d = 1 then sku end)/count(SKU) `开品5天终审率`
from (select 
		case when timestampdiff(second,CreationTime,DevelopLastAuditTime)/86400 <= 3 then 1 else 0 end as is_in5d  
		,t_prod.*
	from t_prod 
	where CreationTime >= date_add('${StartDay}',interval -5 day) and CreationTime < date_add('${NextStartDay}',interval -5 day)
		and status != 20 and ismatrix = 0 and ProjectTeam = '快百货' 
	) ta 
)


-- step3 派生指标数据集
select 
	'${NextStartDay}' `统计日期`
	,t_key.dep `团队` 
	,t_elem_cnt.`元素数量` 
	,t_elem_cnt.`产品库元素SPU数`
	,t_new_spu.`新品SPU数` 
	,t_new_spu.`元素新品SPU数`
	,t_new_sku_sale_in7d.`新品7天SKU动销率`
	,t_new_sku_sale_in14d.`新品14天SKU动销率`
	,t_new_sku_sale_in30d.`新品30天SKU动销率`
	,t_last_aduit_InNd.`开品5天终审率`
-- 	,`提报侵权占比`
from t_key
left join t_elem_cnt on t_key.dep = t_elem_cnt.dep
left join t_new_spu on t_key.dep = t_new_spu.dep
left join t_new_sku_sale_in7d on t_key.dep = t_new_sku_sale_in7d.dep
left join t_new_sku_sale_in14d on t_key.dep = t_new_sku_sale_in14d.dep
left join t_new_sku_sale_in30d on t_key.dep = t_new_sku_sale_in30d.dep
left join t_last_aduit_InNd on t_key.dep = t_last_aduit_InNd.dep
order by `团队` desc 

-- step4 复合指标 = 派生指标叠加计算