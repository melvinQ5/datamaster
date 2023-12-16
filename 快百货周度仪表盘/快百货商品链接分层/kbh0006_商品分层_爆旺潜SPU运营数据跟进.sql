
with topsku as (
select distinct dkpl.spu , dkpl.prod_level ,date('${NextStartDay}') as  mark_date
from dep_kbh_product_level dkpl
where isdeleted = 0 and FirstDay ='${FirstDay}' and prod_level regexp '��|��|Ǳ��'
)

-- select * from topsku where spu =5260504

, pre_od_14 as ( -- �ۺϵ� spu+������Ա+վ��+sku ,����topվ��\topSKU
select *
   , row_number() over (partition by spu, dep2, SellUserName,site  order by sales_14 desc ) sku_sales_sort
from (
    select wo.Product_SPU as spu, wo.Product_Sku as sku, BoxSku, dep2, SellUserName, wo.Site
        , round(sum((totalgross)/ExchangeUSD), 2) sales_14
        , round(sum((totalgross-feegross)/ExchangeUSD), 2) sales_no_feegross_14
        , round(sum((totalprofit)/ExchangeUSD), 2) profit_14
    from wt_orderdetails wo
    join ( select case when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2, *
    from import_data.mysql_store where department regexp '��') s on s.code=wo.shopcode and s.department='��ٻ�'
    join topsku pp on pp.spu=wo.Product_SPU
    where wo.IsDeleted = 0 and TransactionType <> '����' and PayTime >= date (date_add(' ${NextStartDay}', INTERVAL -14 day)) and PayTime < ' ${NextStartDay}'
    group by wo.Product_SPU, wo.Product_Sku, wo.BoxSku, dep2, SellUserName, wo.Site
    ) t
)
-- select * from pre_od_14 where spu =1054487 order by spu, dep2, SellUserName,site ,sku_sales_sort

, top_sku_sort as (
select spu,dep2,SellUserName
     , group_concat( sku )  ���۶�TopSKU
    , group_concat( BoxSku )  ���۶�TopBoxSku
 from (
select *,row_number() over (partition by spu,dep2,SellUserName order by sales_14 desc  ) sku_sales_sort
from (select spu,dep2,SellUserName,sku ,boxsku
    ,sum( sales_14 ) sales_14
    from pre_od_14 group by spu,dep2,SellUserName,sku ,boxsku ) t
) t
where sku_sales_sort  = 1
group by spu,dep2,SellUserName
)

, top_site_sort as (
select spu,dep2,SellUserName
    , group_concat( case when site_sales_sort <= 3 then site end )  ���۶�Top3վ��
    , group_concat( case when sales_14 >= 80  then site end )  ���۶����80usdվ��
 from (
select *,row_number() over (partition by spu,dep2,SellUserName order by sales_14 desc  ) site_sales_sort
from (select spu,dep2,SellUserName,site
    ,sum( sales_14 ) sales_14
    ,sum( sales_no_feegross_14 ) sales_no_feegross_14
    ,sum( profit_14 ) profit_14
    from pre_od_14 group by spu,dep2,SellUserName,site) t
) t
group by spu,dep2,SellUserName
)

-- select * from top_site
-- order by spu,dep2,SellUserName ,sales_sort

 ,od_14 as ( -- �ۺϵ�spu+������Ա
select wo.spu ,dep2 ,SellUserName
     ,sum( sales_14 )  sales_14
     ,sum( sales_no_feegross_14 ) sales_no_feegross_14
     ,sum( profit_14 )  profit_14
from pre_od_14 wo group by wo.spu ,dep2 ,SellUserName
)

, refund_stat as (
select wo.Product_SPU as spu ,dep2 ,SellUserName
     ,round(sum((RefundAmount)/ExchangeUSD),2) refund_14
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  s on s.code=wo.shopcode and s.department='��ٻ�'
join topsku pp on pp.spu=wo.Product_SPU
where wo.IsDeleted = 0 and TransactionType = '�˿�' and SettlementTime >= date(date_add('${NextStartDay}',INTERVAL -14 day)) and SettlementTime < '${NextStartDay}'
group by wo.Product_SPU ,dep2 ,SellUserName
)

,od_30 as (
select wo.Product_SPU as spu ,dep2 ,SellUserName
     ,round(sum((totalgross)/ExchangeUSD),2) sales_30
     ,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_feegross_30
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  s on s.code=wo.shopcode and s.department='��ٻ�'
join topsku pp on pp.spu=wo.Product_SPU
where wo.IsDeleted = 0 and TransactionType <> '����' and PayTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and PayTime < '${NextStartDay}'
group by wo.Product_SPU ,dep2 ,SellUserName
)

