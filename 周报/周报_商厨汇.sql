with
t_key as ( -- 报表输出维度
select '商厨汇' dep
)

,t_mysql_store as (  
select 
	Code 
	,case when NodePathName regexp '泉州' then '快百货二部' 
		when NodePathName regexp '成都' then '快百货一部'  else department 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store
)

,t_orde as (
select OrderNumber ,PlatOrderNumber 
	,TotalGross,TotalProfit,TotalExpend
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate
	,pp.SPU
	,ms.*
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
left join wt_products pp on wo.BoxSku=pp.BoxSku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0  and ms.Department = '商厨汇' 
and OrderStatus != '作废'
-- where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
)

-- select round(sum(TotalGross/ExchangeUSD),2) `销售额`
-- 	,round(sum(TotalProfit/ExchangeUSD),2) `利润额`
-- 	,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),2) `利润率`
-- 	,count(distinct OrderNumber)/ datediff('${NextStartDay}','${StartDay}') `日均订单数`
-- from t_orde

-- select * from t_orde

,t_refd as (
select rf.RefundUSDPrice,RefundReason1,RefundReason2 ,ShipDate 
	,ms.*
from import_data.daily_RefundOrders rf 
join t_mysql_store ms 
	on rf.OrderSource=ms.Code and RefundStatus ='已退款'
		and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'  and ms.Department = '商厨汇'
) 

,t_adse as (
select 
	ad.ShopCode ,ad.SellerSKU ,ad.Asin ,ad.Spend as AdSpend ,ad.TotalSale7Day as AdSales 
	,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
	,ms.*
from t_mysql_store ms
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
-- 	on ad.CreatedTime >='${StartDay}' and ad.CreatedTime< '${NextStartDay}'
		and ad.ShopCode = ms.Code   and ms.Department = '商厨汇'
)

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `访客数` ,OrderedCount `访客销量` ,ChildAsin ,ShopCode 
	,ms.*
from import_data.ListingManage lm
join t_mysql_store ms
	on lm.ShopCode=ms.Code and ReportType='周报' and Monday='${StartDay}' and ms.Department = '商厨汇'
-- 	on lm.ShopCode=ms.Code and ReportType='月报' and Monday='${StartDay}' and ms.Department = '商厨汇'
)

-- step2 派生指标 = 统计期+叠加维度+原子指标
,t_sale_stat as ( 
select '商厨汇' dep
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `税后销售额`
	,round( sum((TotalExpend)/ExchangeUSD),2) `订单成本`
	,sum(ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)) `店铺费用扣除`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `订单表除广告外总成本`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `日均订单数`
from t_orde 
)

,t_refd_stat as (
select '商厨汇' dep
	,sum(RefundUSDPrice) `退款金额`
from t_refd 
)

,t_adse_stat as (
select '商厨汇' dep
	,sum(AdSpend) `广告表广告花费` 
	,sum(AdSales) Adsale 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
	,sum(AdClicks) as AdClicks 
	,sum(AdExposure) as AdExposure 
	,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
)

,t_vist_stat as (
select '商厨汇' dep
	,sum(`访客数`) as `访客数`,sum(`访客销量`) `访客销量` 
from t_vist 
)

-- step3 派生指标数据集
, t_merge as (
select t_key.dep 
	,t_sale_stat.`税后销售额` ,t_sale_stat.`订单表除广告外总成本` ,t_sale_stat.`日均订单数` 
	,`订单成本`
	, `店铺费用扣除`
	,t_refd_stat.`退款金额` 
	,t_adse_stat.`广告表广告花费` ,t_adse_stat.Adsale ,t_adse_stat.Acost
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_vist_stat.`访客数` ,t_vist_stat.`访客销量`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_refd_stat on t_key.dep = t_refd_stat.dep
left join t_sale_stat on t_key.dep = t_sale_stat.dep
left join t_vist_stat on t_key.dep = t_vist_stat.dep
)
-- select * from t_merge 

-- step4 销售统计
--select 
--	'${NextStartDay}' `统计日期`
--	,dep `团队` 
--	,round(`税后销售额`-`退款金额`,2) `销售额`
--	,round(`税后销售额`-`退款金额`+(`订单表除广告外总成本`-`广告表广告花费`),2) `利润额`
--	,round( (`税后销售额`-`退款金额`+(`订单表除广告外总成本`-`广告表广告花费`))/(`税后销售额`-`退款金额`) ,3) `毛利率`
--	,`订单成本`
--	,`订单表除广告外总成本`
--	, `店铺费用扣除`
--	,round(`日均订单数`) `日均订单数`
--	,`税后销售额`
--	,round(`退款金额`/`税后销售额`,4) `退款率`
--	,`退款金额`
--	,`广告表广告花费`
--	,round(`广告表广告花费`/Adsale,4) `ACOS`
--	,round(`广告表广告花费`/(`税后销售额`-`退款金额`),4) `广告花费占比`
--	,round(Adsale/(`税后销售额`-`退款金额`),4) `广告业绩占比`	
--	,AdExposure `曝光量`
--	,AdClicks `点击量`
--	,AdSaleUnits `广告销量`
--	,round(AdClicks/AdExposure,4) `广告点击率`
--	,round(AdSaleUnits/AdClicks,4) `广告转化率`
--	,round(`访客销量`/`访客数`,4) `访客转化率`
--	,round(`访客数`) `访客数`
--	,round((`访客数`-AdClicks)/`访客数`,4) `自然流量占比`
--from t_merge

