--  ������N��
 
with art_spu as (
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
	where date_add(AssginTime,interval - 8 hour)  < '${NextStartDay}' 
		and date_add(AssginTime,interval - 8 hour) >= '${StartDay}' 
		and DevelopStage = 40
	group by ProductId  ,HandleUserName ,AssginTime,AuditTime
	) art on epp.Id = art.ProductId
join ( select case when name in ('������','����2') then '��ٻ�һ��' else split(NodePathNameFull,'>')[2] end as dep2 -- ������Э����Ʒ��������Ʒ����Ա
			,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName
			,name ,department
		from view_roles 
		where ProductRole ='����' 
	-- 	and NodePathName in ('��η�-��Ʒ��','���Ԫ-��Ʒ��','��Ʒ��')
		) vr on art.HandleUserName = vr.name
where epp.ProjectTeam = '��ٻ�' 
	and DevelopLastAuditTime is not null -- ������
	and epp.Status = 10 
group by HandleUserName , SKU ,SPU ,ProductId ,AssginTime,AuditTime, date_add(DevelopLastAuditTime,interval - 8 hour )
	, vr.department
 	, vr.NodePathName
 	, vr.dep2
)

,t_reje as ( -- ��Ȩ����������
select HandleTime ,Reason ,Remark ,ProductId 
from erp_product_product_develop_logs
where Stage = 60 
	and PreStatus = 40 -- �����
	and AftStatus = 50 -- ������
	and Reason = 'ͼƬ��Ȩ'
	and HandleTime >= '2023-04-01' and HandleTime < '2023-05-01'
)

-- -- ͳ��
 select
 	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `��������ʱ�䷶Χ`
 	,dep2 `�Ŷ�`
 	,NodePathName `С��`
 	,HandleUserName `������`
 	, count(DISTINCT t.sPU) `����SPU��`
 from art_spu t 
 group by department
 	,dep2
 	,NodePathName
 	,HandleUserName 

