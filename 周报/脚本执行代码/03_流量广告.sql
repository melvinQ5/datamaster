
with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union select '商厨汇' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)


,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '成都' then '快百货一部'  else '快百货二部' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '快'
)

,t_new_list as ( -- 新刊登链接维度
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.department ,ms.NodePathName
from import_data.wt_listing  eaal 
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0 
)

, t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
		,ad.CreatedTime
		,ms.*
from t_mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code 
) -- 广告表数据会因为延后一天进入，比如3月8日只能查询到3月6日的数据

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `访客数` ,OrderedCount `访客销量` ,ChildAsin ,ShopCode 
	,ms.*
from import_data.ListingManage lm
join t_mysql_store ms
	on lm.ShopCode=ms.Code and ReportType='周报' and Monday='${StartDay}'
-- 	on lm.ShopCode=ms.Code and ReportType='月报' and Monday='${StartDay}'
)

-- 临时查数
-- select NodePathName , shopcode  ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
-- from t_adse 
-- where department regexp '快' 
-- group by NodePathName , shopcode 

-- step2 派生指标 = 统计期+叠加维度+原子指标
, t_adse_stat as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by grouping sets ((),(department))
union 
select '快百货' as department ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse where department regexp '快' 
union
select NodePathName ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse where department regexp '快' 
group by NodePathName 
)
-- select * from t_adse_stat

,t_adse_new_lst as ( -- 新刊登链接广告
select case when t_adse.department IS NULL THEN '公司' ELSE t_adse.department END AS dep 
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(t_adse.department))
union 
select '快百货' as department 
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '快'  
union 
select t_adse.NodePathName
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '快' 
group by t_adse.NodePathName
)



,t_online_list as (
select case when department IS NULL THEN '快百货' ELSE department END AS dep 
	,count(1) `在线链接数`
from (select shopcode,SellerSku,department
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常'
	where department regexp '快' 
	group by shopcode,SellerSku,department
	) tmp1
group by grouping sets ((),(department))
union all 
select NodePathName ,count(1) `在线链接数`
from ( select ShopCode ,SellerSKU ,ms.NodePathName 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常'
	where department regexp '快' 
	group by NodePathName,shopcode,SellerSku
	) tmp1
group by NodePathName
)

, t_ad_cover_list as (
select case when department IS NULL THEN '快百货' ELSE department END AS dep 
	, count(1) `投放广告在线链接数`
from ( 
	select  ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	from erp_amazon_amazon_listing  ta
	join t_mysql_store ms on ta.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常' and ms.department regexp '快'  
	join ( select ListingId 
		from import_data.erp_amazon_amazon_ad_products 
		where AdState = 'enabled' group by ListingId
		) tb on ta.id =tb.ListingId -- 1对多left join,需去重 
	group by ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	) tb 
group by grouping sets ((),(department))

union all 
select NodePathName 
	, count(1) `投放广告在线链接数`
from ( 
	select ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	from erp_amazon_amazon_listing  ta
	join t_mysql_store ms on ta.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '正常' and ms.department regexp '快'  
	join ( select ListingId 
		from import_data.erp_amazon_amazon_ad_products 
		where AdState = 'enabled' group by ListingId
		) tb on ta.id =tb.ListingId -- 1对多left join,需去重 
	group by ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	) tb 
group by NodePathName
)

-- select * from t_ad_cover_list


,t_vist_stat as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` 
from t_vist group by grouping sets ((),(department))
union
select '快百货' as department  ,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` 
from t_vist where department regexp '快'
union
select NodePathName,sum(`访客数`) as `访客数`,sum(`访客销量`) as `访客销量` 
from t_vist where department regexp '快'
group by NodePathName
)

