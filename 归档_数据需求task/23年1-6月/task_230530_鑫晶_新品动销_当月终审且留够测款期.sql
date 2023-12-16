/*
15日开始计算 当月累计终审的产品，在当月14天动销
*/

with
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, de.dep2
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime)as dev_week
from import_data.erp_product_products epp
left join (
	select case when sku = '李琴' then '李琴1688' else sku end  as name
	,boxsku as department
	,case when spu = '商品组' then '泉州商品组' when sku='郑燕飞' then '泉州商品组' else  '成都商品组' end as dep2
	from JinqinSku js where Monday= '2023-03-31'
	) de
	on epp.DevelopUserName = de.name
where date_add(epp.DevelopLastAuditTime,interval - 8 hour) >= '${StartDay}' and date_add(epp.DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}'
    and epp.IsDeleted = 0 and epp.IsMatrix = 0
	AND epp.ProjectTeam ='快百货'
)

, orders as (
select * from (
	select tmp.*
		, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days  -- 出单时长
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='快百货' and PayTime >= '${StartDay}'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min(PayTime) as min_paytime from import_data.wt_orderdetails  od1
			join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0
			and ms1.Department ='快百货' and PayTime >= '${StartDay}'
			where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 group by BoxSku
			) tmp_min on tmp_min.BoxSku =od.BoxSku
		) tmp
	) tmp2
)

, join_listing as (
select t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
	, eaal.MinPublicationDate
from import_data.wt_listing  eaal
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='快百货' and ms.ShopStatus='正常'
join tmp_epp t on  eaal.sku = t.SKU
where eaal.ListingStatus = 1  and IsDeleted = 0
)

-- 组合维度输出(因为包含GM转PM数据，所以计算出单率时 ord_days > 0 )
select  concat('${StartDay}','至', date(date_add('${NextStartDay}',interval -1 day )))  '终审时间范围' ,* from (
	select
	    '日期' `分析维度`, dev_month `开发月`, DevelopUserName `开发人员`, dev_cnt `开发SPU数`
		, round(ord7_sku_cnt/dev_cnt,4) as `7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `30天动销率`
		, round(ord60_sku_cnt/dev_cnt,4) as `60天动销率`, round(ord90_sku_cnt/dev_cnt,4) as `90天动销率`, round(ord120_sku_cnt/dev_cnt,4) as `120天动销率`
		, ord7_sku_sales `7天销售额`, ord14_sku_sales `14天销售额`, ord30_sku_sales `30天销售额`, ord60_sku_sales `60天销售额`, ord90_sku_sales `90天销售额`, ord120_sku_sales `120天销售额`
		from (
		select t.dev_month, '开发合计' as DevelopUserName
			, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by t.dev_month
		) tmp

	union all
	select '日期/开发人员' `分析维度`, dev_month `开发月`, DevelopUserName `开发人员`, dev_cnt `开发sku数`, round(ord7_sku_cnt/dev_cnt,4) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from ( select t.dev_month, t.DevelopUserName
		, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU
-- 		where  DevelopUserName in('李云霞' ,'王婉君' ,'夏菲','左佩' ,'沈邦华','陈倩' ,'李琴1688' ,'丁华丽','金磊')
		group by t.dev_month, t.DevelopUserName
		) tmp

	union all
	select '日期/开发团队'  `分析维度`, dev_month `开发月`, dep2 `开发团队`, dev_cnt `开发sku数`
		, round(ord7_sku_cnt/dev_cnt,10) as d7_rate, round(ord14_sku_cnt/dev_cnt,4) as d14_rate, round(ord30_sku_cnt/dev_cnt,4) as d30_rate
		, round(ord60_sku_cnt/dev_cnt,4) as d60_rate, round(ord90_sku_cnt/dev_cnt,4) as d90_rate, round(ord120_sku_cnt/dev_cnt,4) as d120_rate
		, ord7_sku_sales, ord14_sku_sales, ord30_sku_sales
		, ord60_sku_sales, ord90_sku_sales, ord120_sku_sales
	from (
		select  t.dev_month, t.dep2
		, count(distinct t.SPU) as dev_cnt
			, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
			, count(distinct case when 0 <= ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
			, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
			, round(sum(case when 0 <= ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		from tmp_epp t
		left join orders od on od.BoxSku =t.BoxSKU
		where t.dep2 regexp '泉州商品组|成都商品组'
		group by t.dev_month, t.dep2
		) tmp
) union_tmp
order by  `分析维度`, `开发月`, `开发人员`