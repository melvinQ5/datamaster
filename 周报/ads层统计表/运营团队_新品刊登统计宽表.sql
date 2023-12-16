/* 
新品分析模块\统计分析表\运营团队_新品刊登统计宽表
定位：分析终审之后的销售表现，以此对照 开发团队_新品终审统计宽表
维度：运营团队 x 刊登产品终审周次 x 刊登站点
	运营团队维度枚举：1级快百货 2级快百货一二部 3级销售小组 4级销售人员
指标：
	刊登
		新刊登链接数
		新刊登SKU数
		新刊登SPU数
	出单
		出单链接数
		出单SKU数
		出单SPU数
	动销
		新刊登新品SKU动销率：
		新刊登新品SPU动销率：
		新刊登新品LST动销率：
	广告投放
		有无曝光
			终审7天曝光LST占比（对已刊登SKU从终审开始统计后续表现，下同）
			终审14天曝光LST占比
			终审30天曝光LST占比
		有曝光链接的广告表现
			终审7/15/30天 花费、曝光、点击、销量、销售额
			终审7/15/30天 点击率、转化率、CPC、ROAS、ACOS	、单链接曝光	
				
主要数据源：链接表、广告明细表
*/

with 
t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
    , dd.week_begin_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour)) = dd.full_date
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}' 
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  < '${NextStartDay}' 
	and IsMatrix = 0 and IsDeleted = 0 
	and ProjectTeam ='快百货' and Status = 10
)

,t_list as ( -- 新品链接
select  SellerSKU ,ShopCode ,asin 
	, site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, NodePathName 
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku -- 只看新品
where 
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
)

,t_ad as ( -- 广告明细
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
	,t_list.site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, NodePathName 
	, SellUserName
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
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
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, NodePathName 
	, SellUserName
from import_data.wt_orderdetails wo 
join t_list on t_list.ShopCode = wo.ShopCode and t_list.SellerSKU = wo.SellerSKU -- 只看快百货 新刊登新品链接的对应订单
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 and OrderStatus != '作废' 
)
-- select * from t_orde 

,t_list_stat as ( -- 刊登数
select concat(ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(site,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	,NodePathName,SellUserName,site,dev_month,dev_week
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode) ) list_cnt
	,count(distinct SKU ) list_sku_cnt
	,count(distinct SPU ) list_spu_cnt
from t_list 
group by grouping sets (
	(NodePathName,dev_month) -- 小组x月
	,(NodePathName,dev_week) -- 小组x周
	,(NodePathName,site,dev_month) -- 小组x站点x月
	,(NodePathName,site,dev_week) -- 小组x站点x周
	,(NodePathName,SellUserName,dev_month) -- 人员x月
	,(NodePathName,SellUserName,dev_week) -- 人员x周
	,(NodePathName,SellUserName,site,dev_month) -- 人员x站点x月
	,(NodePathName,SellUserName,site,dev_week) -- 人员x站点x周
	)
)
-- select * from t_list_stat


