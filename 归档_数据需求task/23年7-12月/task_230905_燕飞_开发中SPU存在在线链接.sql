-- ��ٻ�����SPU
with
prod as (
select spu ,ProjectTeam ��Ʒ��ǰ��������
     ,case when IsDeleted = 1 then 'ɾ��' when IsDeleted = 0 then 'δɾ��' end ERP�Ƿ�ɾ����Ʒ
from erp_product_products epp where ismatrix = 1 and
spu in (
    1000616,
5141746,
5291798,
5190659,
5039086,
5131782,
1125989,
1125977,
5101824,
5116889,
5105691,
5097568,
5007080,
1005774,
5133239,
5087298,
5040261,
5216118,
5147050,
5099828,
5159506
  )
)

,t_list as (
select spu, sku, sellersku,shopcode,asin,markettype as site,NodePathName ,department ,dep2
,ms.CompanyCode,SellUserName,date(publicationdate) publicationdate
from erp_amazon_amazon_listing eaal
join ( select case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�' else NodePathName end as dep2 ,*
    from import_data.mysql_store ) ms
    on ms.code= eaal.shopcode and ms.department = '��ٻ�' and ShopStatus='����' and listingstatus=1
    and eaal.isdeleted=0
	and sku<>'' -- 1 �ų�ĸ�����ӣ�2 �ų�δ����sku���ȴ���������ٴ���
)



SELECT
	a.sellersku
    ,a.shopcode
    ,a.asin
    ,a.dep2
    ,a.nodepathname
    ,b.*
from prod b left join t_list a
 on a.spu = b.spu

