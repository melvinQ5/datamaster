

-- ��ٻ�����SPU
with 
t_list as (
select spu, sku,markettype as site,NodePathName ,department ,dep2
,ms.CompanyCode,SellUserName,date(publicationdate) publicationdate
, sellersku,shopcode,asin
,ShopStatus as ����״̬ ,  case when ListingStatus = 1 then '����' when ListingStatus = 5 then '��ɾ��' end as ����״̬
from erp_amazon_amazon_listing eaal 
join ( select case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '��ٻ�'
    and ShopStatus='����'
    and listingstatus=1
	and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
)

,online_spu as (
select spu, group_concat(listing_info) listing_info
from (select spu, concat('[����SKU:',SellerSKU,'  ���ߵ���:',shopcode,'  ��ѡҵ��Ա:',SellUserName,']') as listing_info
      from t_list
      group by spu, ShopCode, SellUserName ,SellerSKU) t
group by spu
)

,prod as ( -- ���ڶ��״̬
select spu
    ,case when ProductStatus = 0 then '����'
		when ProductStatus = 2 then 'ͣ��'
		when ProductStatus = 3 then 'ͣ��'
		when ProductStatus = 4 then '��ʱȱ��'
		when ProductStatus = 5 then '���'
		end as ��Ʒ״̬
	,case when status = 10 then '�������' when status = 20 then '����' when status =0 then '������' end ����״̬
from erp_product_products epp where ismatrix = 1 and IsDeleted = 0 and ProjectTeam = '��ٻ�'
)



,online_stat_by_spu as (
SELECT
	t_list.spu as ����SPU
	, ��Ʒ״̬
	, ����״̬
    ,case when ����״̬ ='�������' then '��ͨ��Ʒ��' when ����״̬ ='������' then '��Ʒ�����б�' when ����״̬ ='����' then '����ʾ' end as erp��Ʒ��
	,count(distinct case when dep2='��ٻ��ɶ�' then CompanyCode end ) ��ٻ��ɶ������˺���
	,count(distinct case when dep2='��ٻ�Ȫ��' then CompanyCode end ) ��ٻ�Ȫ�������˺���
	,count(distinct CompanyCode ) ��ٻ������˺���
	,count(distinct concat(SellerSKU,ShopCode) ) ��ٻ�����������
    , CURRENT_DATE() ���ݸ�������
from t_list
left join prod
 on t_list.spu = prod.spu
group by t_list.spu ,��Ʒ״̬ ,����״̬
)

,online_stat as (
select
    count( case when ��ٻ������˺��� > 6 then ����SPU end ) as ��6��SPU��
from online_stat_by_spu
)

,dev_stat as (
select
    count(distinct case when ��Ʒ״̬ not regexp 'ͣ��|ͣ��' and ����״̬ = '�������' then spu end ) ��ͣ��ͣ��SPU��
from prod
)

, res1_rate as (
select ��6��SPU�� ,��ͣ��ͣ��SPU�� ,round(��6��SPU��/��ͣ��ͣ��SPU��,4) ��6��SPUռ�� from dev_stat,online_stat
)

, res2_detail as ( -- ͣ��ͣ�������ߵ�SPU
select date(now()) ���ݲ�ѯ���� ,p.*
     ,��ٻ������˺���
     ,��ٻ��ɶ������˺���
     ,��ٻ�Ȫ�������˺���
     ,��ٻ����������� ,os.listing_info ������������
from online_spu os
join prod p on os.SPU = p.spu  and p.��Ʒ״̬ regexp 'ͣ��|ͣ��'
left join online_stat_by_spu osbs on os.SPU = osbs.����SPU
order by ��ٻ�����������
)

-- select * from res1_rate
-- select * from res2_detail

select t_list.spu, ShopCode, SellUserName ,SellerSKU ,NodePathName ,dep2
from t_list
join prod p on t_list.SPU = p.spu  and p.��Ʒ״̬ regexp 'ͣ��|ͣ��'
group by t_list.spu, ShopCode, SellUserName ,SellerSKU ,NodePathName ,dep2
