-- ��ի�� ��վ��ͳ��ҵ��
-- �븴�̿������������ǲ����⼸��վ��

with 
t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.spu , eppea.Name ,DevelopLastAuditTime
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
left join import_data.erp_product_products epp on eppaea.spu = epp.SPU 
where eppea.DataStatus = 1 and epp.IsMatrix = 1 and epp.IsDeleted = 0 and ProjectTeam = '��ٻ�' and epp.Status = 10  AND name = '��ի��'
group by eppaea.spu , eppea.Name ,DevelopLastAuditTime
)

,od as (
select wo.BoxSku ,wo.Product_SPU as spu ,wo.Product_SKU as SKU 
	, round(TotalGross/ExchangeUSD) as sales
	,PayTime , wo.site 
	, tmp.name
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
join
	( -- һ��sku���Ԫ�� ����ж���
	select distinct eppaea.sku ,eppea.Name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id  AND name = '��ի��'
	) tmp
	on wo.Product_SKU = tmp.sku -- ��SKU��������
where wo.IsDeleted = 0  and PayTime  < '${NextStartDay}' and PayTime >= '${StartDay}' and ms.Department = '��ٻ�'
)

,dim_new as (
select boxsku from erp_product_products epp 
where  DevelopLastAuditTime >= '2023-01-01' and DevelopLastAuditTime < '2023-04-01'  
	and epp.IsMatrix = 0 and epp.IsDeleted = 0 and ProjectTeam = '��ٻ�' 
group by boxsku 
)

, ele_stat as ( 
select name 
	,count(distinct spu ) `��Ʒ��SPU��`
	,count(distinct case when DevelopLastAuditTime < '2023-02-01' then spu end) as `����1������SPU��`  
	,count(distinct case when DevelopLastAuditTime < '2023-03-01' then spu end) as `����2������SPU��`  
	,count(distinct case when DevelopLastAuditTime < '2023-04-01' then spu end) as `����3������SPU��`  
from t_elem 
group by name 
) 

, od_stat as (
select name , site 
	,sum( case when name is not null and left(PayTime,7) = '2023-01' then sales end ) `1��Ԫ�����۶�`
	,sum( case when name is not null and left(PayTime,7) = '2023-02' then sales end ) `2��Ԫ�����۶�`
	,sum( case when name is not null and left(PayTime,7) = '2023-03' then sales end ) `3��Ԫ�����۶�`
	,sum( case when name is not null and MONTH(PayTime) <= 3 then sales end ) `Q1Ԫ�����۶�`
-- 	,sum( sales) `���۶�`
    ,count(distinct case when name is not null and left(PayTime,7) = '2023-01' then spu end ) `1�³���Ԫ��Ʒspu��`
    ,count(distinct case when name is not null and left(PayTime,7) = '2023-02' then spu end ) `2�³���Ԫ��Ʒspu��`
    ,count(distinct case when name is not null and left(PayTime,7) = '2023-03' then spu end ) `3�³���Ԫ��Ʒspu��`
    ,count(distinct case when name is not null and MONTH(PayTime) <= 3  then spu end ) `Q1����Ԫ��Ʒspu��`
from od
join dim_new on od.boxsku = dim_new.boxsku 
group by grouping sets ((name),(name , site)) 
)

select od_stat.name `Ԫ������`
	,site `վ��` 
	,ele_stat.`��Ʒ��SPU��`
	,`1��Ԫ�����۶�` 
	,`2��Ԫ�����۶�` 
	,`3��Ԫ�����۶�` 
	,Q1Ԫ�����۶�
	
	,round(`1�³���Ԫ��Ʒspu��`/����1������SPU��,2) `1��SPU������`
	,round(`2�³���Ԫ��Ʒspu��`/����2������SPU��,2) `2��SPU������`
	,round(`3�³���Ԫ��Ʒspu��`/����3������SPU��,2) `3��SPU������`
	,round(`Q1����Ԫ��Ʒspu��`/����3������SPU��,2) `Q1SPU������`
	
	,round(`1��Ԫ�����۶�`/1�³���Ԫ��Ʒspu��,2) `1��SPU����`
	,round(`2��Ԫ�����۶�`/2�³���Ԫ��Ʒspu��,2) `2��SPU����`
	,round(`3��Ԫ�����۶�`/3�³���Ԫ��Ʒspu��,2) `3��SPU����`
	,round(`Q1Ԫ�����۶�`/Q1����Ԫ��Ʒspu��,2) `Q1SPU����`

from od_stat
left join ele_stat on ele_stat.name = od_stat.name
WHERE od_stat.name is not null
