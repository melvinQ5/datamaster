-- wt����˿���ѷ�̯��SKU�� select * from wt_orderdetails where OrderNumber=20230912184143972409 and IsDeleted=0



with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select spu ,sku ,DATE(DevelopLastAuditTime) dev_date ,DevelopLastAuditTime
from import_data.erp_product_products
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsDeleted=0 and ProjectTeam='��ٻ�' and IsMatrix=0
)



,ad as (
select spu,sku,waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits ,waad.AdSpend ,waad.AdSales ,waad.AdProfit
    ,right(ShopCode,2) as site
	, timestampdiff(SECOND,DevelopLastAuditTime,waad.GenerateDate)/86400 as ad_days -- ���
from prod  -- ����ֱ�ӹ��� join ���Ͳ�Ʒ on sku ,��Ϊ���Ƽ���Ч����֮��ʼ����7/14�죬���Ǵӿ��ǿ�ʼ��
join import_data.wt_adserving_amazon_daily waad on prod.sku = waad.sku
-- where waad.GenerateDate >= '${StartDay}' and timestampdiff(SECOND,DevelopLastAuditTime,waad.GenerateDate)/86400 >=0 and waad.IsDeleted=0
)


,ad_stat as (
 select  sku ,site
		-- �ع���
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdExposure end)) as ad21_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdExposure end)) as ad60_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdExposure end)) as ad90_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdExposure end)) as ad120_Exposure
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdClicks end)) as ad21_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdClicks end)) as ad60_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdClicks end)) as ad90_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdClicks end)) as ad120_Clicks
		-- ����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdSaleUnits end)) as ad21_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSaleUnits end)) as ad60_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSaleUnits end)) as ad90_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSaleUnits end)) as ad120_SaleUnits
		-- ����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSpend end)) as ad7_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSpend end)) as ad14_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdSpend end)) as ad21_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSpend end)) as ad30_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSpend end)) as ad60_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSpend end)) as ad90_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSpend end)) as ad120_Spend
		-- ���۶�
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSales end)) as ad7_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSales end)) as ad14_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdSales end)) as ad21_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSales end)) as ad30_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSales end)) as ad60_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSales end)) as ad90_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSales end)) as ad120_Sales
		-- �����
	    , round(sum(case when 0 < ad_days and ad_days <= 7 then AdProfit end)) as ad7_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdProfit end)) as ad14_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdProfit end)) as ad21_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdProfit end)) as ad30_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdProfit end)) as ad60_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdProfit end)) as ad90_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdProfit end)) as ad120_Profit
		from ad  group by sku ,site
)

,od_stat as (
select
    wo.Product_SPU as SPU
    ,wo.Product_Sku as SKU
    ,ms.Site
    ,round( count( distinct case when TransactionType ='����' then PlatOrderNumber end) ) as ������
    ,round( sum( case when TransactionType ='����' then  SaleCount end) ) as ����
    ,round( sum( case when TransactionType ='����' then  TotalGross/ExchangeUSD end) ,2) as ���۶�_������
    ,round( sum( case when TransactionType ='����' then  TotalProfit/ExchangeUSD end) ,2) as �����
    ,round( sum( case when TransactionType ='�˿�' then  RefundAmount/ExchangeUSD end) ,2) as �˿��
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�'
join prod  on wo.Product_Sku = prod.sku
where wo.IsDeleted=0 and wo.TransactionType !='����'
group by wo.Product_SPU ,wo.Product_Sku ,ms.site
)

,merge as (
select t0.sku as sku_merge,t0.site վ�� ,t1.* ,t2.*
from ( select spu ,sku ,site from prod join (select distinct site from mysql_store) ms ) t0
left join od_stat t1 on  t0.sku =t1.sku and t0.Site = t1.site
left join ad_stat t2 on  t0.sku =t2.sku and t0.Site = t2.site
where  coalesce(t1.sku,t2.sku) is not null   -- ȥ��û�г�����û�й����м�¼, ���һ��SKU��û�г���Ҳû�й����ᱻ����ȥ����
)


select prod.SPU as ��Ʒspu ,prod.sku as ��Ʒsku ,prod.dev_date ,merge.*
from prod left join merge on prod.sku =merge.sku_merge


