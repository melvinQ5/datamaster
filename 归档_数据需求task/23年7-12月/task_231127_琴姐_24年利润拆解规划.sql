with
prod as (
select wp.spu ,wp.sku ,wp.boxsku,case when DevelopLastAuditTime >= '2023-01-01' then '�����Ʒ' else '�����Ʒ' end �������Ʒ
from wt_products wp
left join dep_kbh_product_test dk on wp.sku =dk.sku
left join JinqinSku js on wp.spu = js.spu and monday='2023-11-27'
where  wp.projectteam = '��ٻ�' and wp.isdeleted = 0
    and js.spu is null  -- �ų�̭���嵥��������ͳ�Ƶ�̭��SPU)
    and ele_name_group not regexp '����|�ļ�|����|��ի|ʥ������˽�|ʥ��|��ʥ|�ж�' -- �ų�ָ������Ʒ��������Ϊ������Ʒ
)

,od_pay as (   -- ���۶���˿����ݣ��������˿�����
select wo.shopcode ,wo.SellerSku  ,ifnull(wo.Product_Sku,0) as sku   ,�������Ʒ
    ,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
    , sum(salecount ) salecount
from import_data.wt_orderdetails wo
join mysql_store  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join prod on wo.Product_Sku = prod.sku
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by wo.shopcode ,wo.SellerSku ,wo.Product_Sku ,�������Ʒ
)

,od_refund as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select shopcode ,SellerSku ,ifnull(wo.Product_Sku,0) as sku
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join mysql_store  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join prod on wo.Product_Sku = prod.sku
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '�˿�'
group by shopcode ,SellerSku  ,wo.Product_Sku
)

,od_deduct_refund as ( -- ���˿�
select  shopcode  ,sellersku  ,sku
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku   ,sku  , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku  ,sku , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku  ,sku
)

,od_lst_stat as( -- ��������ͳ��
select prod.�������Ʒ ,a.shopcode ,a.SellerSku ,prod.spu ,a.sku ,round(sales,2) sales ,round(profit,2) profit ,sales_refund,salecount
from od_deduct_refund a left join od_pay b on a.SellerSku =b.SellerSku and a.shopcode =b.shopcode and a.sku =b.sku
left join prod on a.sku =prod.sku
)

,ad_sku_map as ( -- ����ܱ�ƥ������SKU
select wl.shopcode,wl.sellersku ,wl.asin ,wl.sku,wl.spu
from wt_listing wl
join prod on wl.sku = prod.sku
join wt_adserving_amazon_weekly aa on wl.ShopCode = aa.ShopCode and wl.SellerSKU = aa.SellerSKU and wl.Asin = aa.Asin
group by wl.shopcode,wl.sellersku  ,wl.asin  ,wl.sku,wl.spu
)
--    select * from ad_sku_map


,ad as (
select  waad.shopcode ,waad.SellerSku ,t.sku
     ,AdSales  , AdSaleUnits
    , waad.AdClicks   , waad.AdExposure  ,waad.AdSpend
from wt_adserving_amazon_weekly waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '��ٻ�' and Year=2023  and week <= 45 -- 45���� 1030-1105 ���5��������
left join ad_sku_map t on waad.ShopCode=t.ShopCode and waad.SellerSku =t.SellerSKU and waad.Asin = t.asin
)

, ad_stat as (
select  shopcode  ,SellerSku,sku
        -- �ع���
        , round(sum(AdExposure)) as AdExposure
        -- ��滨��
        , round(sum(AdSpend),2) as AdSpend
        -- ������۶�
        , round(sum(AdSales),2) as AdSales
        -- �������
        , round(sum(AdSaleUnits),2) as AdSaleUnits
        -- �����
        , round(sum(AdClicks)) as AdClicks
        from ad  group by  shopcode ,SellerSku,sku
)

,od_stat as (
select �������Ʒ
,round( sum(profit - AdSpend) ,2) �����M3
, count(distinct spu) ����SPU��
,round( sum(salecount) /  count(distinct spu) ,0) ��Ʒ����
,round( sum(sales) /  sum(salecount) ,2) ������
,round( sum(profit - AdSpend) /  sum(sales) ,4) ������R3
,round( sum(AdSpend) ,2) ��滨��
,round( sum(sales) ,2) ���۶�S3
,round( sum(AdExposure) /  count(distinct spu) ,0) ��Ʒ�ع���
,round( sum(AdSaleUnits) /  count(distinct spu) ,0) ��浥Ʒ����
,round( sum(AdClicks) /   sum(AdExposure) ,6) CTR
,round( sum(AdSaleUnits) /   sum(AdClicks) ,6) CVR
,round( sum(AdSpend) /   sum(AdClicks) ,4) CPC
from od_lst_stat t1 left join ad_stat t2 on t1.shopcode=t2.ShopCode and t1.SellerSku=t2.SellerSku and t1.sku=t2.sku
group by �������Ʒ)

,prod_stat as ( select �������Ʒ , count(distinct spu) SPU��  from prod group by �������Ʒ )

select
t1.�������Ʒ
,�����M3
,spu��
,round( ����SPU�� /  SPU�� ,0) SPU������
,��Ʒ����
,������
,������R3
,����SPU��
,���۶�S3
,��Ʒ�ع���
,CTR
,CVR
,CPC
,��浥Ʒ����
,��Ʒ���� - ��浥Ʒ���� as ��Ȼ��Ʒ����
from od_stat t1 join prod_stat t2 on t1.�������Ʒ=t2.�������Ʒ