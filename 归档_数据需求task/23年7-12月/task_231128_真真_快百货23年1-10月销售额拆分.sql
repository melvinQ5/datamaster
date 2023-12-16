
-- 1128�棺����ٻ������˺Ż�ȡ������¼��������������¼�еĲ�Ʒ���л���
with od as (
select
round(TotalGross/ExchangeUSD,2) sales
,case when epp.CreationTime >= '2023-01-01' then '23����Ӳ�Ʒ'
    when epp.CreationTime < '2023-01-01' and ProductStatus = 0 then '23��֮ǰ����ҵ�ǰ������Ʒ'
    when epp.CreationTime < '2023-01-01' and ProductStatus != 0 then '23��֮ǰ����ҵ�ǰ��������Ʒ' else '23��֮ǰ����ҵ�ǰ��������Ʒ' end ������Ʒ���
,wo.BoxSku,epp.spu
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�'
left join erp_product_products epp on epp.BoxSKU = wo.boxsku and IsMatrix=0  and epp.IsDeleted=0
where
	settlementtime >= '2023-01-01' and settlementtime < '2023-11-01'  and wo.IsDeleted=0
)

select ������Ʒ��� ,round(sum(sales),2) ���۶�usd ,count( distinct spu ) ����spu��
from od
group by ������Ʒ���;

-- 1129�棺����ٻ�����ERP��Ʒ��ȥ��ȡ������¼����������������¼�����е��̹���������
with od as (
select
round(TotalGross/ExchangeUSD,2) sales_usd
,round(TotalGross,2) sales
,case when epp.CreationTime >= '2023-01-01' then '23����Ӳ�Ʒ'
    when epp.CreationTime < '2023-01-01' and ProductStatus = 0 then '23��֮ǰ����ҵ�ǰ������Ʒ'
    when epp.CreationTime < '2023-01-01' and ProductStatus != 0 then '23��֮ǰ����ҵ�ǰ��������Ʒ' else '23��֮ǰ����ҵ�ǰ��������Ʒ' end ������Ʒ���
,wo.BoxSku,epp.spu
from import_data.wt_orderdetails wo
join erp_product_products epp on epp.BoxSKU = wo.boxsku and IsMatrix=0  and epp.IsDeleted=0 and epp.projectteam = '��ٻ�' and epp.CreationTime < '2023-11-01'
where
	settlementtime >= '2023-01-01' and settlementtime < '2023-11-01'  and wo.IsDeleted=0
)

,od_stat as (
select ������Ʒ��� ,round(sum(sales_usd),2) ���۶�usd ,round(sum(sales),2) ���۶�cny  ,count( distinct spu ) ����spu��
from od
group by ������Ʒ��� )

select * from od_stat