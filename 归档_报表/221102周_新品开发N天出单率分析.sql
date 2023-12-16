/*
新品开发N天出单率=对应销售二部三部出单SKU数/开发完成SKU数
对开发终审时间按周来分组sk，计算每个sku的首单天数。

每个sku只有一个 首单天数（最早出单日期-开发完成日期）,每笔订单的每个sku只有1个 首单天数,
按首单天数，则"30天首单动销率"的业务含义是：7月开发完成的sku中，有多少个能在30天内就能至少开出1单

对于GM转PM（有开发终审时间且skuSource=2的SKU），即SKU先跟卖出效果的，我们进行SKU开发终审，然后让二部三部去卖。
所以计算其最早出单时间的时候也是开发终审之后，因此其首单天数也为正数。
*/

with 
newcateg as ( -- 拿到新类目 -- 现在可以用产品宽表
select pp.id,pp.spu,pp.sku,bp.ChineseName,bpv.ChineseValueName
from erp_product_products pp
join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
where ChineseName = '小组类别' and bpv.ChineseValueName is Not null
)

, tmp_epp as (
select
	n.ChineseValueName as newpath1 -- 新类目1级
 	, epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime) as dev_week -- 23年的周计数不加1
from import_data.erp_product_products epp
join newcateg n on n.sku = epp.SKU -- 只计算有打新分类标签的sku
where epp.DevelopLastAuditTime >= '2022-05-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
)


, orders as ( 
select * from (
	select tmp.* 
		, datediff(min_paytime,DevelopLastAuditTime) as ord_days -- 出单时长
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department, epp.newpath1
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
-- 			, b.OrderNumber
			, (if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalGross
			, (if(TaxGross>0, TotalProfit, TotalProfit-(TotalGross*IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalProfit
		from import_data.OrderDetails od
		join import_data.mysql_store ms on ms.Code = od.ShopIrobotId 
			and ms.Department in ('销售二部', '销售三部') and PayTime >= '2022-05-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join (select BoxSku, min(PayTime) as min_paytime from import_data.OrderDetails od1
			join import_data.mysql_store ms1 on ms1.Code = od1.ShopIrobotId and ms1.Department in ('销售二部', '销售三部') and PayTime >= '2022-05-01'
			where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 group by BoxSku) tmp_min on tmp_min.BoxSku =od.BoxSku 
		left join 
			( -- 回溯历史当月需过滤订单
			select OrderNumber , pay_month
			from (select left(PayTime,7) as pay_month, OrderNumber, GROUP_CONCAT(TransactionType) alltype 
				FROM import_data.OrderDetails where ShipmentStatus = '未发货' and OrderStatus = '作废' and PayTime >= '2022-05-01'
				group by OrderNumber, pay_month) a
			where alltype = '付款'
			) b 
			on b.OrderNumber = od.OrderNumber and b.pay_month = left(od.PayTime,7)
		left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
		where  b.OrderNumber is null 
		) tmp
	) tmp2 
)

, join_listing as ( 
select t.newpath1, t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
	, eaal.PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
)



-- 表1 sku明细输出
select ords.*,jl.`在线链接数`,round(`累计出单链接数`/jl.`在线链接数`,4) `链接动销率`, DATE_FORMAT(jl.`首次刊登时间`,'%Y/%m/%d') `首次刊登日期` from
	(select newpath1 `类目`, SPU, SKU, BoxSku, DevelopUserName `开发人员`, SkuSource_cn `正逆向`, ord_days`首单天数`, WEEKOFYEAR(DevelopLastAuditTime)+1 `开发周次` 
		, DATE_FORMAT(DevelopLastAuditTime,'%Y/%m/%d') `开发终审日期`, DATE_FORMAT(min_paytime,'%Y/%m/%d') `首单日期`
		, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `订单统计截止日期`
		, round(sum(AfterTax_TotalGross),2) `累计收入`, round(sum(AfterTax_TotalProfit),2) `累计利润`, count(distinct PlatOrderNumber) `累计订单数`
		, count(distinct concat(SellerSku,ShopIrobotId)) `累计出单链接数`
	from orders group by newpath1, SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, ord_days, WEEKOFYEAR(DevelopLastAuditTime)+1
		, `开发终审日期`, `首单日期`, `订单统计截止日期`
	) ords
left join (
	select newpath1, SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime) 
		, count(1) `在线链接数`, min(PublicationDate) `首次刊登时间`
	from join_listing
	group by newpath1, SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime)
	) jl on ords.SKU = jl.SKU


-- 表2 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
select * from (
	select '日期' `分析维度`, dev_week `开发周`, newpath1 `新类目`, DevelopUserName `开发人员`, SkuSource_cn `开发来源`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( 
		select t.dev_week, '全类目' newpath1, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
		) tmp
	union all 
	select '日期/类目'  `分析维度`, dev_week `开发周`, newpath1 `新类目`, DevelopUserName `开发人员`, SkuSource_cn `开发来源`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, t.newpath1, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.newpath1
		) tmp
	
	union all 
	select '日期/开发人员'  `分析维度`, dev_week `开发周`, newpath1 `新类目`, DevelopUserName `开发人员`, SkuSource_cn `开发来源`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, '全类目' as newpath1, t.DevelopUserName, '来源合计' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.DevelopUserName
		) tmp
	union all 
	select '日期/开发来源'  `分析维度`, dev_week `开发周`, newpath1 `新类目`, DevelopUserName `开发人员`, SkuSource_cn `开发来源`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, '全类目' as newpath1, '开发合计' DevelopUserName, t.SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.SkuSource_cn
		) tmp
	union all 
	select '日期/开发来源/类目'  `分析维度`, dev_week `开发周`, newpath1 `新类目`, DevelopUserName `开发人员`, SkuSource_cn `开发来源`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, t.newpath1, '开发合计' DevelopUserName, t.SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.SkuSource_cn, t.newpath1
		) tmp
	union all 
	select '日期/开发人员/类目'  `分析维度`, dev_week `开发周`, newpath1 `新类目`, DevelopUserName `开发人员`, SkuSource_cn `开发来源`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_week, t.newpath1, t.DevelopUserName, '来源合计' as SkuSource_cn
			, count(distinct t.BoxSKU) as dev_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU group by t.dev_week, t.DevelopUserName, t.newpath1
		) tmp
) union_tmp
order by  `分析维度`, `开发周`, `新类目`, `开发人员`, `开发来源`