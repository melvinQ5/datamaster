
/*
按日统计新品14天动销率
*/

with 
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	,epp.ProductName 
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime) as dev_week 
from import_data.erp_product_products epp
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	AND epp.ProjectTeam ='快百货' 
-- 	and  DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊') 
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.spu ,eppaea.sku ,eppea.Name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join tmp_epp on eppaea.sku = tmp_epp.sku 
group by eppaea.spu ,eppaea.sku ,eppea.Name 
)

, orders as ( 
select * from (
	select tmp.* 
		, datediff(min_paytime,DevelopLastAuditTime) as ord_days -- 出单时长
		, datediff(paytime,min_paytime) as ord_days_since_sale -- 首次出单开始计算时长
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='快百货' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU  -- 23年终审且有出单
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
	, eaal.PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='快百货' and ms.ShopStatus='正常'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
)


-- 周动销_sku  (因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
-- select * from (
-- 	select '日期' `分析维度`
-- 		, dev_week `开发周`
-- 		, DevelopUserName `开发人员`, dev_cnt `开发sku数`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `30天动销率`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60天动销率`, round(ord90_sku_cnt/dev_cnt,4) as `90天动销率`, round(ord120_sku_cnt/dev_cnt,4) as `120天动销率`
-- 		, ord7_sku_sales `7天销售额`, ord14_sku_sales `14天销售额`, ord30_sku_sales `30天销售额`, ord60_sku_sales `60天销售额`, ord90_sku_sales `90天销售额`, ord120_sku_sales `120天销售额`
-- 	from ( 
-- 		select t.dev_week, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
-- 		) tmp
-- 	union all 
-- 	select '日期/开发人员'  `分析维度`, dev_week `开发周`, DevelopUserName `开发人员`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_week, t.DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊') 
-- 		group by t.dev_week, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `分析维度`, `开发周`, `开发人员`



-- 周动销_spu  (因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
-- select * from (
-- 	select '日期' `分析维度`
-- 		, dev_week `开发周`
-- 		, DevelopUserName `开发人员`, dev_cnt `开发sku数`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `30天动销率`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60天动销率`, round(ord90_sku_cnt/dev_cnt,4) as `90天动销率`, round(ord120_sku_cnt/dev_cnt,4) as `120天动销率`
-- 		, ord7_sku_sales `7天销售额`, ord14_sku_sales `14天销售额`, ord30_sku_sales `30天销售额`, ord60_sku_sales `60天销售额`, ord90_sku_sales `90天销售额`, ord120_sku_sales `120天销售额`
-- 	from ( 
-- 		select t.dev_week, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu  end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_week
-- 		) tmp
-- 	union all 
-- 	select '日期/开发人员'  `分析维度`, dev_week `开发周`, DevelopUserName `开发人员`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_week, t.DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊') 
-- 		group by t.dev_week, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `分析维度`, `开发周`, `开发人员`


-- 日动销_sku  (因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
-- select * from (
-- 	select '日期' `分析维度`
-- 		, dev_date `终审日期`
-- 		, DevelopUserName `开发人员`, dev_cnt `开发sku数`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `30天动销率`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60天动销率`, round(ord90_sku_cnt/dev_cnt,4) as `90天动销率`, round(ord120_sku_cnt/dev_cnt,4) as `120天动销率`
-- 		, ord7_sku_sales `7天销售额`, ord14_sku_sales `14天销售额`, ord30_sku_sales `30天销售额`, ord60_sku_sales `60天销售额`, ord90_sku_sales `90天销售额`, ord120_sku_sales `120天销售额`
-- 	from ( 
-- 		select t.dev_date, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_date
-- 		) tmp
-- 	union all 
-- 	select '日期/开发人员'  `分析维度`, dev_date `终审日期`, DevelopUserName `开发人员`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_date, t.DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.BoxSKU) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.BoxSKU end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.BoxSKU end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.BoxSKU end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.BoxSKU end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.BoxSKU end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.BoxSKU end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊') 
-- 		group by t.dev_date, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `分析维度`, `终审日期`, `开发人员`


-- 日动销_spu  (因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
-- select * from (
-- 	select '日期' `分析维度`
-- 		, dev_date `终审日期`
-- 		, DevelopUserName `开发人员`, dev_cnt `开发sku数`
-- 		, round(ord7_sku_cnt/dev_cnt,4) as `7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `30天动销率`
-- 		, round(ord60_sku_cnt/dev_cnt,4) as `60天动销率`, round(ord90_sku_cnt/dev_cnt,4) as `90天动销率`, round(ord120_sku_cnt/dev_cnt,4) as `120天动销率`
-- 		, ord7_sku_sales `7天销售额`, ord14_sku_sales `14天销售额`, ord30_sku_sales `30天销售额`, ord60_sku_sales `60天销售额`, ord90_sku_sales `90天销售额`, ord120_sku_sales `120天销售额`
-- 	from ( 
-- 		select t.dev_date, '开发合计' as DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt 
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_date
-- 		) tmp
-- 	union all 
-- 	select '日期/开发人员'  `分析维度`, dev_date `终审日期`, DevelopUserName `开发人员`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
-- 		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
-- 	from ( select t.dev_date, t.DevelopUserName, '来源合计' as SkuSource_cn
-- 			, count(distinct t.spu) as dev_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7  then od.spu end) as ord7_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 14 then od.spu end) as ord14_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 30 then od.spu end) as ord30_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 60 then od.spu end) as ord60_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 90 then od.spu end) as ord90_sku_cnt
-- 			, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days  <= 120 then od.spu end) as ord120_sku_cnt
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 			, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU 
-- -- 		where  t.DevelopUserName in ('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊') 
-- 		group by t.dev_date, t.DevelopUserName
-- 		) tmp
-- ) union_tmp
-- order by  `分析维度`, `终审日期`, `开发人员`



