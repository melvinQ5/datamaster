-- 周度美工复盘优质文案数据源

with 
t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime ,ProductName ,DevelopUserName ,Artist ,Editor
	, case when ProductStatus = 0 then '正常'
			when ProductStatus = 2 then '停产'
			when ProductStatus = 3 then '停售'
			when ProductStatus = 4 then '暂时缺货'
			when ProductStatus = 5 then '清仓'
		end as `产品状态`
    , week_num_in_year dev_week
	, left(DevelopLastAuditTime,7) dev_month
from import_data.wt_products wp
join dim_date dd on date(wp.DevelopLastAuditTime) = dd.full_date
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-01-01' 
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  < '${NextStartDay}' 
	 and IsDeleted = 0 
	and ProjectTeam ='快百货' 
)

,t_list as ( -- 新品链接
select  SellerSKU ,ShopCode ,asin 
	, site
	,  dev_week
	,  dev_month
	, NodePathName 
	, case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code
join t_prod on wl.sku = t_prod.sku -- 只看新品
where 
	MinPublicationDate>= '2023-01-01'  
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
)

,t_ad as ( -- 广告明细
select t_list.spu, t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
	,t_list.site
	,  dev_week
	,  dev_month
	, NodePathName 
	, SellUserName
	, Spend 
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU

where asa.CreatedTime >=  '2023-01-01'  
)

,t_orde as (  -- 新刊登链接对应订单
select 
	t_list.SellerSKU ,t_list.ShopCode ,t_list.asin 
	,PlatOrderNumber ,TotalGross,TotalProfit
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,t_list.site
	,dev_month
	, NodePathName 
	, SellUserName
from import_data.wt_orderdetails wo 
join t_list on t_list.ShopCode = wo.ShopCode and t_list.SellerSKU = wo.SellerSKU -- 只看快百货 新刊登新品链接的对应订单
where PayTime >=  '2023-01-01'   and wo.IsDeleted=0 and OrderStatus != '作废' 
)
-- select * from t_orde 

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `累计广告点击率` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `终审7天广告点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `终审14天广告点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `终审30天广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `累计广告转化率`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `终审7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `终审14天广告转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `终审30天广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as `累计ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `终审7天ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `终审14天ROAS`, round(ad30_TotalSale7Day/ad30_Spend,2) as `终审30天ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `累计ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `终审7天ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `终审14天ACOS`, round(ad30_Spend/ad30_TotalSale7Day,2) as `终审30天ACOS`
from 
	( select  asin , site ,sku ,spu 
		-- 曝光量
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Exposure end)) as ad30_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Spend end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Spend end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Spend end),2) as ad30_Spend
		, round(sum(Spend),2) as ad_Spend
		-- 广告销售额
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7Day end),2) as ad30_TotalSale7Day
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- 广告销量	
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7DayUnit end),2) as ad30_sku_TotalSale7DayUnit
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Clicks end)) as ad30_sku_Clicks
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  
		group by asin , site ,sku ,spu 
	) tmp  
)
-- select * from t_ad_stat

,t_groupby_spu as (
select a.spu 
	, round(sum(ad14_sku_TotalSale7DayUnit)/sum(ad14_sku_Clicks),6) as `终审14天广告转化率_spu`
	, round(sum(ad14_sku_Clicks)/sum(ad14_sku_Exposure),4) as `终审14天广告点击率_spu`
	, sum(ad14_sku_Exposure) 终审14天曝光量_spu
from t_ad_stat a 
left join t_prod b on a.sku = b.sku 
group by a.spu 
)


-- -- 编辑导出
 select a.SPU ,DevelopUserName as 开发人员 ,ProductName as 产品名 ,Artist as 美工 ,Editor as 编辑 , 产品状态 ,asin ,site
 ,WEEKOFYEAR(DevelopLastAuditTime)+1 终审周次
 ,ad7_sku_Exposure 终审7天曝光量
 ,ad14_sku_Exposure 终审14天曝光量
 ,ad7_sku_Clicks 终审7天点击量
 ,ad7_sku_Clicks 终审14天点击量
 ,终审7天广告点击率
 ,终审14天广告点击率
 ,终审7天广告转化率
 ,终审14天广告转化率
 ,ad7_sku_TotalSale7DayUnit 终审7天广告销量
 ,ad14_sku_TotalSale7DayUnit 终审14天广告销量
 from t_ad_stat a
 left join t_prod b on a.sku = b.sku
 left join t_groupby_spu c on a.spu =c.spu
 left join dim_date dd on date(DevelopLastAuditTime) = dd.date_key 
 where 终审14天广告转化率_spu >= 0.05
 and 终审14天曝光量_spu >= 500
 and week_num_in_year = WEEKOFYEAR('${NextStartDay}')+1 -3 -- 统计周往前推两周，留够14天 -- 周次+1
