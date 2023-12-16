-- �����¶ȼ�Ч���� ������30�����ϵ�����
-- ά�ȣ�
-- ��С���ȣ�����+ͳ���£�����9�£�
-- ���ӷ�Χ�����ж�������
-- ��Ʒ��Χ�����в�Ʒ

with
prod as (
select p.sku
  ,d.ele_name_priority
  ,left(DevelopLastAuditTime,7) dev_month
  ,date(DevelopLastAuditTime) dev_date
from wt_products p
join dep_kbh_product_test d
  on d.sku = p.sku
)

-- ----------���㶩������
,od_pay as (   -- ��������
select  shopcode ,sellersku ,asin  , sku ,wo.BoxSku
	,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
	,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
	,round( sum(salecount ),2) SaleCount_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�' and NodePathName !='������Ӫ��'
left join wt_products wp on wo.BoxSku  = wp.BoxSku and wp.ProjectTeam ='��ٻ�' and wp.IsDeleted =0
where
	PayTime >=  '${StartDay}'  and PayTime <  '${NextStartDay}'  -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
    and wo.IsDeleted=0
group by shopcode ,sellersku ,asin  ,sku  ,wo.BoxSku
)

,od_refund as ( -- ʹ���˿��
select shopcode ,sellersku ,asin  ,wo.BoxSku
	,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '�˿�'
group by shopcode ,sellersku ,asin  ,wo.BoxSku
)

,od_stat_pre as ( -- ���˿�
select  shopcode  ,sellersku ,asin
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,asin , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,asin , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,asin
)

,t_orde_week_stat as (
select  a.shopcode ,a.sellersku ,a.asin ,sku ,boxsku
    ,sales as TotalGross_weekly
    ,profit as TotalProfit_weekly
    ,sales_refund as TotalGross_weekly_refund
    ,SaleCount_weekly
from od_stat_pre a
left join  od_pay b
on a.shopcode  = b.shopcode and a.sellersku =b.sellersku and a.asin = b.asin
)
-- ----------���������

,t_ad as (
select shopcode ,SellerSku ,asin
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily asa
where  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}'
)



, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select  shopcode ,sellersku ,asin
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
		from t_ad  group by shopcode ,sellersku ,asin
	) tmp
)

,lst_pub as (
select t1.shopcode ,t1.sellersku ,t1.asin ,min(MinPublicationDate) MinPublicationDate from  t_orde_week_stat t1 join wt_listing wl
on t1.shopcode=wl.ShopCode and t1.SellerSku=wl.SellerSKU and t1.asin = wl.asin
group by t1.shopcode ,t1.sellersku ,t1.asin )

,t0 as (
select distinct sku, ele_name_priority ����Ԫ�� ,dev_date �������� from prod
)

, res as (
select
	replace( concat('${StartDay}','_',date(date_add('${NextStartDay}',-1)) ),'-','') ����ͳ�Ʒ�Χ
	,t1.shopcode ,t1.sellersku ,t1.asin ,t1.sku ,t1.BoxSku
	, CompanyCode , AccountCode
    , case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ����
    , NodePathName as ����С�� ,SellUserName ������Ա

    ,ifnull(SaleCount_weekly,0) `����`
    ,ifnull(TotalGross_weekly,0) `���۶�`
    ,ifnull(TotalProfit_weekly,0) �����_δ��ad
    ,round( ifnull(TotalProfit_weekly,0) / ifnull(TotalGross_weekly,0) ,4 ) ������_δ��ad
	,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `�����_��ad`
    ,round( ( ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0) ) / ifnull(TotalGross_weekly,0) ,4 ) ������_��ad
    ,ifnull(TotalGross_weekly_refund,0) `�˿��`
    ,ad_sku_Exposure `����ع���`
	,ifnull(ad_Spend,0) `��滨��`
	,ad_TotalSale7Day `������۶�`
	,ad_sku_TotalSale7DayUnit `�������`
	,ad_sku_Clicks `�������`
	,click_rate `�������`
	,adsale_rate `���ת����`
	,ROAS `ROAS`
	,ACOS `ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `CPC`
	,wl.MinPublicationDate ���ӿ���ʱ��
	,t0.����Ԫ��
	,��������
from t_orde_week_stat t1
left join t0 on t1.sku = t0.sku
left join t_ad_stat
	on t1.ShopCode = t_ad_stat.ShopCode
	and t1.sellersku = t_ad_stat.sellersku and t1.asin =t_ad_stat.asin
left join mysql_store ms on t1.shopcode =ms.Code
left join lst_pub wl
    on t1.shopcode=wl.ShopCode and t1.SellerSku=wl.SellerSKU and t1.asin = wl.asin
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_weekly,0) >0  and ifnull(SaleCount_weekly,0)>0
-- 	and t0.sku =1101153.01
order by t1.shopcode ,t1.sellersku
)

select * from res


