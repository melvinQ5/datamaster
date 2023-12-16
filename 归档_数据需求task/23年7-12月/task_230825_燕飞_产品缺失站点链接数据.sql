/*
��Ʒ�˺�ȱʧ��������
վ�㷶Χ�� UK DE FR US CA ES IT MX
�˺ŷ�Χ����ٻ����д��ڵ���״̬='����'���˺�
��Ʒ��Χ�� ��ƷԪ�ذ�������ʥ�ڡ�ʥ���ڡ� �� �������ӵ�վ�㲻ȫ��SPU
�ֶΣ�Ԫ������ spu վ�� �����˺� �Ƿ�����������  asin sellersku
������̫����С�����������������ӵ�վ�㲻ȫ��SPU�����
 */


with
online_lst as ( -- ������������
select spu ,CompanyCode ,Site ,asin ,SellerSKU
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.ShopCode=ms.Code and ListingStatus=1 and ShopStatus='����' and Department='��ٻ�'
and IsDeleted=0
)

, unfull_spu as ( -- ����վ�㲻ȫ��SPU
select spu
from online_lst where site regexp 'UK|DE|FR|US|CA|ES|IT|MX'
group by spu HAVING count(distinct site) <8
)

,ele as ( -- Ԫ��ӳ�����С������ SKU+NAME
select spu ,group_concat(Name) ele_name
from (
    select eppaea.spu ,eppea.Name
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    where eppea.name regexp '��ʥ��|ʥ����'
    group by eppaea.spu ,eppea.Name
    ) t
group by spu
)

, wp as (
select epp.spu ,ele.ele_name  from erp_product_products epp
join ele on epp.SPU=ele.Spu and IsDeleted=0 and IsMatrix=1 and DevelopLastAuditTime is not null and ProjectTeam='��ٻ�'
)

, t_key as (
select wp.* ,ms.CompanyCode from wp
join ( select distinct CompanyCode from mysql_store where Department='��ٻ�' and ShopStatus='����') ms on 1=1
join unfull_spu usp on wp.spu = usp.spu
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

,banneds as (
select wp.spu , GROUP_CONCAT( channelsitecode ) AS banneds_site
from unfull_spu join wt_products wp on unfull_spu.spu = wp.SPU and wp.ProjectTeam='��ٻ�'
join ( SELECT productid,  channelsitecode
    FROM erp_product_product_banneds
    WHERE platformcode = 'Amazon'
    ) pb ON pb.productid = wp.id
group by wp.spu
)




, res as (
select
    t1.spu
    ,t1.ele_name as ��Ʒ����
    ,t2.seller_list as ��Ʒ��������
    ,t1.CompanyCode as �˺�
    ,banneds_site as �˺Ž���վ��
    ,'��' �Ƿ�����վ�㲻ȫ
    ,case when tuk.asin is not null then 'UK' end as ��UKվ
    ,case when tde.asin is not null then 'DE' end as ��DEվ
    ,case when tfr.asin is not null then 'FR' end as ��FRվ
    ,case when tus.asin is not null then 'US' end as ��USվ
    ,case when tca.asin is not null then 'CA' end as ��CAվ
    ,case when tes.asin is not null then 'ES' end as ��ESվ
    ,case when tit.asin is not null then 'IT' end as ��ITվ
    ,case when tmx.asin is not null then 'MX' end as ��MXվ

    ,tuk.asin as uk_asin
    ,tde.asin as de_asin
    ,tfr.asin as fr_asin
    ,tus.asin as us_asin
    ,tca.asin as ca_asin
    ,tes.asin as es_asin
    ,tit.asin as it_asin
    ,tmx.asin as mx_asin

    ,tuk.sellersku as uk_����sku
    ,tde.sellersku as de_����sku
    ,tfr.sellersku as fr_����sku
    ,tus.sellersku as us_����sku
    ,tca.sellersku as ca_����sku
    ,tes.sellersku as es_����sku
    ,tit.sellersku as it_����sku
    ,tmx.sellersku as mx_����sku
from t_key t1
left join prod_seller t2 on t1.SPU = t2.spu
left join banneds t3 on t1.SPU = t3.spu
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'UK' group by spu, CompanyCode ) tuk on t1.SPU = tuk.spu and t1.CompanyCode = tuk.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'DE' group by spu, CompanyCode ) tde on t1.SPU = tde.spu and t1.CompanyCode = tde.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'FR' group by spu, CompanyCode ) tfr on t1.SPU = tfr.spu and t1.CompanyCode = tfr.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'US' group by spu, CompanyCode ) tus on t1.SPU = tus.spu and t1.CompanyCode = tus.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'CA' group by spu, CompanyCode ) tca on t1.SPU = tca.spu and t1.CompanyCode = tca.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'ES' group by spu, CompanyCode ) tes on t1.SPU = tes.spu and t1.CompanyCode = tes.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'IT' group by spu, CompanyCode ) tit on t1.SPU = tit.spu and t1.CompanyCode = tit.CompanyCode
left join  (select spu ,CompanyCode, group_concat(asin) asin , group_concat(sellersku) sellersku from online_lst where site = 'MX' group by spu, CompanyCode ) tmx on t1.SPU = tmx.spu and t1.CompanyCode = tmx.CompanyCode
)

select * from res
-- select count(*) from res
-- select count(*) from t_key
