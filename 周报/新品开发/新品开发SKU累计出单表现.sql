/*
新品开发N天出单率=对应PM出单SKU数/开发完成SKU数
对开发终审时间按周来分组sk，计算每个sku的首单天数。

每个sku只有一个 首单天数（最早出单日期-开发完成日期）,每笔订单的每个sku只有1个 首单天数,
按首单天数，则"30天首单动销率"的业务含义是：7月开发完成的sku中，有多少个能在30天内就能至少开出1单

对于GM转PM（有开发终审时间且skuSource=2的SKU），即SKU先跟卖出效果的，我们进行SKU开发终审，然后让二部三部去卖。
所以计算其最早出单时间的时候也是开发终审之后，因此其首单天数也为正数。
*/

with 
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(epp.DevelopLastAuditTime) = dd.full_date
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	AND epp.ProjectTeam ='快百货' 
-- 	and DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊') 
)

, orders as ( 
select * from (
	select tmp.* 
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days -- 出单时长
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department , epp.dev_week
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='快百货' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min(PayTime) as min_paytime from import_data.wt_orderdetails  od1
			join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
			and ms1.Department ='快百货' and PayTime >= '2023-01-01'
			where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 group by BoxSku
			) tmp_min on tmp_min.BoxSku =od.BoxSku 
		) tmp
	) tmp2 
)

, join_listing as ( 
select t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
	, eaal.MinPublicationDate ,shopcode ,sellersku
from import_data.wt_listing  eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='快百货' and ms.ShopStatus='正常'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  and eaal.IsDeleted = 0 
)

-- sku明细输出
-- select count(1) from (
select ords.*,jl.`在线链接数`,round(`累计出单链接数`/jl.`在线链接数`,4) `链接动销率`
from
	(select  SPU, SKU, BoxSku, DevelopUserName `开发人员`
		, SkuSource_cn `正逆向`, ord_days`首单天数`
	    , dev_week `终审周次`
		, DATE_FORMAT(DevelopLastAuditTime,'%Y/%m/%d') `开发终审日期`
		, DATE_FORMAT(min_paytime,'%Y/%m/%d') `首单日期`
		, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `订单统计截止日期`
		, round(sum(AfterTax_TotalGross),2) `累计收入`
		, round(sum(AfterTax_TotalProfit),2) `累计利润`
		, count(distinct PlatOrderNumber) `累计订单数`
		, count(distinct concat(SellerSku,ShopIrobotId)) `累计出单链接数`
		, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 
			then AfterTax_TotalGross end)) as ord30_sku_sales
	from orders group by SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, ord_days, dev_week
		, `开发终审日期`, `首单日期`, `订单统计截止日期`
	) ords
left join (
-- 	select SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime) ,MinPublicationDate `首次刊登时间`
	select SKU, count(DISTINCT concat(shopcode,sellersku)) `在线链接数`
	from join_listing
	group by SKU
	) jl on ords.SKU = jl.SKU
-- 	) t 
