
with 
-- step1 ����Դ����
t_prod as (
select SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,spu ,CreationTime ,boxsku ,SkuSource ,Status 
from import_data.erp_product_products
where IsDeleted =0 
)

,t_key as ( -- ���������ά��
select '��˾' as dep
union select '��ٻ�' 
union select '�̳���' 
union 
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union 
select NodePathName from import_data.mysql_store where department regexp '��' 
)

,t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
select 
	Code 
	,case when NodePathName regexp 'Ȫ��' then '��ٻ�����' 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department 
		end as department
	,NodePathName
	,department as department_old
from import_data.mysql_store
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime
	,t_prod.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join t_prod on eppaea.sku = t_prod.sku 
where t_prod.ismatrix = 0 and t_prod.status != 20 
group by eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime,t_prod.ProjectTeam
)

,t_copy_new_pp as ( -- 2�¸��Ʋ�Ʒ����Ʒ
select epp.spu , epp.sku
from import_data.erp_product_product_copy_relations eppcr 
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id 
where  epp.IsMatrix =0 and eppcr.IsDeleted = 0
group by epp.spu , epp.sku
)

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
,t_elem_cnt as (
select dep 
	,count(distinct name) `Ԫ������` 
	,count(distinct Spu)   `��Ʒ��Ԫ��SPU��`	
from ( select name ,ProjectTeam as dep ,spu from t_elem where ProjectTeam = '��ٻ�' 
	group by name ,dep ,spu) tmp 
group by dep
)


,t_new_spu as (
select CASE WHEN ProjectTeam  IS NULL THEN '��˾' ELSE ProjectTeam  END AS dep
	,count(distinct t_prod.spu ) `��ƷSPU��` 
	,count(distinct case when tag.spu is not null then tag.spu end) `Ԫ����ƷSPU��`
from t_prod
left join (select spu from t_elem group by spu ) tag on t_prod.spu = tag.spu 
left join t_copy_new_pp on t_prod.spu = t_copy_new_pp.spu
where IsMatrix = 0 and DevelopLastAuditTime  < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}' 
	and t_copy_new_pp.spu is null 
group by grouping sets ((),(ProjectTeam))
)

,t_new_sku_sale_in7d as (
select entire_sku.ProjectTeam as dep
	, round(count(part_SKU.SKU)/count(entire_sku.SKU),4) `��Ʒ7��SKU������`
from ( -- ����SKU
	select wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	from import_data.wt_products wp 
	left join t_copy_new_pp on wp.sku = t_copy_new_pp.sku
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) 
		and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
		and IsDeleted = 0 and t_copy_new_pp.sku is null and wp.ProjectTeam = '��ٻ�'
	group by wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	) entire_sku 
left join ( -- ����SKU
	select SKU ,ProjectTeam  
	from import_data.wt_orderdetails wo  
	join import_data.wt_products wp on wp.BoxSku = wo.BoxSku 
	where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
		and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}'
		and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SKU ,ProjectTeam   
	) part_SKU 
	on entire_sku.SKU = part_SKU.SKU
group by entire_sku.ProjectTeam
)

,t_new_sku_sale_in14d as (
select entire_sku.ProjectTeam as dep
	, round(count(part_SKU.SKU)/count(entire_sku.SKU),4) `��Ʒ14��SKU������`
from ( -- ����SKU
	select wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	from import_data.wt_products wp 
	left join t_copy_new_pp on wp.sku = t_copy_new_pp.sku
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) 
		and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
		and IsDeleted = 0 and t_copy_new_pp.sku is null and wp.ProjectTeam = '��ٻ�'
	group by wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	) entire_sku 
left join ( -- ����SKU
	select SKU ,ProjectTeam  
	from import_data.wt_orderdetails wo  
	join import_data.wt_products wp on wp.BoxSku = wo.BoxSku 
	where  wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
		and wo.Department = '��ٻ�'
		and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}'
		and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SKU ,ProjectTeam   
	) part_SKU 
	on entire_sku.SKU = part_SKU.SKU
group by entire_sku.ProjectTeam
)


,t_new_sku_sale_in30d as (
select entire_sku.ProjectTeam as dep
	, round(count(part_SKU.SKU)/count(entire_sku.SKU),4) `��Ʒ30��SKU������`
from ( -- ����SKU
	select wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	from import_data.wt_products wp 
	left join t_copy_new_pp on wp.sku = t_copy_new_pp.sku
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) 
		and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
		and IsDeleted = 0 and t_copy_new_pp.sku is null and wp.ProjectTeam = '��ٻ�'
	group by wp.SKU ,ProjectTeam ,BoxSku ,DevelopLastAuditTime
	) entire_sku 
left join ( -- ����SKU
	select SKU ,ProjectTeam  
	from import_data.wt_orderdetails wo  
	join import_data.wt_products wp on wp.BoxSku = wo.BoxSku 
	where  wo.Department = '��ٻ�' and  DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
		and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}'
		and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SKU ,ProjectTeam   
	) part_SKU 
	on entire_sku.SKU = part_SKU.SKU
group by entire_sku.ProjectTeam
)


,t_last_aduit_InNd as (  -- ��Ʒ���N������������ �� ��Ʒ�������
select 
	'��ٻ�' dep
	,count(case when is_in5d = 1 then sku end)/count(SKU) `��Ʒ5��������`
from (select 
		case when timestampdiff(second,CreationTime,DevelopLastAuditTime)/86400 <= 3 then 1 else 0 end as is_in5d  
		,t_prod.*
	from t_prod 
	where CreationTime >= date_add('${StartDay}',interval -5 day) and CreationTime < date_add('${NextStartDay}',interval -5 day)
		and status != 20 and ismatrix = 0 and ProjectTeam = '��ٻ�' 
	) ta 
)


-- step3 ����ָ�����ݼ�
select 
	'${NextStartDay}' `ͳ������`
	,t_key.dep `�Ŷ�` 
	,t_elem_cnt.`Ԫ������` 
	,t_elem_cnt.`��Ʒ��Ԫ��SPU��`
	,t_new_spu.`��ƷSPU��` 
	,t_new_spu.`Ԫ����ƷSPU��`
	,t_new_sku_sale_in7d.`��Ʒ7��SKU������`
	,t_new_sku_sale_in14d.`��Ʒ14��SKU������`
	,t_new_sku_sale_in30d.`��Ʒ30��SKU������`
	,t_last_aduit_InNd.`��Ʒ5��������`
-- 	,`�ᱨ��Ȩռ��`
from t_key
left join t_elem_cnt on t_key.dep = t_elem_cnt.dep
left join t_new_spu on t_key.dep = t_new_spu.dep
left join t_new_sku_sale_in7d on t_key.dep = t_new_sku_sale_in7d.dep
left join t_new_sku_sale_in14d on t_key.dep = t_new_sku_sale_in14d.dep
left join t_new_sku_sale_in30d on t_key.dep = t_new_sku_sale_in30d.dep
left join t_last_aduit_InNd on t_key.dep = t_last_aduit_InNd.dep
order by `�Ŷ�` desc 

-- step4 ����ָ�� = ����ָ����Ӽ���