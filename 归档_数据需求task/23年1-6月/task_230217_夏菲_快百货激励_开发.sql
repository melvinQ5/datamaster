/*
 * SKU统计范围：统计日期-sku终审时间 <= 30天
 * 订单统计范围：快百货店铺所属订单， 且统计日期-sku终审时间 <= 30天
 * 开发人员统计范围：'李云霞' ,'王婉君' ,'夏菲','陈倩' ,'李琴' ,'丁华丽'
 * 日均出单sku件数(日均销量) = 总出单sku件数 ÷ （统计日期-sku终审时间）
 */

with 
wp as ( 
select  BoxSku ,DevelopLastAuditTime ,DevelopUserName ,sku
	, case when DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲') then '快次元'
		when DevelopUserName in ('陈倩' ,'李琴' ,'丁华丽') then '快次方'
	end as team1
from wt_products wp 
where DevelopLastAuditTime >= DATE_ADD(CURRENT_DATE() ,-90) and DevelopLastAuditTime < CURRENT_DATE()  
	and IsDeleted = 0 and  DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','陈倩' ,'李琴' ,'丁华丽')
)


, orders as (
select 
	datediff(CURRENT_DATE()-1 ,DevelopLastAuditTime) test_days -- 出单时长
	, PlatOrderNumber ,OrderNumber ,wp.BoxSku
	, paytime ,DevelopLastAuditTime
	, shopcode ,SellerSku,Asin
	, TotalProfit , TotalGross ,RefundAmount ,ExchangeUSD
from import_data.wt_orderdetails wo 
join wp on wo.BoxSku = wp.boxsku
where wo.IsDeleted = 0 and TransactionType ='付款' 
	and wo.Department = '快百货'
)


, ord_cnt as ( -- 总销量
select boxsku 
	,test_days 
	,count(distinct PlatOrderNumber) as ord_cnt 
	,count(distinct concat(shopcode,SellerSku,Asin)) `出单链接数`
	,round(sum((TotalGross + RefundAmount)/ExchangeUSD),2) `销售额` -- 仅减去了当期退款(负数)
	,round(sum((TotalProfit + RefundAmount)/ExchangeUSD),2) `利润额` -- 仅减去了当期退款(负数)
	,round(sum((TotalGross + RefundAmount)/ExchangeUSD)/sum((TotalProfit + RefundAmount)/ExchangeUSD),4) `利润率`
from orders group by boxsku ,test_days
)

, listing_cnt as ( 
select wp.BoxSku ,count(distinct concat(ShopCode ,SellerSKU ,ASIN)) `在线链接数` ,min(PublicationDate) `首次刊登时间`
from import_data.erp_amazon_amazon_listing eaal 
join wp on eaal.BoxSku = wp.Boxsku
-- where ListingStatus =1
group by wp.boxsku , ShopCode ,SellerSKU ,ASIN
)

-- select ROW_NUMBER () over (partition by boxsku order by `日均出单sku件数`desc ) as `销量排名` 
-- 	, tmp.*
-- from (
	select wp.team1 `团队` 
		,wp.DevelopUserName `开发人员` 
		,wp.sku ,wp.boxsku
		,to_date(wp.DevelopLastAuditTime) `终审日期`
		,ord_cnt.`销售额` ,ord_cnt.`利润额` , DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `订单统计截止日期`
		,listing_cnt.`首次刊登时间` 
		,round(ord_cnt/test_days , 2) `日均出单sku件数`
	-- 	,listing_cnt. `在线链接数` 
		,ord_cnt.`出单链接数` 
	-- 	,round(`出单链接数`/`在线链接数` , 1) `链接动销率`
	from wp 
	left join ord_cnt on ord_cnt.boxsku = wp.boxsku
	left join listing_cnt on listing_cnt.boxsku = wp.boxsku
	order by `日均出单sku件数` desc 
-- ) tmp 