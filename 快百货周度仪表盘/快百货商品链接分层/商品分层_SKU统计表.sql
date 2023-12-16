
with
prod_mark as ( -- ��Ʒ�ֲ�
select spu ,prod_level
from dep_kbh_product_level where isdeleted=0 and FirstDay =  '${StartDay}'
)

,od_list_in30d_pay as ( -- ��������
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku ,Product_Sku as sku
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight_in30d
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight_in30d
    ,round(sum(totalgross/wo.ExchangeUSD),2) totalgross_in30d
    ,round(sum(totalprofit/wo.ExchangeUSD),2) totalprofit_in30d
    ,round( sum(FeeGross/ExchangeUSD),2 ) feegross_in30d
    ,count(distinct PlatOrderNumber) orders_in30d -- ������
    ,round( sum(SaleCount),2 ) salecount_in30d
    ,count(distinct case when feegross= 0 then  PlatOrderNumber end) orders_no_freight_in30d
from import_data.wt_orderdetails wo
join prod_mark pm on wo.Product_SPU = pm.spu
join ( select * ,case when NodePathName regexp '�ɶ�' then '�ɶ�' when NodePathName regexp 'Ȫ��|��Ʒ��' then 'Ȫ��' end as dep2
       from mysql_store ) ms on wo.shopcode=ms.Code
and PayTime >= date(date_add('${NextStartDay}',INTERVAL  -1*'${days}' day)) and PayTime < '${NextStartDay}' and ms.department regexp '��'
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

,prod_mark_sku as ( -- ��Ʒ�ֲ�
    select t.* ,pm.prod_level
    from (select spu, sku from od_list_in30d group by spu, sku) t
    left join prod_mark pm on t.SPU =pm.SPU
)

-- select * from prod_mark_sku


,ad_list_in30d as (
select  ta.asin, ta.site,spu,ta.sku
    ,sum( AdSpend ) as Spend
    ,sum( AdExposure ) as Exposure
    ,sum( AdClicks ) as Clicks
    ,sum( AdSkuSaleCount7Day ) as AdSkuSaleCount7Day
    ,sum( AdSkuSale7Day ) as AdSkuSale7Day
from (select distinct Asin ,Site ,sku ,spu  from od_list_in30d ) ta
left join import_data.wt_adserving_amazon_daily asa on ta.Site = right(asa.ShopCode,2) and ta.Asin = asa.Asin
where GenerateDate >=date_add(  '${NextStartDay}' , INTERVAL  -1-1*'${days}' DAY)
  and GenerateDate<  date_add('${NextStartDay}',interval -1 day)
group by  ta.asin, ta.site ,spu,ta.sku
)

,od_list_set as (
select od.* ,Spend ,Exposure ,Clicks ,AdSkuSaleCount7Day ,AdSkuSale7Day
from od_list_in30d od
left join ad_list_in30d ad on od.Asin =ad.Asin and od.Site = ad.Site and od.sku =ad.SKU
)
-- select * from od_list_set

,add_index_1 as (
select *
    ,round(Clicks/Exposure,2) CTR
    ,round(AdSkuSaleCount7Day/Clicks,2) CVR
    ,round(Spend/Clicks,2) CPC
    ,round(AdSkuSale7Day/Spend,2) ROAS
    ,round(Spend/AdSkuSale7Day,2) ACOS
from (
select spu ,sku
    ,round(sum( totalgross_in30d  )) `���۶�`
    ,round(sum( totalprofit_in30d )) `�����`
    ,round(sum( orders_in30d )) `������`
    ,round(sum( salecount_in30d )) `����`
    ,round(sum( feegross_in30d )) `�˷�����`
    ,round(sum( Spend )) `��滨��`
    ,round(sum( totalprofit_in30d - ifnull(Spend,0) )) `�۹�������`
    ,round(sum( totalprofit_in30d - ifnull(feegross_in30d,0) - ifnull(Spend,0) )) `���˷ѿ۹�������`
    ,round(count( distinct concat(asin ,site)  )) `����������`
    ,round(count( distinct case when orders_in30d >= 15 then concat(asin ,site) end )) `15������������`
    ,round(count( distinct case when orders_in30d >= 5 and orders_in30d < 15 then concat(asin ,site) end )) `5��14��������`
    ,round(count( distinct case when orders_in30d >= 3 and orders_in30d < 5 then concat(asin ,site) end )) `3��4��������`
    ,round(count( distinct case when orders_in30d >= 3 then concat(asin ,site) end ) / count( distinct concat(asin ,site) ) ,4) `3������ռ��`

    ,round( sum( case when orders_in30d >= 15 then orders_in30d end ) / count( distinct case when orders_in30d >= 15 then concat(asin ,site) end ),1 ) `15����������ƽ��������`
    ,round( sum( case when orders_in30d >= 5 and orders_in30d < 15 then orders_in30d end ) / count( distinct case when orders_in30d >= 5 and orders_in30d < 15 then concat(asin ,site) end ),1 ) `5��14������ƽ��������`
    ,round( sum( case when orders_in30d >= 3 and orders_in30d < 5 then orders_in30d end ) / count( distinct case when orders_in30d >= 3 and orders_in30d < 5 then concat(asin ,site) end ),1 ) `3��4������ƽ��������`

    ,sum( Spend ) as Spend
    ,sum( Exposure ) as Exposure
    ,sum( Clicks ) as Clicks
    ,sum( AdSkuSaleCount7Day ) as AdSkuSaleCount7Day
    ,sum( AdSkuSale7Day ) as AdSkuSale7Day
from od_list_set group by spu ,sku
) t
)

,add_index_2 as (
select spu ,sku
     ,sum(day_orders)/count(distinct pay_date) `�վ�����`
     ,count(distinct pay_date) `��������`
     ,max(day_orders) `����ն���`
     ,min(day_orders) `����ն���`
from (select spu ,Product_Sku as sku, date(paytime) pay_date, count(distinct PlatOrderNumber) day_orders
      from import_data.wt_orderdetails wo
        join prod_mark pm on wo.Product_SPU = pm.spu
        join ( select * ,case when NodePathName regexp '�ɶ�' then '�ɶ�' when NodePathName regexp 'Ȫ��|��Ʒ��' then 'Ȫ��' end as dep2
               from mysql_store ) ms on wo.shopcode=ms.Code
        and PayTime >= date(date_add('${NextStartDay}',INTERVAL  -1*'${days}' day)) and PayTime < '${NextStartDay}' and ms.department regexp '��'
        and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>'' and dep2 in ('${team1}','${team2}')
      group by spu ,sku, pay_date ) t
group by spu ,sku
)

,add_index_3 as (
select spu ,sku ,group_concat( UK��3��ҵ��ռ�� ) UK��3��ҵ��ռ�� ,group_concat(DE��3��ҵ��ռ��) DE��3��ҵ��ռ�� ,group_concat(FR��3��ҵ��ռ��) FR��3��ҵ��ռ��
    ,group_concat(US��3��ҵ��ռ��) US��3��ҵ��ռ�� ,group_concat(CA��3��ҵ��ռ��) CA��3��ҵ��ռ��
from (
    select spu ,sku
         ,case when site = 'UK' then over3ods_list_rate_by_site end as `UK��3��ҵ��ռ��`
         ,case when site = 'DE' then over3ods_list_rate_by_site end as `DE��3��ҵ��ռ��`
         ,case when site = 'FR' then over3ods_list_rate_by_site end as `FR��3��ҵ��ռ��`
         ,case when site = 'US' then over3ods_list_rate_by_site end as `US��3��ҵ��ռ��`
         ,case when site = 'CA' then over3ods_list_rate_by_site end as `CA��3��ҵ��ռ��`
    from (select spu ,sku, site, totalgross_in30d_by_site as  totalgross_in30d_by_site
               , CAST( round(totalgross_in30d_by_site / sum(totalgross_in30d_by_site) over (partition by  spu,sku ), 2)  as VARCHAR ) as over3ods_list_rate_by_site
          from (select spu ,sku, site, sum(totalgross_in30d) totalgross_in30d_by_site
                from od_list_in30d
                where orders_in30d > 3
                group by spu ,sku, site) ta ) tb
    ) tc
group by spu ,sku
)

,add_index_4 as ( -- �ҵ�������
select spu ,Product_Sku as sku
    ,round(sum( TotalGross/ExchangeUSD  )) `���˷ѵ����۶�`
    ,round(sum( TotalProfit/ExchangeUSD )) `���˷ѵ������`
    ,count(distinct PlatOrderNumber)  `���˷ѵ�������`
    ,round(  sum( TotalProfit ) /  sum( TotalGross  ),2) as `�ҵ�������`
from import_data.wt_orderdetails wo
join prod_mark pm on wo.Product_SPU = pm.spu
join ( select * ,case when NodePathName regexp '�ɶ�' then '�ɶ�' when NodePathName regexp 'Ȫ��|��Ʒ��' then 'Ȫ��' end as dep2
       from mysql_store ) ms on wo.shopcode=ms.Code
and PayTime >= date(date_add('${NextStartDay}',INTERVAL  -1*'${days}' day)) and PayTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>'' and dep2 in ('${team1}','${team2}')
and FeeGross = 0
group by spu ,sku
)


,add_attr_1 as (
select pm.spu ,pm.sku ,epp.boxsku ,epp.productname `��Ʒ����`  ,epps. StartNumber `������` ,eppila.LogisticAttributeName `��������`
from prod_mark_sku pm
join erp_product_products epp on pm.sku = epp.sku and epp.IsMatrix=0
left join erp_product_product_suppliers epps on epp.id = epps.ProductId and epps.IsDefault = 1 and epps.IsDeleted = 0 and epps.Status=40
left join erp_product_product_in_logistic_attributes eppila on epp.id = eppila.ProductId
)

select
    date( '${NextStartDay}' ) `��ǩ��������`
    , attr1.boxsku
    , pm.*
    ,`��Ʒ����`
    ,`��������`
    ,`������`

    ,`���˷ѵ����۶�`
    ,`���˷ѵ������`
    ,`���˷ѵ�������`
    ,`�ҵ�������`

    ,`���۶�`
    ,`�����`

    ,`�˷�����`
    ,`��滨��`
    ,`�۹�������`
    ,`���˷ѿ۹�������`

    ,`������`
    ,`����`
    ,`��������`
    , round(`�վ�����`) `�վ�����`
    ,`����ն���`
    ,`����ն���`

    ,`Spend`
    ,`Exposure`
    ,`Clicks`
    ,`AdSkuSaleCount7Day`
    ,`AdSkuSale7Day`
    ,`CTR`
    ,`CVR`
    ,`CPC`
    ,`ROAS`
    ,`ACOS`

    ,`UK��3��ҵ��ռ��`
    ,`DE��3��ҵ��ռ��`
    ,`FR��3��ҵ��ռ��`
    ,`US��3��ҵ��ռ��`
    ,`CA��3��ҵ��ռ��`

    ,`����������`
    ,`15������������`
    ,`5��14��������`
    ,`3��4��������`
    ,`3������ռ��`

    ,`15����������ƽ��������`
    ,`5��14������ƽ��������`
    ,`3��4������ƽ��������`

from prod_mark_sku pm
left join add_index_1 a1 on pm.SKU = a1.SKU
left join add_index_2 a2 on pm.SKU = a2.SKU
left join add_index_3 a3 on pm.SKU = a3.SKU
left join add_index_4 a4 on pm.SKU = a4.SKU
left join add_attr_1 attr1 on pm.SKU = attr1.SKU
-- where pm.spu = 5238250