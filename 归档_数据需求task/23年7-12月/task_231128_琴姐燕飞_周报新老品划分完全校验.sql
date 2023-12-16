

with
prod as (
select wp.sku ,wp.spu ,wp.BoxSku
  ,ifnull(ele_name_priority,'��Ԫ�ر�ǩ') ���ȼ�Ԫ��
  ,ifnull(istheme,'������Ʒ') ����
  ,ifnull(ispotenial,'�Ǹ�ǱƷ') ��Ǳ
  ,left(DevelopLastAuditTime,7) ��������
    ,wp.cat1 һ����Ŀ
  ,case when wp.DevelopLastAuditTime >=  date_add( DATE_ADD('${StartDay}',interval -day( '${StartDay}'  )+1 day) ,interval -2 month)
    and wp.DevelopLastAuditTime <'${NextStartDay}' then '��Ʒ' else '��Ʒ' end as ����Ʒ -- ����Ʒ����
    ,ProductStatusName
from wt_products wp
join dep_kbh_product_test vke on wp.SKU = vke.sku
where wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0
)

,od_pay as (   -- ���۶���˿����ݣ��������˿�����
select wo.shopcode ,wo.SellerSku ,ifnull(wo.Product_Sku,0) as sku ,wo.BoxSku
    ,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
    ,round( sum(salecount ),2) salecount
    ,count(distinct PlatOrderNumber) orders_cnt
    ,count(distinct Product_SPU) od_spu_cnt
	,round( sum(FeeGross/ExchangeUSD) ,4) `�˷�����`
	,round( sum(TradeCommissions/ExchangeUSD) ,4) `���׳ɱ�`
	,round( sum(PurchaseCosts/ExchangeUSD) ,4) `�ɹ��ɱ�`
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD ) ,0 ) ) �����ɱ�
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
left join dep_kbh_product_test d on wo.BoxSku = d.boxsku
left join view_kbh_lst_pub_tag vl on wo.shopcode =vl.shopcode and wo.sellersku = vl.sellersku and wo.BoxSku=vl.boxsku  -- vl������ͼֻ��37��boxskuΪ�գ�Ŀǰ�ȽϿ��׵�ƥ�䷽��
left join wt_products wp on wo.Product_Sku =wp.sku and wp.IsDeleted=0 and wp.ProjectTeam='��ٻ�'
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by wo.shopcode ,wo.SellerSku ,wo.Product_Sku ,wo.BoxSku
)

,od_refund as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select shopcode ,SellerSku ,ifnull(wo.Product_Sku,0) as sku ,wo.BoxSku
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '�˿�'
group by shopcode ,SellerSku ,sku ,wo.BoxSku
)

,od_stat_pre as ( -- ���˿�
select  shopcode  ,sellersku ,sku ,BoxSku
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,sku ,BoxSku , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,sku,BoxSku  , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,sku ,BoxSku
)

,od_stat as(
select a.shopcode ,a.SellerSku ,a.sku ,a.boxsku ,sales ,profit ,sales_refund
,salecount
, orders_cnt
,od_spu_cnt
, `�˷�����`
,`���׳ɱ�`
,`�ɹ��ɱ�`
,�����ɱ�
,round(ori_gross,2) ori_gross
,round(ori_profit,2) ori_profit
from od_stat_pre a left join od_pay b on a.SellerSku =b.SellerSku and a.shopcode =b.shopcode and a.sku =b.sku
)

-- ----------���������


,t0 as ( -- todo �������и����ӣ������ӱ����޸����ӣ��������ӹ���SKUδ�ɹ�  ShopCode='ZI-ES'  and SellerSKU = 'P230920F8VY02TZIUK-02'
select t.* ,prod.spu
     ,week_num_in_year ,month, '${StartDay}' firstday
     ,�������� ,����Ʒ ,����, ��Ǳ ,һ����Ŀ ,���ȼ�Ԫ��
from ( select shopcode ,SellerSku , sku ,boxsku from od_stat
    ) t
join ( select week_num_in_year,month from dim_date where full_date = '${StartDay}' ) dd
left join prod on t.sku =prod.sku
)


