/*
按周、月发版
产品开发终审时间往后推7天，14天，30天，60天，90天
美工：广告点击率，广告转化率，访客转化率
编辑：曝光SKU占比，广告转化率，访客转化率

7天曝光sku占比=（在终审时间7天内的广告表现数据，且曝光量大于0的sku数） ÷（当周开发的sku数）
*/



with
tmp_epp as ( -- 5月刊登过的产品
select  *
    , DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week
 	, date(date_add(DevelopLastAuditTime,interval -8 hour)) dev_day
from (select wl.BoxSku
   , wl.sku
   , wl.spu
   , Product_Editor
   , Product_Artist
   , min(MinPublicationDate) as DevelopLastAuditTime
from wt_listing wl
join mysql_store ms on wl.ShopCode = ms.code and ms.Department = '快百货'
       left join (select sku, editor as Product_Editor, artist as Product_Artist
                  from import_data.wt_products) staff on wl.sku = staff.sku
left join wt_products wp on wp.sku = wl.sku and wp.ProjectTeam ='快百货' and wp.IsDeleted = 0
where MinPublicationDate >= date_add(current_date(), interval -3 month) and MinPublicationDate < '9999-12-31'
    and wp.DevelopLastAuditTime  >= date_add(MinPublicationDate, interval -3 month)
and wl.IsDeleted = 0
group by wl.BoxSku, wl.sku, wl.spu, Product_Editor, Product_Artist ) t
)

-- tmp_epp as (
-- select BoxSku , SKU, SPU, DevelopLastAuditTime ,GROUP_CONCAT(Product_Artist) as Product_Artist,GROUP_CONCAT(Product_Editor) as Product_Editor,dev_month,dev_week
-- , GROUP_CONCAT(HandleUserName) as HandleUserName
-- from (
-- select
-- 	 epp.BoxSKU
--  	, epp.SKU
--  	, epp.SPU
--  	, epp.DevelopLastAuditTime
--  	, epps.HandleUserName
-- 	, case when epps.DevelopStage = '40' and epps.HandleUserName in ('沈庆雯','涂宇佳','张娟','赵敏','黄雪莉','方鑫','左卓','康祝念','林琪琪','杜金杉','陈倩') then HandleUserName end Product_Artist
-- 	, case when epps.DevelopStage = '50' and epps.HandleUserName in ('朱玉洁','杜宇','刘冬','沈庆雯','符雪花','赵晋','陈俊宇','廖文莉') then HandleUserName end Product_Editor	
--  	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
--  	, if(year(developlastAuditTime)='2022',WEEKOFYEAR(DevelopLastAuditTime)+1,WEEKOFYEAR(DevelopLastAuditTime)) as dev_week 
-- from import_data.erp_product_products epp
-- join import_data.erp_product_product_statuses epps on epp.id=epps.ProductId 
-- where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
-- 	and epps.DevelopStage in ('40','50')
-- ) tmp 
-- group by BoxSku , SKU, SPU, DevelopLastAuditTime, dev_month,dev_week
-- )

, ad as ( 
select asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit, t.SPU, t.SKU, t.BoxSku ,ms.Site
	, DevelopLastAuditTime, Product_Artist, Product_Editor
	, timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- 广告
from import_data.erp_amazon_amazon_listing eaal 
join tmp_epp t on  eaal.sku = t.SKU 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('快百货')
join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
where  asa.CreatedTime >= date_add(current_date(), interval -3 month)
)

