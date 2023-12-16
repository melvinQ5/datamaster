with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '公司' as dep
union
select department as dep from import_data.mysql_store
union
select split_part(NodePathNameFull,'>',2) from import_data.mysql_store
union
select NodePathName from import_data.mysql_store
)

,t_new_list as ( -- 新刊登链接维度
select SKU ,MinPublicationDate ,ShopCode ,SellerSKU ,ASIN 
from import_data.wt_listing wl 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' and length(SKU) > 0 and wl.IsDeleted = 0 
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
)

, t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
		,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code 
)

-- select to_date(CreatedTime) ,count(1)
-- from AdServing_Amazon where CreatedTime > '2023-03-01'
-- group by to_date(CreatedTime) 
-- 
-- select to_date(DorisImportTime) ,count(1)
-- from AdServing_Amazon where CreatedTime > '2023-03-01'
-- group by to_date(DorisImportTime) 

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `访客数` ,OrderedCount `访客销量` 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.ListingManage lm
inner join import_data.mysql_store ms
-- --	on lm.ShopCode=ms.Code and ReportType='周报' and Monday='${StartDay}'
 	on lm.ShopCode=ms.Code and ReportType='月报' and Monday='${StartDay}'
)

-- step2 派生指标 = 统计期+叠加维度+原子指标
, t_adse_stat as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by grouping sets ((),(department))
union 
select dep2 ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by dep2 
union
select NodePathName ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by NodePathName 
)

,t_adse_new_lst as ( -- 新刊登链接广告
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse join t_new_list 
	on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(department))
union 
select dep2
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse join t_new_list 
	on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by dep2
union 
select NodePathName
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse join t_new_list 
	on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by NodePathName
)

,t_vist_stat as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` from t_vist group by grouping sets ((),(department))
union
select dep2 ,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` from t_vist group by dep2
union
select NodePathName,sum(`访客数`) as `访客数`,sum(`访客销量`) as `访客销量` from t_vist group by NodePathName
)

-- step3 派生指标数据集
, t_merge as (
select t_key.dep 
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_adse_new_lst.new_lst_exp ,t_adse_new_lst.new_lst_clk ,t_adse_new_lst.new_lst_ad_untis
	,t_vist_stat.`访客数` ,t_vist_stat.`访客销量`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_adse_new_lst on t_key.dep = t_adse_new_lst.dep
left join t_vist_stat on t_key.dep = t_vist_stat.dep
)

-- step4 复合指标 = 派生指标叠加计算
select 
	'${NextStartDay}' `统计日期`
	,dep `团队` 
	,AdExposure `曝光量`
	,AdClicks `点击量`
	,AdSaleUnits `广告销量`
	,round(AdClicks/AdExposure,4) `广告点击率`
	,round(AdSaleUnits/AdClicks,4) `广告转化率`
	,round(new_lst_clk/new_lst_exp,4) `新刊登广告点击率`
	,round(new_lst_ad_untis/new_lst_clk,4) `新刊登广告转化率`
	,round(`访客数`) `访客数`
	,round(`访客销量`/`访客数`,4) `访客转化率`
	,round((`访客数`-AdClicks)/`访客数`,4) `自然流量占比`
from t_merge
order by `团队` desc 