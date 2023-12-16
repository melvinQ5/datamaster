-- ���Ԫ�������ڿ��Ԫ�ɶ��Ŀ��ǣ����ԪȪ�ݵĿ��ǣ��ֿ����˵�
-- ������������һ�����Ǽ�¼��sku ռ��


with 
-- step1 ����Դ����
de as ( -- 
select case when sku = '����' then '����1688' else sku end  as name ,boxsku as department,spu as dep2 
from JinqinSku js where Monday= '2023-03-31' and spu in ('���Ԫ��Ʒ��','��η���Ʒ��','��Ʒ��')
)

,t_prod as ( 
select spu 
	,left(de.dep2,3) as  dev_dep
	,DevelopUserName
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products epp 
left join de on epp.DevelopUserName = de.name 
where IsDeleted =0 and IsMatrix = 1 and ProjectTeam = '��ٻ�'
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour) >= '${StartDay}' and DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}' 
)

,t_list as ( -- ����ʱ����2��1������
select wl.spu ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
	,ms.NodePathName 
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code  
where 
	PublicationDate>= '${StartDay}' 
	and PublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
)

,t_min_list as (
select 
	round(timestampdiff(second,`����ʱ��`,`�״ο���ʱ��` )/86400,2) as `������ʱ��������`
	,tb.*
from (
	select t_prod.SPU 
		,t_prod.dev_dep `�����Ŷ�`
		, NodePathName `�����Ŷ�`
		,DevelopLastAuditTime `����ʱ��`
		,t_prod.DevelopUserName `������Ա`
		,min(PublicationDate) as  `�״ο���ʱ��` 
	from t_prod
	left join  t_list on t_list.spu = t_prod.spu
	where t_list.spu is not null 
	group by  t_prod.SPU ,t_prod.dev_dep , NodePathName ,DevelopLastAuditTime ,t_prod.DevelopUserName
	order by  t_prod.SPU
	) tb 
)
-- ��ϸ
select * from t_min_list

select 
	'���Ԫ-Ȫ��������' `������`
	,count(distinct case when `�����Ŷ�` = '���Ԫ-Ȫ��������' and `�����Ŷ�` = '���Ԫ' and `������ʱ��������` < 86400*2 then spu end ) `���SPU��`
	,count(distinct case when `�����Ŷ�` = '���Ԫ' then spu end ) `��Ӧ�����Ŷ���ƷSPU��`
	,round(count(distinct case when `�����Ŷ�` = '���Ԫ-Ȫ��������' and `�����Ŷ�` = '���Ԫ' and `������ʱ��������` < 86400*2 then spu end ) 
	/ count(distinct case when `�����Ŷ�` = '���Ԫ' then spu end ),4) `�����`
from t_min_list
union all 
select 
	'���Ԫ-�ɶ�������'
	,count(distinct case when `�����Ŷ�` = '���Ԫ-�ɶ�������' and `�����Ŷ�` = '���Ԫ' and `������ʱ��������` < 86400*2 then spu end )
	,count(distinct case when `�����Ŷ�` = '���Ԫ' then spu end ) 
	,round(count(distinct case when `�����Ŷ�` = '���Ԫ-�ɶ�������' and `�����Ŷ�` = '���Ԫ' and `������ʱ��������` < 86400*2 then spu end ) 
	/ count(distinct case when `�����Ŷ�` = '���Ԫ' then spu end ),4) 
from t_min_list
union all 
select 
	'��η�-Ȫ��������'
	,count(distinct case when `�����Ŷ�` = '��η�-Ȫ��������' and `�����Ŷ�` = '��η�' and `������ʱ��������` < 86400*2 then spu end ) 
	,count(distinct case when `�����Ŷ�` = '��η�' then spu end ) 
	,round(count(distinct case when `�����Ŷ�` = '��η�-Ȫ��������' and `�����Ŷ�` = '��η�' and `������ʱ��������` < 86400*2 then spu end ) 
	/ count(distinct case when `�����Ŷ�` = '��η�' then spu end ) ,4)
from t_min_list
union all 
select 
	'��η�-�ɶ�������'
	,count(distinct case when `�����Ŷ�` = '��η�-�ɶ�������' and `�����Ŷ�` = '��η�' and `������ʱ��������` < 86400*2 then spu end ) 
	,count(distinct case when `�����Ŷ�` = '��η�' then spu end ) 
	,round(count(distinct case when `�����Ŷ�` = '��η�-�ɶ�������' and `�����Ŷ�` = '��η�' and `������ʱ��������` < 86400*2 then spu end ) 
	/ count(distinct case when `�����Ŷ�` = '��η�' then spu end ) ,4)
from t_min_list

-- ,count(distinct case when `�����Ŷ�` = '���Ԫ-�ɶ�������' and `�����Ŷ�` = '���Ԫ' and `������ʱ��������` < 86400*2 then spu end ) 
-- 	/ count(distinct case when `�����Ŷ�` = '���Ԫ' then spu end ) `���Ԫ-�ɶ�������`
-- 	,count(distinct case when `�����Ŷ�` = '��η�-Ȫ��������' and `�����Ŷ�` = '��η�' and `������ʱ��������` < 86400*2 then spu end ) 
-- 	/ count(distinct case when `�����Ŷ�` = '��η�' then spu end ) `��η�-Ȫ��������`
-- 	,count(distinct case when `�����Ŷ�` = '��η�-�ɶ�������' and `�����Ŷ�` = '��η�' and `������ʱ��������` < 86400*2 then spu end ) 
-- 	/ count(distinct case when `�����Ŷ�` = '��η�' then spu end ) `��η�-�ɶ�������`

