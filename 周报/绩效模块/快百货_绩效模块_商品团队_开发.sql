
with
t_prod as ( -- 23��3��1����������
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, vr.department
 	, vr.NodePathName
 	, vr.dep2
from import_data.erp_product_products epp
left join 
	( select case when name in ('������','����2') then '��ٻ�һ��' else split(NodePathNameFull,'>')[2] end as dep2 -- ������Э����Ʒ��������Ʒ����Ա
		,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName
		,name ,department
	from view_roles 
	where ProductRole ='����' 
-- 	and NodePathName in ('��η�-��Ʒ��','���Ԫ-��Ʒ��','��Ʒ��')
	) vr on epp.DevelopUserName = vr.name
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-03-01' and date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) < '2023-07-01' 
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='��ٻ�' 
	and epp.DevelopUserName != '���'
)

-- select count(distinct SPU ) from t_prod where DevelopUserName = '���ξ�'
-- ����������� ��ƷSPU�� �����յ� view_rolesӰ��

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,wo.BoxSku 
	,PayTime
	,timestampdiff(SECOND,t_prod.DevelopLastAuditTime,PayTime)/86400 as ord_days 
	, timestampdiff(SECOND,spu_min_paytime,PayTime)/86400 as ord_days_since_od 
	,t_prod.Department
	,t_prod.dep2 
	,t_prod.NodePathName 
	,t_prod.DevelopUserName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_prod on wo.boxsku = t_prod.boxsku 
left join ( select Product_SPU , min(PayTime) as spu_min_paytime 
	from import_data.wt_orderdetails  od1
	join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
	and ms1.Department ='��ٻ�' and PayTime >= '2023-03-01' and PayTime < '2023-07-01' -- Ϊ�����׵�30�� 
	where TransactionType = '����'  and OrderStatus <> '����' and OrderTotalPrice > 0 
	group by Product_SPU
	) tmp_min on wo.Product_SPU =tmp_min.Product_SPU 
where 
	PayTime >= '2023-04-01' and PayTime < '2023-07-01' and wo.IsDeleted=0 
	and ms.Department = '��ٻ�'
)

-- select * from t_orde where dep2 is null 


,t_prod_q2_stat as (
select 
	'��ٻ�' �Ŷ�
	,'' ��Ա
	,count(distinct spu) 4��������ƷSPU��
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
union all
select
	dep2  �Ŷ�
	,'' ��Ա
	,count(distinct spu) 4��������ƷSPU��
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
group by dep2
union all
select
	case when NodePathName is null then '֧Ԯ�Ŷ�' else NodePathName end  �Ŷ�
	,'' ��Ա
	,count(distinct spu) 4��������ƷSPU��
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
group by NodePathName
union all 
select
	case when NodePathName is null then '֧Ԯ�Ŷ�' else NodePathName end  �Ŷ�
	,DevelopUserName ��Ա
	,count(distinct spu) 4��������ƷSPU��
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
group by NodePathName,DevelopUserName
)

,t_od_q2_stat as (
select 
	'��ٻ�' �Ŷ�
	,'' ��Ա
	,round(sum(TotalGross/ExchangeUSD)) Q2_��Ʒҵ��
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU�׵�30�����۶�
from t_orde 
union all
select
	dep2 �Ŷ�
	,'' ��Ա
	,round(sum(TotalGross/ExchangeUSD)) Q2_��Ʒҵ��
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU�׵�30�����۶�
from t_orde 
group by dep2
union all
select
	case when NodePathName is null then '֧Ԯ�Ŷ�' else NodePathName end  �Ŷ�
	,'' ��Ա
	,round(sum(TotalGross/ExchangeUSD)) Q2_��Ʒҵ��
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU�׵�30�����۶�
from t_orde 
group by NodePathName
union all 
select
	case when NodePathName is null then '֧Ԯ�Ŷ�' else NodePathName end  �Ŷ�
	,DevelopUserName ��Ա
	,round(sum(TotalGross/ExchangeUSD)) Q2_��Ʒҵ��
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU�׵�30�����۶�
from t_orde 
group by NodePathName,DevelopUserName
)

,t_new_spu_sale_in14d as ( -- ��������������14�����ϵĵ�SPU, 4��15�Ųſ�ʼͳ�����ָ��
select 
	'��ٻ�' �Ŷ�
	,'' ��Ա
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_����14��SPU������`
from ( select wp.SPU from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU ) entire_spu  -- ����spu
left join ( -- ����spu
	select SPU 
	from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SPU  
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU

union all 
select 
	entire_spu.dep2 �Ŷ�
	,'' ��Ա
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_����14��SPU������`
from ( select wp.SPU,dep2 from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU,dep2 ) entire_spu  -- ����spu
left join ( -- ����spu
	select SPU ,dep2 from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by  SPU ,dep2
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU and entire_spu.dep2 = part_SPU.dep2
group by entire_spu.dep2

union all 
select 
	case when entire_spu.NodePathName is null then '֧Ԯ�Ŷ�' else entire_spu.NodePathName end  �Ŷ�
	,'' ��Ա
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_����14��SPU������`
from ( select wp.SPU,NodePathName from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU,NodePathName ) entire_spu  -- ����spu
left join ( -- ����spu
	select SPU ,NodePathName from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by  SPU ,NodePathName
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU and entire_spu.NodePathName = part_SPU.NodePathName
group by entire_spu.NodePathName

union all 
select 
	case when entire_spu.NodePathName is null then '֧Ԯ�Ŷ�' else entire_spu.NodePathName end  �Ŷ�
	,entire_spu.DevelopUserName ��Ա
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_����14��SPU������`
from ( select wp.SPU,NodePathName ,DevelopUserName from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU,NodePathName,DevelopUserName ) entire_spu  -- ����spu
left join ( -- ����spu
	select SPU ,NodePathName ,DevelopUserName from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by  SPU ,NodePathName ,DevelopUserName
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU and entire_spu.NodePathName = part_SPU.NodePathName 
		and entire_spu.DevelopUserName = part_SPU.DevelopUserName
group by entire_spu.NodePathName,entire_spu.DevelopUserName
)

select 
	case 
		when ta.�Ŷ� = '��ٻ�' then 1 
		when ta.�Ŷ� = '��ٻ�һ��' then 2  
		when ta.�Ŷ� = '��ٻ�����' then 3 
		when ta.�Ŷ� = '���Ԫ-��Ʒ��' and  ta.��Ա = '' then 4
		when ta.�Ŷ� = '��η�-��Ʒ��' and  ta.��Ա = '' then 5
		when ta.�Ŷ� = '�����-��Ʒ��' and  ta.��Ա = '' then 6
		when ta.�Ŷ� = '֧Ԯ�Ŷ�' and  ta.��Ա = '' then 7
		when ta.�Ŷ� = '���Ԫ-��Ʒ��' and  ta.��Ա != '' then 8
		when ta.�Ŷ� = '��η�-��Ʒ��' and  ta.��Ա != '' then 9
		when ta.�Ŷ� = '�����-��Ʒ��' and  ta.��Ա != '' then 10
		when ta.�Ŷ� = '֧Ԯ�Ŷ�' and  ta.��Ա != '' then 11
	end as ����
	,ta.* 
	,Q2_��Ʒҵ��
	,Q2_SPU�׵�30�����۶�
	,Q2_����14��SPU������
from t_prod_q2_stat ta 
left join t_od_q2_stat tb on ta.�Ŷ� = tb.�Ŷ� and ta.��Ա = tb.��Ա
left join t_new_spu_sale_in14d tc on ta.�Ŷ� = tc.�Ŷ� and ta.��Ա = tc.��Ա
order by ����