,t_orde_stat as ( -- 出单数
select concat(ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(site,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	,NodePathName,SellUserName,site,dev_month,dev_week
	,count(distinct concat(SellerSKU,ShopCode) ) od_list_cnt
	,count(distinct SKU ) od_list_sku_cnt
	,count(distinct SPU ) od_list_spu_cnt
	,count( distinct PlatOrderNumber) orders_total
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
-- 	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
-- 	,round(sum(TotalProfit)/sum(TotalGross) ,4) Profit_rate
from t_orde 
group by grouping sets (
	(NodePathName,dev_month) -- 小组x月
	,(NodePathName,dev_week) -- 小组x周
	,(NodePathName,site,dev_month) -- 小组x站点x月
	,(NodePathName,site,dev_week) -- 小组x站点x周
	,(NodePathName,SellUserName,dev_month) -- 人员x月
	,(NodePathName,SellUserName,dev_week) -- 人员x周
	,(NodePathName,SellUserName,site,dev_month) -- 人员x站点x月
	,(NodePathName,SellUserName,site,dev_week) -- 人员x站点x周
	)
)
-- select * from t_orde_stat 

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `累计广告点击率` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `终审7天广告点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `终审14天广告点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `终审30天广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `累计广告转化率`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `终审7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `终审14天广告转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `终审30天广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as `累计ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `终审7天ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `终审14天ROAS`, round(ad30_TotalSale7Day/ad30_Spend,2) as `终审30天ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `累计ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `终审7天ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `终审14天ACOS`, round(ad30_Spend/ad30_TotalSale7Day,2) as `终审30天ACOS`
from 
	( select concat(ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(site,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
		,NodePathName,SellUserName,site,dev_month,dev_week
		-- 曝光量
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Exposure end)) as ad30_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then cost*ExchangeUSD end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then cost*ExchangeUSD end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then cost*ExchangeUSD end),2) as ad30_Spend
		, round(sum(cost*ExchangeUSD),2) as ad_Spend
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
		group by grouping sets (
			(NodePathName,dev_month) -- 小组x月
			,(NodePathName,dev_week) -- 小组x周
			,(NodePathName,site,dev_month) -- 小组x站点x月
			,(NodePathName,site,dev_week) -- 小组x站点x周
			,(NodePathName,SellUserName,dev_month) -- 人员x月
			,(NodePathName,SellUserName,dev_week) -- 人员x周
			,(NodePathName,SellUserName,site,dev_month) -- 人员x站点x月
			,(NodePathName,SellUserName,site,dev_week) -- 人员x站点x周
			)
	) tmp  
)
-- select * from t_ad_stat

,t_merage as (
select
	case 
		when concat(t_list_stat.NodePathName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.site,t_list_stat.SellUserName,t_list_stat.dev_week) is null then  '运营团队x终审月' 
		when concat(t_list_stat.NodePathName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.site,t_list_stat.SellUserName,t_list_stat.dev_month) is null then  '运营团队x终审周' 
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.SellUserName,t_list_stat.dev_week) is null then  '运营团队x站点x终审月' 
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.SellUserName,t_list_stat.dev_month) is null then  '运营团队x站点x终审周' 
		when concat(t_list_stat.SellUserName,t_list_stat.NodePathName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.site,t_list_stat.dev_week) is null then  '运营人员x终审月'
		when concat(t_list_stat.SellUserName,t_list_stat.NodePathName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.site,t_list_stat.dev_month) is null then  '运营人员x终审周' 
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.SellUserName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.dev_week) is null then  '运营人员x站点x终审月'
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.SellUserName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.dev_month) is null then  '运营人员x站点x终审周' 
	end as `预置分析维度`
	
	,t_list_stat.NodePathName `运营团队`
	,t_list_stat.SellUserName `运营人员`
	,t_list_stat.site `站点`
	,t_list_stat.dev_month `终审月份`
	,t_list_stat.dev_week `终审周次`
	
	
	,round(od_list_cnt/list_cnt,2) `新刊登链接动销率`
	,round(od_list_sku_cnt/list_sku_cnt,2) `新刊登SKU动销率`
	,round(od_list_spu_cnt/list_spu_cnt,2) `新刊登SPU动销率`
	
	,orders_total `累计订单量`
	,TotalGross `累计销售额`
-- 	,TotalProfit `累计利润额`
-- 	,Profit_rate `毛利率`
	
	,list_cnt `刊登链接数`
	,list_sku_cnt `刊登SKU数`
	,list_spu_cnt `刊登SPU数`
	
	,od_list_cnt `出单链接数`
	,od_list_sku_cnt `出单SKU数`
	,od_list_spu_cnt `出单SPU数`
	
	,ad_sku_Exposure `累计曝光`
	,ad7_sku_Exposure `终审7天曝光`
	,ad14_sku_Exposure `终审14天曝光`
	,ad30_sku_Exposure `终审30天曝光`
	
	,ad_sku_Clicks `累计点击` 
	,ad7_sku_Clicks `终审7天点击` 
	,ad14_sku_Clicks `终审14天点击`
	,ad30_sku_Clicks `终审30天点击`
	
	,`累计广告点击率`
	,`终审7天广告点击率`
	,`终审14天广告点击率`
	,`终审30天广告点击率`
	
	,ad_sku_TotalSale7DayUnit `累计广告销量`
	,ad7_sku_TotalSale7DayUnit `终审7天广告销量`
	,ad14_sku_TotalSale7DayUnit `终审14天广告销量`
	,ad30_sku_TotalSale7DayUnit `终审30天广告销量`
	
	,`累计广告转化率`
	,`终审7天广告转化率`
	,`终审14天广告转化率`
	,`终审30天广告转化率`
	
	,ad_Spend `累计广告花费`
	,ad7_Spend `终审7天广告花费`
	,ad14_Spend `终审14天广告花费`
	,ad30_Spend `终审14天广告花费`
	
	,ad_TotalSale7Day `累计广告销售额`
	,ad7_TotalSale7Day `终审7天广告销售额`
	,ad14_TotalSale7Day `终审14天广告销售额`
	,ad30_TotalSale7Day `终审14天广告销售额`
	
	,`累计ROAS`
	,`终审7天ROAS`
	,`终审14天ROAS`
	,`终审30天ROAS`
	
	,`累计ACOS`
	,`终审7天ACOS`
	,`终审14天ACOS`
	,`终审30天ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `累计CPC`
	,round(ad7_Spend/ad7_sku_Clicks,2) `终审7天CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `终审14天CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `终审30天CPC`
	
	,replace(concat(right(date('${StartDay}'),5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right(date('${StartDay}'),5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `终审时间范围`
	,replace(concat(right(date('${StartDay}'),5),'至',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `广告时间范围`


from t_list_stat
left join t_ad_stat on t_list_stat.tbcode =t_ad_stat.tbcode 
left join t_orde_stat on t_list_stat.tbcode =t_orde_stat.tbcode 
)

select t_merage.* ,dd.week_num_in_year as 终审周序号 ,dd.week_begin_date as 对照当周周一
from t_merage
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date)  dd on year('${StartDay}') = dd.year and t_merage.`终审周次` = dd.week_num_in_year
order by `预置分析维度` desc ,`运营团队`,`运营人员`,`站点`,`终审月份`,`终审周次`

