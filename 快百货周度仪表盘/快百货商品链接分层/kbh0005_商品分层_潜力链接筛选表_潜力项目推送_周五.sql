/*
��Ǳ������ɸѡ���Ĳ�Ʒ��Χ����
�ļ�1��Ǳ������ɸѡ��_�������������ӡ���������Ʒ��Ӫ�ˣ�����һ����ı�����Ʒ��Ӧ����������
�ļ�2��Ǳ������ɸѡ��_Ǳ����Ŀ���͡����������۶ˣ���Ǳ����Ŀ�������ݿ⡷Ǳ�����嵥�����к���������SA���ӵģ�����һ�С����ͱ�׼�������������ֺ��ļ�1�ظ�


����һ����ı����Ǳ�����Ӧ����������(������������Ǳ�������Ч���ڽ��б�ע)
������1 ͳ�ƽ�14����֣� start_stat_days=14 end_stat_days=0
������2 ͳ�ƽ�7����֣� start_stat_days=7 end_stat_days=0
ÿ�����ṩ��Ǳ��Ʒ�嵥��ǩ������Ч�����Ǵ�����һ��ʼ���㣬��˱����廹���ܶԲ�Ʒ�ֲ���

 */
-- team �ɶ� Ȫ��
with topsku as (
select pp.spu ,pp.sku ,pp.productname ,pp.boxsku ,date(pp.DevelopLastAuditTime) DevelopLastAuditTime ,mt.prod_level as push_type ,PushRule ,PushSite ,PushDate
from erp_product_products pp
join ( select spu ,prod_level -- ֻ���ڿ�ʼ���ͺ�ֹͣ��������֮�� �ҷֲ�=Ǳ�����Ʒ
            ,group_concat(PushRule) PushRule ,group_concat(PushSite) PushSite ,max(PushDate)  PushDate
       from dep_kbh_product_level_potentail dkplp
    where  '${NextStartDay}' >= dkplp.PushDate
      and  '${NextStartDay}' <= dkplp.StopPushDate
      and prod_level = 'Ǳ����' and isStopPush ='��'
    group by spu ,prod_level
    ) mt on pp.spu= mt.spu -- �˴�����ֱ�ӱ�ǵ����ݱ�,��Ϊ������Ϊ����һ���㣬��Ǳ�����嵥��Ԥ������һ��ǡ���Ϊ�˸������ṩ��������case when
where IsMatrix=0 and IsDeleted=0 and ProjectTeam = '��ٻ�'
group by pp.spu ,pp.sku ,pp.productname ,DevelopLastAuditTime ,pp.boxsku ,mt.prod_level ,PushRule ,PushSite ,PushDate
)
-- select * from topsku where spu =5260504

,od as (
select wo.sellersku,wo.shopcode
     ,round(sum((totalgross)/ExchangeUSD),2) sales_fully
     ,round(sum((totalgross-feegross)/ExchangeUSD),2) sales
     ,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit
     ,count(distinct platordernumber) orders
     ,count(distinct date(PayTime)) order_days
     ,round(sum(feegross/ExchangeUSD),2) freightfee
from wt_orderdetails wo
join mysql_store s on s.code=wo.shopcode and s.department='��ٻ�'
-- and NodePathName regexp '${team}'
join topsku pp on pp.boxsku=wo.boxsku
where wo.IsDeleted = 0 and PayTime >=date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1 day)) and PayTime<date(date_add('${NextStartDay}',INTERVAL -'${end_stat_days}'-1 day))
group by wo.sellersku,wo.shopcode
)

