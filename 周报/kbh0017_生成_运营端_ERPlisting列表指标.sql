
insert into dep_kbh_listing_level_details ( MarkDate ,asin ,ShopCode ,sellersku ,ListingId
    ,`ListLevel`
    ,`OldListLevel`
    ,`MinPublicationDate`
    ,`site`
    ,`AccountCode`
    ,`NodePathName`
    ,`SellUserName`

    ,`salescountInt1`
    ,`SalesCountInt2`
    ,`SalesCountInt3`
    ,`SalesCountIn1w`
    ,`SalesCountIn2w`
    ,`SalesCountIn30d`
    ,`SalesCountIn90d`

    ,`ExposureInt2`
    ,`ExposureInt3`
    ,`ExposureInt4`
    ,`ExposureIn1w`
    ,`ExposureIn2w`

    ,`ClicksInt2`
    ,`ClicksInt3`
    ,`ClicksInt4`
    ,`ClicksIn1w`
    ,`ClicksIn2w`

    ,`AdSpendInt2`
    ,`AdSpendInt3`
    ,`AdSpendInt4`
    ,`AdSpendIn1w`
    ,`AdSpendIn2w`
    ,`BoxSku`
    ,`SPU`
    ,`SKU`
    ,`wttime`
 )

with
lst as ( -- ��30���������������
select  dkll .*
from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay =  date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2 week) -- ����һ�ټ�7�����嵥�洢��firstday
	-- and dkll.Department = '��ٻ��ɶ�'
)
-- select * from lst where asin ='B07V8FFXT7' and site = 'ES'

,lst_1 as ( -- ����
select  distinct asin ,site ,list_level as mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-2 week)
)

,lst_2 as (  -- ������
select  distinct asin ,site ,list_level as mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-2 week)
)

,lst_3 as ( -- ������
select  distinct asin ,site ,list_level as mark_3 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-2 week)
)

, od_list_in30d as ( -- ���ӷֲ�����Ϊasin+site���ҵ���Ӧ��С����
select distinct wo.site,asin,boxsku,Product_Sku as sku,shopcode,ms.AccountCode,SellerSku,SellUserName,NodePathName,dep2 ,date(wo.PublicationDate)  PublicationDate
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
where PayTime >=  date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1), INTERVAL -30 DAY) and PayTime<  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
    and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' and ms.department regexp '��'
)



-- select * from od_list_in30d where  asin ='B0C5C83VQ9'  ;

, listings as ( -- ��С����
select
     lst.asin
     , oli.shopcode
     , oli.SellerSku
     , lst.FirstDay as ͳ���ܵ���һ
     -- , week as ����
     , dep2 as �Ŷ�
     , case when list_level = 'ɢ��' then '����' else list_level end as list_level
     , lst.site
     , oli.PublicationDate
     , oli.AccountCode
     , oli.SellUserName
     , oli.NodePathName
     , ListingStatus as ����״̬
     , sales_no_freight as ��30�첻���˷����۶�
     , sales_in30d ��30�����۶�
     , profit_in30d ��30�������
     , list_orders ��30�충����
     , prod_level
     , oli.BoxSku
     , lst.spu
     , oli.sku
     , lst.ProductStatus as ��Ʒ״̬
     , lst.isnew as ����Ʒ״̬
     , lst.ele_name as Ԫ��
     , wp.ProductName
     , date(wp.DevelopLastAuditTime) ����ʱ��
     , lst.wttime as ����ͳ��ʱ��
     -- ,od.code �ϰ������ӵ���top1���̼���, od.SellUserName ��ѡҵ��Ա
from lst
left join  od_list_in30d oli on lst.asin = oli.asin and lst.site = oli.site
left join (select distinct spu, productname ,DevelopLastAuditTime from wt_products where ProjectTeam='��ٻ�' and IsDeleted=0) wp on lst.spu = wp.spu
-- left join wt_listing wl on lst.asin =wl.asin and lst.site =wl.MarketType
-- left join od on od.asin = lst.asin and od.site =lst.site and od.spu =lst.spu
where oli.SellerSku is not null
)



, od as (
select asin,wo.SellerSku,wo.shopcode
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 1 day ) and PayTime< '${NextStartDay}' then SaleCount end ) T_1����
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 2 day ) and PayTime< date_add('${NextStartDay}',interval - 1 day ) then SaleCount end ) T_2����
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 3 day ) and PayTime< date_add('${NextStartDay}',interval - 2 day ) then SaleCount end ) T_3����
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 1 week ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) ��1������
     ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 2 week ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) ��2������
    ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 30 day ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) ��30������
    ,SUM( case when PayTime >=date_add('${NextStartDay}',interval - 90 day ) and PayTime< date_add('${NextStartDay}',interval - 0 day ) then SaleCount end ) ��90������
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
and PayTime >= date_add('${NextStartDay}',interval - 90 day ) and PayTime < '${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '����'  and asin <>'' and ms.department regexp '��'
  -- and  NodePathName regexp '�ɶ�'
group by asin,wo.SellerSku,wo.shopcode
)

