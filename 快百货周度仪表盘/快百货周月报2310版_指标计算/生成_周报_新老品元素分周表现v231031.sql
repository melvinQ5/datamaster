-- todo �ۺϱ������Ҫ��д����ʱ���ٲ�ѯ��������Ϊһ��Ҫ���ܣ� �� ������ϸ����ֱ�Ӳ�SQL��������Ϊֻ��һ�ܣ�

insert into manual_table_duplicate (wttime,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36)
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
from wt_products wp
left join dep_kbh_product_test vke on wp.SKU = vke.sku
where wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0
  -- and wp.ProductStatus !=2
)

,mysql_store_team as ( -- �޳�������Ӫ��,����dep2����ά��
select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,* from import_data.mysql_store where Department = '��ٻ�' and NodePathName != '������Ӫ��'
)

,od_pay as (   -- ���۶���˿����ݣ��������˿�����
select wo.shopcode ,wo.SellerSku ,ifnull(wo.Product_Sku,0) as sku
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
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD ) ,4) ) �����ɱ�
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
left join dep_kbh_product_test d on wo.BoxSku = d.boxsku
left join view_kbh_lst_pub_tag vl on wo.shopcode =vl.shopcode and wo.sellersku = vl.sellersku and wo.BoxSku=vl.boxsku  -- vl������ͼֻ��37��boxskuΪ�գ�Ŀǰ�ȽϿ��׵�ƥ�䷽��
left join wt_products wp on wo.Product_Sku =wp.sku and wp.IsDeleted=0 and wp.ProjectTeam='��ٻ�'
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by wo.shopcode ,wo.SellerSku ,wo.Product_Sku
)

,od_refund as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select shopcode ,SellerSku ,ifnull(wo.Product_Sku,0) as sku
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '�˿�'
group by shopcode ,SellerSku ,sku
)

,od_stat_pre as ( -- ���˿�
select  shopcode  ,sellersku ,sku
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,sku , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,sku , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,sku
)

,od_stat as(
select a.shopcode ,a.SellerSku ,a.sku ,sales ,profit ,sales_refund
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

,t_ad as ( --
select  waad.shopcode ,waad.SellerSku ,waad.sku
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , waad.AdClicks as Clicks  , waad.AdExposure as Exposure ,waad.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '��ٻ�' and  GenerateDate >=  date_add('${StartDay}',interval -1 day) and GenerateDate <  date_add('${NextStartDay}',interval -1 day)
left join dep_kbh_lst_sku_maps_test wl on waad.ShopCode = wl.ShopCode and  waad.SellerSKU = wl.SellerSKU -- todo ����sku������ʱ ��ʱ������������ʹ��
)

,add_ad_sku as ( -- todo ��ʱ����sku, ��������ձ���ȱʧSKU���⡷������Ҫ���erp_listing���� ProductId ��Ч������
select  wl.SellerSKU ,wl.ShopCode ,max(wl.sku) sku
from (select shopcode ,sellersku from t_ad where sku is null group by shopcode, sellersku) t1
join erp_amazon_amazon_listing wl on wl.ShopCode = t1.ShopCode and wl.SellerSKU = t1.SellerSku
group by wl.SellerSKU ,wl.ShopCode
)

, t_ad_stat as (
select  t1.shopcode  ,t1.SellerSku  ,coalesce(t1.sku,t2.sku) sku
-- �ع���
, round(sum(Exposure)) as ad_sku_Exposure
-- ��滨��
, round(sum(Spend),2) as ad_Spend
-- ������۶�
, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
-- �������
, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
-- �����
, round(sum(Clicks)) as ad_sku_Clicks
from t_ad  t1
left join add_ad_sku t2  on t2.ShopCode = t1.ShopCode and t2.SellerSKU = t1.SellerSku
group by  t1.shopcode  ,t1.SellerSku  ,coalesce(t1.sku,t2.sku)
)

,t_online_lst as (
select ShopCode ,SellerSKU ,sku
from wt_listing wl join mysql_store ms on wl.ShopCode=ms.Code and ms.Department='��ٻ�' and ListingStatus = 1 and ShopStatus='����' group by ShopCode, SellerSKU, sku
)

,ware_stat as(
select   round( sum( `��ǰ�ڲֲ�Ʒ���`)/10000,4) `���ڲֲ�Ʒ���_��Ԫ` -- ��Ԫ
from  dep_kbh_product_test wp
join  (
	SELECT boxsku ,sum(ifnull(TotalPrice,0)) `��ǰ�ڲֲ�Ʒ���`
	FROM ( -- local_warehouse ���زֱ�
		select TotalPrice, TotalInventory ,wi.boxsku
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products where  IsDeleted=0 and ProjectTeam='��ٻ�' ) tmp on wi.BoxSku = tmp.BoxSku
		where WarehouseName = '��ݸ��' and TotalInventory > 0
		  and CreatedTime = date_add('${NextStartDay}',-1) and department = '��ٻ�'
		)  tmp
	group by boxsku
) ware on wp.boxsku = ware.boxsku
)

