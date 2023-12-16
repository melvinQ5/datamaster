
with 
ele as ( 
select eppaea.sku ,group_concat(eppea.name) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.name = '�ļ�'
group by eppaea.sku 
)


, od as (
select wo.BoxSku
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) ��7������
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) ��14������
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) ��21������
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) ��28������

     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2) ��7�����۶�
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2) ��14�����۶�
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2) ��21�����۶�
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2)
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) ��7�������
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) ��14�������
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) ��21�������
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) ��28�������

     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) ��7��������
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) ��14��������
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) ��21��������
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) ��28��������
    from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
and SettlementTime  >= date_add('${NextStartDay}',interval - 90 day ) and SettlementTime < '${NextStartDay}' and wo.IsDeleted=0
    and asin <>'' and ms.department regexp '��'
    and FeeGross = 0
group by  wo.BoxSku
)

-- �ļ�

select wp.sku ,wp.ProductName ,ele.ele_name ,od.*
from wt_products wp
join ele  on wp.sku =ele.sku
left join od on od.BoxSku =wp.BoxSku


-- ���ļ�  7��29�ղ�ѯ
/*
select wp.sku ,wp.ProductName ,ele.ele_name ,od.*
-- select count(1)
from wt_products wp
left join ele  on wp.sku =ele.sku
left join od on od.BoxSku =wp.BoxSku
where ele.sku is null and wp.ProjectTeam='��ٻ�' and wp.IsDeleted= 0 and ProductStatus !=2

 */