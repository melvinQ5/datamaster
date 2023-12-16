/*
230721��
��Ʒ�ֲ㶨���ǣ�����30�������Ʒȫ�����꣬�ֳ�
���� = ����30������Ĳ�Ʒ�У������˷ѽ����ڵ���1500usd��SPU
���� = ����30������Ĳ�Ʒ�У������˷ѽ����ڵ���500usd��SPU
Ǳ�� = ����Ʒ��Ӫ��Ա�ӷǱ�������ɸѡ�
���� = ��|��|Ǳ��֮��������ĳ�����Ʒ
 */

-- ��������
-- ���� Department = ��ٻ�

insert into dep_kbh_product_level (`FirstDay`,Department, `SPU`,isdeleted , `Week`,
	prod_level  ,ProductStatus ,sales_no_freight
	,profit_no_freight
	,AdSpend_in30d ,sales_in30d ,profit_in30d
	,AdSpend_in7d ,sales_in7d ,profit_in7d
	,isnew ,markdate ,wttime)
with
od_list_in30d_pay as ( -- ��������
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight
    ,round(sum(totalgross/wo.ExchangeUSD),2) sales_in30d
    ,round(sum(totalprofit/wo.ExchangeUSD),2) profit_in30d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then (totalgross)/wo.ExchangeUSD end),2),0) sales_in7d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then totalprofit/wo.ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- ������
    ,count(distinct case when paytime >=date(date_add('${NextStartDay}',INTERVAL -14 day)) and paytime< '${NextStartDay}' then PlatOrderNumber end ) orders_in14d -- ��14�충����
from import_data.wt_orderdetails wo join mysql_store ms on wo.shopcode=ms.Code
and PayTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and PayTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '����'  and wo.asin <>'' and wo.boxsku<>''
group by wo.site, wo.asin,spu,boxsku
)

,od_list_in30d_refund as ( -- �˿�����
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refund
     ,abs(round(sum( case when SettlementTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and SettlementTime< date_add('${NextStartDay}', INTERVAL -0 DAY)  then RefundAmount/ExchangeUSD end ),2)) refund_in7d
from wt_orderdetails wo join mysql_store  ms on ms.code=wo.shopcode
and SettlementTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and SettlementTime < '${NextStartDay}' and ms.department regexp '��'
and wo.IsDeleted = 0 and TransactionType = '�˿�'  and wo.asin <>''  and wo.boxsku<>''
group by wo.site, wo.asin,spu,boxsku
)

,od_list_in30d as ( -- �������ӵ�����ͳ��
select p.BoxSku ,p.spu ,p.Asin ,p.Site
    ,sales_no_freight - ifnull(refund,0) as sales_no_freight
    ,profit_no_freight - ifnull(refund,0) as profit_no_freight
    ,sales_in30d - ifnull(refund,0) as sales_in30d
    ,profit_in30d - ifnull(refund,0) as profit_in30d
    ,sales_in7d - ifnull(refund_in7d,0) as sales_in7d
    ,profit_in7d - ifnull(refund_in7d,0) as profit_in7d
from od_list_in30d_pay p
left join  od_list_in30d_refund r on p.Site =r.Site and p.asin = r.Asin and p.BoxSku = r.BoxSku
)

, lst_ad_spend as ( -- �������ӵĹ��ͳ��, �ۺϵ�sku���Ȳ����������
select wl.boxsku
     ,sum(Spend) AdSpend_in30d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -7-2 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -2 DAY) then Spend end ) AdSpend_in7d
from ( select sellersku ,shopcode ,boxsku from wt_listing wl join mysql_store ms on wl.shopcode = ms.code and ms.Department = '��ٻ�' group by  sellersku ,shopcode ,boxsku ) wl
join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
    and CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
group by wl.boxsku
)

,prod_mark as ( -- ��Ʒ�ֲ�
select t.spu
	, case when sales_no_freight >=1500 then '����' when sales_no_freight>=500 and sales_no_freight<1500 then'����'
	else '����' end as prod_level
    , sales_no_freight
    , profit_no_freight
    , AdSpend_in30d
    , AdSpend_in7d
    , sales_in30d
    , sales_in7d
    , profit_in30d
    , profit_in7d
	, s.ProductStatus
    , isnew
from (
	select
	    spu
       , sum(AdSpend_in30d )  AdSpend_in30d
       , sum(AdSpend_in7d )  AdSpend_in7d
       , sum(sales_no_freight )  sales_no_freight
       , sum(profit_no_freight - ifnull(AdSpend_in30d,0) ) profit_no_freight
       , sum(sales_in30d)       sales_in30d
       , sum(profit_in30d - ifnull(AdSpend_in30d,0) )      profit_in30d
       , sum(sales_in7d)        sales_in7d
       , sum(profit_in7d - ifnull(AdSpend_in7d,0))       profit_in7d
	from (select spu
               , boxsku
               , sum(sales_no_freight)  sales_no_freight
               , sum(profit_no_freight) profit_no_freight
               , sum(sales_in30d)       sales_in30d
               , sum(profit_in30d)      profit_in30d
               , sum(sales_in7d)        sales_in7d
               , sum(profit_in7d)       profit_in7d
          from od_list_in30d
          group by spu, boxsku) oli
	left join lst_ad_spend las on oli.boxsku = las.boxsku
    group by spu
	) t
left join ( select epp.spu
            ,case when ProductStatus = 0 then '����'
                when ProductStatus = 2 then 'ͣ��'
                when ProductStatus = 3 then 'ͣ��'
                when ProductStatus = 4 then '��ʱȱ��'
                when ProductStatus = 5 then '���'
                end as ProductStatus
            ,case when new.spu is not null then '��Ʒ' else '��Ʒ' end isnew
            from import_data.erp_product_products epp
            left join (select distinct spu from view_kbp_new_products) new on epp.spu = new.spu
	where IsDeleted = 0 and ismatrix = 1 and DevelopLastAuditTime is not null
	) s on t.spu = s.spu
)
, res as (
select '${StartDay}' ,'��ٻ�' ,prod_mark.SPU  ,0 as isdeleted ,WEEKOFYEAR('${StartDay}')+1 ,prod_level
    ,ProductStatus
    ,round(sales_no_freight,2) sales_no_freight
    ,round(profit_no_freight,2) profit_no_freight
    ,round(AdSpend_in30d,2) AdSpend_in30d
    ,round(sales_in30d,2) sales_in30d
    ,round(profit_in30d,2) profit_in30d
    ,round(AdSpend_in7d,2) AdSpend_in7d
    ,round(sales_in7d,2) sales_in7d
    ,round(profit_in7d,2) profit_in7d
    ,isnew
    ,'${NextStartDay}' as markdate
    ,now()
from prod_mark
where prod_level is not null and spu is not null )

-- select * from res;
select * from res;

-- select sum(sales_in7d) from res
-- select round(sum(profit_in30d)/sum(sales_in30d),4) from res
-- where prod_level regexp '��|��' ;
-- select count(distinct spu) from res where prod_level regexp '����|����'
-- select sum(sales_in7d) from dep_kbh_product_level where FirstDay='2023-08-07'


