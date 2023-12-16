/*
按周、月发版
产品开发终审时间往后推7天，14天，30天，60天，90天
美工：广告点击率，广告转化率，访客转化率
编辑：曝光SKU占比，广告转化率，访客转化率

7天曝光sku占比=（在终审时间7天内的广告表现数据，且曝光量大于0的sku数） ÷（当周开发的sku数）
SKU曝光 >100个 算有效曝光，这个待我再改下代码哈。比如sku10000.01 在7天内曝光量累计达到100，sku10000.01就被有效曝光

*/

with 
tmp_epp as (
select BoxSku , SKU, SPU, DevelopLastAuditTime ,GROUP_CONCAT(Product_Artist) as Product_Artist,GROUP_CONCAT(Product_Editor) as Product_Editor,dev_month,dev_week
from (
select
	 epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
	, case when epps.DevelopStage = '40' and epps.HandleUserName in ('沈庆雯','涂宇佳','张娟','赵敏','黄雪莉') then HandleUserName end Product_Artist
	, case when epps.DevelopStage = '50' and epps.HandleUserName in ('朱玉洁','杜宇','刘冬','沈庆雯','符雪花','赵晋') then HandleUserName end Product_Editor	
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
from import_data.erp_product_products epp
join import_data.erp_product_product_statuses epps on epp.id=epps.ProductId 
where epp.DevelopLastAuditTime >= '2022-05-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epps.DevelopStage in ('40','50')
) tmp 
group by BoxSku , SKU, SPU, DevelopLastAuditTime, dev_month,dev_week
)


, ad as ( 
select asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit, t.SPU, t.SKU, t.BoxSku
	, DevelopLastAuditTime, Product_Artist, Product_Editor
	, timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- 广告
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 7*86400 then '是' else '否' end `是否7天`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 14 then '是' else '否' end `是否14天`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 30 then '是' else '否' end `是否30天`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 60 then '是' else '否' end `是否60天`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 90 then '是' else '否' end `是否90天`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 120 then '是' else '否' end `是否120天`
from import_data.erp_amazon_amazon_listing eaal 
join tmp_epp t on  eaal.sku = t.SKU 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部')
join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
where eaal.ListingStatus = 1  and asa.CreatedTime >= '2022-05-01'
)


-- , ad_group as (  
-- select 
-- from ad 
-- group by ad_days, ShopCode, Asin, SPU, SKU, BoxSku, DevelopLastAuditTime, Product_Artist, Product_Editor
-- )

-- select asa.id ,asa.AdActivityName `广告活动名称`, asa.CreatedTime`广告创建时间`, asa.ShopCode ,asa.Asin , asa.Clicks`点击量`, asa.Exposure`曝光量`, asa.TotalSale7DayUnit`销量`
-- 	, t.SPU, t.SKU, t.BoxSku
-- 	, DevelopLastAuditTime`开发终审时间`, Product_Artist, Product_Editor
-- 	, datediff(asa.CreatedTime,t.DevelopLastAuditTime) as ad_days -- 广告
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 7 then '是' else '否' end `是否7天`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 14 then '是' else '否' end `是否14天`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 30 then '是' else '否' end `是否30天`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 60 then '是' else '否' end `是否60天`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 90 then '是' else '否' end `是否90天`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 120 then '是' else '否' end `是否120天`
-- from import_data.erp_amazon_amazon_listing eaal 
-- join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
-- join tmp_epp t on  eaal.sku = t.SKU 
-- join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部')
-- where eaal.ListingStatus = 1  and asa.CreatedTime >= '2022-10-17'


