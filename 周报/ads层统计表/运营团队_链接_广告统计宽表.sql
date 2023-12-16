
with 
t_mysql_store as (  -- 组织架构临时改变前
select 
	Code ,Site 
	,case when NodePathName regexp '泉州' then '快百货泉州' 
		when NodePathName regexp '成都' then '快百货成都'  else department 
		end as department
	,NodePathName
	,department as department_old
	,SellUserName 
from import_data.mysql_store
)

,t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}' 
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  < '${NextStartDay}' 
	and IsMatrix = 0 and IsDeleted = 0 
	and ProjectTeam ='快百货' and Status = 10
)

,t_list as ( -- 新品链接
select  SellerSKU ,ShopCode ,asin 
	, site
	,department 
	, NodePathName 
	, date(MinPublicationDate) pub_day
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
from import_data.wt_listing wl 
join t_mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku -- 只看新品
where 
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
)

,t_ad as ( -- 广告明细
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,	asa.SellerSKU 
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days
	, t_list.site
	, department 
	, NodePathName 
	, SellUserName
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
)

-- 卡在这里 两张表关联不出结果	
select ad.*
from t_list t left join t_ad ad on t.shopcode = ad.shopcode and t.sellersku = ad.sellersku 


,t_ad_stat as (
select t.pub_day 
-- ,t.department ,t.NodePathName, t.SellUserName ,t.site ,t.shopcode ,t.sellersku 
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
from t_list t left join t_ad ad on t.shopcode = ad.shopcode and t.sellersku = ad.sellersku 
group by t.pub_day 
-- ,t.department ,t.NodePathName, t.SellUserName ,t.site ,t.shopcode ,t.sellersku 
) 

select * from t_ad_stat


	select '日期' `分析维度`, pub_day `刊登日` , department 团队
		, case dayofweek(pub_day) when 2 then '周一' when 3 then '周二' when 4 then '周三' when 5 then '周四' 
			when 6 then '周五' when 7 then '周六' when 1 then '周天' end `周序`
		, '' `广告站点` 
		, list_cnt `链接数`
		, round(ad3_sku_cnt/list_cnt,4) as `3天曝光链接占比`
		, round(ad4_sku_cnt/list_cnt,4) as `4天曝光链接占比`
		, round(ad5_sku_cnt/list_cnt,4) as `5天曝光链接占比`
		, round(ad6_sku_cnt/list_cnt,4) as `6天曝光链接占比`
		, round(ad7_sku_cnt/list_cnt,4) as `7天曝光链接占比`
		, round(ad14_sku_cnt/list_cnt,4) as `14天曝光链接占比`
		, round(ad30_sku_cnt/list_cnt,4) as `30天曝光链接占比`
		
		, round(ad3_sku_Exposure/list_cnt,4) as `3天链接平均曝光`
		, round(ad4_sku_Exposure/list_cnt,4) as `4天链接平均曝光`
		, round(ad5_sku_Exposure/list_cnt,4) as `5天链接平均曝光`
		, round(ad6_sku_Exposure/list_cnt,4) as `6天链接平均曝光`
		, round(ad7_sku_Exposure/list_cnt,4) as `7天链接平均曝光`
		, round(ad14_sku_Exposure/list_cnt,4) as `14天链接平均曝光`
		, round(ad30_sku_Exposure/list_cnt,4) as `30天链接平均曝光`
		
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
		select pub_day ,department 
			,count(distinct concat(shopcode,sellersku) ) list_cnt
			-- 有曝光sku
			, count(distinct case when ad3_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad3_sku_cnt
			, count(distinct case when ad4_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad4_sku_cnt
			, count(distinct case when ad5_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad5_sku_cnt
			, count(distinct case when ad6_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad6_sku_cnt
			, count(distinct case when ad7_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad30_sku_cnt
			
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
		from t_ad_stat 
		group by pub_day ,department
		) tmp