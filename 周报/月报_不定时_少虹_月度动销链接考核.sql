-- 销售月度绩效考核 ：销量30个以上的链接
-- 维度：
-- 最小粒度：链接+统计月（完整9月）
-- 链接范围：所有动销链接
-- 产品范围：所有产品

with
prod as (
select p.sku
  ,d.ele_name_priority
  ,left(DevelopLastAuditTime,7) dev_month
  ,date(DevelopLastAuditTime) dev_date
from wt_products p
join dep_kbh_product_test d
  on d.sku = p.sku
)

-- ----------计算订单表现
,od_pay as (   -- 付款数据
select  shopcode ,sellersku ,asin  , sku ,wo.BoxSku
	,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
	,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
	,round( sum(salecount ),2) SaleCount_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '快百货' and NodePathName !='定制运营组'
left join wt_products wp on wo.BoxSku  = wp.BoxSku and wp.ProjectTeam ='快百货' and wp.IsDeleted =0
where
	PayTime >=  '${StartDay}'  and PayTime <  '${NextStartDay}'  -- 获取更久远的数据是为了包含到表主键的自然周
    and wo.IsDeleted=0
group by shopcode ,sellersku ,asin  ,sku  ,wo.BoxSku
)

,od_refund as ( -- 使用退款表
select shopcode ,sellersku ,asin  ,wo.BoxSku
	,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款'
group by shopcode ,sellersku ,asin  ,wo.BoxSku
)

,od_stat_pre as ( -- 扣退款
select  shopcode  ,sellersku ,asin
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,asin , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,asin , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,asin
)

,t_orde_week_stat as (
select  a.shopcode ,a.sellersku ,a.asin ,sku ,boxsku
    ,sales as TotalGross_weekly
    ,profit as TotalProfit_weekly
    ,sales_refund as TotalGross_weekly_refund
    ,SaleCount_weekly
from od_stat_pre a
left join  od_pay b
on a.shopcode  = b.shopcode and a.sellersku =b.sellersku and a.asin = b.asin
)
-- ----------计算广告表现

,t_ad as (
select shopcode ,SellerSku ,asin
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily asa
where  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}'
)



, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select  shopcode ,sellersku ,asin
		-- 曝光量
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(Spend),2) as ad_Spend
		-- 广告销售额
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- 广告销量
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  group by shopcode ,sellersku ,asin
	) tmp
)

,lst_pub as (
select t1.shopcode ,t1.sellersku ,t1.asin ,min(MinPublicationDate) MinPublicationDate from  t_orde_week_stat t1 join wt_listing wl
on t1.shopcode=wl.ShopCode and t1.SellerSku=wl.SellerSKU and t1.asin = wl.asin
group by t1.shopcode ,t1.sellersku ,t1.asin )

,t0 as (
select distinct sku, ele_name_priority 优先元素 ,dev_date 终审日期 from prod
)

, res as (
select
	replace( concat('${StartDay}','_',date(date_add('${NextStartDay}',-1)) ),'-','') 订单统计范围
	,t1.shopcode ,t1.sellersku ,t1.asin ,t1.sku ,t1.BoxSku
	, CompanyCode , AccountCode
    , case when NodePathName regexp  '成都' then '成都' else '泉州' end as 区域
    , NodePathName as 销售小组 ,SellUserName 销售人员

    ,ifnull(SaleCount_weekly,0) `销量`
    ,ifnull(TotalGross_weekly,0) `销售额`
    ,ifnull(TotalProfit_weekly,0) 利润额_未扣ad
    ,round( ifnull(TotalProfit_weekly,0) / ifnull(TotalGross_weekly,0) ,4 ) 利润率_未扣ad
	,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `利润额_扣ad`
    ,round( ( ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0) ) / ifnull(TotalGross_weekly,0) ,4 ) 利润率_扣ad
    ,ifnull(TotalGross_weekly_refund,0) `退款额`
    ,ad_sku_Exposure `广告曝光量`
	,ifnull(ad_Spend,0) `广告花费`
	,ad_TotalSale7Day `广告销售额`
	,ad_sku_TotalSale7DayUnit `广告销量`
	,ad_sku_Clicks `广告点击量`
	,click_rate `广告点击率`
	,adsale_rate `广告转化率`
	,ROAS `ROAS`
	,ACOS `ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `CPC`
	,wl.MinPublicationDate 链接刊登时间
	,t0.优先元素
	,终审日期
from t_orde_week_stat t1
left join t0 on t1.sku = t0.sku
left join t_ad_stat
	on t1.ShopCode = t_ad_stat.ShopCode
	and t1.sellersku = t_ad_stat.sellersku and t1.asin =t_ad_stat.asin
left join mysql_store ms on t1.shopcode =ms.Code
left join lst_pub wl
    on t1.shopcode=wl.ShopCode and t1.SellerSku=wl.SellerSKU and t1.asin = wl.asin
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_weekly,0) >0  and ifnull(SaleCount_weekly,0)>0
-- 	and t0.sku =1101153.01
order by t1.shopcode ,t1.sellersku
)

select * from res


