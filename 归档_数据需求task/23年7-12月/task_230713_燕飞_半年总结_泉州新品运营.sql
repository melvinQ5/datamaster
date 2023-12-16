/*
 * �����ԣ�Ȫ����Ʒ��Ӫ
 */

with 
wp as (select sku ,spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01' 
    and ProjectTeam = '��ٻ�' )

,r1 as (
select  left('${StartDay}',7) ͳ���·�
    ,round(sum(TotalGross/ExchangeUSD),2) ��Ʒ���۶�
    ,round(sum(TotalProfit/ExchangeUSD),2) ��Ʒ�����
    ,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),4) ��Ʒ������_δ�۹��
    ,count(distinct wo.Product_SPU) ��Ʒ����SPU��
    ,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.Product_SPU),4) ��Ʒ����SPU����
    
    ,round(sum( case when dkpl.spu is not null then  TotalGross/ExchangeUSD end ),2) ��Ʒ������ҵ��
    ,round(count( distinct case when dkpl.spu is not null then Product_SPU end ),2) ��Ʒ��������
    ,round( sum( case when dkpl.spu is not null then  TotalGross/ExchangeUSD end ) / count( distinct case when dkpl.spu is not null then Product_SPU end ) ,4)   ��Ʒ�������
--     ,count(distinct tag.spu ) ��Ʒ����SPU��_����
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	from import_data.mysql_store where department regexp '��' )  ms 
	on wo.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
join wp on wo.product_sku = wp.sku -- 23������������Ʒ
left join ( 
	select distinct spu 
	from dep_kbh_product_level
	where FirstDay = '${StartDay}' and Department = '��ٻ�' and prod_level regexp '����|����' 
	) dkpl on dkpl.spu = wo.Product_SPU 
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
group by left('${StartDay}',7)
)

-- , r2 as (
-- select left('${StartDay}',7) ͳ���·�
-- 	,count( distinct case when prod_level regexp '����|����'  then dkpl.spu end ) ��Ʒ��������
-- 	,sum(  case when prod_level regexp '����|����'  then sales_in30d  end) ��Ʒ������ҵ��
-- 	,round( sum(  case when prod_level regexp '����|����' then sales_in30d end) / count(distinct case when prod_level regexp '����|����' and isnew='��Ʒ' then dkpl.spu end),4 ) ��Ʒ�������
-- from dep_kbh_product_level dkpl
-- join wp on dkpl.spu = wp.spu -- 23������������Ʒ
-- where FirstDay = '${StartDay}' and Department = '��ٻ�Ȫ��'
-- )

,od_list_in30d as ( -- ��ʱ�޸�Ȫ�����Ӷ���  ���ۼƳ��� 
select asin,wo.site,Product_SPU as spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- ���˿���˷�
	,round(sum((totalgross)/ExchangeUSD),2) sales_in30d -- ���˿���˷�
	,round(sum((totalprofit)/ExchangeUSD),2) profit_in30d -- ���˿���˷�
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalgross)/ExchangeUSD end),2),0) sales_in7d
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalprofit)/ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- ������
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	from import_data.mysql_store where department regexp '��' )  ms 
	on wo.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' and ms.department regexp '��' 
group by wo.site,asin,spu,boxsku
)

, list_mark as (
select site
        , t.asin
        , t.spu 
        , t.sales_in30d
        , case
             when list_orders >= 15 and prod_level regexp '����|����' THEN 'S'
             when list_orders >= 5 and prod_level regexp '����|����' THEN 'A'
             when list_orders >= 5 THEN 'B'
             when list_orders < 5 AND list_orders >0 THEN 'C' 
             else 'ɢ��'
        END as list_level
    from ( select site, asin, spu, sum(orders) list_orders
               , sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
        from od_list_in30d
        group by site, asin, spu ) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '��ٻ�' and FirstDay = '${StartDay}'
    join wp on t.spu = wp.spu -- 23������������Ʒ
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='����' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
)

, r3 as (
select left('${StartDay}',7)  ͳ���·�
	, count( DISTINCT case when list_level regexp 'S|A' THEN CONCAT(ASIN,Site) END ) ��ƷSA������
	, sum( case when list_level regexp 'S|A' THEN sales_in30d end ) ��ƷSA����ҵ��
from list_mark
)

, r4 as (
select left('${StartDay}',7)  ͳ���·�
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����14��SPU������`
from wp entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU 
	from (
        select wo.*
        	, case when dep2 = '��ٻ�����' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku and  date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01'  and ProjectTeam = '��ٻ�' 
        where wo.Department = '��ٻ�' 
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU 
	) part on entire.Sku = part.Product_SKU
)

, r5 as ( -- ��Ʒ������
select left('${StartDay}',7)  ͳ���·�
	,round( count(distinct concat(SellerSKU,ShopCode)) / count(distinct wl.sku) ,1 ) ��Ʒsku�����¿���ƽ��������
from import_data.wt_listing wl 
join wp on wl.spu = wp.spu -- 23������������Ʒ
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	from import_data.mysql_store where department regexp '��' )  ms 
	on wl.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
where MinPublicationDate  >= '${StartDay}' and MinPublicationDate < '${NextStartDay}'
)


select r1.* 
	, r3.��ƷSA������ ,r3.��ƷSA����ҵ�� ,r4.����14��SPU������ ,r5.��Ʒsku�����¿���ƽ�������� 
from r1 
left join  r3 on r1.ͳ���·� = r3.ͳ���·� 
left join  r4 on r1.ͳ���·� = r4.ͳ���·� 
left join  r5 on r1.ͳ���·� = r5.ͳ���·� 