,prod_stat as ( -- �������ӷֲ�ͳ����Ŷ�
select  count(distinct a.spu) ��δͣ��SPU��
from dep_kbh_product_test a
left join wt_products wp on a.sku = wp.sku and IsDeleted=0 and ProjectTeam='��ٻ�'
where a.ProductStatus !=2
)

,online_lst as (
select shopcode , sellersku from erp_amazon_amazon_listing eaal join mysql_store_team ms on eaal.ShopCode = ms.code
    and ShopStatus='����' and ListingStatus=1 group by shopcode ,sellersku
)

,t0 as ( -- todo �������и����ӣ������ӱ����޸����ӣ��������ӹ���SKUδ�ɹ�  ShopCode='ZI-ES'  and SellerSKU = 'P230920F8VY02TZIUK-02'
select t.* ,prod.spu
     ,week_num_in_year ,month, '${StartDay}' firstday
     ,�������� ,����Ʒ ,����, ��Ǳ ,һ����Ŀ ,���ȼ�Ԫ��
     ,case when SellerSku regexp 'Event' then '��' else '��' end �Ƿ�������¼
from ( select shopcode ,SellerSku , sku from od_stat
    union select shopcode ,SellerSku , sku from t_online_lst
    union select shopcode ,SellerSku , sku from t_ad_stat  -- where length(sku) >0 -- �����������skuΪ�յļ�¼
    ) t
join ( select week_num_in_year,month from dim_date where full_date = '${StartDay}' ) dd
left join prod on t.sku =prod.sku
)