, lst_ad_spend as ( -- ������SKU�ۺϼ�����ѣ���ֹ����������ӵĹ�滨�ѣ���Ҫ�����������ӵĹ�滨��
select SPU,dep2 ,SellUserName
     ,sum(Spend) AdSpend_in30d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then Spend end ) AdSpend_in14d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then Exposure end ) Exposure_in14d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then Clicks end ) Clicks_in14d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then TotalSale7DayUnit end ) ad_sales_in14d
from (select sellersku ,shopcode ,topsku.SPU
    from topsku join wt_listing on topsku.spu =wt_listing.spu
    group by  sellersku ,shopcode ,topsku.SPU ) wl
join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code
where CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
group by SPU ,dep2 ,SellUserName
)

, online_stat as ( -- �����˺� ��������
select spu ,dep2 ,SellUserName ,count(distinct CompanyCode) �����˺�����
    , count(distinct concat(SellerSKU,ShopCode)) ����������
from erp_amazon_amazon_listing eaal
join  ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��') ms on eaal.shopcode=ms.Code and eaal.ListingStatus = 1 and ms.ShopStatus = '����'
group by spu ,dep2 ,SellUserName
)

, sa_lst_stat as (
select spu ,SellUserName , case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2
     ,count(DISTINCT CONCAT(ASIN,SITE )) AS sa������
from dep_kbh_listing_level_details
where  ListLevel regexp 'S|A'
group by spu ,SellUserName ,NodePathName
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

, res as (
select
    concat(mark_date,a.spu,a.SellUserName) as ��id
    , mark_date ��ǩ��������
    , a.spu
    , prod_level as ��Ʒ�ֲ�
    , a.dep2 as �����Ŷ�
    , a.SellUserName as ��ѡҵ��Ա
    , case when locate(a.SellUserName,j.seller_list) >0  then '��' end as ��ѡ�Ƿ������۸�����
    , sales_30 as ���۶�_30��
    , sales_no_feegross_30 as ���˷����۶�_30��
    , round(sales_14,2)  as  ���۶�_14��
    , round(sales_no_feegross_14,2) as ���˷����۶�_14��
    , ifnull(����������,0) ����������
    , ifnull(�����˺�����,0) �����˺�����
    , ifnull(SA������,0) SA������  -- ��SPU��10��SA���ӣ�������������3��
    , ifnull( AdSpend_in14d,0 ) as ��滨��_14��
    , round( ifnull(AdSpend_in14d,0) / sales_14 ,2 ) as ��滨��ռ��_14��
    , round( ifnull(refund_14,0) / sales_14 ,2 ) as �˿���_14��
    , round( (profit_14 - ifnull(AdSpend_in14d,0))  / sales_14 ,2) �۹��������_14��
    , Exposure_in14d as SPU�ع���_14��
    , Clicks_in14d as  SPU�����_14��
    , round( Clicks_in14d / Exposure_in14d ,4 ) as SPU�����_14��
    , round( ad_sales_in14d / Clicks_in14d ,4 ) as SPUת����_14��
    , ���۶�Top3վ��
    , ���۶����80usdվ��
    , ���۶�TopSKU
    , ���۶�TopBoxSku
from topsku t1
left join od_30 a on t1.SPU = a.spu
left join od_14 b on a.spu =b.spu and a.SellUserName = b.SellUserName and a.dep2 = b.dep2
left join top_site_sort f on a.spu =f.spu and a.SellUserName = f.SellUserName and a.dep2 = f.dep2
left join lst_ad_spend c on a.spu =c.spu and a.SellUserName = c.SellUserName and a.dep2 = c.dep2
left join online_stat d on a.spu = d.spu and a.SellUserName = d.SellUserName and a.dep2 = d.dep2
left join refund_stat e on a.spu = e.spu and a.SellUserName = e.SellUserName and a.dep2 = e.dep2
left join sa_lst_stat h on a.spu = h.spu and a.SellUserName = h.SellUserName and a.dep2 = h.dep2
left join top_sku_sort i on a.spu =i.spu and a.SellUserName = i.SellUserName and a.dep2 = i.dep2
left join prod_seller j on a.spu =j.spu

)

 select * from res
-- select count(*) from res