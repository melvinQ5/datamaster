--  ������N��
 
with editor_spu as (
select HandleUserName , SKU ,SPU ,ProductId ,AssginTime,AuditTime, date_add(DevelopLastAuditTime,interval - 8 hour ) DevelopLastAuditTime
	, vr.department 
 	, vr.NodePathName
 	, vr.dep2
 	
from import_data.erp_product_products epp 
join (
	select ProductId  ,HandleUserName 
		,date_add(AssginTime,interval - 8 hour) AssginTime 
		,date_add(AuditTime,interval - 8 hour ) AuditTime
	from import_data.erp_product_product_statuses epps 
	where date_add(AssginTime,interval - 8 hour)  < '${NextSteditorDay}' 
		and date_add(AssginTime,interval - 8 hour) >= '${SteditorDay}' 
		and DevelopStage = 50
	group by ProductId  ,HandleUserName ,AssginTime,AuditTime
	) editor on epp.Id = editor.ProductId
join ( select case when name in ('������','����2') then '��ٻ�һ��' else split(NodePathNameFull,'>')[2] end as dep2 -- ������Э����Ʒ��������Ʒ����Ա
			,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName
			,name ,department
		from view_roles 
		where ProductRole ='�༭' 
	-- 	and NodePathName in ('��η�-��Ʒ��','���Ԫ-��Ʒ��','��Ʒ��')
		) vr on editor.HandleUserName = vr.name
where epp.ProjectTeam = '��ٻ�' 
	and DevelopLastAuditTime is not null -- ������
	and epp.Status = 10 
group by HandleUserName , SKU ,SPU ,ProductId ,AssginTime,AuditTime, date_add(DevelopLastAuditTime,interval - 8 hour )
	, vr.department
 	, vr.NodePathName
 	, vr.dep2
)

-- -- ��ϸ
-- select 
-- 	HandleUserName `������`
-- 	,NodePathName `С��`
--  ,dep2 `�Ŷ�`
-- 	,SKU 
-- 	,SPU 
-- -- 	,ProductId 
-- 	,to_date(AssginTime) `�༭����ʱ��`
-- 	,to_date(AuditTime) `�༭���ʱ��`
-- 	,to_date(DevelopLastAuditTime) `��Ʒ����ʱ��`
-- from editor_spu

-- -- ͳ��
 select
 	replace(concat(right('${SteditorDay}',5),'��',right(to_date(date_add('${NextSteditorDay}',-1)),5)),'-','') `�༭����ʱ�䷶Χ`
 	,dep2 `�Ŷ�`
 	,NodePathName `С��`
 	,HandleUserName `������`
 	, count(DISTINCT t.sPU) `����SPU��`
 from editor_spu t 
 group by department
 	,dep2
 	,NodePathName
 	,HandleUserName 
