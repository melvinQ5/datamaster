/*
按周、月发版
产品开发终审时间往后推7天，14天，30天，60天，90天
美工：广告点击率，广告转化率，访客转化率
编辑：曝光SKU占比，广告转化率，访客转化率

7天曝光sku占比=（在终审时间7天内的广告表现数据，且曝光量大于0的sku数） ÷（当周开发的sku数）

*/

with 
tmp_epp as (
select BoxSku , SKU, SPU, DevelopLastAuditTime , editor as Product_Editor , artist as Product_Artist 
	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
 	, date(date_add(developlastAuditTime,interval -8 hour)) dev_day
from import_data.wt_products where DevelopLastAuditTime >= '2023-05-01'
)


-- tmp_epp as (
-- select BoxSku , SKU, SPU, DevelopLastAuditTime ,GROUP_CONCAT(Product_Artist) as Product_Artist,GROUP_CONCAT(Product_Editor) as Product_Editor,dev_month,dev_week,dev_day
-- , GROUP_CONCAT(HandleUserName) as HandleUserName
-- from (
-- 	select
-- 		 epp.BoxSKU
-- 	 	, epp.SKU
-- 	 	, epp.SPU
-- 	 	, epp.DevelopLastAuditTime
-- 	 	, epps.HandleUserName
-- 		, case when epps.DevelopStage = '40' and epps.HandleUserName in ('沈庆雯','涂宇佳','张娟','赵敏','黄雪莉','方鑫','左卓','康祝念','林琪琪','杜金杉','陈倩') then HandleUserName end Product_Artist
-- 		, case when epps.DevelopStage = '50' and epps.HandleUserName in ('朱玉洁','杜宇','刘冬','沈庆雯','符雪花','赵晋','陈俊宇','廖文莉') then HandleUserName end Product_Editor	
-- 		, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
-- 	 	, if(year(developlastAuditTime)='2022',WEEKOFYEAR(DevelopLastAuditTime)+1,WEEKOFYEAR(DevelopLastAuditTime)) as dev_week 
-- 	 	, date(date_add(developlastAuditTime,interval -8 hour)) dev_day
-- 	from import_data.erp_product_products epp
-- 	join import_data.erp_product_product_statuses epps on epp.id=epps.ProductId 
-- 	where date_add(developlastAuditTime,interval -8 hour) >= '2023-03-20' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
-- 		and epps.DevelopStage in ('40','50')
-- 	) tmp 
-- group by BoxSku , SKU, SPU, DevelopLastAuditTime, dev_month,dev_week,dev_day
-- )


, ad as ( 
select asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit, t.SPU, t.SKU, t.BoxSku ,ms.Site 
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
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('快百货')
join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
where  asa.CreatedTime >= '2023-03-20'
)