-- sku明细输出 
	select tmp_epp.sku 
		,tmp_epp.spu
		,tmp_epp.productname
		,ele_name `元素`
		, Festival`季节`
		,`产品状态`
		,`侵权状态`
		,`开发终审日期`
		,`开发周次`
		,ords.*
		,case when `首单30天销售额` >=100 then 1 else 0 end as `首单30天内是否达100美金`
	from tmp_epp 
	left join (select  SKU, BoxSku, DevelopUserName `开发人员`
			, DATE_FORMAT(min_paytime,'%Y/%m/%d') `首单日期`
			, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `订单统计截止日期`
			, round(sum(AfterTax_TotalGross),2) `截至0326销售额`
			, round(sum(AfterTax_TotalProfit),2) `截至0326利润额`
			,  count(distinct to_date(paytime)) `截至0326出单天数`
			, round(sum( case when ord_days_since_sale <= 30 then AfterTax_TotalGross end ),2) `首单30天销售额`
			, round(sum( case when ord_days_since_sale <= 30 then AfterTax_TotalProfit end ),2) `首单30天利润额`
			, round(sum( case when ord_days_since_sale <= 30 then AfterTax_TotalProfit end )/sum( case when ord_days_since_sale <= 30 then AfterTax_TotalGross end ),2) `首单30天毛利率`
			, count(distinct case when ord_days_since_sale <= 30 then PlatOrderNumber end ) `首单30天订单数`
			, count(distinct case when ord_days_since_sale <= 30 then concat(SellerSku,ShopIrobotId) end  ) `首单30天出单链接数`
		from orders 
		 首次出单后30天内
		group by  SKU, BoxSku, DevelopUserName
			, `首单日期`, `订单统计截止日期`
		) ords
		on tmp_epp.sku = ords.sku 
	left join (
		select SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime) 
			, count(1) `在线链接数`
		from join_listing
		group by SPU, SKU, BoxSku, DevelopUserName, SkuSource_cn, to_date(DevelopLastAuditTime)
		) jl on ords.SKU = jl.SKU
	left join (
		select sku , productname ,Festival 
			,DATE_FORMAT(DevelopLastAuditTime,'%Y/%m/%d') `开发终审日期` , WEEKOFYEAR(DevelopLastAuditTime) `开发周次` 
			,TortType `侵权状态` 
			,case when wp.ProductStatus = 0 then '正常'
				when wp.ProductStatus = 2 then '停产'
				when wp.ProductStatus = 3 then '停售'
				when wp.ProductStatus = 4 then '暂时缺货'
				when wp.ProductStatus = 5 then '清仓'
				end as  `产品状态`
		from import_data.wt_products wp 
	) wp on tmp_epp.sku = wp.sku 
	left join (select sku,GROUP_CONCAT(name) ele_name from t_elem group by sku) t_elem on tmp_epp.sku = t_elem.sku 