-- -- 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
select * from (
	select '日期' `分析维度`, dev_month `开发月`, '合计' `美工`, '合计' `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad60_sku_cnt/dev_cnt,4) as `60天曝光SKU占比`, round(ad90_sku_cnt/dev_cnt,4) as `90天曝光SKU占比`, round(ad120_sku_cnt/dev_cnt,4) as `120天曝光SKU占比`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		, round(ad60_sku_Clicks/ad60_sku_Exposure,4) as `60天点击率`, round(ad90_sku_Clicks/ad90_sku_Exposure,4) as `90天点击率`, round(ad120_sku_Clicks/ad120_sku_Exposure,4) as `120天点击率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		, round(ad60_sku_TotalSale7DayUnit/ad60_sku_Clicks,4) as `60天转化率`, round(ad90_sku_TotalSale7DayUnit/ad90_sku_Clicks,4) as `90天转化率`, round(ad120_sku_TotalSale7DayUnit/ad120_sku_Clicks,4) as `120天转化率`
		, ad7_sku_Exposure `7天曝光量`, ad14_sku_Exposure `14天曝光量`, ad30_sku_Exposure `30天曝光量`, ad60_sku_Exposure `60天曝光量`, ad90_sku_Exposure `90天曝光量`, ad120_sku_Exposure `120天曝光量`
		, ad7_sku_Clicks `7天点击量`, ad14_sku_Clicks `14天点击量`, ad30_sku_Clicks `30天点击量`, ad60_sku_Clicks `60天点击量`, ad90_sku_Clicks `90天点击量`, ad120_sku_Clicks `120天点击量`
		, ad7_sku_TotalSale7DayUnit `7天销量`, ad14_sku_TotalSale7DayUnit `14天销量`, ad30_sku_TotalSale7DayUnit `30天销量`, ad60_sku_TotalSale7DayUnit `60天销量`, ad90_sku_TotalSale7DayUnit `90天销量`, ad120_sku_TotalSale7DayUnit `120天销量`
		from ( 
		select dev_month
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			, count(distinct case when ad60_sku_Exposure > 100 then BoxSKU end) as ad60_sku_cnt
			, count(distinct case when ad90_sku_Exposure > 100 then BoxSKU end) as ad90_sku_cnt
			, count(distinct case when ad120_sku_Exposure > 100 then BoxSKU end) as ad120_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure, sum(ad60_sku_Exposure) as ad60_sku_Exposure, sum(ad90_sku_Exposure) as ad90_sku_Exposure, sum(ad120_sku_Exposure) as ad120_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks, sum(ad60_sku_Clicks) as ad60_sku_Clicks, sum(ad90_sku_Clicks) as ad90_sku_Clicks, sum(ad120_sku_Clicks) as ad120_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit, sum(ad60_sku_TotalSale7DayUnit) as ad60_sku_TotalSale7DayUnit, sum(ad90_sku_TotalSale7DayUnit) as ad90_sku_TotalSale7DayUnit, sum(ad120_sku_TotalSale7DayUnit) as ad120_sku_TotalSale7DayUnit
		from 
			( select t.dev_month , ad.BoxSku,t.BoxSku as t_BoxSku
			-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Exposure end)) as ad60_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Exposure end)) as ad90_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Exposure end)) as ad120_sku_Exposure
				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Clicks end)) as ad60_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Clicks end)) as ad90_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Clicks end)) as ad120_sku_Clicks
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then TotalSale7DayUnit end)) as ad60_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then TotalSale7DayUnit end)) as ad90_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then TotalSale7DayUnit end)) as ad120_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_month ,ad.BoxSku,t.BoxSku
			) tmp1
		group by dev_month
		) tmp
union all 
	select '日期\美工' `分析维度`, dev_month `开发月`, Product_Artist `美工`, '合计' `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad60_sku_cnt/dev_cnt,4) as `60天曝光SKU占比`, round(ad90_sku_cnt/dev_cnt,4) as `90天曝光SKU占比`, round(ad120_sku_cnt/dev_cnt,4) as `120天曝光SKU占比`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		, round(ad60_sku_Clicks/ad60_sku_Exposure,4) as `60天点击率`, round(ad90_sku_Clicks/ad90_sku_Exposure,4) as `90天点击率`, round(ad120_sku_Clicks/ad120_sku_Exposure,4) as `120天点击率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		, round(ad60_sku_TotalSale7DayUnit/ad60_sku_Clicks,4) as `60天转化率`, round(ad90_sku_TotalSale7DayUnit/ad90_sku_Clicks,4) as `90天转化率`, round(ad120_sku_TotalSale7DayUnit/ad120_sku_Clicks,4) as `120天转化率`
		, ad7_sku_Exposure `7天曝光量`, ad14_sku_Exposure `14天曝光量`, ad30_sku_Exposure `30天曝光量`, ad60_sku_Exposure `60天曝光量`, ad90_sku_Exposure `90天曝光量`, ad120_sku_Exposure `120天曝光量`
		, ad7_sku_Clicks `7天点击量`, ad14_sku_Clicks `14天点击量`, ad30_sku_Clicks `30天点击量`, ad60_sku_Clicks `60天点击量`, ad90_sku_Clicks `90天点击量`, ad120_sku_Clicks `120天点击量`
		, ad7_sku_TotalSale7DayUnit `7天销量`, ad14_sku_TotalSale7DayUnit `14天销量`, ad30_sku_TotalSale7DayUnit `30天销量`, ad60_sku_TotalSale7DayUnit `60天销量`, ad90_sku_TotalSale7DayUnit `90天销量`, ad120_sku_TotalSale7DayUnit `120天销量`
		from ( 
		select dev_month, Product_Artist
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			, count(distinct case when ad60_sku_Exposure > 100 then BoxSKU end) as ad60_sku_cnt
			, count(distinct case when ad90_sku_Exposure > 100 then BoxSKU end) as ad90_sku_cnt
			, count(distinct case when ad120_sku_Exposure > 100 then BoxSKU end) as ad120_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure, sum(ad60_sku_Exposure) as ad60_sku_Exposure, sum(ad90_sku_Exposure) as ad90_sku_Exposure, sum(ad120_sku_Exposure) as ad120_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks, sum(ad60_sku_Clicks) as ad60_sku_Clicks, sum(ad90_sku_Clicks) as ad90_sku_Clicks, sum(ad120_sku_Clicks) as ad120_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit, sum(ad60_sku_TotalSale7DayUnit) as ad60_sku_TotalSale7DayUnit, sum(ad90_sku_TotalSale7DayUnit) as ad90_sku_TotalSale7DayUnit, sum(ad120_sku_TotalSale7DayUnit) as ad120_sku_TotalSale7DayUnit
		from 
			( select t.dev_month , ad.BoxSku, t.Product_Artist,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Exposure end)) as ad60_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Exposure end)) as ad90_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Exposure end)) as ad120_sku_Exposure
				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Clicks end)) as ad60_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Clicks end)) as ad90_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Clicks end)) as ad120_sku_Clicks
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then TotalSale7DayUnit end)) as ad60_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then TotalSale7DayUnit end)) as ad90_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then TotalSale7DayUnit end)) as ad120_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_month ,ad.BoxSku, t.Product_Artist,t.BoxSku
			) tmp1
		group by dev_month,Product_Artist
		) tmp