, ad as (
select od.asin,od.SellerSku,od.shopcode
    ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 day ) and createdtime< date_add('${NextStartDay}',interval - 1 day )  then Exposure end ),0) `T_2�ع�`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 3 day ) and createdtime< date_add('${NextStartDay}',interval - 2 day ) then Exposure end ),0) `T_3�ع�`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 4 day ) and createdtime< date_add('${NextStartDay}',interval - 3 day ) then Exposure end ),0) `T_4�ع�`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 1 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then Exposure end ),0) ��1���ع�
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then Exposure end ),0) ��2���ع�

    ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 day ) and createdtime< date_add('${NextStartDay}',interval - 1 day )  then clicks end ),0) `T_2���`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 3 day ) and createdtime< date_add('${NextStartDay}',interval - 2 day ) then clicks end ),0) `T_3���`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 4 day ) and createdtime< date_add('${NextStartDay}',interval - 3 day ) then clicks end ),0) `T_4���`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 1 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then clicks end ),0) ��1�ܵ��
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then clicks end ),0) ��2�ܵ��

    ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 day ) and createdtime< date_add('${NextStartDay}',interval - 1 day )  then spend end ),0) `T_2��滨��`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 3 day ) and createdtime< date_add('${NextStartDay}',interval - 2 day ) then spend end ),0) `T_3��滨��`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 4 day ) and createdtime< date_add('${NextStartDay}',interval - 3 day ) then spend end ),0) `T_4��滨��`
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 1 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then spend end ),0) ��1�ܹ�滨��
     ,ifnull(SUM( case when createdtime >=date_add('${NextStartDay}',interval - 2 week ) and createdtime< date_add('${NextStartDay}',interval - 0 day ) then spend end ),0) ��2�ܹ�滨��

from import_data. AdServing_Amazon asa
join mysql_store ms on asa.shopcode=ms.Code and ms.department regexp '��'
join od on asa.ShopCode = od.ShopCode and asa.SellerSKU = od.SellerSKU and asa.Asin =od.Asin
and CreatedTime >= date_add('${NextStartDay}',interval - 90 day ) and CreatedTime < '${NextStartDay}'
group by od.asin,od.SellerSku,od.shopcode
)

,add_listing_id as (
select wl.id ,t.asin  ,t.shopcode ,t.SellerSku
from  listings t
left join (select asin, shopcode, sellersku ,id from  erp_amazon_amazon_listing group by asin, shopcode, sellersku ,id ) wl
on t.asin = wl.asin and t.ShopCode=wl.ShopCode and t.SellerSKU=wl.SellerSKU
order by wl.asin ,wl.shopcode ,wl.sellersku
)

-- select * from ad;
, res as (
select
    date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1 week) as  �����ǩ����
    ,l.asin
    ,l.shopcode
    ,l.sellersku ����SKU
    ,ali.id
    ,list_level as ��ǰ���ӱ�ǩ
    ,concat(ifnull(mark_1,'��'),'-',ifnull(mark_2,'��'),'-',ifnull(mark_3,'��'))  ��ʷ���ӱ�ǩ
    ,date(l.PublicationDate) �״ο���ʱ��
    ,l.site
    ,l.AccountCode
    ,l.NodePathName
    ,l.SellUserName
    ,ifnull(od.T_1����,0)
    ,ifnull(od.T_2����,0)
    ,ifnull(od.T_3����,0)
    ,ifnull(od.��1������,0)
    ,ifnull(od.��2������,0)
    ,ifnull(od.��30������,0)
    ,ifnull(od.��90������,0)
    ,ifnull(ad.T_2�ع�,0) ,ifnull(ad.T_3�ع�,0) ,ifnull(ad.T_4�ع�,0) ,ifnull(ad.��1���ع�,0) ,ifnull(ad.��2���ع�,0)
    ,ifnull(ad.T_2���,0) ,ifnull(ad.T_3���,0) ,ifnull(ad.T_4���,0) ,ifnull(ad.��1�ܵ��,0) ,ifnull(ad.��2�ܵ��,0)
    ,ifnull(ad.T_2��滨��,0) ,ifnull(ad.T_3��滨��,0) ,ifnull(ad.T_4��滨��,0) ,ifnull(ad.��1�ܹ�滨��,0) ,ifnull(ad.��2�ܹ�滨��,0)
    ,l.BoxSku
    ,l.spu
    ,l.sku
    ,now()
from listings l
left join od on  l.ShopCode = od.ShopCode and l.SellerSKU = od.SellerSKU and l.Asin =od.Asin
left join ad on  l.ShopCode = ad.ShopCode and l.SellerSKU = ad.SellerSKU and l.Asin =ad.Asin
left join lst_1 on l.site = lst_1.site  and l.Asin =lst_1.Asin
left join lst_2 on l.site = lst_2.site  and l.Asin =lst_2.Asin
left join lst_3 on l.site = lst_3.site  and l.Asin =lst_3.Asin
left join add_listing_id ali on l.ShopCode = ali.ShopCode and l.SellerSKU = ali.SellerSKU and l.Asin =ali.Asin
)

select * from res;

