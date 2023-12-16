CREATE  VIEW `ads_Editor_Airtst_AdPerformance_detail` AS 

with 
tmp_epp as (
select BoxSku , SKU, SPU, DevelopLastAuditTime , Artist ,Editor 
	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
from import_data.wt_products wp 
where IsDeleted =0 and DevelopLastAuditTime >= '2022-10-03'
)  



, ad as ( 
select waad.GenerateDate, waad.ShopCode ,waad.Asin , waad.AdClicks , waad.AdExposure , waad.AdSaleUnits , t.SPU, t.SKU, t.BoxSku
	, DevelopLastAuditTime, t.Artist, t.Editor
	, datediff(waad.GenerateDate,t.DevelopLastAuditTime) as ad_days -- ���
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 7 then '��' else '��' end `�Ƿ�7��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 14 then '��' else '��' end `�Ƿ�14��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 30 then '��' else '��' end `�Ƿ�30��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 60 then '��' else '��' end `�Ƿ�60��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 90 then '��' else '��' end `�Ƿ�90��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 120 then '��' else '��' end `�Ƿ�120��`
from import_data.wt_listing wl 
join tmp_epp t on  wl.sku = t.SKU 
join import_data.mysql_store ms on wl.ShopCode = ms.code and ms.Department in ('���۶���', '��������')
join import_data.wt_adserving_amazon_daily waad  on wl.ShopCode = waad.ShopCode and wl.SellerSKU = waad.SellerSKU and wl.SellerSKU <> ''
where wl.ListingStatus = 1  
and waad.GenerateDate >= '2022-10-03'
)


-- ��1 ���ദ��sku��ϸ
select t.dev_week`������` ,t.sku ,t.BoxSku, t.DevelopLastAuditTime `��������ʱ��`, ad.Artist `����`, ad.Editor `�༭`
	-- �ع���
	, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as `7���ع���` -- ad7_sku_Exposure 
	, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as `14���ع���` -- ad14_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as `30���ع���` -- ad30_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 60 then AdExposure end)) as `60���ع���` -- ad60_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 90 then AdExposure end)) as `90���ع���` -- ad90_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 120 then AdExposure end)) as `120���ع���` -- ad120_sku_Exposure
	-- �����
	, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as `7������` -- ad7_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as `14������` -- ad14_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as `30������` -- ad30_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 60 then AdClicks end)) as `60������` -- ad60_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 90 then AdClicks end)) as `90������` -- ad90_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 120 then AdClicks end)) as `120������` -- ad120_sku_Clicks
	-- ����	
	, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as `7������` -- ad7_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as `14������` -- ad14_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as `30������` -- ad30_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSaleUnits end)) as `60������` -- ad60_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSaleUnits end)) as `90������` -- ad90_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSaleUnits end)) as `120������` -- ad120_sku_TotalSale7DayUnit
from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  
-- where ad.Product_Artist is not null and ad.Product_Editor is not null 
group by t.dev_week ,t.sku , t.BoxSku, t.DevelopLastAuditTime, ad.Artist, ad.Editor