,list as ( -- �������Ӧ���е���������
select wl.id 
     , NodePathName,sellusername, wl.shopcode,markettype,wl.sellersku,price,wl.asin,wl.spu ,wl.sku,od.boxsku,od.productname ,s.companycode
     ,concat(dklld.ListLevel,'-',dklld.OldListLevel)  ��4�����ӷֲ�
     ,wl.MinPublicationDate as �״ο���ʱ��
     ,'����' �����Ƿ�����
from wt_listing wl
join topsku od on od.sku=wl.sku
join mysql_store s on s.code=wl.shopcode and s.department='��ٻ�'
    -- and NodePathName regexp '${team}'
    and listingstatus=1 and shopstatus='����' and IsDeleted = 0
join ( select shopcode ,SellerSKU ,asin  from erp_amazon_amazon_listing group by shopcode ,SellerSKU ,asin ) eaal
    on wl.shopcode = eaal.shopcode and  wl.SellerSKU = eaal.SellerSKU  and  wl.asin = eaal.asin   -- ���flinkͬ������ᵼ��
left join ( select distinct asin ,site ,ListLevel ,OldListLevel from dep_kbh_listing_level_details ) dklld on wl.asin = dklld.asin and wl.MarketType = dklld.site
where wl.IsDeleted = 0
)

,online_stat as (
select spu
     ,count(distinct CompanyCode) as `SPU�����˺���`
     ,count(distinct case when NodePathName regexp '�ɶ�' then CompanyCode end ) as `SPU�����˺���_�ɶ�`
     ,count(distinct case when NodePathName regexp 'Ȫ��' then CompanyCode end ) as `SPU�����˺���_Ȫ��`
     ,count(distinct concat(SellerSKU,ShopCode)) as `SPU��������`
     ,count(distinct case when NodePathName regexp '�ɶ�' then concat(SellerSKU,ShopCode) end ) as `SPU��������_�ɶ�`
     ,count(distinct case when NodePathName regexp 'Ȫ��' then concat(SellerSKU,ShopCode) end ) as `SPU��������_Ȫ��`
from list group by spu
)

-- select * from list


,addetail as ( -- �������Ӧ���е��������ӵĹ������
select al.shopcode,al.sellersku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales
from AdServing_Amazon ads
left join erp_amazon_amazon_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
join mysql_store s on s.code=ads.shopcode and s.department='��ٻ�'
join topsku od on od.sku=al.sku
-- and NodePathName regexp '${team}'
where createdtime>= date(date_add('${NextStartDay}',INTERVAL -'${start_stat_days}'-1 day)) and createdtime<= date(date_add('${NextStartDay}',INTERVAL -'${end_stat_days}'-1 day))
group by al.shopcode,al.sellersku
)

