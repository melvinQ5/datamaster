with 
t_user_mannul as (
      select '开发' title ,'快次元' dep2 ,['李云霞' ,'王婉君' ,'夏菲' ,'沈邦华'] users
union select '美工' title ,'快次元' dep2 ,['方鑫','赵晋','涂宇佳','黄雪莉'] users
union select '编辑' title ,'快次元' dep2 ,['朱玉洁'] users
union select '采购' title ,'快次元' dep2 ,['农玥怡','余小梅','赵飞燕'] users

union select '开发' title ,'快次方' dep2 ,['陈倩' ,'李琴1688' ,'丁华丽'] users 
union select '美工' title ,'快次方' dep2 ,['沈庆雯','张娟','左卓'] users  
union select '编辑' title ,'快次方' dep2 ,['刘冬','符雪花'] users  
union select '采购' title ,'快次方' dep2 ,['王泊霖','蒲叶波'] users  
)

,t_user as (
select * 
from (select dep2 ,title ,unnest as users 
	from t_user_mannul ,unnest(users)
	) tmp 
where title = '开发'
)

,t_dev_stage as (
select epp.SPU ,epps.AuditTime as manager_audittime
from erp_product_products epp 
join erp_product_product_statuses epps on epp.id = epps.ProductId 
where epp.IsMatrix =1 and epps.DevelopStage = 30
	and CreationTime >= '${StartDay}' 
	and CreationTime < '${NextStartDay}' 
)


,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.spu ,eppea.Name as ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.spu ,eppea.Name 
)

,t_prod as (
select epp.SPU 
	,epp.DevelopLastAuditTime ,epp.CreationTime 
	,epp.DevelopUserName 
	,case when t_elem.spu is null then '非元素品' else ele_name end ele_name
from erp_product_products epp 
left join t_elem on epp.spu = t_elem.spu 
where epp.IsMatrix = 1 and IsDeleted = 0 
)

,t_last_audit as ( 
select  t_prod.DevelopUserName 
	,case when ele_name is null then '合计' else ele_name end as ele_name
	,count(distinct t_prod.spu) `终审SPU数`
from t_prod 
join t_user on t_prod.DevelopUserName = t_user.users 
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' 
group by grouping sets ((t_prod.DevelopUserName),(t_prod.DevelopUserName ,t_prod.ele_name))
)

,t_add_spu as ( 
select  t_prod.DevelopUserName 
	,case when ele_name is null then '合计' else ele_name end as ele_name
	,count(distinct t_prod.spu) `添加SPU数`
	,count(distinct case when timestampdiff(SECOND ,t_prod.CreationTime ,t_dev_stage.manager_audittime)<=86400*3 
		then t_prod.spu end) `添加3天内经理审核SPU数`
	,count(distinct case when timestampdiff(SECOND ,t_prod.CreationTime ,t_dev_stage.manager_audittime)<=86400*2 
		then t_prod.spu end) `添加2天内经理审核SPU数`
	,count(distinct case when timestampdiff(SECOND ,t_prod.CreationTime ,t_dev_stage.manager_audittime)<=86400*1 
		then t_prod.spu end) `添加1天内经理审核SPU数`
	,count(distinct case when DevelopLastAuditTime >= '${NextStartDay}' 
	or DevelopLastAuditTime is null then t_prod.spu end) `添加当周未终审SPU数`	
from t_prod 
join t_user on t_prod.DevelopUserName = t_user.users 
left join t_dev_stage on t_dev_stage.spu = t_prod.spu 
where  CreationTime >= '${StartDay}' and CreationTime < '${NextStartDay}'  
group by grouping sets ((t_prod.DevelopUserName),(t_prod.DevelopUserName ,t_prod.ele_name))
)


select t_add_spu.DevelopUserName,t_add_spu.ele_name
	,`添加SPU数` 
	,`添加当周未终审SPU数` 
	,`添加3天内经理审核SPU数`
	,`添加2天内经理审核SPU数`
	,`添加1天内经理审核SPU数`	
	,`终审SPU数` 
from t_add_spu
left join t_last_audit on t_add_spu.DevelopUserName = t_last_audit.DevelopUserName
	and t_add_spu.ele_name = t_last_audit.ele_name
order by DevelopUserName ,ele_name