-- ��һ���� ��skuȴδƥ�䵽����Ʒ:
-- 1.1 �������ڿ�ٻ���������Ʒ���������㣬��Ϊƥ���Ʒ��ǩʱ��Ҫ��erp��ٻ���Ʒ�⡣������ύ��Ӫ��ҵ��ȥ����
select epp.sku as ��ǰsku ,* from (
    select * from (
        select distinct  wp.DevelopLastAuditTime ����ʱ�� ,wp.ProjectTeam ��Ʒerp�������� , department ���̹������� ,t.*
        from (select t0.shopcode,t0.SellerSku,t0.sku as ������sku, t0.boxsku ,����Ʒ,department
            from t0
            left join od_stat on t0.ShopCode = od_stat.ShopCode and t0.SellerSku = od_stat.SellerSku and t0.sku =od_stat.sku
            join mysql_store ms on t0.shopcode =ms.code where ����Ʒ is null and t0.sku > 0  and t0.SellerSku not regexp 'Event' ) t
        left join wt_products wp on t.������sku =wp.sku and wp.IsDeleted=0 ) t2 where ��Ʒerp�������� is not  null
    ) t3
    left join erp_product_products epp on t3.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix=0 and epp.ProjectTeam = '��ٻ�';

-- 1.2 sku �� boxsku�Ķ��չ�ϵ�����˱仯, �������е�ʱ��¼��sku������ƥ�䲻��erp��Ʒ����boxskuȥƥ�䷢�����µ�sku��
-- �������boxskuȥƥ���ǩ�� dep_kbh_product_test����ÿ�������µ�ƥ���ϵ
select epp.sku as ��ǰsku ,* from (
    select * from (
        select distinct  wp.DevelopLastAuditTime ����ʱ�� ,wp.ProjectTeam ��Ʒerp�������� , department ���̹������� ,t.*
        from (select t0.shopcode,t0.SellerSku,t0.sku as ������sku, t0.boxsku ,����Ʒ,department
            from t0
            left join od_stat on t0.ShopCode = od_stat.ShopCode and t0.SellerSku = od_stat.SellerSku and t0.sku =od_stat.sku
            join mysql_store ms on t0.shopcode =ms.code where ����Ʒ is null and t0.sku > 0  and t0.SellerSku not regexp 'Event' ) t
        left join wt_products wp on t.������sku =wp.sku and wp.IsDeleted=0 ) t2 where ��Ʒerp�������� is null
    ) t3
    left join erp_product_products epp on t3.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix=0 and epp.ProjectTeam = '��ٻ�';

-- �ڶ����֣�������Ӫ��Ĳ��ֳ�����Ʒ��û��ERPϵͳsku ������δƥ�䵽����Ʒ�Ȼ���ERP�ı�ǩ��
select NodePathName,shopcode ,SellerSku  ,wo.BoxSku ����Դ����SKU , Product_Sku ,wp.sku ,SaleCount ����,OrderNumber ,PlatOrderNumber ,PayTime
from wt_orderdetails wo join mysql_store ms on ms.Code =wo.shopcode and ms.NodePathName='������Ӫ��' and Product_Sku is null and TransactionType='����'and wo.IsDeleted = 0
left join wt_products wp on wo.BoxSku=wp.BoxSku
order by PayTime desc;



-- �����һ����
select eaal.sku ��ٻ�����sku,eaal.spu ����spu ,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ��Ʒ״̬ ,wp.ProjectTeam sku��ǰerp�������� ,eaal.ShopCode ,ms.CompanyCode ,ms.Department ���̵�ǰ�������� ,ShopStatus ���̵�ǰ״̬
        ,wp.DevelopLastAuditTime
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode=ms.Code and ms.Department='��ٻ�'
join erp_product_products wp on eaal.sku = wp.sku and ProjectTeam='������' and wp.IsDeleted=0 and wp.IsMatrix=0
where eaal.ListingStatus=1
order by ShopStatus desc