,adstate as( -- �Ƿ񿪹����
select  b.code shopcode,sku sellersku
from import_data.erp_amazon_amazon_ad_products tb
join erp_user_user_platform_account_sites b on b.id=tb.shopid
group by b.code, sku
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

,res1 as (
select
     date('${NextStartDay}')`ͳ������`
     ,PushDate `Ǳ������������`
     ,push_type
     ,list.*
     ,a.sales_fully as ���۶�
     ,a.orders as ������
     ,a.order_days  as ��������
     ,a.sales as ���˷����۶�
     ,a.profit as ���˷������
     ,round(profit/sales,4)`�ҵ�������_���˷�`
     ,a.freightfee �˷�����
     ,round((profit-spend),2)`�۹����˷������`
     ,round((profit-spend) /sales,4) `�۹����˷�������`
     ,exposure as �ع���
     ,clicks as �����
     ,spend as ��滨��
     ,adorders as ����Ʒ����
     ,adsales as ������۶�
     ,round(clicks/exposure,4) ctr
     ,round(adorders/clicks,4) cvr
     ,round(spend/clicks,4) cpc
     ,round(SPEND/adsales,4) acost
     ,round(adsales/spend,2) ROI
--     ,round(adsales*profit/sales-spend,2) adprofit
     ,case when f.sellersku is not null then '�������'
        else '��δƥ�䵽�������'
    end as ���״̬
    ,PushRule as ���ͱ�׼
    ,PushSite as ����վ��
    ,SPU��������
    ,SPU�����˺���
    ,g.seller_list as ��Ʒ���۸�����

    ,SPU�����˺���_�ɶ�
    ,SPU�����˺���_Ȫ��
    ,SPU��������_�ɶ�
    ,SPU��������_Ȫ��
    ,ele_name as Ԫ��
    ,DevelopLastAuditTime as ��������
from list
left join od a on a.sellersku=list.sellersku and a.shopcode=list.shopcode
left join addetail ad on ad.shopcode=list.shopcode and ad.sellersku=list.sellersku
left join adstate f on f.shopcode = list.shopcode and f.sellersku=list.sellersku
LEFT join topsku d on d.sku=list.sku
LEFT join online_stat e on e.spu=list.spu
LEFT join prod_seller g on g.spu=list.spu
LEFT join ele h on h.spu=list.spu
)

, topsite as (
select spu ,group_concat(MarketType) ���۶�topվ��
from ( select * ,dense_rank() over (partition by spu order by spu_site_sales desc) spu_site_sales_sort
    from ( SELECT spu,MarketType,sum(���۶�) as spu_site_sales FROM res1 where ���۶�>0 group by spu,MarketType ) t1
    ) t2
where spu_site_sales_sort <= 4 group by spu
)

, topseller as (
select spu ,group_concat(SellUserName) ���۶�top��Ա
from (select * ,dense_rank() over (partition by spu order by spu_seller_sales desc) spu_seller_sales_sort
    from ( SELECT spu,SellUserName,sum(���۶�) as spu_seller_sales FROM res1 where ���۶�>0 group by spu,SellUserName ) t1
    ) t2
where spu_seller_sales_sort <= 4 group by spu
)

, res2 as ( -- ���۶�ع������������ֵ=0����վ������վ��˳��uk de ca fr us it es au mx
select
    t2.���۶�topվ��
    ,t3.���۶�top��Ա
    ,dense_rank() over (partition by res1.spu order by spu_sales desc) ���۶�_վ������
    ,dense_rank() over (partition by res1.spu order by spu_exposure desc) �ع���_վ������
    ,res1.*

from res1
left join  ( SELECT Id
        ,case when ���۶�>0 then ���۶�
        when ���۶� is null and MarketType ='UK' then -1
        when ���۶� is null and MarketType ='DE' then -2
        when ���۶� is null and MarketType ='CA' then -3
        when ���۶� is null and MarketType ='FR' then -4
        when ���۶� is null and MarketType ='US' then -5
        when ���۶� is null and MarketType ='IT' then -6
        when ���۶� is null and MarketType ='ES' then -7
        when ���۶� is null and MarketType ='AU' then -8
        when ���۶� is null and MarketType ='MX' then -9
        end as spu_sales

        ,case when �ع���>0 then �ع���
        when �ع��� is null and MarketType ='UK' then -1
        when �ع��� is null and MarketType ='DE' then -2
        when �ع��� is null and MarketType ='CA' then -3
        when �ع��� is null and MarketType ='FR' then -4
        when �ع��� is null and MarketType ='US' then -5
        when �ع��� is null and MarketType ='IT' then -6
        when �ع��� is null and MarketType ='ES' then -7
        when �ع��� is null and MarketType ='AU' then -8
        when �ع��� is null and MarketType ='MX' then -9
        end as spu_exposure

FROM res1 ) t1 on res1.id = t1.id
left join topsite t2 on res1.spu = t2.spu
left join topseller t3 on res1.spu = t3.spu
)

select * from res2 order by Ǳ������������ desc ,spu ,���۶�_վ������




-- SELECT count(*) FROM res

-- SELECT * FROM res where id = 'a0d9def9-2505-4731-9d99-34bde6056398'
-- SELECT id  FROM res group by id having count(*) >1
-- WHERE  list_level ='S'
-- and markettype ='CA' AND ASIN = 'B0C38PK7G9'

-- select sum(IFNULL(���˷����۶�,0)) from res where markettype ='CA' AND ASIN = 'B0C38PK7G9';
