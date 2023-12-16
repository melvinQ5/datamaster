-- 4月广告明细需求

with t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DevelopLastAuditTime
from import_data.erp_product_products 
where DevelopLastAuditTime  >= '${StartDay}'
	and DevelopLastAuditTime < '${NextStartDay}'
	and IsMatrix = 0 and IsDeleted = 0 
	and ProjectTeam ='快百货' and Status = 10
)
-- select * from epp 

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join t_prod on eppaea.sku = t_prod.sku 
group by eppaea.sku 
)

,t_list as ( -- 当月刊登所有链接 （包含新老品）
select wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
left join t_elem on wl.sku =t_elem .sku 
where 
	MinPublicationDate >= '${StartDay}' 
	and MinPublicationDate < '${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and NodePathName regexp '${team}'
    and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
)

,t_orde as ( -- 当月出单 （包含新老品）
select PlatOrderNumber ,TotalGross,TotalProfit
	,ExchangeUSD ,shopcode  ,sellersku  ,OrderStatus 
from import_data.wt_orderdetails wo 
join mysql_store ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and OrderStatus != '作废' 
	and ms.Department = '快百货' 
	and NodePathName regexp '${team}'
)

,t_orde_stat as (
 select shopcode  ,sellersku  
 -- 	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
 -- 	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
 -- 	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
 	,count( distinct PlatOrderNumber ) orders_total
 	,round( sum(TotalGross/ExchangeUSD),2 ) TotalGross
  	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
  	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
 from t_orde 
 group by shopcode  ,sellersku  
)

,t_ad as ( 
select t_list.sku, asa.AdActivityName ,campaignBudget ,abs(cost) cost,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , abs(asa.Clicks) Clicks, asa.Exposure
	,ROAS ,Acost as ACOS ,abs(spend) spend
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days -- 广告 - 刊登
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >='${StartDay}' and asa.CreatedTime<'${NextStartDay}'
)

, t_ad_name as ( -- 广告活动名称
select shopcode  ,sellersku 
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,AdActivityName from t_ad group by shopcode  ,sellersku  ,AdActivityName) tb 
group by shopcode  ,sellersku 
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `累计广告点击率` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `刊登7天广告点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `刊登14天广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `累计广告转化率`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `刊登7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `刊登14天广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as `累计ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `刊登7天ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `刊登14天ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `累计ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `刊登7天ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `刊登14天ACOS`
from 
	( select shopcode  ,sellersku 
		-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(case when 0 < ad_days and ad_days <= 7 then spend end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then spend end),2) as ad14_Spend
		, round(sum( spend ),2) as ad_Spend
		-- 广告销售额
		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- 广告销量	
		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku 
	) tmp  
)
-- select * from t_ad_stat where spu = 5203342 


,t_merage as (
select 
	replace(concat(right(date('${StartDay}'),5),'至',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace( concat(right(date('${StartDay}'),5),'至',if(current_date()='${NextStartDay}',right(date(date_add('${NextStartDay}',-2)),5)  , right(date(date_add('${NextStartDay}',-1)),5) ) ),'-','')  `广告时间范围`
	,left(ta.DevelopLastAuditTime,7) `产品终审月份`
	,t_list.shopcode
	,t_list.sellersku `渠道sku`
	,t_list.asin 
	,t_list.site 
	,t_list.AccountCode
	,t_list.NodePathName `销售团队`
	,t_list.SellUserName `首选业务员`
	
	,date(MinPublicationDate) `链接首次刊登时间`
	,AdActivityName `广告活动名称`

    ,`近14天广告点击率`
	,`近14天广告转化率`
	,ad_sku_Exposure_in14d  `近14天广告曝光量`
	,ad_sku_Clicks_in14d    `近14天广告点击量`
	,ad_TotalSale7Day_in14d `近14天广告销售额`
	,ad_Spend_in14d `近14天广告花费`
	,`近14天CPC`

	,ad_sku_Exposure `累计曝光量`
	,ad7_sku_Exposure `刊登7天曝光量`
	,ad14_sku_Exposure `刊登14天曝光量`
	
	,ad_Spend `累计广告花费`
	,ad7_Spend `刊登7天广告花费`
	,ad14_Spend `刊登14天广告花费`
	
	,ad_TotalSale7Day `累计广告销售额`
	,ad7_TotalSale7Day `刊登7天广告销售额`
	,ad14_TotalSale7Day `刊登14天广告销售额`
	
	,ad_sku_TotalSale7DayUnit `累计广告销量`
	,ad7_sku_TotalSale7DayUnit `刊登7天广告销量`
	,ad14_sku_TotalSale7DayUnit `刊登14天广告销量`
	
	,ad_sku_Clicks `累计点击` 
	,ad7_sku_Clicks `刊登7天点击` 
	,ad14_sku_Clicks `刊登14天点击`
	
	
	,`累计广告点击率`
	,`刊登7天广告点击率`
	,`刊登14天广告点击率`
	
	,`累计广告转化率`
	,`刊登7天广告转化率`
	,`刊登14天广告转化率`
	
	,`累计ROAS`
	,`刊登7天ROAS`
	,`刊登14天ROAS`
	
	,`累计ACOS`
	,`刊登7天ACOS`
	,`刊登14天ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `累计CPC`
	,round(ad7_Spend/ad7_sku_Clicks,2) `刊登7天CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `刊登14天CPC`

-- 	,TotalGross_in7d `终审7天销售额usd`
-- 	,TotalGross_in14d `终审14天销售额usd`
-- 	,orders_daily `日均订单量`

 	,TotalGross `累计销售额`
 	,TotalProfit `累计利润额`
 	,Profit_rate `毛利率`

	,t_list.spu
	,t_list.sku 
	,t_list.boxsku 
	,ProductName 
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,Festival `季节节日`
	,ele_name `元素` 
	,ta.DevelopLastAuditTime `产品终审时间`
	,ta.DevelopUserName `开发人员`
from t_list
left join t_prod on t_list.sku = t_prod.sku 
left join (
	select sku ,case when TortType is null then '未标记' else TortType end TortType ,Festival ,Artist ,Editor 
		,ProductName ,DevelopUserName ,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) as DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
		from import_data.wt_products wp
		where IsDeleted =0  and ProjectTeam='快百货' 
	) ta on t_list.sku =ta.sku 
left join t_ad_stat on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
left join t_ad_name on  t_list.ShopCode = t_ad_name.ShopCode and t_list.SellerSKU = t_ad_name.SellerSKU 
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
)

-- select count(1)
select * 
from t_merage