-- -- 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
,t_res as (
select * from (
	select '日期' `分析维度`, dev_week `首次刊登周`, '合计' `美工`, '合计' `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7天点击SKU占比`, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14天点击SKU占比`, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30天点击SKU占比`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7天转化SKU占比`, round(ad14_sales_sku_cnt/dev_cnt,4) as `14天转化SKU占比`, round(ad30_sales_sku_cnt/dev_cnt,4) as `30天转化SKU占比`
		
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		, ad7_sku_Exposure `7天曝光量`, ad14_sku_Exposure `14天曝光量`, ad30_sku_Exposure `30天曝光量`
		, ad7_sku_Clicks `7天点击量`, ad14_sku_Clicks `14天点击量`, ad30_sku_Clicks `30天点击量`
		, ad7_sku_TotalSale7DayUnit `7天销量`, ad14_sku_TotalSale7DayUnit `14天销量`, ad30_sku_TotalSale7DayUnit `30天销量`
		from ( 
		select dev_week
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			-- 有点击sku 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			-- 有广告销量sku 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
		from 
			( select t.dev_week , ad.BoxSku,t.BoxSku as t_BoxSku
			-- 曝光量
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				-- 点击量
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				-- 销量	
				, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku,t.BoxSku
			) tmp1
		group by dev_week
		) tmp
union all 
	select '日期\美工' `分析维度`, dev_week `首次刊登周`, Product_Artist `美工`, '合计' `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7天点击SKU占比`, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14天点击SKU占比`, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30天点击SKU占比`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7天转化SKU占比`, round(ad14_sales_sku_cnt/dev_cnt,4) as `14天转化SKU占比`, round(ad30_sales_sku_cnt/dev_cnt,4) as `30天转化SKU占比`

		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		, ad7_sku_Exposure `7天曝光量`, ad14_sku_Exposure `14天曝光量`, ad30_sku_Exposure `30天曝光量`
		, ad7_sku_Clicks `7天点击量`, ad14_sku_Clicks `14天点击量`, ad30_sku_Clicks `30天点击量`
		, ad7_sku_TotalSale7DayUnit `7天销量`, ad14_sku_TotalSale7DayUnit `14天销量`, ad30_sku_TotalSale7DayUnit `30天销量`
		from ( 
		select dev_week, Product_Artist
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			-- 有点击sku 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			-- 有广告销量sku 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt

			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
		from 
			( select t.dev_week , ad.BoxSku, t.Product_Artist,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				-- 点击量
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				-- 销量	
				, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku, t.Product_Artist,t.BoxSku
			) tmp1
		group by dev_week,Product_Artist
		) tmp
		
		
union all 
	select '日期\编辑' `分析维度`, dev_week `首次刊登周`,  '合计' `美工`, Product_Editor `编辑`
		, dev_cnt `sku数`
		, round(ad7_sku_cnt/dev_cnt,4) as `7天曝光SKU占比`, round(ad14_sku_cnt/dev_cnt,4) as `14天曝光SKU占比`, round(ad30_sku_cnt/dev_cnt,4) as `30天曝光SKU占比`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7天点击SKU占比`, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14天点击SKU占比`, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30天点击SKU占比`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7天转化SKU占比`, round(ad14_sales_sku_cnt/dev_cnt,4) as `14天转化SKU占比`, round(ad30_sales_sku_cnt/dev_cnt,4) as `30天转化SKU占比`

		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30天转化率`
		, ad7_sku_Exposure `7天曝光量`, ad14_sku_Exposure `14天曝光量`, ad30_sku_Exposure `30天曝光量`
		, ad7_sku_Clicks `7天点击量`, ad14_sku_Clicks `14天点击量`, ad30_sku_Clicks `30天点击量`
		, ad7_sku_TotalSale7DayUnit `7天销量`, ad14_sku_TotalSale7DayUnit `14天销量`, ad30_sku_TotalSale7DayUnit `30天销量`
		from ( 
		select dev_week, Product_Editor
			, count(distinct t_BoxSku) as dev_cnt
			-- 有曝光sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			-- 有点击sku 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			-- 有广告销量sku 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
		from 
			( select t.dev_week , ad.BoxSku, t.Product_Editor,t.BoxSku as t_BoxSku
				-- 曝光量
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				-- 点击量
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				-- 销量	
				, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU
			group by t.dev_week ,ad.BoxSku, t.Product_Editor,t.BoxSku
			) tmp1
		group by dev_week,Product_Editor
		) tmp
) union_tmp
where `美工` is not null and `编辑` is not null -- 美工编辑人员名单是硬编码的，不含名单外参与过编辑的人员 'dev_cnt' 
order by  `分析维度`, `首次刊登周` desc , `美工`, `编辑`
) 

select * from t_res 