-- -- 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
select * from (
	select '日期' `分析维度`, dev_day `开发日`
		, case dayofweek(dev_day) when 2 then '周一' when 3 then '周二' when 4 then '周三' when 5 then '周四' 
			when 6 then '周五' when 7 then '周六' when 1 then '周天' end `周序`
		, '' `广告站点` 
		, dev_cnt `sku数`
		, dev_spu_cnt `spu数`
		, round(ad3_sku_cnt/dev_cnt,4) as `3天曝光SKU占比`
		, round(ad4_sku_cnt/dev_cnt,4) as `4天曝光SKU占比`
		, round(ad5_sku_cnt/dev_cnt,4) as `5天曝光SKU占比`
		, round(ad6_sku_cnt/dev_cnt,4) as `6天曝光SKU占比`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`
		, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`
		, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		
		, round(ad3_clicks_sku_cnt/dev_cnt,4) as `3天点击SKU占比`
		, round(ad4_clicks_sku_cnt/dev_cnt,4) as `4天点击SKU占比`
		, round(ad5_clicks_sku_cnt/dev_cnt,4) as `5天点击SKU占比`
		, round(ad6_clicks_sku_cnt/dev_cnt,4) as `6天点击SKU占比`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7天点击SKU占比`
		, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14天点击SKU占比`
		, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30天点击SKU占比`
		
		, round(ad3_sales_sku_cnt/dev_cnt,4) as `3天转化SKU占比`
		, round(ad4_sales_sku_cnt/dev_cnt,4) as `4天转化SKU占比`
		, round(ad5_sales_sku_cnt/dev_cnt,4) as `5天转化SKU占比`
		, round(ad6_sales_sku_cnt/dev_cnt,4) as `6天转化SKU占比`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7天转化SKU占比`
		, round(ad14_sales_sku_cnt/dev_cnt,4) as `14天转化SKU占比`
		, round(ad30_sales_sku_cnt/dev_cnt,4) as `30天转化SKU占比`
		
		, round(ad3_sku_Clicks/ad3_sku_Exposure,4) as `3天点击率`
		, round(ad4_sku_Clicks/ad4_sku_Exposure,4) as `4天点击率`
		, round(ad5_sku_Clicks/ad5_sku_Exposure,4) as `5天点击率`
		, round(ad6_sku_Clicks/ad6_sku_Exposure,4) as `6天点击率`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`
		, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`
		, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		
		, round(ad3_sku_TotalSale7DayUnit/ad3_sku_Clicks,4) as `3天转化率`
-- 		, round(ad4_sku_TotalSale7DayUnit/ad4_sku_Clicks,4) as `4天转化率`
-- 		, round(ad5_sku_TotalSale7DayUnit/ad5_sku_Clicks,4) as `5天转化率`
-- 		, round(ad6_sku_TotalSale7DayUnit/ad6_sku_Clicks,4) as `6天转化率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`
		, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`
		, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		
		, ad3_sku_Exposure `3天曝光量`
-- 		, ad4_sku_Exposure `4天曝光量`
-- 		, ad5_sku_Exposure `5天曝光量`
-- 		, ad6_sku_Exposure `6天曝光量`
		, ad7_sku_Exposure `7天曝光量`
		, ad14_sku_Exposure `14天曝光量`
		, ad30_sku_Exposure `30天曝光量`
		
		, ad3_sku_Clicks `3天点击量`
-- 		, ad4_sku_Clicks `4天点击量`
-- 		, ad5_sku_Clicks `5天点击量`
-- 		, ad5_sku_Clicks `6天点击量`
		, ad7_sku_Clicks `7天点击量`
		, ad14_sku_Clicks `14天点击量`
		, ad30_sku_Clicks `30天点击量`
		
		, ad3_sku_TotalSale7DayUnit `3天销量`
-- 		, ad4_sku_TotalSale7DayUnit `4天销量`
-- 		, ad5_sku_TotalSale7DayUnit `5天销量`
-- 		, ad6_sku_TotalSale7DayUnit `6天销量`
		, ad7_sku_TotalSale7DayUnit `7天销量`
		, ad14_sku_TotalSale7DayUnit `14天销量`
		, ad30_sku_TotalSale7DayUnit `30天销量`
		
		from ( 
		select dev_day
			, count(distinct t_BoxSku) as dev_cnt
			, count(distinct SPU) as dev_spu_cnt
			-- 有曝光sku
			, count(distinct case when ad3_sku_Exposure > 100 then BoxSKU end) as ad3_sku_cnt
			, count(distinct case when ad4_sku_Exposure > 100 then BoxSKU end) as ad4_sku_cnt
			, count(distinct case when ad5_sku_Exposure > 100 then BoxSKU end) as ad5_sku_cnt
			, count(distinct case when ad6_sku_Exposure > 100 then BoxSKU end) as ad6_sku_cnt
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			
			-- 有点击sku 
			, count(distinct case when ad3_sku_Clicks > 0 then BoxSKU end) as ad3_clicks_sku_cnt 
			, count(distinct case when ad4_sku_Clicks > 0 then BoxSKU end) as ad4_clicks_sku_cnt 
			, count(distinct case when ad5_sku_Clicks > 0 then BoxSKU end) as ad5_clicks_sku_cnt 
			, count(distinct case when ad6_sku_Clicks > 0 then BoxSKU end) as ad6_clicks_sku_cnt 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			
			-- 有广告销量sku 
			, count(distinct case when ad3_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad3_sales_sku_cnt 
			, count(distinct case when ad4_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad4_sales_sku_cnt 
			, count(distinct case when ad5_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad5_sales_sku_cnt 
			, count(distinct case when ad6_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad6_sales_sku_cnt 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			
			, sum(ad3_sku_Exposure) as ad3_sku_Exposure
			, sum(ad4_sku_Exposure) as ad4_sku_Exposure
			, sum(ad5_sku_Exposure) as ad5_sku_Exposure
			, sum(ad6_sku_Exposure) as ad6_sku_Exposure
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure
			, sum(ad14_sku_Exposure) as ad14_sku_Exposure
			, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			
			, sum(ad3_sku_Clicks) as ad3_sku_Clicks
			, sum(ad4_sku_Clicks) as ad4_sku_Clicks
			, sum(ad5_sku_Clicks) as ad5_sku_Clicks
			, sum(ad6_sku_Clicks) as ad6_sku_Clicks
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks
			, sum(ad14_sku_Clicks) as ad14_sku_Clicks
			, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			
			, sum(ad3_sku_TotalSale7DayUnit) as ad3_sku_TotalSale7DayUnit
			, sum(ad4_sku_TotalSale7DayUnit) as ad4_sku_TotalSale7DayUnit
			, sum(ad5_sku_TotalSale7DayUnit) as ad5_sku_TotalSale7DayUnit
			, sum(ad6_sku_TotalSale7DayUnit) as ad6_sku_TotalSale7DayUnit
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit
			, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit
			, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
			
		from 
			( select t.dev_day , ad.BoxSku,t.BoxSku as t_BoxSku ,t.SPU 
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Exposure end)) as ad3_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Exposure end)) as ad4_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Exposure end)) as ad5_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Exposure end)) as ad6_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure

				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Clicks end)) as ad3_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Clicks end)) as ad4_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Clicks end)) as ad5_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Clicks end)) as ad6_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then TotalSale7DayUnit end)) as ad3_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then TotalSale7DayUnit end)) as ad4_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then TotalSale7DayUnit end)) as ad5_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then TotalSale7DayUnit end)) as ad6_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_day ,ad.BoxSku,t.BoxSku ,t.SPU
			) tmp1
		group by dev_day
		) tmp
	union all 
	select '日期x站点' `分析维度`
		, dev_day `开发日`
		, case dayofweek(dev_day) when 2 then '周一' when 3 then '周二' when 4 then '周三' when 5 then '周四' 
			when 6 then '周五' when 7 then '周六' when 1 then '周天' end `周序`
		, site `广告站点` 
		, dev_cnt `sku数`
		, dev_spu_cnt `spu数`
		, round(ad3_sku_cnt/dev_cnt,4) as `3天曝光SKU占比`
		, round(ad4_sku_cnt/dev_cnt,4) as `4天曝光SKU占比`
		, round(ad5_sku_cnt/dev_cnt,4) as `5天曝光SKU占比`
		, round(ad6_sku_cnt/dev_cnt,4) as `6天曝光SKU占比`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`
		, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`
		, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		
		, round(ad3_clicks_sku_cnt/dev_cnt,4) as `3天点击SKU占比`
		, round(ad4_clicks_sku_cnt/dev_cnt,4) as `4天点击SKU占比`
		, round(ad5_clicks_sku_cnt/dev_cnt,4) as `5天点击SKU占比`
		, round(ad6_clicks_sku_cnt/dev_cnt,4) as `6天点击SKU占比`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7天点击SKU占比`
		, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14天点击SKU占比`
		, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30天点击SKU占比`
		
		, round(ad3_sales_sku_cnt/dev_cnt,4) as `3天转化SKU占比`
		, round(ad4_sales_sku_cnt/dev_cnt,4) as `4天转化SKU占比`
		, round(ad5_sales_sku_cnt/dev_cnt,4) as `5天转化SKU占比`
		, round(ad6_sales_sku_cnt/dev_cnt,4) as `6天转化SKU占比`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7天转化SKU占比`
		, round(ad14_sales_sku_cnt/dev_cnt,4) as `14天转化SKU占比`
		, round(ad30_sales_sku_cnt/dev_cnt,4) as `30天转化SKU占比`
		
		, round(ad3_sku_Clicks/ad3_sku_Exposure,4) as `3天点击率`
		, round(ad4_sku_Clicks/ad4_sku_Exposure,4) as `4天点击率`
		, round(ad5_sku_Clicks/ad5_sku_Exposure,4) as `5天点击率`
		, round(ad6_sku_Clicks/ad6_sku_Exposure,4) as `6天点击率`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`
		, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`
		, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		
		, round(ad3_sku_TotalSale7DayUnit/ad3_sku_Clicks,4) as `3天转化率`
-- 		, round(ad4_sku_TotalSale7DayUnit/ad4_sku_Clicks,4) as `4天转化率`
-- 		, round(ad5_sku_TotalSale7DayUnit/ad5_sku_Clicks,4) as `5天转化率`
-- 		, round(ad6_sku_TotalSale7DayUnit/ad6_sku_Clicks,4) as `6天转化率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`
		, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`
		, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		
		, ad3_sku_Exposure `3天曝光量`
-- 		, ad4_sku_Exposure `4天曝光量`
-- 		, ad5_sku_Exposure `5天曝光量`
-- 		, ad6_sku_Exposure `6天曝光量`
		, ad7_sku_Exposure `7天曝光量`
		, ad14_sku_Exposure `14天曝光量`
		, ad30_sku_Exposure `30天曝光量`
		
		, ad3_sku_Clicks `3天点击量`
-- 		, ad4_sku_Clicks `4天点击量`
-- 		, ad5_sku_Clicks `5天点击量`
-- 		, ad5_sku_Clicks `6天点击量`
		, ad7_sku_Clicks `7天点击量`
		, ad14_sku_Clicks `14天点击量`
		, ad30_sku_Clicks `30天点击量`
		
		, ad3_sku_TotalSale7DayUnit `3天销量`
-- 		, ad4_sku_TotalSale7DayUnit `4天销量`
-- 		, ad5_sku_TotalSale7DayUnit `5天销量`
-- 		, ad6_sku_TotalSale7DayUnit `6天销量`
		, ad7_sku_TotalSale7DayUnit `7天销量`
		, ad14_sku_TotalSale7DayUnit `14天销量`
		, ad30_sku_TotalSale7DayUnit `30天销量`
		
		from ( 
		select dev_day ,site
			, count(distinct t_BoxSku) as dev_cnt
			, count(distinct SPU) as dev_spu_cnt
			-- 有曝光sku
			, count(distinct case when ad3_sku_Exposure > 100 then BoxSKU end) as ad3_sku_cnt
			, count(distinct case when ad4_sku_Exposure > 100 then BoxSKU end) as ad4_sku_cnt
			, count(distinct case when ad5_sku_Exposure > 100 then BoxSKU end) as ad5_sku_cnt
			, count(distinct case when ad6_sku_Exposure > 100 then BoxSKU end) as ad6_sku_cnt
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			
			-- 有点击sku 
			, count(distinct case when ad3_sku_Clicks > 0 then BoxSKU end) as ad3_clicks_sku_cnt 
			, count(distinct case when ad4_sku_Clicks > 0 then BoxSKU end) as ad4_clicks_sku_cnt 
			, count(distinct case when ad5_sku_Clicks > 0 then BoxSKU end) as ad5_clicks_sku_cnt 
			, count(distinct case when ad6_sku_Clicks > 0 then BoxSKU end) as ad6_clicks_sku_cnt 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			
			-- 有广告销量sku 
			, count(distinct case when ad3_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad3_sales_sku_cnt 
			, count(distinct case when ad4_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad4_sales_sku_cnt 
			, count(distinct case when ad5_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad5_sales_sku_cnt 
			, count(distinct case when ad6_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad6_sales_sku_cnt 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			
			, sum(ad3_sku_Exposure) as ad3_sku_Exposure
			, sum(ad4_sku_Exposure) as ad4_sku_Exposure
			, sum(ad5_sku_Exposure) as ad5_sku_Exposure
			, sum(ad6_sku_Exposure) as ad6_sku_Exposure
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure
			, sum(ad14_sku_Exposure) as ad14_sku_Exposure
			, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			
			, sum(ad3_sku_Clicks) as ad3_sku_Clicks
			, sum(ad4_sku_Clicks) as ad4_sku_Clicks
			, sum(ad5_sku_Clicks) as ad5_sku_Clicks
			, sum(ad6_sku_Clicks) as ad6_sku_Clicks
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks
			, sum(ad14_sku_Clicks) as ad14_sku_Clicks
			, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			
			, sum(ad3_sku_TotalSale7DayUnit) as ad3_sku_TotalSale7DayUnit
			, sum(ad4_sku_TotalSale7DayUnit) as ad4_sku_TotalSale7DayUnit
			, sum(ad5_sku_TotalSale7DayUnit) as ad5_sku_TotalSale7DayUnit
			, sum(ad6_sku_TotalSale7DayUnit) as ad6_sku_TotalSale7DayUnit
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit
			, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit
			, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
			
		from 
			( select t.dev_day , ad.BoxSku,t.BoxSku as t_BoxSku , t.spu ,site 
				-- 曝光量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Exposure end)) as ad3_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Exposure end)) as ad4_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Exposure end)) as ad5_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Exposure end)) as ad6_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure

				-- 点击量
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Clicks end)) as ad3_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Clicks end)) as ad4_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Clicks end)) as ad5_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Clicks end)) as ad6_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				
				-- 销量	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then TotalSale7DayUnit end)) as ad3_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then TotalSale7DayUnit end)) as ad4_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then TotalSale7DayUnit end)) as ad5_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then TotalSale7DayUnit end)) as ad6_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  
			where site in ('UK','US')
			group by t.dev_day ,ad.BoxSku,t.BoxSku ,ad.site ,t.spu 
			) tmp1
		group by dev_day ,site
		) tmp
) union_tmp
-- where `美工` is not null and `编辑` is not null -- 美工编辑人员名单是硬编码的，不含名单外参与过编辑的人员
order by  `分析维度`, `广告站点`, `开发日` desc