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
select pp.spu ,pp.sku ,pp.productname ,pp.boxsku ,mt.prod_level as push_type
from erp_product_products pp
join ( select distinct dkpl.spu
            , dkpl.prod_level
    from dep_kbh_product_level dkpl
     where FirstDay = date_add(subdate(' ${NextStartDay}', date_format(' ${NextStartDay}', '%w')-1),interval -1 week) and prod_level regexp '��|��' ) mt on pp.spu= mt.spu
  -- �˴�����ֱ�ӱ�ǵ����ݱ�,��Ϊ������Ϊ����һ���㣬��Ǳ�����嵥��Ԥ������һ��ǡ���Ϊ�˸������ṩ��������case when
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
and NodePathName regexp '${team}'
join topsku pp on pp.boxsku=wo.boxsku
where wo.IsDeleted = 0 and PayTime >=date(date_add(CURRENT_DATE(),INTERVAL -'${start_stat_days}'-1 day)) and PayTime<date(date_add(CURRENT_DATE(),INTERVAL -'${end_stat_days}'-1 day))
group by wo.sellersku,wo.shopcode
)

,list as ( -- �������Ӧ���е���������
select wl.id 
     , NodePathName,sellusername, wl.shopcode,markettype,wl.sellersku,price,wl.asin,wl.spu ,wl.sku,od.boxsku,od.productname,s.CompanyCode
     ,concat(dklld.ListLevel,'-',dklld.OldListLevel)  ��4�����ӷֲ�
     ,wl.MinPublicationDate as �״ο���ʱ��
    ,'����' �����Ƿ�����
from wt_listing wl
join topsku od on od.sku=wl.sku
join mysql_store s on s.code=wl.shopcode and s.department='��ٻ�'
    and NodePathName regexp '${team}'
    and listingstatus=1 and shopstatus='����' and IsDeleted = 0
join ( select shopcode ,SellerSKU ,asin  from erp_amazon_amazon_listing group by shopcode ,SellerSKU ,asin ) eaal
    on wl.shopcode = eaal.shopcode and  wl.SellerSKU = eaal.SellerSKU  and  wl.asin = eaal.asin   -- ���flinkͬ������ᵼ��
left join ( select distinct asin ,site ,ListLevel ,OldListLevel from dep_kbh_listing_level_details ) dklld on wl.asin = dklld.asin and wl.MarketType = dklld.site
where wl.IsDeleted = 0
)
-- select * from list

,online_stat as (
select spu
     ,count(distinct CompanyCode) as `SPU�����˺���`
     ,count(distinct concat(SellerSKU,ShopCode)) as `SPU��������`
from list group by spu
)

,addetail as ( -- �������Ӧ���е��������ӵĹ������
select al.shopcode,al.sellersku,sum(exposure)exposure,sum(clicks)clicks,sum(spend) spend,sum(AdSkuSaleCount7Day) adorders,sum(AdSkuSale7Day) adsales
from AdServing_Amazon ads
left join erp_amazon_amazon_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode
join mysql_store s on s.code=ads.shopcode and s.department='��ٻ�'
join topsku od on od.sku=al.sku
and NodePathName regexp '${team}'
where createdtime>= date(date_add(CURRENT_DATE(),INTERVAL -'${start_stat_days}'-1 day)) and createdtime<= date(date_add(CURRENT_DATE(),INTERVAL -'${end_stat_days}'-1 day))
group by al.shopcode,al.sellersku
)

,adstate as(
select distinct b.code shopcode,sku sellersku
from import_data.erp_amazon_amazon_ad_products tb
join erp_user_user_platform_account_sites b on b.id=tb.shopid
)


,res as (
select date(CURRENT_DATE())`ͳ������`,push_type
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
    ,SPU��������
    ,SPU�����˺���
from list
left join od a on a.sellersku=list.sellersku and a.shopcode=list.shopcode
left join addetail ad on ad.shopcode=list.shopcode and ad.sellersku=list.sellersku
left join adstate f on f.shopcode = list.shopcode and f.sellersku=list.sellersku
LEFT join topsku d on d.sku=list.sku
LEFT join online_stat e on e.spu=list.spu
order by sales desc
)

-- SELECT count(*) FROM res
SELECT * FROM res
-- WHERE  list_level ='S'
-- and markettype ='CA' AND ASIN = 'B0C38PK7G9'

-- select sum(IFNULL(���˷����۶�,0)) from res where markettype ='CA' AND ASIN = 'B0C38PK7G9';