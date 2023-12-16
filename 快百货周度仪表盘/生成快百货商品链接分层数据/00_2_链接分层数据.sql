/*
231026��
SA�������۶��׼���䣬�����������Ǳ������Ʒ������

230721��
���ӷֲ㶨���ǣ�������30���������ȫ�����꣬�ֳ�
S = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У������˷ѽ����ڵ���750usd������
A = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У������˷ѽ����ڵ���250usd������
Ǳ�� = ����������Դ��һ��SA����֮������������н�14���3����������,���ǲ�����14��3����������ѡ������ӣ���ͣ��ֻ��SA����3�ࣩ
���� = S|A|Ǳ������֮�������������
 */


insert into dep_kbh_listing_level (`FirstDay`,`Department` , `asin`, `site`,`spu`,`Week`,
	list_level ,old_list_level ,ListingStatus ,sales_no_freight,sales_in30d ,profit_in30d ,sales_in7d ,profit_in7d ,list_orders
	,prod_level ,isnew ,ProductStatus ,ele_name ,isdeleted ,wttime)

with
-- kbh_store as ( -- �������п�ٻ��������ĵ��̣����ϵ��̱���Ŀǰ������ٻ��ĵ���
-- select distinct ShopStatus ,Code ,'��ٻ�' as department , case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�'  when NodePathName regexp  'Ȫ��' then  '��ٻ�Ȫ��' end as dep2  from mysql_store where department ='��ٻ�'
-- union select distinct '�ر�' as ShopStatus , shopcode,'��ٻ�' as department , case when Team regexp  '�ɶ�' then '��ٻ��ɶ�'  when Team regexp  'Ȫ��' then  '��ٻ�Ȫ��' end as dep2  from wt_orderdetails where IsDeleted = 0 and department = '��ٻ�'
-- )
kbh_store as ( -- �������п�ٻ��������ĵ��̣����ϵ��̱���Ŀǰ������ٻ��ĵ���
select distinct ShopStatus ,Code ,'��ٻ�' as department , case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�'  when NodePathName regexp  'Ȫ��' then  '��ٻ�Ȫ��' end as dep2  from mysql_store where department ='��ٻ�'
)

,od_list_in30d_pay as ( -- ��������
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku ,dep2
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight
    ,round(sum(totalgross/wo.ExchangeUSD),2) sales_in30d
    ,round(sum(totalprofit/wo.ExchangeUSD),2) profit_in30d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then (totalgross)/wo.ExchangeUSD end),2),0) sales_in7d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then totalprofit/wo.ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- ������
    ,count(distinct case when paytime >=date(date_add('${NextStartDay}',INTERVAL -14 day)) and paytime< '${NextStartDay}' then PlatOrderNumber end ) orders_in14d -- ��14�충����
from import_data.wt_orderdetails wo
join kbh_store ms on wo.shopcode = ms.code
and PayTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and PayTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>''
group by wo.site, wo.asin,spu,boxsku,dep2
)

,od_list_in30d_refund as ( -- �˿�����
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku,dep2
   ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refund
    ,abs(round(sum( case when SettlementTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and SettlementTime< date_add('${NextStartDay}', INTERVAL -0 DAY)  then RefundAmount/ExchangeUSD end ),2)) refund_in7d
from import_data.wt_orderdetails wo
join kbh_store ms on wo.shopcode = ms.code
and SettlementTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and SettlementTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '�˿�'  and wo.asin <>''  and wo.boxsku<>''
group by wo.site, wo.asin,spu,boxsku,dep2
)

, lst_ad_spend as ( -- ��滨������
select ad.StoreSite ,ad.Asin, wl.boxsku,dep2
     ,sum(Spend) AdSpend_in30d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -7-2 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -2 DAY) then Spend end ) AdSpend_in7d
from ( select sellersku ,shopcode ,boxsku,dep2 from wt_listing wl
    join kbh_store ms on wl.shopcode = ms.code  and ms.Department = '��ٻ�' group by  sellersku ,shopcode ,boxsku,dep2
	) wl
