with 
-- step1 数据源处理 
t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
		,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
		,right(ms.Code,2) country ,ms.Market
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
-- 	on ad.CreatedTime >= '${StartDay}' and ad.CreatedTime < '${NextStartDay}'
		and ad.ShopCode = ms.Code 
where ms.Department = '快百货'
) -- 广告表数据会因为延后一天进入，比如3月8日只能查询到3月6日的数据


,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `访客数` ,OrderedCount `访客销量` 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
	,right(ms.Code,2) country ,ms.Market
from import_data.ListingManage lm
inner join import_data.mysql_store ms
	on lm.ShopCode=ms.Code and ReportType='周报' and Monday='${StartDay}'
-- 	on lm.ShopCode=ms.Code and ReportType='月报' and Monday='${StartDay}'
where ms.Department = '快百货'
)

-- step2 派生指标 = 统计期+叠加维度+原子指标
, t_adse_stat as (
select market , country 
	,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by market , country
)

,t_vist_stat as (
select market , country 
	,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` from t_vist 
group by market , country
)

-- step3 派生指标数据集
, t_merge as (
select t_vist_stat.market , t_vist_stat.country 
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_vist_stat.`访客数` ,t_vist_stat.`访客销量`
from t_vist_stat 
left join t_adse_stat on t_adse_stat.country = t_vist_stat.country
)

-- step4 复合指标 = 派生指标叠加计算
select 
	market , country 
	,AdExposure `曝光量`
	,AdClicks `点击量`
	,AdSaleUnits `广告销量`
	,round(AdClicks/AdExposure,4) `广告点击率`
	,round(AdSaleUnits/AdClicks,4) `广告转化率`
	,round(`访客数`) `访客数`
	,round(`访客销量`/`访客数`,4) `访客转化率`
	,round((`访客数`-AdClicks)/`访客数`,4) `自然流量占比`
from t_merge
order by  market , country  desc 