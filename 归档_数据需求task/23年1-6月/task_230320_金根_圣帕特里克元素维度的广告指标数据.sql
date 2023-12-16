with 
-- step1 数据源处理 
t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku 
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where length(sku) > 0 and eppea.Name  ='圣帕特里克节'
group by  eppaea.sku
)

,t_list as (
select wl.SPU ,wl.SKU ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin ,IsDeleted `是否删除`
from erp_amazon_amazon_listing  wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_elem on wl.sku = t_elem.sku 
where 
-- 	PublicationDate >= '${StartDay}' and PublicationDate < '${NextStartDay}' 
-- 	and wl.IsDeleted = 0 
	ms.Department = '快百货' 
)


,t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure 
		,TotalSale7DayUnit as AdSaleUnits
		,TotalSale7Day
		,Spend
		,CPC
		,t_list.sku
		,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
		,right(ms.Code,2) country ,ms.Market
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad on ad.ShopCode = ms.Code  
join t_list on ad.ShopCode  = t_list.ShopCode and ad.SellerSKU  = t_list.SellerSKU and ad.asin  = t_list.asin
where ms.Department = '快百货' and ad.CreatedTime >= '${StartDay}' and ad.CreatedTime < '${NextStartDay}'
) 

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `访客数` ,OrderedCount `访客销量` 
	,department ,dep2 ,NodePathName 
	,country ,Market ,sku
from (
	select t_list.sku ,TotalCount ,FeaturedOfferPercent ,OrderedCount ,ms.department 
		,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,right(ms.Code,2) country ,ms.Market
	from import_data.ListingManage lm
	inner join import_data.mysql_store ms
		on lm.ShopCode=ms.Code and ReportType='周报' and Monday>='2023-02-26' and Monday <='2023-03-12'
	join t_list on lm.ShopCode  = t_list.ShopCode and lm.ChildAsin  = t_list.asin
	where ms.Department = '快百货'
	union all 
	select t_list.sku ,TotalCount ,FeaturedOfferPercent ,OrderedCount ,ms.department 
		,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,right(ms.Code,2) country ,ms.Market
	from import_data.ListingManage lm
	inner join import_data.mysql_store ms
		on lm.ShopCode=ms.Code and ReportType='月报' and Monday='2023-02-01'
	join t_list on lm.ShopCode  = t_list.ShopCode and lm.ChildAsin  = t_list.asin
	where ms.Department = '快百货'
	) ta 
)
-- step2 派生指标 = 统计期+叠加维度+原子指标
, t_adse_stat as (
select sku ,ShopCode ,SellerSKU ,asin  
	,sum(AdClicks) as AdClicks 
	,sum(AdExposure) as AdExposure
	,sum(AdSaleUnits) as AdSaleUnits
	,sum(TotalSale7Day) as TotalSale7Day
	,sum(Spend) as Spend
	,sum(CPC) as CPC
from t_adse 
group by sku ,ShopCode ,SellerSKU ,asin  
)
-- 
-- ,t_vist_stat as (
-- select sku
-- 	,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` 
-- from t_vist 
-- group by sku
-- )

-- step3 派生指标数据集
-- , t_merge as (
-- select t_vist_stat.sku 
-- 	,,ShopCode ,SellerSKU ,asin  
-- 	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  
-- 	,t_adse_stat.AdSaleUnits
-- 	,t_adse_stat.Spend
-- 	,t_adse_stat.TotalSale7Day
-- 	,t_vist_stat.`访客数` ,t_vist_stat.`访客销量`
-- from t_vist_stat 
-- join t_adse_stat on t_adse_stat.sku = t_vist_stat.sku
-- )

-- step4 复合指标 = 派生指标叠加计算
select 
	sku
	,ShopCode ,SellerSKU ,asin  
	,AdExposure `曝光量`
	,AdClicks `点击量`
	,AdSaleUnits `广告销量`
	,Spend `广告花费`
	,CPC `点击CPC`
	,TotalSale7Day `广告销售额`
	,round(AdClicks/AdExposure,4) `广告点击率`
	,round(AdSaleUnits/AdClicks,4) `广告转化率`
-- 	,round(`访客数`) `访客数`
-- 	,round(`访客销量`/`访客数`,4) `访客转化率`
-- 	,round((`访客数`-AdClicks)/`访客数`,4) `自然流量占比`
from t_adse_stat

-- order by  sku  desc 