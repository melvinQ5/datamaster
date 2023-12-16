/*
 �ɶ����ӷֲ㶨���ǣ�
S = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У��ۼƶ����� ���ڵ���15��������
A = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У��ۼƶ����� 5-14�� ������
B = SA����֮��������ۼƶ����� 5-14�� ������
C = SAB����֮��������ۼƶ����� 0-4�� ������
���ѽ�30���������ȫ�����꣩


Ȫ�� ������ ���ӷֲ㶨���ǣ�
S = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У��վ������� ���ڵ���5��������
A = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У��վ������� 1-4�� ������
B = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У��վ������� 0.5-1�� ������
C = ����30��ͳ�Ʊ��������Ĳ�Ʒ���ò�Ʒ���г��������У�����SAB�����г�������
����ֻ�ѱ�������Ʒ�����г������ӷ��꣬δ�ѽ�30��Ǳ����������Ʒ�����ӷ��꣩
 */



-- ���� ��ٻ��ɶ���SA���� ��������ɸѡ���岻ͬ�ڳɶ� �� ���������������ٻ��ģ�
insert into dep_kbh_listing_level (`FirstDay`,`Department` , `asin`, `site`,`Week`,
	list_level ,ListingStatus ,sales_no_freight,sales_in30d ,profit_in30d ,sales_in7d ,profit_in7d ,list_orders ,wttime)
with od_list_in30d as ( -- site,asin,spu,boxsku �ۺ�
select asin,wo.site,Product_SPU as spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- ���˿���˷�
	,round(sum((totalgross)/ExchangeUSD),2) sales_in30d -- ���˿���˷�
	,round(sum((totalprofit)/ExchangeUSD),2) profit_in30d -- ���˿���˷�
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalgross)/ExchangeUSD end),2),0) sales_in7d
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalprofit)/ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- ������
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' and ms.department regexp '��'and  NodePathName regexp '�ɶ�'
group by wo.site,asin,spu,boxsku
)

select '${StartDay}','��ٻ��ɶ�����1' ,asin ,site ,WEEKOFYEAR('${StartDay}')+1 ,list_level ,ListingStatus ,sales_no_freight,sales_in30d ,sales_in7d  ,list_orders ,now()
from (select site
        , t.asin
        , t.sales_no_freight
        , t.sales_in30d
        , t.sales_in7d
        , t.profit_in30d
        , t.profit_in7d 
        , t.list_orders
        , case -- ���վ�������
             when list_orders/30 >= 5 and prod_level regexp '����|����' THEN 'S'
             when list_orders/30 >= 1 and prod_level regexp '����|����' THEN 'A'
             when list_orders/30 >= 0.5 and prod_level regexp '����|����' THEN 'B'
             when list_orders/30 >0 and prod_level regexp '����|����' THEN 'C'
            ELSE 'ɢ��'
            END as list_level
        , case when tmp.asin is not null then '����' else 'δ����' end as ListingStatus
    from (select site, asin, spu, sum(orders) list_orders
    			, sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
        from od_list_in30d
        group by site, asin, spu) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '��ٻ�'  and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='����' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
) tmp
where list_level is not null;


-- ���� ��ٻ�Ȫ�ݵ�SA���� ��������ɸѡ���岻ͬ�ڳɶ� �� ���������������ٻ��ģ�
insert into dep_kbh_listing_level (`FirstDay`,`Department` , `asin`, `site`,`Week`,
	list_level ,ListingStatus ,sales_no_freight,sales_in30d ,profit_in30d ,sales_in7d ,profit_in7d ,list_orders ,wttime)
with od_list_in30d as ( -- site,asin,spu,boxsku �ۺ�
select asin,wo.site,Product_SPU as spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- ���˿���˷�
	,round(sum((totalgross)/ExchangeUSD),2) sales_in30d -- ���˿���˷�
	,round(sum((totalprofit)/ExchangeUSD),2) profit_in30d -- ���˿���˷�
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalgross)/ExchangeUSD end),2),0) sales_in7d
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalprofit)/ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- ������
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' and ms.department regexp '��'and  NodePathName regexp 'Ȫ��'
group by wo.site,asin,spu,boxsku
)

select '${StartDay}','��ٻ�Ȫ�ݲ���1' ,asin ,site ,WEEKOFYEAR('${StartDay}')+1 ,list_level ,ListingStatus ,sales_no_freight,sales_in30d ,sales_in7d  ,list_orders ,now()
from (select site
        , t.asin
        , t.sales_no_freight
        , t.sales_in30d
        , t.sales_in7d
        , t.profit_in30d
        , t.profit_in7d
        , t.list_orders
        , case -- ���վ�������
             when list_orders/30 >= 5 and prod_level regexp '����|����' THEN 'S'
             when list_orders/30 >= 1 and prod_level regexp '����|����' THEN 'A'
             when list_orders/30 >= 0.5 and prod_level regexp '����|����' THEN 'B'
             when list_orders/30 >0 and prod_level regexp '����|����' THEN 'C'
            ELSE 'ɢ��'
            END as list_level
        , case when tmp.asin is not null then '����' else 'δ����' end as ListingStatus
    from (select site, asin, spu, sum(orders) list_orders
    		, sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
        from od_list_in30d
        group by site, asin, spu) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '��ٻ�'  and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='����' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
) tmp
where list_level is not null;

