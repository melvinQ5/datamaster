with 
de as (
select case when sku = '����' then '����1688' else sku end  as name ,boxsku as department,spu as dep2 
from JinqinSku js where Monday= '2023-03-31' 
)

,epps as (
select to_date(date_add(AuditTime,interval -8 hour)) AuditTime 
	,to_date(date_add(HandleTime,interval -8 hour)) HandleTime
	,DevelopStage
	,HandleUserName
	,ProductId
from import_data.erp_product_product_statuses

)

,dev as ( -- ���
select sku ,spu ,HandleUserName ,dep2 , HandleTime
from import_data.erp_product_products epp 
join epps on epp.Id = epps.ProductId 
left join de on epps.HandleUserName = de.name 
where HandleTime  < '${NextStartDay}' and HandleTime >= '${StartDay}' 
	and DevelopStage = 10 and dep2 in ('���Ԫ��Ʒ��','��η���Ʒ��','��Ʒ��')
group by sku ,spu ,HandleUserName ,dep2 ,HandleTime
) 

,art as ( -- ����
select sku ,spu  ,HandleUserName ,dep2 ,AuditTime
from import_data.erp_product_products epp 
join  epps on epp.Id = epps.ProductId 
left join de on epps.HandleUserName = de.name 
where AuditTime  < '${NextStartDay}' and AuditTime >= '${StartDay}' 
	and DevelopStage = 40 and dep2 in ('���Ԫ��Ʒ��','��η���Ʒ��','��Ʒ��')
group by sku ,spu  ,HandleUserName ,dep2 ,AuditTime
) 

,editor as ( -- �༭
select sku ,spu  ,HandleUserName ,dep2 ,AuditTime
from import_data.erp_product_products epp 
join epps on epp.Id = epps.ProductId 
left join de on epps.HandleUserName = de.name 
where AuditTime  < '${NextStartDay}' and AuditTime >= '${StartDay}' 
	and DevelopStage = 50
group by sku ,spu  ,HandleUserName ,dep2 ,AuditTime
) 


select '�������SPU��' meric
	,HandleUserName `��Ա`
	,dep2 `�Ŷ�`
	,HandleTime `����`
	,count(distinct spu) `SPU��`
from dev 
group by HandleUserName ,dep2 , HandleTime
union 
select '��������SPU��' meric,HandleUserName,dep2 , AuditTime ,count(distinct spu) value
from art 
group by HandleUserName,dep2 , AuditTime
union 
select '�༭����SPU��' meric,HandleUserName,dep2 , AuditTime ,count(distinct spu) value
from editor 
group by HandleUserName,dep2 , AuditTime

