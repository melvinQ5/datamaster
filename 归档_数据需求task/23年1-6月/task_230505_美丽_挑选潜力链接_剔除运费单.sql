-- 接下来 将实体改为一条链接 ，注释非需求字段

with t_prod as ( -- 新品:3月后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' 
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

,t_list as ( 
select wl.SPU ,wl.SKU ,BoxSku , wl.MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,DATE_ADD(t_prod.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
left join t_elem on wl.sku =t_elem .sku 
where 
	MinPublicationDate >= '2023-03-01'
	and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
-- 	and NodePathName in ('运营组-泉州1组','运营组-泉州2组','运营组-泉州3组')
	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
)

-- 标记优化类型：2周内3单以上，客单价20美金以上
,t_orde as ( 
select OrderNumber ,wo.PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode ,asin 
	,ExchangeUSD,TransactionType,wo.SellerSku,RefundAmount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,timestampdiff(second,MinPublicationDate,PayTime)/86400 as ord_days -- 订单表中为最早刊登时间
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join (
	select shopcode,SellerSku,MinPublicationDate from t_list group by shopcode,SellerSku,MinPublicationDate 
	) t_list
	on wo.shopcode = t_list.shopcode and wo.SellerSku = t_list.SellerSku 
join t_prod on wo.Product_SKU = t_prod.sKU
left join (select PlatOrderNumber from wt_orderdetails 
	where FeeGross > 0 
		and PayTime >= '2023-03-01' and PayTime < '${NextStartDay}'
		and IsDeleted=0 
	group by PlatOrderNumber 
	) tb on wo.PlatOrderNumber =tb.PlatOrderNumber
where 
	PayTime >= '2023-03-01' and PayTime < '${NextStartDay}'
	and wo.IsDeleted=0 
	and ms.Department = '快百货' 
-- 	and NodePathName in ('运营组-泉州1组','运营组-泉州2组','运营组-泉州3组')
	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
	and tb.PlatOrderNumber is null  -- 剔除运费单
)
-- select count(1) from t_orde  

,t_orde_stat as (
select shopcode  ,sellersku  
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
	
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalProfit /ExchangeUSD end ),2) TotalProfit_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalProfit/ExchangeUSD end ),2) TotalProfit_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalProfit/ExchangeUSD end ),2) TotalProfit_in30d
	
	,count( distinct PlatOrderNumber ) orders_total
	,round( sum( case when PayTime >= '2023-04-01' then TotalGross/ExchangeUSD end ),2 ) TotalGross_Q2
	,round(sum( case when PayTime >= '2023-04-01' then TotalProfit/ExchangeUSD end ),2) TotalProfit_Q2
	
	,count(distinct case when timestampdiff(SECOND,paytime,'${NextStartDay}')/86400  <= 30
		then PlatOrderNumber end) orders_in30d -- 30天内订单数
from t_orde 
group by shopcode  ,sellersku  
)
-- select *
-- from t_orde_stat

,t_ad as ( 
select t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, DevelopLastAuditTime
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days -- 广告 - 刊登
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '2023-03-01' and  asa.CreatedTime < '${NextStartDay}'
)