,t_vist_new_lst_stat as (
select case when t_vist.department IS NULL THEN '公司' ELSE t_vist.department END AS dep 
	,sum(`访客数`) as `新刊登访客数`,sum(`访客销量`) `新刊登访客销量` 
from t_vist 
join t_new_list on t_vist.ShopCode =t_new_list.ShopCode and t_vist.ChildAsin =t_new_list.Asin 
group by grouping sets ((),(t_vist.department))
union
select '快百货' as department ,sum(`访客数`) as `新刊登访客数`,sum(`访客销量`) `新刊登访客销量` 
from t_vist 
join t_new_list on t_vist.ShopCode =t_new_list.ShopCode and t_vist.ChildAsin =t_new_list.Asin 
where t_vist.department regexp '快'
union
select t_vist.NodePathName ,sum(`访客数`) as `新刊登访客数`,sum(`访客销量`) `新刊登访客销量` 
from t_vist join t_new_list on t_vist.ShopCode =t_new_list.ShopCode and t_vist.ChildAsin =t_new_list.Asin
where t_vist.department regexp '快'
group by t_vist.NodePathName
)

, t_list_cnt as (
select case when department is null then '公司' else department end as dep
	,count(1) `新刊登链接数`
from (select department,shopcode,SellerSku,Asin from t_new_list 
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) tmp1 
group by grouping sets ((),(department))
union 
select '快百货' as department ,count(1) `新刊登链接数`
from (select shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '快' 
	group by shopcode,SellerSku,Asin 
	) tmp2 
union 
select NodePathName ,count(1) `新刊登链接数`
from (select NodePathName,shopcode,SellerSku,Asin from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'  and department regexp '快' 
	group by NodePathName,shopcode,SellerSku,Asin ) tmp3 
group by NodePathName
)

-- step3 派生指标数据集
, t_merge as (
select t_key.dep 
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_adse_new_lst.new_lst_exp ,t_adse_new_lst.new_lst_clk ,t_adse_new_lst.new_lst_ad_untis
	,t_vist_stat.`访客数` ,t_vist_stat.`访客销量`
	,t_vist_new_lst_stat.`新刊登访客数` ,t_vist_new_lst_stat.`新刊登访客销量`
	,t_list_cnt.`新刊登链接数`
	,t_ad_cover_list.`投放广告在线链接数`
	,t_online_list.`在线链接数`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_adse_new_lst on t_key.dep = t_adse_new_lst.dep
left join t_list_cnt on t_key.dep = t_list_cnt.dep
left join t_vist_stat on t_key.dep = t_vist_stat.dep 
left join t_vist_new_lst_stat on t_key.dep = t_vist_new_lst_stat.dep
left join t_online_list on t_key.dep = t_online_list.dep
left join t_ad_cover_list on t_key.dep = t_ad_cover_list.dep
)

-- step4 复合指标 = 派生指标叠加计算
select 
	'${NextStartDay}' `统计日期`
	,dep `团队` 
	,AdExposure `链接曝光量`
	,AdClicks `广告点击量`
	,AdSaleUnits `广告销量`
	,round(AdClicks/AdExposure,4) `广告点击率`
	,round(AdSaleUnits/AdClicks,4) `广告转化率`
	,new_lst_exp `新刊登广告曝光量`
	,round(new_lst_exp/`新刊登链接数`) `新刊登平均链接曝光量`
	,round(new_lst_clk/new_lst_exp,4) `新刊登广告点击率`
	,round(new_lst_ad_untis/new_lst_clk,4) `新刊登广告转化率`
	,round(`新刊登访客销量`/`新刊登访客数`,4) `新刊登访客转化率`

	,round(`新刊登访客数`) `新刊登访客数`
-- 	,round(`访客销量`/`访客数`,4) `访客转化率`
	,round(`投放广告在线链接数`/`在线链接数`,4) `链接广告投放率`
-- 	,round(`访客数`) `访客数`
-- 	,round((`访客数`-AdClicks)/`访客数`,4) `自然流量占比`
from t_merge
order by `团队` desc 
