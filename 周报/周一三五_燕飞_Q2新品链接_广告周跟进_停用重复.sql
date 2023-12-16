
/*
-- 每周二 （周二才能拿到完整一周广告数据）
链接经营标签类型：
    新品1 '近14天3单+'
    新品2 '除运费客单20usd且近14天2单+'
    全品 '近30天日均0.5单'
    老品 '上周出单天数达4天_或_上周5单同时环比单量达1.5倍'
        1 上周有4天出单都在出单
        2 上周出单5单以上，同时环比再上周增长1.5倍以上
*/

with t_prod as ( -- 新品:3月后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-08-01' 
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

,t_list as ( -- 3月至今终审的链接
select wl.SPU ,wl.SKU ,BoxSku ,MinPublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
	,DATE_ADD(t_prod.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
left join t_elem on wl.sku =t_elem .sku 
where 
	MinPublicationDate>= '2023-08-01' 
	and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and NodePathName regexp '${team}'
)

,t_orde as ( 
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 20 then 1 else 0 end as isOver20usd
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_prod on wo.Product_SKU = t_prod.sKU
where 
	PayTime >= '2023-08-01' and PayTime < '${NextStartDay}'
	and wo.IsDeleted=0 
	and ms.Department = '快百货'  and TransactionType = '付款'
    and NodePathName regexp '${team}'
)

,t_orde_week_stat as ( -- 用于统计订单
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_total
	,count( distinct case when PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) then PlatOrderNumber end ) orders_total_in30d
	,round( sum(salecount),2 ) salecount
	,round( sum(TotalGross/ExchangeUSD),2 ) TotalGross
	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
from t_orde
left join dim_date on dim_date.full_date = date(t_orde.PayTime)
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)
-- select * from t_orde_week_stat;


,t_orde_stat as ( -- 用于筛链接
select shopcode  ,sellersku 
	,count(distinct case when timestampdiff(SECOND,paytime,'${NextStartDay}')/86400  <= 14
		then PlatOrderNumber end) orders_in14d -- 14天内订单数
	,count( distinct case when isOver20usd = 1
		then PlatOrderNumber end ) orders_over_20usd -- 除运费超20美金订单数
from t_orde 
group by shopcode  ,sellersku 
)

,t_ad as ( -- 优化链接对应广告数据
select t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, DevelopLastAuditTime
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days -- 广告 - 刊登
	, dim_date.week_num_in_year ad_stat_week
	, list_type
from (
	select shopcode  ,sellersku ,GROUP_CONCAT(list_type) list_type
	from (
		select shopcode  ,sellersku  ,'近14天3单+' list_type
		from t_orde_stat where orders_in14d >= 3 -- 14天内出3单
		union 
		select shopcode  ,sellersku  ,'除运费客单20usd且近14天2单+' list_type
		from t_orde_stat where orders_over_20usd > 0 and  orders_in14d >= 2
		) tb
	group by shopcode  ,sellersku
	) ta 
join t_list on t_list.ShopCode = ta.ShopCode and t_list.SellerSKU = ta.SellerSKU 
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU
left join dim_date on dim_date.full_date = asa.CreatedTime
where asa.CreatedTime >= '2023-08-01' and  asa.CreatedTime < '${NextStartDay}'
)
-- select * from t_ad;

, t_ad_name as ( -- 广告活动名称
select shopcode  ,sellersku ,ad_stat_week
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,ad_stat_week,AdActivityName from t_ad  group by shopcode  ,sellersku ,ad_stat_week ,AdActivityName) tb 
group by shopcode  ,sellersku ,ad_stat_week
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `累计广告点击率` 
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `累计广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as `累计ROAS` 
	, round(ad_Spend/ad_TotalSale7Day,2) as `累计ACOS`
from 
	( select shopcode  ,sellersku ,ad_stat_week ,list_type
		-- 曝光量
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(cost*ExchangeUSD),2) as ad_Spend
		-- 广告销售额
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- 广告销量	
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku ,ad_stat_week ,list_type
	) tmp  
)
-- select * from t_ad_stat 
-- where spu = 5203342 

,t_merage as (
select
    list_type `运营优化标签`
	,t_list.AccountCode `账号`
	,t_list.NodePathName `销售团队`
	,t_list.SellUserName `首选业务员`
	,t_list.site `站点`
	,t_list.shopcode `店铺简码`
	,t_list.sellersku `渠道sku`
	,t_list.asin
	,t_ad_stat.ad_stat_week `广告统计周`
--      增加当周周一 ！
	,AdActivityName `广告活动名称`
	,ad_sku_Exposure `累计曝光`
	,ad_Spend `累计广告花费`
	,round(ad_Spend/TotalGross,4) `广告花费占比`
	,ad_TotalSale7Day `累计广告销售额`
	,ad_sku_TotalSale7DayUnit `累计广告销量`
	,ad_sku_Clicks `累计点击` 
	,`累计广告点击率`
	,`累计广告转化率`
	,`累计ROAS`
	,`累计ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `累计CPC`
-- 	,orders_daily `日均订单量`
 	,TotalGross `累计销售额`
 	,TotalProfit `累计利润额`
 	,Profit_rate `毛利率`
 	,orders_total `累计订单量`
	,salecount `累计销量`
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
	,replace(concat(right('2023-08-01' ,5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right('2023-08-01' ,5),'至',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `广告时间范围`
	,left(ta.DevelopLastAuditTime,7) `产品终审月份`
from t_ad_stat
left join t_ad_name on  t_ad_stat.ShopCode = t_ad_name.ShopCode and t_ad_stat.SellerSKU = t_ad_name.SellerSKU and t_ad_stat.ad_stat_week = t_ad_name.ad_stat_week
left join t_list on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
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
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
left join t_orde_week_stat on  t_ad_stat.ShopCode = t_orde_week_stat.ShopCode and t_ad_stat.SellerSKU = t_orde_week_stat.SellerSKU 
	and t_ad_stat.ad_stat_week = t_orde_week_stat.pay_week
)

-- select count(1)
select * from t_merage