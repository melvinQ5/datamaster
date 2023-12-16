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
	, datediff(waad.GenerateDate,t.DevelopLastAuditTime) as ad_days -- 广告
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 7 then '是' else '否' end `是否7天`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 14 then '是' else '否' end `是否14天`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 30 then '是' else '否' end `是否30天`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 60 then '是' else '否' end `是否60天`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 90 then '是' else '否' end `是否90天`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 120 then '是' else '否' end `是否120天`
from import_data.wt_listing wl 
join tmp_epp t on  wl.sku = t.SKU 
join import_data.mysql_store ms on wl.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部')
join import_data.wt_adserving_amazon_daily waad  on wl.ShopCode = waad.ShopCode and wl.SellerSKU = waad.SellerSKU and wl.SellerSKU <> ''
where wl.ListingStatus = 1  
and waad.GenerateDate >= '2022-10-03'
)


-- 表1 美编处理sku明细
select t.dev_week`开发周` ,t.sku ,t.BoxSku, t.DevelopLastAuditTime `开发终审时间`, ad.Artist `美工`, ad.Editor `编辑`
	-- 曝光量
	, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as `7天曝光量` -- ad7_sku_Exposure 
	, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as `14天曝光量` -- ad14_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as `30天曝光量` -- ad30_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 60 then AdExposure end)) as `60天曝光量` -- ad60_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 90 then AdExposure end)) as `90天曝光量` -- ad90_sku_Exposure
	, round(sum(case when 0 < ad_days and ad_days <= 120 then AdExposure end)) as `120天曝光量` -- ad120_sku_Exposure
	-- 点击量
	, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as `7天点击量` -- ad7_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as `14天点击量` -- ad14_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as `30天点击量` -- ad30_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 60 then AdClicks end)) as `60天点击量` -- ad60_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 90 then AdClicks end)) as `90天点击量` -- ad90_sku_Clicks
	, round(sum(case when 0 < ad_days and ad_days <= 120 then AdClicks end)) as `120天点击量` -- ad120_sku_Clicks
	-- 销量	
	, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as `7天销量` -- ad7_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as `14天销量` -- ad14_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as `30天销量` -- ad30_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSaleUnits end)) as `60天销量` -- ad60_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSaleUnits end)) as `90天销量` -- ad90_sku_TotalSale7DayUnit
	, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSaleUnits end)) as `120天销量` -- ad120_sku_TotalSale7DayUnit
from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  
-- where ad.Product_Artist is not null and ad.Product_Editor is not null 
group by t.dev_week ,t.sku , t.BoxSku, t.DevelopLastAuditTime, ad.Artist, ad.Editor