,res1 as (
select now() ,'${StartDay}' as firstday , '${ReportType}' as reporttype
    ,ms.ShopStatus ,t0.shopcode ,t0.SellerSKU
    ,t0.sku ,t0.spu
    ,����Ʒ  ,���� ,t0.���ȼ�Ԫ��  ,��Ǳ ,һ����Ŀ ,��������
    ,ifnull(lst_pub_tag ,'��������')  ���ӿ��ǻ���
    ,case when '${ReportType}' = '�ܱ�' then week_num_in_year when '${ReportType}' = '�±�' then month end as ��Ȼ����
     ,firstday as ���ڵ�һ�� ,ms.CompanyCode ,ms.AccountCode ,���� ,����С�� ,������Ա
    ,ifnull(salecount,0) `����`
    ,ifnull(orders_cnt,0) `������`
    ,ifnull(sales,0) `���۶�`
    ,ifnull(profit,0) �����_δ��ad
    ,round(ifnull(profit,0) - ifnull(ad_Spend,0),2) `�����_��ad`
    ,ifnull(ori_gross,0) `���۶�_���˷�δ���˿�`
    ,ifnull(ori_profit,0) `�����_���˷�δ���˿�`
    ,round (  ori_profit /  ori_gross  ,4 ) �ҵ�������
    ,ifnull(sales_refund,0) `�˿��`
    ,ifnull(�˷�����,0) `�˷�����`
    ,ifnull(���׳ɱ�,0) `���׳ɱ�`
    ,ifnull(�ɹ��ɱ�,0) `�ɹ��ɱ�`
    ,ifnull(�����ɱ�,0) `�����ɱ�`
    ,ad_sku_Exposure `����ع���`
    ,ifnull(ad_Spend,0) `��滨��`
    ,ad_TotalSale7Day `������۶�`
    ,ad_sku_TotalSale7DayUnit `�������`
    ,ad_sku_Clicks `�������`
    ,�Ƿ�������¼
    ,ol.SellerSKU as online_sellersku
from t0
left join od_stat on t0.ShopCode = od_stat.ShopCode and t0.SellerSku = od_stat.SellerSku and t0.sku =od_stat.sku
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.SellerSku = t_ad_stat.SellerSku
left join view_kbh_lst_pub_tag vl on t0.SellerSku=vl.SellerSKU and t0.shopcode = vl.shopcode
left join (select * , case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ���� , NodePathName as ����С�� ,SellUserName ������Ա
      from mysql_store where Department = '��ٻ�') ms on t0.shopcode = ms.code
join erp_product_products epp on epp.sku = t0.sku and epp.ProjectTeam='��ٻ�' and epp.IsMatrix=0
left join online_lst ol on t0.ShopCode = ol.ShopCode and t0.SellerSku = ol.SellerSku
order by t0.shopcode ,t0.SellerSKU ,t0.sku ,��Ȼ���� ,���ڵ�һ��
)


,res2 as ( -- ���Ӿۺ�
select now() ,'${StartDay}' as firstday , '${ReportType}' as reporttype
    ,ShopStatus ,res1.shopcode ,���ӿ��ǻ��� ,�������� ,����Ʒ ,���ȼ�Ԫ�� ,��Ȼ���� ,���ڵ�һ��  ,CompanyCode,AccountCode,����,����С��,������Ա
    ,round(sum(����),0) ����
    ,round(sum(���۶�),2) ���۶�
    ,round(sum(�����_��ad),2) �����_��ad
    ,round(sum(�����_δ��ad),2) �����_δ��ad
    ,round(sum(���۶�_���˷�δ���˿�),2) ���۶�_���˷�δ���˿�
    ,round(sum(�����_���˷�δ���˿�),2) �����_���˷�δ���˿�
    ,round(sum(�˿��),2) �˿��
    ,round(sum(����ع���)) ����ع���
    ,round(sum(��滨��),2)  ��滨��
    ,round(sum(������۶�),2) ������۶�
    ,round(sum(�������),2) �������
    ,round(sum(�������),2) �������
    ,round(sum(�˷�����),2) �˷�����
    ,round(sum(���׳ɱ�),2) ���׳ɱ�
    ,round(sum(�ɹ��ɱ�),2) �ɹ��ɱ�
    ,round(sum(�����ɱ�),2) �����ɱ�
    ,���� ,��Ǳ ,һ����Ŀ ,�Ƿ�������¼
    ,count( distinct online_sellersku) ��������SKU��
from res1
group by ShopStatus ,res1.shopcode ,����Ʒ  ,���� ,���ȼ�Ԫ�� ,��Ǳ,һ����Ŀ ,�������� ,���ӿ��ǻ��� ,��Ȼ���� ,���ڵ�һ��,CompanyCode,AccountCode,����,����С��,������Ա ,�Ƿ�������¼
)


-- ��ϸ��
-- select * from res1 ;
-- �ۺϱ�
select * from res2
-- select count(1) from res2;



-- ���Ա�
-- select sum(ad_Spend) from t_ad_stat;
-- select sum(�˿��) from res1;

-- ���۶Ա�
-- select sum(�����_��ad)/sum(���۶�) from res3;
-- select sum(��ǰδͣ��SPU��) from res3;
-- select sum(TotalGross_weekly) from t_orde_week_stat;