join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
    and CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
group by ad.StoreSite ,ad.Asin, wl.boxsku,dep2
)

,od_list_in30d as ( -- �������ӵ�����ͳ��
select p.BoxSku ,p.spu ,p.Asin ,p.Site,p.dep2
    ,sales_no_freight - ifnull(refund,0) as sales_no_freight
    ,profit_no_freight - ifnull(refund,0) -ifnull(AdSpend_in30d,0) as profit_no_freight
    ,sales_in30d - ifnull(refund,0) as sales_in30d
    ,profit_in30d - ifnull(refund,0) -ifnull(AdSpend_in30d,0) as profit_in30d
    ,sales_in7d - ifnull(refund_in7d,0) as sales_in7d
    ,profit_in7d - ifnull(refund_in7d,0) -ifnull(AdSpend_in7d,0) as profit_in7d
    ,orders
    ,orders_in14d
from od_list_in30d_pay p
left join od_list_in30d_refund r on p.Site =r.Site and p.asin = r.Asin and p.BoxSku = r.BoxSku and p.dep2 = r.dep2
left join lst_ad_spend l on p.site = l.StoreSite and p.asin = l.Asin and p.BoxSku = l.BoxSku and p.dep2 = l.dep2
)

,lst_1 as ( -- ����
select  distinct asin ,site ,list_level as mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,lst_2 as (  -- w-2��
select  distinct asin ,site ,list_level as mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,lst_3 as ( -- w-3��
select  distinct asin ,site ,list_level as mark_3 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)

, res as (
select '${StartDay}', dep2  ,asin ,site ,spu ,WEEKOFYEAR('${StartDay}')+1 ,list_level ,old_list_level ,ListingStatus
	,sales_no_freight ,sales_in30d ,profit_in30d ,sales_in7d  ,profit_in7d ,list_orders
	,prod_level ,isnew ,ProductStatus ,ele_name ,0 as isdeleted ,now()
from (select t.site
        , t.asin
        , t.spu
        , t.dep2
        , s.prod_level
        , concat(ifnull(mark_1,'��'),'-',ifnull(mark_2,'��'),'-',ifnull(mark_3,'��'))  old_list_level
        , s.isnew
        , s.ProductStatus
        , tag.ele_name
        , t.sales_no_freight
        , t.sales_in30d
        , t.sales_in7d
        , t.profit_in30d
        , t.profit_in7d
        , t.list_orders
        , case
             when t.sales_no_freight >= 750  THEN 'S' -- and prod_level regexp '����|����'
             when t.sales_no_freight >= 250  THEN 'A' -- and prod_level regexp '����|����'
             else '����'
        END as list_level
        , case when tmp.asin is not null then '����' else 'δ����' end as ListingStatus
    from (select site, asin, spu,dep2 , sum(orders) list_orders
               , sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
               , sum(orders_in14d) orders_in14d
        from od_list_in30d
        group by site, asin, spu ,dep2 ) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '��ٻ�' and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join kbh_store ms on eaal.shopcode = ms.code and ms.ShopStatus='����' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
    left join ( select spu ,GROUP_CONCAT(name)  as ele_name
    	from ( select distinct eppaea.spu , eppea.name
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id ) t
		group by spu ) tag on t.spu = tag.spu
    left join lst_1 on t.site = lst_1.site  and t.Asin =lst_1.Asin
    left join lst_2 on t.site = lst_2.site  and t.Asin =lst_2.Asin
    left join lst_3 on t.site = lst_3.site  and t.Asin =lst_3.Asin
) tmp
where list_level is not null and dep2 is not null
)


 select * from res  ;
-- select count(DISTINCT CONCAT(ASIN,SITE)) from res where list_level regexp 'S|A'
 -- select sum(sales_in7d) from dep_kbh_listing_level where FirstDay='2023-08-07'
