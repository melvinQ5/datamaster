

/*
 1-6����Ҫ���⣨ʥ������˽ڣ���ի�ڡ�����ڣ�԰�ա��ļ������⣩��ҵ�������������ʣ���滨�������������Ʒ�ڵ��µ�ҵ���ܶ �������SKU��Ӧƽ��������
 
 */


with 
newpp as (select sku ,spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01' 
    and ProjectTeam = '��ٻ�' )
    
, r1 as ( -- ��Ʒ������
select left('${StartDay}',7)  ͳ���·�
	,round( count(distinct concat(SellerSKU,ShopCode)) / count(distinct wl.sku) ,4 ) ������Ʒsku�����¿���ƽ��������
from wt_listing wl 
join ( select eppaea.sku , GROUP_CONCAT( eppea.name ) ele_name 
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name ='${ele_name}'
	group by sku ) tag on wl.sku = tag.sku
join newpp on wl.spu = newpp.spu -- 23������������Ʒ
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	from import_data.mysql_store where department regexp '��' )  ms 
	on wl.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
where MinPublicationDate  >= '${StartDay}' and MinPublicationDate < '${NextStartDay}'
)

, r2 as (
select left('${StartDay}',7)  ͳ���·� , '${ele_name}' as ele_name
	,round(sum(TotalGross/ExchangeUSD),2) �������۶�
    ,round(sum(TotalProfit/ExchangeUSD),2) ���������
    ,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),4) ����������_δ�۹��
    ,round(sum( case when newpp.sku is not null then TotalGross/ExchangeUSD end ),2) ������Ʒ���۶�
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	from import_data.mysql_store where department regexp '��' )  ms 
	on wo.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
join ( select eppaea.sku 
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name ='${ele_name}'
	group by sku ) tag on wo.Product_SKU = tag.sku
left join newpp on wo.Product_SKU = newpp.sku
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.department regexp '��'
group by left('${StartDay}',7) , ele_name
)


select r1.ͳ���·� , '${ele_name}' as ����
	,�������۶�
	,���������
	,����������_δ�۹��
	,������Ʒ���۶�
	,������Ʒsku�����¿���ƽ�������� 
from r1 
left join r2 on r1.ͳ���·� = r2.ͳ���·�



