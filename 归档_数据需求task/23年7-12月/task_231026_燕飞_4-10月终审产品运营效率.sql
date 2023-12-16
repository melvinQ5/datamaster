-- wt表的退款额已分摊到SKU上 select * from wt_orderdetails where OrderNumber=20230912184143972409 and IsDeleted=0



with
prod as ( -- 商品运营组推送  SPUx周次
select spu ,sku ,DATE(DevelopLastAuditTime) dev_date ,DevelopLastAuditTime
from import_data.erp_product_products
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsDeleted=0 and ProjectTeam='快百货' and IsMatrix=0
)



,ad as (
select spu,sku,waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits ,waad.AdSpend ,waad.AdSales ,waad.AdProfit
    ,right(ShopCode,2) as site
	, timestampdiff(SECOND,DevelopLastAuditTime,waad.GenerateDate)/86400 as ad_days -- 广告
from prod  -- 这里直接广告表 join 推送产品 on sku ,因为是推荐生效日期之后开始算广告7/14天，不是从刊登开始算
join import_data.wt_adserving_amazon_daily waad on prod.sku = waad.sku
-- where waad.GenerateDate >= '${StartDay}' and timestampdiff(SECOND,DevelopLastAuditTime,waad.GenerateDate)/86400 >=0 and waad.IsDeleted=0
)


,ad_stat as (
 select  sku ,site
		-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdExposure end)) as ad21_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdExposure end)) as ad60_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdExposure end)) as ad90_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdExposure end)) as ad120_Exposure
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdClicks end)) as ad21_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdClicks end)) as ad60_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdClicks end)) as ad90_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdClicks end)) as ad120_Clicks
		-- 销量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdSaleUnits end)) as ad21_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSaleUnits end)) as ad60_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSaleUnits end)) as ad90_SaleUnits
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSaleUnits end)) as ad120_SaleUnits
		-- 花费
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSpend end)) as ad7_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSpend end)) as ad14_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdSpend end)) as ad21_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSpend end)) as ad30_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSpend end)) as ad60_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSpend end)) as ad90_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSpend end)) as ad120_Spend
		-- 销售额
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSales end)) as ad7_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSales end)) as ad14_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdSales end)) as ad21_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSales end)) as ad30_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSales end)) as ad60_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSales end)) as ad90_Sales
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdSales end)) as ad120_Sales
		-- 利润额
	    , round(sum(case when 0 < ad_days and ad_days <= 7 then AdProfit end)) as ad7_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdProfit end)) as ad14_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 21 then AdProfit end)) as ad21_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdProfit end)) as ad30_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdProfit end)) as ad60_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdProfit end)) as ad90_Profit
		, round(sum(case when 0 < ad_days and ad_days <= 120 then AdProfit end)) as ad120_Profit
		from ad  group by sku ,site
)

,od_stat as (
select
    wo.Product_SPU as SPU
    ,wo.Product_Sku as SKU
    ,ms.Site
    ,round( count( distinct case when TransactionType ='付款' then PlatOrderNumber end) ) as 订单量
    ,round( sum( case when TransactionType ='付款' then  SaleCount end) ) as 销量
    ,round( sum( case when TransactionType ='付款' then  TotalGross/ExchangeUSD end) ,2) as 销售额_不含退
    ,round( sum( case when TransactionType ='付款' then  TotalProfit/ExchangeUSD end) ,2) as 利润额
    ,round( sum( case when TransactionType ='退款' then  RefundAmount/ExchangeUSD end) ,2) as 退款额
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '快百货'
join prod  on wo.Product_Sku = prod.sku
where wo.IsDeleted=0 and wo.TransactionType !='其他'
group by wo.Product_SPU ,wo.Product_Sku ,ms.site
)

,merge as (
select t0.sku as sku_merge,t0.site 站点 ,t1.* ,t2.*
from ( select spu ,sku ,site from prod join (select distinct site from mysql_store) ms ) t0
left join od_stat t1 on  t0.sku =t1.sku and t0.Site = t1.site
left join ad_stat t2 on  t0.sku =t2.sku and t0.Site = t2.site
where  coalesce(t1.sku,t2.sku) is not null   -- 去除没有出单或没有广告的行记录, 如果一个SKU既没有出单也没有广告则会被整体去除掉
)


select prod.SPU as 产品spu ,prod.sku as 产品sku ,prod.dev_date ,merge.*
from prod left join merge on prod.sku =merge.sku_merge


