CREATE  VIEW `ads_Editor_Airtst_AdPerformance_stat` AS 
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
from import_data.wt_listing wl 
join tmp_epp t on  wl.sku = t.SKU 
join import_data.mysql_store ms on wl.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部')
join import_data.wt_adserving_amazon_daily waad  on wl.ShopCode = waad.ShopCode and wl.SellerSKU = waad.SellerSKU and wl.SellerSKU <> ''
where wl.ListingStatus = 1  
and waad.GenerateDate >= '2022-10-03'
)


-- 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
select * from (
	select '日期' `分析维度`, dev_week `开发周`, '合计' `美工`, '合计' `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad7_sku_AdClicks/ad7_sku_AdExposure,4) as `7天点击率`, round(ad14_sku_AdClicks/ad14_sku_AdExposure,4) as `14天点击率`, round(ad30_sku_AdClicks/ad30_sku_AdExposure,4) as `30天点击率`
		, round(ad7_sku_AdSaleUnits/ad7_sku_AdClicks,4) as `7天转化率`, round(ad14_sku_AdSaleUnits/ad14_sku_AdClicks,4) as `14天转化率`, round(ad30_sku_AdSaleUnits/ad30_sku_AdClicks,4) as `30天转化率`
		, ad7_sku_AdExposure `7天曝光量`, ad14_sku_AdExposure `14天曝光量`, ad30_sku_AdExposure `30天曝光量`
		, ad7_sku_AdClicks `7天点击量`, ad14_sku_AdClicks `14天点击量`, ad30_sku_AdClicks `30天点击量`
		, ad7_sku_AdSaleUnits `7天销量`, ad14_sku_AdSaleUnits `14天销量`, ad30_sku_AdSaleUnits `30天销量`
		from ( 
		select dev_week
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_AdExposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_AdExposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_AdExposure > 100 then BoxSKU end) as ad30_sku_cnt
			, sum(ad7_sku_AdExposure) as ad7_sku_AdExposure, sum(ad14_sku_AdExposure) as ad14_sku_AdExposure, sum(ad30_sku_AdExposure) as ad30_sku_AdExposure
			, sum(ad7_sku_AdClicks) as ad7_sku_AdClicks, sum(ad14_sku_AdClicks) as ad14_sku_AdClicks, sum(ad30_sku_AdClicks) as ad30_sku_AdClicks
			, sum(ad7_sku_AdSaleUnits) as ad7_sku_AdSaleUnits, sum(ad14_sku_AdSaleUnits) as ad14_sku_AdSaleUnits, sum(ad30_sku_AdSaleUnits) as ad30_sku_AdSaleUnits
		from 
			( select t.dev_week , ad.BoxSku,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_AdExposure
				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_AdClicks
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_AdSaleUnits
			from tmp_epp t join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku,t.BoxSku
			) tmp1
		group by dev_week
		) tmp
union all 
	select '日期\美工' `分析维度`, dev_week `开发周`, Artist `美工`, '合计' `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad7_sku_AdClicks/ad7_sku_AdExposure,4) as `7天点击率`, round(ad14_sku_AdClicks/ad14_sku_AdExposure,4) as `14天点击率`, round(ad30_sku_AdClicks/ad30_sku_AdExposure,4) as `30天点击率`
		, round(ad7_sku_AdSaleUnits/ad7_sku_AdClicks,4) as `7天转化率`, round(ad14_sku_AdSaleUnits/ad14_sku_AdClicks,4) as `14天转化率`, round(ad30_sku_AdSaleUnits/ad30_sku_AdClicks,4) as `30天转化率`
		, ad7_sku_AdExposure `7天曝光量`, ad14_sku_AdExposure `14天曝光量`, ad30_sku_AdExposure `30天曝光量`
		, ad7_sku_AdClicks `7天点击量`, ad14_sku_AdClicks `14天点击量`, ad30_sku_AdClicks `30天点击量`
		, ad7_sku_AdSaleUnits `7天销量`, ad14_sku_AdSaleUnits `14天销量`, ad30_sku_AdSaleUnits `30天销量`
		from ( 
		select dev_week, Artist
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_AdExposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_AdExposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_AdExposure > 100 then BoxSKU end) as ad30_sku_cnt
			, sum(ad7_sku_AdExposure) as ad7_sku_AdExposure, sum(ad14_sku_AdExposure) as ad14_sku_AdExposure, sum(ad30_sku_AdExposure) as ad30_sku_AdExposure
			, sum(ad7_sku_AdClicks) as ad7_sku_AdClicks, sum(ad14_sku_AdClicks) as ad14_sku_AdClicks, sum(ad30_sku_AdClicks) as ad30_sku_AdClicks
			, sum(ad7_sku_AdSaleUnits) as ad7_sku_AdSaleUnits, sum(ad14_sku_AdSaleUnits) as ad14_sku_AdSaleUnits, sum(ad30_sku_AdSaleUnits) as ad30_sku_AdSaleUnits
			from
			( select t.dev_week , ad.BoxSku, t.Artist,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_AdExposure
				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_AdClicks
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_AdSaleUnits
			from tmp_epp t join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku, t.Artist,t.BoxSku
			) tmp1
		group by dev_week,Artist
		) tmp