union all 
	select '日期\编辑' `分析维度`, dev_month `开发月`,  '合计' `美工`, Product_Editor `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad60_sku_cnt/dev_cnt,4) as `60天曝光SKU占比`, round(ad90_sku_cnt/dev_cnt,4) as `90天曝光SKU占比`, round(ad120_sku_cnt/dev_cnt,4) as `120天曝光SKU占比`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		, round(ad60_sku_Clicks/ad60_sku_Exposure,4) as `60天点击率`, round(ad90_sku_Clicks/ad90_sku_Exposure,4) as `90天点击率`, round(ad120_sku_Clicks/ad120_sku_Exposure,4) as `120天点击率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		, round(ad60_sku_TotalSale7DayUnit/ad60_sku_Clicks,4) as `60天转化率`, round(ad90_sku_TotalSale7DayUnit/ad90_sku_Clicks,4) as `90天转化率`, round(ad120_sku_TotalSale7DayUnit/ad120_sku_Clicks,4) as `120天转化率`
		, ad7_sku_Exposure `7天曝光量`, ad14_sku_Exposure `14天曝光量`, ad30_sku_Exposure `30天曝光量`, ad60_sku_Exposure `60天曝光量`, ad90_sku_Exposure `90天曝光量`, ad120_sku_Exposure `120天曝光量`
		, ad7_sku_Clicks `7天点击量`, ad14_sku_Clicks `14天点击量`, ad30_sku_Clicks `30天点击量`, ad60_sku_Clicks `60天点击量`, ad90_sku_Clicks `90天点击量`, ad120_sku_Clicks `120天点击量`
		, ad7_sku_TotalSale7DayUnit `7天销量`, ad14_sku_TotalSale7DayUnit `14天销量`, ad30_sku_TotalSale7DayUnit `30天销量`, ad60_sku_TotalSale7DayUnit `60天销量`, ad90_sku_TotalSale7DayUnit `90天销量`, ad120_sku_TotalSale7DayUnit `120天销量`
		from ( 
		select dev_month, Product_Editor
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			, count(distinct case when ad60_sku_Exposure > 100 then BoxSKU end) as ad60_sku_cnt
			, count(distinct case when ad90_sku_Exposure > 100 then BoxSKU end) as ad90_sku_cnt
			, count(distinct case when ad120_sku_Exposure > 100 then BoxSKU end) as ad120_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure, sum(ad60_sku_Exposure) as ad60_sku_Exposure, sum(ad90_sku_Exposure) as ad90_sku_Exposure, sum(ad120_sku_Exposure) as ad120_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks, sum(ad60_sku_Clicks) as ad60_sku_Clicks, sum(ad90_sku_Clicks) as ad90_sku_Clicks, sum(ad120_sku_Clicks) as ad120_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit, sum(ad60_sku_TotalSale7DayUnit) as ad60_sku_TotalSale7DayUnit, sum(ad90_sku_TotalSale7DayUnit) as ad90_sku_TotalSale7DayUnit, sum(ad120_sku_TotalSale7DayUnit) as ad120_sku_TotalSale7DayUnit
		from 
			( select t.dev_month , ad.BoxSku, t.Product_Editor,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Exposure end)) as ad60_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Exposure end)) as ad90_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Exposure end)) as ad120_sku_Exposure
				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Clicks end)) as ad60_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Clicks end)) as ad90_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Clicks end)) as ad120_sku_Clicks
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then TotalSale7DayUnit end)) as ad60_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then TotalSale7DayUnit end)) as ad90_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then TotalSale7DayUnit end)) as ad120_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_month ,ad.BoxSku, t.Product_Editor,t.BoxSku
			) tmp1
		group by dev_month,Product_Editor
		) tmp
) union_tmp
where `美工` is not null and `编辑` is not null -- 美工编辑人员名单是硬编码的，不含名单外参与过编辑的人员，本数据也是为了评估目前在工作的人 
order by  `分析维度`, `开发月`, `美工`, `编辑`