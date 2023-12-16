
with
t_list as ( -- 刊登时间在2月1日至今
select wl.SPU ,wl.SKU ,wl.BoxSku ,PublicationDate ,MarketType ,SellerSKU ,wl.ShopCode ,asin 
	,DATE_ADD(epp.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
	,ms.AccountCode ,ms.Department ,ms.SellUserName ,ms.Site  ,ms.NodePathName ,ms.ShopStatus 
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
left join erp_product_products epp on wl.sku = epp.sku 
where IsMatrix = 0 and epp.IsDeleted = 0 and ProjectTeam ='快百货' and Status = 10
	and ms.Department = '快百货' 
	and wl.BoxSku in (
		4390461,
		4301024,
		4430400,
		4399848,
		4475424,
		4476812
		)
)

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode ,asin 
	,ExchangeUSD,TransactionType,wo.SellerSku
	,wo.Product_SPU as SPU ,PayTime
	,timestampdiff(SECOND,tmp.PublicationDate,PayTime)/86400 as ord_days 
	,ms.department ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join (
	select shopcode ,sellersku  ,PublicationDate
	from t_list group by shopcode ,sellersku ,PublicationDate
	) tmp 
	on wo.shopcode = tmp.shopcode and wo.sellersku = tmp.sellersku 
where 
-- 	PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and 
	wo.IsDeleted=0 
	and ms.Department = '快百货' 
-- 	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
-- 	and NodePathName in ('快次方-成都销售组')
-- 	and NodePathName in ('快次元-成都销售组')
)

,t_ad as ( 
select t_list.SPU, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.SellerSKU ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
	, DevelopLastAuditTime
	, timestampdiff(SECOND,PublicationDate,asa.CreatedTime)/86400 as ad_days -- 广告
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
)

,t_ad_stat as (
select tmp.* 
	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `刊登7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `刊登14天点击率`
	, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `刊登30天点击率`
	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `刊登7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `刊登14天广告转化率`
	, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `刊登30天广告转化率`
from 
	( select shopcode  ,sellersku 
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
		from t_ad  group by shopcode  ,sellersku 
	) tmp
)

,t_orde_stat as (
select shopcode  ,sellersku 
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
	,count( distinct PlatOrderNumber) orders_total
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
-- 	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30天出单链接数`
	,to_date(min(paytime)) `首次出单时间`
from t_orde 
group by shopcode  ,sellersku 
)

,t_merage as (
select t_list.spu ,t_list.sku 
	,t_list.boxsku
	,ProductName `产品名`
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,t_list.sellersku 
	,t_list.shopcode 
	,t_list.ShopStatus 
	,t_list.site 
-- 	,t_list.AccountCode
-- 	,t_list.department 
	,t_list.NodePathName `团队`
	,t_list.SellUserName `首选业务员`
	,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) `终审时间`
	,to_date(PublicationDate) `刊登时间`
	,`首次出单时间`
	,ad7_sku_Exposure `刊登7天曝光`
	,ad14_sku_Exposure `刊登14天曝光`
	,ad30_sku_Exposure `刊登30天曝光`
	,ad7_sku_Clicks `刊登7天点击` 
	,ad14_sku_Clicks `刊登14天点击`
	,ad30_sku_Clicks `刊登30天点击`
	,`刊登7天点击率`
	,`刊登14天点击率`
	,`刊登30天点击率`
	,ad7_sku_TotalSale7DayUnit `刊登7天广告销量`
	,ad14_sku_TotalSale7DayUnit `刊登14天广告销量`
	,ad30_sku_TotalSale7DayUnit `刊登30天广告销量`
	,`刊登7天广告转化率`
	,`刊登14天广告转化率`
	,`刊登30天广告转化率`
	,TotalGross_in7d `刊登7天销售额usd`
	,TotalGross_in14d `刊登14天销售额usd`
	,TotalGross_in30d `刊登30天销售额usd`
	,orders_total `累计订单量`
	,TotalGross `累计销售额`
	,TotalProfit `累计利润额`
	,Profit_rate `毛利率`
from t_list 
left join 
	(select sku ,ProductName 
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
		,TortType
	from wt_products wp where isdeleted = 0 
	) ta  on t_list.sku =ta.sku
left join t_ad_stat on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
)

-- select count(1)
select * 
from t_merage
order by SPU
