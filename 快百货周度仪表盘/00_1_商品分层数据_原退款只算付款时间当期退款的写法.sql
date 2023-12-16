/*
230721��
��Ʒ�ֲ㶨���ǣ�����30�������Ʒȫ�����꣬�ֳ�
���� = ����30������Ĳ�Ʒ�У������˷ѽ����ڵ���1500usd��SPU
���� = ����30������Ĳ�Ʒ�У������˷ѽ����ڵ���500usd��SPU
Ǳ�� = ����Ʒ��Ӫ��Ա�ӷǱ�������ɸѡ�
���� = ��|��|Ǳ��֮��������ĳ�����Ʒ
�����˷����۶�۳�����ʱ�䵱���ڵ��˿���ڼ��������µñ�����
���۶�ȡֵ����˵�����۳�˰�ѡ��۳�����ʱ���ڵ��˿�
�����ȡֵ����˵�����۳�˰�ѡ��۳�����ʱ���ڵ��˿�۳���Ʒ��Ӧ���ӵ����й�滨�ѣ����۸������Ƿ������

 */

-- ��������
-- ���� Department = ��ٻ�
/*
insert into dep_kbh_product_level (`FirstDay`,Department, `SPU`, `Week`,
	prod_level  ,ProductStatus ,sales_no_freight
	,profit_no_freight
	,AdSpend_in30d ,sales_in30d ,profit_in30d
	,AdSpend_in7d ,sales_in7d ,profit_in7d
	,isnew ,wttime)

 */


with
od_list_in30d as ( -- site,asin,spu,boxsku �ۺ�
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight
    ,round(sum(totalgross/wo.ExchangeUSD),2) sales_in30d
    ,round(sum(totalprofit/wo.ExchangeUSD),2) profit_in30d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then (totalgross)/wo.ExchangeUSD end),2),0) sales_in7d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then totalprofit/wo.ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- ������
    ,count(distinct case when paytime >=date(date_add('${NextStartDay}',INTERVAL -14 day)) and paytime< '${NextStartDay}' then PlatOrderNumber end ) orders_in14d -- ��14�충����
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code and PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '����'  and wo.asin <>''  and wo.boxsku<>''  and ms.department regexp '��'
group by wo.site, wo.asin,spu,boxsku
)

, lst_ad_spend as ( -- ������SKU�ۺϼ�����ѣ���ֹ����������ӵĹ�滨�ѣ���Ҫ�����������ӵĹ�滨��
select boxsku
     ,sum(Spend) AdSpend_in30d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -7-2 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -2 DAY) then Spend end ) AdSpend_in7d
from import_data.AdServing_Amazon ad
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code
join (select sellersku ,shopcode ,boxsku from wt_listing group by  sellersku ,shopcode ,boxsku ) wl on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
where CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
group by boxsku
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
    , DevelopLastAuditTime
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

left join ( select spu
            ,case when ProductStatus = 0 then '����'
                when ProductStatus = 2 then 'ͣ��'
                when ProductStatus = 3 then 'ͣ��'
                when ProductStatus = 4 then '��ʱȱ��'
                when ProductStatus = 5 then '���'
                end as ProductStatus
            ,date_add(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
            from import_data.erp_product_products epp
	where IsDeleted = 0 and ismatrix = 1 and DevelopLastAuditTime is not null
	) s on t.spu = s.spu
)
, res as (
select '${StartDay}' ,'��ٻ�' ,prod_mark.SPU  ,WEEKOFYEAR('${StartDay}')+1 ,prod_level
    ,ProductStatus
    ,round(sales_no_freight,2) sales_no_freight
    ,round(profit_no_freight,2) profit_no_freight
    ,round(AdSpend_in30d,2) AdSpend_in30d
    ,round(sales_in30d,2) sales_in30d
    ,round(profit_in30d,2) profit_in30d
    ,round(AdSpend_in7d,2) AdSpend_in7d
    ,round(sales_in7d,2) sales_in7d
    ,round(profit_in7d,2) profit_in7d
    ,CASE WHEN date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-07-01' THEN '��Ʒ' else '��Ʒ'end as isnew
    ,now()
from prod_mark
where prod_level is not null and spu is not null )

-- select * from res;

-- select sum(profit_in30d/sales_in30d) from res
-- where prod_level regexp '��|��' ;
select count(distinct spu) from res where prod_level regexp '����|����'

-- select count( distinct  spu) from dep_kbh_product_level where prod_level= '����' and FirstDay='2023-07-10'
