
with
prod as (
select SKU ,SPU , BoxSku ,DATE(DevelopLastAuditTime) ��������
,year(DevelopLastAuditTime) �������
,ProductName
,Cat1 ,Cat2 ,Cat3 ,Cat4 ,Cat5
,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ProductStatus
,TortType
from wt_products wp
where ProjectTeam='��ٻ�' and CategoryPathByChineseName regexp 'A3���ְ���>A3������Ʒ' and IsDeleted = 0
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku
)

,od as (
select wo.BoxSku ,wo.Product_Sku as sku  ,wo.Product_SPU as SPU ,TotalGross ,FeeGross,ExchangeUSD ,salecount ,PayTime ,nodepathname
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code
where wo.IsDeleted = 0
	and OrderStatus !='����' and TransactionType = '����' -- S1���۶�
	and ms.Department  = '��ٻ�' and PayTime>'2020-01-01'
)

,t_od_stat as (
select
	sku ,boxsku ,spu
    ,year(paytime) �������
    ,month(paytime) �����·�
    ,sum(salecount) ����
    ,round(sum(TotalGross/ExchangeUSD  ),2) ���۶�
    ,round(sum( (TotalGross-FeeGross)/ExchangeUSD  ),2) �����˷����۶�
from od
group by sku ,boxsku ,spu ,������� ,�����·�
)

select t2.������� ,t2.�����·� ,t1.* ,t3.ele_name
     ,���� ,���۶� ,�����˷����۶�
from prod t1
left join t_od_stat t2 on t1.sku =t2.sku
left join t_elem t3 on t1.sku =t3.sku
order by  t1.sku ,t2.������� ,t2.�����·�


