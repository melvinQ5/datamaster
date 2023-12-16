
-- ��ٻ�����SPU
with
t_list as (
select spu, sku, sellersku,shopcode,asin,markettype as site,NodePathName ,department ,dep2
,ms.CompanyCode,SellUserName,date(publicationdate) publicationdate
from erp_amazon_amazon_listing eaal
join ( select case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '��ٻ�' and ShopStatus='����' and listingstatus=1
	and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
)

,online_spu as (
select spu, group_concat(shopcode) shopcode, group_concat(SellUserName) SellUserName
from (select spu, ShopCode, SellUserName
      from t_list
      group by spu, ShopCode, SellUserName) t
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


-- select p.* from online_spu os join prod p on os.SPU = p.spu  and p.ProductStatus regexp 'ͣ��|ͣ��'


SELECT
	t_list.spu as ����SPU
	,��Ʒ״̬
	,����״̬
    ,case when ����״̬ ='�������' then '��ͨ��Ʒ��' when ����״̬ ='������' then '��Ʒ�����б�' when ����״̬ ='����' then '����ʾ' end as erp��Ʒ��
    ,tag �ſ����Ʒ��ǩ
	,count(distinct case when dep2='��ٻ��ɶ�' then CompanyCode end ) ��ٻ��ɶ������˺���
	,count(distinct case when dep2='��ٻ�Ȫ��' then CompanyCode end ) ��ٻ�Ȫ�������˺���
	,count(distinct CompanyCode ) ��ٻ������˺���
    , CURRENT_DATE() ���ݸ�������
from t_list
left join prod on t_list.spu = prod.spu
left join (
        select spu , group_concat(tag ) tag
       from (
            select distinct spu , unique_brand_shop as tag from dep_kbh_product_test where unique_brand_shop ='һ��һ��Ʒ'
            union select distinct spu ,ispotenial as tag from dep_kbh_product_test where ispotenial ='��ǱƷ'
            ) dkpt group by spu
           ) t
    on t_list.spu = t.spu
group by t_list.spu ,��Ʒ״̬ ,����״̬  ,t_list.department ,tag
order by ��ٻ������˺��� desc



