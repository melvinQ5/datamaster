
with 
t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.Name = '夏季'
group by eppaea.sku 
)

,t_prod as ( -- 新品:3月后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
from import_data.wt_products wp 
-- where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}'
where  IsDeleted = 0 
and ProjectTeam ='快百货' 
)

,t_list as ( 
select wl.SPU ,wl.SKU ,BoxSku , wl.MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,month(MinPublicationDate) pub_month
	,date(DevelopLastAuditTime) dev_date ,DevelopUserName
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code  and ms.Site regexp 'UK|DE|FR|US|CA'
join t_prod on wl.sku = t_prod.sku 
where wl.IsDeleted = 0
	and ms.Department = '快百货' and wl.IsDeleted = 0 
-- 	and MinPublicationDate  >= '2021-01-01'
-- 	and MinPublicationDate < '${NextStartDay}'
)

,t_ad as ( -- 广告明细
select  asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS ,Spend 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, ms.SellUserName 
	,WEEKOFYEAR(asa.CreatedTime) crea_week 
	,month(asa.CreatedTime) crea_month 
from import_data.AdServing_Amazon asa 
join t_list on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
join mysql_store ms on ms.Code  = asa.ShopCode and ms.Department = '快百货'
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  < '${NextStartDay}'
)

,t_orde as (  
select 
	PlatOrderNumber ,TotalGross,TotalProfit ,FeeGross ,SaleCount 
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,RefundAmount 
	,ms.SellUserName
	,shopcode
	,wo.SellerSku 
	,WEEKOFYEAR(PayTime) pay_week  
	,month(PayTime) pay_month
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on wo.Product_SKU = t_prod.sKU
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
	and OrderStatus != '作废' and ms.Department = '快百货' and TransactionType = '付款'
)
-- select * from t_orde 'wt_isting'


,t_sale_stat as (
select
	shopcode 
	,sellersku 
	,pay_month 
-- 	,pay_week
	,round(sum(TotalGross/ExchangeUSD),2) `销售额` 
	,round(sum(RefundAmount/ExchangeUSD),2) `退款额` 
	,round(sum(TotalProfit/ExchangeUSD),2) `利润额` 
	,count(distinct PlatOrderNumber) `订单数` 
	,round( sum( FeeGross/ExchangeUSD ),2) `运费收入`
	,round( sum(salecount )) `销量`
from t_orde
group by shopcode,sellersku,pay_month 
)

, t_ad_stat as (
select tmp.* 
	, round(Clicks/Exposure,4) as CTR
	, round(TotalSale7DayUnit/Clicks,6) as CVR
	, round(TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/Clicks,4) as `CPC`
from 
	( select 
		shopcode 
		,sellersku 
		,crea_month 
		-- 曝光量
		, round(sum( Exposure )) as Exposure
		-- 广告花费
		, round(sum( spend),2) as ad_Spend
		-- 广告销售额
		, round(sum( TotalSale7Day ),2) as TotalSale7Day
		-- 广告销量	
		, round(sum( TotalSale7DayUnit )) as TotalSale7DayUnit
		-- 点击量
		, round(sum( Clicks )) as Clicks
		from t_ad 
		group by shopcode,sellersku,crea_month 
	) tmp  
)



,t_merge as ( 
select 
	Site
	,AccountCode 
	,NodePathName 
	,SellUserName 
	,t_list.shopcode 
	,t_list.sellersku 
	,t_list.asin 
	,t_list.sku
	,ele 元素
	,dev_date 终审日期 
	,t_list.DevelopUserName 开发人员
	,date(t_list.MinPublicationDate)  `刊登日期`
	,t_list.dim_month 统计月
	,ta.pay_month 出单月份
	,td.crea_month 广告月份
	,销售额 -- 不含退款
	,利润额  as 利润额_未扣广告 
	,round(利润额/销售额,2) 利润率_未扣广告
	,利润额 - ad_Spend  as 利润额_扣广告
	,round((利润额 - ad_Spend)/销售额,2) 利润率_扣广告
	,订单数
	,销量
	,ifnull(运费收入,0) 运费收入 -- 所有空值都按0填充
	,round(ifnull(运费收入,0)/销售额,2) 运费占比
	,Exposure
	,Clicks 
	,ad_Spend 
	,if(ad_Spend=0,null,round(ad_Spend/销售额,2)) 广告花费占比 -- 所有0值都去除 
	,TotalSale7Day AS 广告销售额_含其他sku
	,TotalSale7DayUnit AS 广告销量_含其他sku
	,CTR
	,CVR 
	,CPC
	,ACOS
	,ROAS
	,round(TotalSale7Day/(销售额-退款额),2) 广告业绩占比
from (
	select t_list.* ,dim_month 
	from t_list 
	cross join ( select distinct month as dim_month from dim_date where year = 2023 and month in (5,6,7) ) dim 
	where t_list.pub_month <= dim_month  
	) t_list 
left join t_sale_stat ta on t_list.shopcode = ta.shopcode and t_list.sellersku = ta.sellersku  and t_list.dim_month = ta.pay_month 
left join t_ad_stat td on t_list.shopcode = td.shopcode and t_list.sellersku = td.sellersku  and t_list.dim_month = td.crea_month 
join t_elem on t_list.sku = t_elem .sku 
)

-- 按链接求和算广告花费 ， 按店铺求和算guang
--  select count(1) from t_merge
select * from t_merge 
