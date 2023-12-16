-- �ԱȽ����1 aa���wt��sum���һ�£�0925-1001�����ܹ�滨��14657usd,���н�7��(T-1��T-8)�������ӣ�asin+site���Ĺ�滨����6291��ʣ����������������ӵĻ���

-- �ܱ�
select ifnull(ms.dep2,'��ٻ�') Department
		,sum(TotalSale7Day) TotalSale7Day
		,sum(AdOtherSale7Day) AdOtherSale7Day
		,sum(Spend) Spend
		,round(sum(TotalSale7Day)/sum(Spend),4) ROAS
		,round(sum(Spend)/sum(Clicks),4) CPC
		,round(sum(Clicks)/sum(Exposure),4) AdClickRate
		,round(sum(TotalSale7DayUnit)/sum(Clicks),4) AdSaleRate
		,sum(Clicks) AdClicks
		,sum(Exposure) AdExposures
		,count(distinct sellersku,shopcode) adlist_cnt
	from import_data.AdServing_Amazon ad
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
		on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day) and ad.ShopCode = ms.Code
	group by grouping sets ((),(ms.dep2)) ;

-- �ֲ�
select sum( AdSpend ) as Spend
from import_data.wt_adserving_amazon_daily asa
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms  on asa.ShopCode = ms.Code
where GenerateDate >= date_add(  '${NextStartDay}' , INTERVAL  -1-1*'${days}' DAY)
    and GenerateDate < date_add('${NextStartDay}',interval -1 day) ;

-- �ֲ�
with
prod_mark as ( -- ��Ʒ�ֲ�
select distinct  spu ,prod_level
from dep_kbh_product_level where isdeleted=0 and FirstDay =  '${StartDay}'
)

,od_list_in30d_pay as (  -- ��������
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku ,Product_Sku as sku
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight_in30d
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight_in30d
    ,round(sum(totalgross/wo.ExchangeUSD),2) totalgross_in30d
    ,round(sum(totalprofit/wo.ExchangeUSD),2) totalprofit_in30d
    ,round( sum(FeeGross/ExchangeUSD),2 ) feegross_in30d
    ,round( sum(SaleCount),2 ) salecount_in30d
    ,count(distinct PlatOrderNumber) orders_in30d -- ������
    ,count(distinct case when feegross= 0 then  PlatOrderNumber end) orders_no_freight_in30d
from import_data.wt_orderdetails wo
join prod_mark pm on wo.Product_SPU = pm.spu
join ( select * ,case when NodePathName regexp '�ɶ�' then '�ɶ�' when NodePathName regexp 'Ȫ��|��Ʒ��' then 'Ȫ��' end as dep2
       from mysql_store ) ms on wo.shopcode=ms.Code
and PayTime >= date(date_add('${NextStartDay}',INTERVAL  -1*'${days}' day)) and PayTime < date_add('${NextStartDay}',interval -1 day) and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>'' and dep2 in ('${team1}','${team2}')
group by wo.site, wo.asin,Product_SPU,boxsku ,Product_Sku
)

,od_list_in30d_refund as ( -- �˿�����
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refund
     ,abs(round(sum( case when SettlementTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and SettlementTime< date_add('${NextStartDay}', INTERVAL -0 DAY)  then RefundAmount/ExchangeUSD end ),2)) refund_in7d
from wt_orderdetails wo
join ( select * ,case when NodePathName regexp '�ɶ�' then '�ɶ�' when NodePathName regexp 'Ȫ��|��Ʒ��' then 'Ȫ��' end as dep2
       from mysql_store ) ms on wo.shopcode=ms.Code
and SettlementTime >= date(date_add('${NextStartDay}',INTERVAL  -1*'${days}'  day)) and SettlementTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '�˿�'  and wo.asin <>''  and wo.boxsku<>''  and dep2 in ('${team1}','${team2}')
group by wo.site, wo.asin,spu,boxsku
)

,od_list_in30d as ( -- �������ӵ�����ͳ��
select p.BoxSku ,p.spu ,p.Asin ,p.Site ,p.sku
    ,totalgross_in30d - ifnull(refund,0) as totalgross_in30d
    ,totalprofit_in30d - ifnull(refund,0) as totalprofit_in30d
    ,feegross_in30d
    ,orders_in30d
    ,salecount_in30d
    ,orders_no_freight_in30d
    ,sales_no_freight_in30d - ifnull(refund,0) as sales_no_freight_in30d
from od_list_in30d_pay p
left join  od_list_in30d_refund r on p.Site =r.Site and p.asin = r.Asin and p.BoxSku = r.BoxSku
)

,ad_list_in30d as (
select  ta.asin, ta.site,spu,ta.sku
    ,sum( Spend ) as Spend
from ( select distinct Asin ,Site ,sku ,spu  from od_list_in30d ) ta
join
    ( select asin , right(ShopCode,2) site
        ,sum( AdSpend ) as Spend
    from import_data.wt_adserving_amazon_daily asa
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on asa.ShopCode = ms.Code
    where GenerateDate >=date_add(  '${NextStartDay}' , INTERVAL  -1-1*'${days}' DAY)
        and GenerateDate< date_add('${NextStartDay}',interval -1 day)
    group by asin , right(ShopCode,2)
    ) asa
    on ta.Site = asa.site  and ta.Asin = asa.Asin
group by  ta.asin, ta.site ,spu,ta.sku
)

,weekreport as (
select asin ,site ,sum(Spend) Spend
from import_data.AdServing_Amazon ad
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms
    on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime< date_add('${NextStartDay}',interval -1 day) and ad.ShopCode = ms.Code
group by asin ,site
)

select sum(spend) from ad_list_in30d