union all 
	select '日期\编辑' `分析维度`, dev_week `开发周`,  '合计' `美工`, Editor `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad7_sku_AdClicks/ad7_sku_AdExposure,4) as `7天点击率`, round(ad14_sku_AdClicks/ad14_sku_AdExposure,4) as `14天点击率`, round(ad30_sku_AdClicks/ad30_sku_AdExposure,4) as `30天点击率`
		, round(ad7_sku_AdSaleUnits/ad7_sku_AdClicks,4) as `7天转化率`, round(ad14_sku_AdSaleUnits/ad14_sku_AdClicks,4) as `14天转化率`, round(ad30_sku_AdSaleUnits/ad30_sku_AdClicks,4) as `30天转化率`
		, ad7_sku_AdExposure `7天曝光量`, ad14_sku_AdExposure `14天曝光量`, ad30_sku_AdExposure `30天曝光量`
		, ad7_sku_AdClicks `7天点击量`, ad14_sku_AdClicks `14天点击量`, ad30_sku_AdClicks `30天点击量`
		, ad7_sku_AdSaleUnits `7天销量`, ad14_sku_AdSaleUnits `14天销量`, ad30_sku_AdSaleUnits `30天销量`
		from ( 
		select dev_week, Editor
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_AdExposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_AdExposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_AdExposure > 100 then BoxSKU end) as ad30_sku_cnt
			, sum(ad7_sku_AdExposure) as ad7_sku_AdExposure, sum(ad14_sku_AdExposure) as ad14_sku_AdExposure, sum(ad30_sku_AdExposure) as ad30_sku_AdExposure
			, sum(ad7_sku_AdClicks) as ad7_sku_AdClicks, sum(ad14_sku_AdClicks) as ad14_sku_AdClicks, sum(ad30_sku_AdClicks) as ad30_sku_AdClicks
			, sum(ad7_sku_AdSaleUnits) as ad7_sku_AdSaleUnits, sum(ad14_sku_AdSaleUnits) as ad14_sku_AdSaleUnits, sum(ad30_sku_AdSaleUnits) as ad30_sku_AdSaleUnits
			from
			( select t.dev_week , ad.BoxSku, t.Editor,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_AdExposure
				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_AdClicks
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_AdSaleUnits
			from tmp_epp t join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku, t.Editor,t.BoxSku
			) tmp1
		group by dev_week,Editor
		) tmp
) union_tmp
where `美工` is not null and `编辑` is not null 
order by  `分析维度`, `开发周`, `美工`, `编辑`