, t_ad_name as ( -- 广告活动名称
select shopcode  ,sellersku 
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,AdActivityName from t_ad  group by shopcode  ,sellersku  ,AdActivityName) tb 
group by shopcode  ,sellersku 
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `Q2_广告点击率` 
-- 	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `刊登7天广告点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `刊登14天广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,4) as `Q2_广告转化率`
-- 	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `刊登7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `刊登14天广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as `Q2_ROAS` 
-- 	, round(ad7_TotalSale7Day/ad7_Spend,2) as `刊登7天ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `刊登14天ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `Q2_ACOS`
-- 	, round(ad7_Spend/ad7_TotalSale7Day,2) as `刊登7天ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `刊登14天ACOS`
	, round(ad_TotalSale7DayUnit_in30d/ad_Clicks_in30d,6) as `近30天广告转化率`
	, round(ad_TotalSale7Day_in30d/ad_Spend_in30d,4) as `近30天ROAS`
from 
	( select shopcode  ,sellersku 
		-- 曝光量
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when CreatedTime > '2023-04-01' then Exposure end )) as ad_sku_Exposure
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then Exposure end )) as ad_Exposure_in30d
		-- 广告花费
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then cost*ExchangeUSD end),2) as ad7_Spend
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then cost*ExchangeUSD end),2) as ad14_Spend
		, round(sum(case when CreatedTime > '2023-04-01' then cost*ExchangeUSD end ),2) as ad_Spend
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then cost*ExchangeUSD end ),2) as ad_Spend_in30d
		-- 广告销售额
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(case when CreatedTime > '2023-04-01' then TotalSale7Day end),2) as ad_TotalSale7Day
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then TotalSale7Day end ),2) as ad_TotalSale7Day_in30d
		-- 广告销量	
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when CreatedTime > '2023-04-01' then TotalSale7DayUnit end ),2) as ad_sku_TotalSale7DayUnit
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then TotalSale7DayUnit end )) as ad_TotalSale7DayUnit_in30d
		-- 点击量
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when CreatedTime > '2023-04-01' then Clicks end)) as ad_sku_Clicks
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then Clicks end )) as ad_Clicks_in30d
		from t_ad  group by shopcode  ,sellersku 
	) tmp  
)
-- select * from t_ad_stat where spu = 5203342 


,t_merage as (
select 
	replace(concat(right('2023-03-01',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right('2023-03-01',5),'至',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `广告时间范围`
	,left(ta.DevelopLastAuditTime,7) `产品终审月份`
	
	,t_list.shopcode
	,t_list.sellersku `渠道sku`
	,t_list.asin 
	,t_list.site 
	,t_list.AccountCode
	,t_list.NodePathName `销售团队`
	,t_list.SellUserName `首选业务员`
	
-- 	,to_date(DATE_ADD(MinPublicationDate,interval - 8 hour)) `链接首次刊登时间`
	,AdActivityName `拼接广告活动名称`
	
	,orders_in30d `近30天订单量`
	,近30天广告转化率
	,近30天ROAS
	,ad_TotalSale7DayUnit_in30d `近30天广告销量`
	,ad_Clicks_in30d `近30天广告点击量`
	,ad_Spend_in30d `近30天广告花费`
	,ad_TotalSale7Day_in30d `近30天广告销售额`
	
	,ad_sku_Exposure `Q2_曝光量`
-- 	,ad7_sku_Exposure `刊登7天曝光量`
-- 	,ad14_sku_Exposure `刊登14天曝光量`
	
	,ad_Spend `Q2_广告花费`
-- 	,ad7_Spend `刊登7天广告花费`
-- 	,ad14_Spend `刊登14天广告花费`
	 
	,ad_TotalSale7Day `Q2_广告销售额`
-- 	,ad7_TotalSale7Day `刊登7天广告销售额`
-- 	,ad14_TotalSale7Day `刊登14天广告销售额`
	
	,ad_sku_TotalSale7DayUnit `Q2_广告销量`
-- 	,ad7_sku_TotalSale7DayUnit `刊登7天广告销量`
-- 	,ad14_sku_TotalSale7DayUnit `刊登14天广告销量`
	
	,ad_sku_Clicks `Q2_点击量` 
-- 	,ad7_sku_Clicks `刊登7天点击量` 
-- 	,ad14_sku_Clicks `刊登14天点击量`
	
	,`Q2_广告点击率`
-- 	,`刊登7天广告点击率`
-- 	,`刊登14天广告点击率`
	
	,`Q2_广告转化率`
-- 	,`刊登7天广告转化率`
-- 	,`刊登14天广告转化率`
	
	,`Q2_ROAS`
-- 	,`刊登7天ROAS`
-- 	,`刊登14天ROAS`
	
	,`Q2_ACOS`
-- 	,`刊登7天ACOS`
-- 	,`刊登14天ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `Q2_CPC`
-- 	,round(ad7_Spend/ad7_sku_Clicks,2) `刊登7天CPC`
-- 	,round(ad14_Spend/ad14_sku_Clicks,2) `刊登14天CPC`

-- 	,TotalGross_in7d `终审7天销售额usd`
-- 	,TotalGross_in14d `终审14天销售额usd`
-- 	,orders_daily `日均订单量`

-- 	,TotalGross_in7d `刊登7天销售额`
-- 	,TotalGross_in14d `刊登14天销售额`
-- 	,TotalGross_in30d `刊登30天销售额`
-- 	
-- 	,TotalProfit_in7d `刊登7天利润额`
-- 	,TotalProfit_in14d `刊登14天利润额`
-- 	,TotalProfit_in30d `刊登30天利润额`
-- 	
-- 	,round(TotalProfit_in7d/TotalGross_in7d,2) `刊登7天毛利率`
-- 	,round(TotalProfit_in14d/TotalGross_in14d,2) `刊登14天毛利率`
-- 	,round(TotalProfit_in30d/TotalGross_in30d,2) `刊登30天毛利率`
-- 	
 	,TotalGross_Q2 `Q2销售额`
 	,TotalProfit_Q2 `Q2利润额`
 	,round(TotalProfit_Q2/TotalGross_Q2,2) `Q2毛利率`

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
-- join (
-- 	select shopcode  ,sellersku 
-- 	from t_orde_stat where orders_in30d >= 0 -- 30天内出3单
-- 	group by shopcode  ,sellersku
-- 	) ta on t_list.shopcode = ta.shopcode and t_list.sellersku = ta.sellersku 
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
select * from t_merage 

