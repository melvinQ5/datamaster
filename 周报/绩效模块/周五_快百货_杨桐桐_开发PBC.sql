with 
t_user_mannul as (
      select '����' title ,'���Ԫ' dep2 ,['����ϼ' ,'�����' ,'�ķ�' ,'��'] users
union select '����' title ,'���Ԫ' dep2 ,['����','�Խ�','Ϳ���','��ѩ��'] users
union select '�༭' title ,'���Ԫ' dep2 ,['�����'] users
union select '�ɹ�' title ,'���Ԫ' dep2 ,['ũ�h��','��С÷','�Է���'] users

union select '����' title ,'��η�' dep2 ,['��ٻ' ,'����1688' ,'������'] users 
union select '����' title ,'��η�' dep2 ,['������','�ž�','��׿'] users  
union select '�༭' title ,'��η�' dep2 ,['����','��ѩ��'] users  
union select '�ɹ�' title ,'��η�' dep2 ,['������','��Ҷ��'] users  
)

,t_user as (
select * 
from (select dep2 ,title ,unnest as users 
	from t_user_mannul ,unnest(users)
	) tmp 
where title = '����'
)

,t_dev_stage as (
select epp.SPU ,epps.AuditTime as manager_audittime
from erp_product_products epp 
join erp_product_product_statuses epps on epp.id = epps.ProductId 
where epp.IsMatrix =1 and epps.DevelopStage = 30
	and CreationTime >= '${StartDay}' 
	and CreationTime < '${NextStartDay}' 
)


,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.spu ,eppea.Name as ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.spu ,eppea.Name 
)

,t_prod as (
select epp.SPU 
	,epp.DevelopLastAuditTime ,epp.CreationTime 
	,epp.DevelopUserName 
	,case when t_elem.spu is null then '��Ԫ��Ʒ' else ele_name end ele_name
from erp_product_products epp 
left join t_elem on epp.spu = t_elem.spu 
where epp.IsMatrix = 1 and IsDeleted = 0 
)

,t_last_audit as ( 
select  t_prod.DevelopUserName 
	,case when ele_name is null then '�ϼ�' else ele_name end as ele_name
	,count(distinct t_prod.spu) `����SPU��`
from t_prod 
join t_user on t_prod.DevelopUserName = t_user.users 
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' 
group by grouping sets ((t_prod.DevelopUserName),(t_prod.DevelopUserName ,t_prod.ele_name))
)

,t_add_spu as ( 
select  t_prod.DevelopUserName 
	,case when ele_name is null then '�ϼ�' else ele_name end as ele_name
	,count(distinct t_prod.spu) `���SPU��`
	,count(distinct case when timestampdiff(SECOND ,t_prod.CreationTime ,t_dev_stage.manager_audittime)<=86400*3 
		then t_prod.spu end) `���3���ھ������SPU��`
	,count(distinct case when timestampdiff(SECOND ,t_prod.CreationTime ,t_dev_stage.manager_audittime)<=86400*2 
		then t_prod.spu end) `���2���ھ������SPU��`
	,count(distinct case when timestampdiff(SECOND ,t_prod.CreationTime ,t_dev_stage.manager_audittime)<=86400*1 
		then t_prod.spu end) `���1���ھ������SPU��`
	,count(distinct case when DevelopLastAuditTime >= '${NextStartDay}' 
	or DevelopLastAuditTime is null then t_prod.spu end) `��ӵ���δ����SPU��`	
from t_prod 
join t_user on t_prod.DevelopUserName = t_user.users 
left join t_dev_stage on t_dev_stage.spu = t_prod.spu 
where  CreationTime >= '${StartDay}' and CreationTime < '${NextStartDay}'  
group by grouping sets ((t_prod.DevelopUserName),(t_prod.DevelopUserName ,t_prod.ele_name))
)


select t_add_spu.DevelopUserName,t_add_spu.ele_name
	,`���SPU��` 
	,`��ӵ���δ����SPU��` 
	,`���3���ھ������SPU��`
	,`���2���ھ������SPU��`
	,`���1���ھ������SPU��`	
	,`����SPU��` 
from t_add_spu
left join t_last_audit on t_add_spu.DevelopUserName = t_last_audit.DevelopUserName
	and t_add_spu.ele_name = t_last_audit.ele_name
order by DevelopUserName ,ele_name