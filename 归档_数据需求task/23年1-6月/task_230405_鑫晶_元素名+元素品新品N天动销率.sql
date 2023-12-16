-- 元素新品N天动销率

with 
t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
	select eppaea.sku , eppea.Name ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku , eppea.Name
)

,tmp_epp as ( -- 筛元素品
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, de.dep2
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime) as dev_week 
from import_data.erp_product_products epp
join ( select sku from t_elem group by sku ) t_elem on epp.sku = t_elem.sku 
left join (
	select case when sku = '李琴' then '李琴1688' else sku end  as name 
	,boxsku as department
	,case when spu = '商品组' then '泉州商品组' when sku='郑燕飞' then '泉州商品组' else spu end as dep2 
	from JinqinSku js where Monday= '2023-03-31' 
	) de 
	on epp.DevelopUserName = de.name 
where epp.DevelopLastAuditTime >= '2023-01-01' and epp.DevelopLastAuditTime < '2023-04-01'
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='快百货' 
)

, orders as ( 
select * from (
	select tmp.* 
		, datediff(min_paytime,DevelopLastAuditTime) as ord_days -- 出单时长
		, timestampdiff(SECOND,min_paytime,PayTime)/86400 as ord_days_since_od 
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department
			, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
			, round(TotalGross/ExchangeUSD,2) as AfterTax_TotalGross
			, round(TotalProfit/ExchangeUSD,2) as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='快百货' and PayTime >= '2023-01-01' AND PayTime < '2023-04-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min(PayTime) as min_paytime from import_data.wt_orderdetails  od1
			join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
			and ms1.Department ='快百货' and PayTime >= '2023-01-01' AND PayTime < '2023-04-01'
			where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 group by BoxSku
			) tmp_min on tmp_min.BoxSku =od.BoxSku 
		) tmp
	) tmp2 
)

--  select * from orders 

, join_listing as ( 
select t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, DevelopLastAuditTime
	, eaal.PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department  ='快百货' and ms.ShopStatus='正常'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
)


-- 元素品的动销率
-- select '日期' `分析维度`
-- 	, dev_week `开发周`
-- 	, DevelopUserName `开发人员`, dev_cnt `开发spu数`
-- 	, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
-- 	, ord7_sku_sales `终审7天销售额`, ord14_sku_sales `终审14天销售额`, ord30_sku_sales `终审30天销售额` ,ord30_sku_sales_since_od `首单30天销售额`
-- from ( 
-- 	select t.dev_week, '开发合计' as DevelopUserName
-- 		, count(distinct t.SPU) as dev_cnt
-- 		, count(distinct case when 0 < ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
-- 		, count(distinct case when 0 < ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
-- 		, count(distinct case when 0 < ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
-- 		, count(distinct case when 0 < ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
-- 		, count(distinct case when 0 < ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
-- 		, count(distinct case when 0 < ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
-- 		, round(sum(case when 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
-- 		, round(sum(case when 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
-- 		, round(sum(case when 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
-- 		, round(sum(case when 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
-- 		, round(sum(case when 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
-- 		, round(sum(case when 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
-- 		, round(sum(case when 0 < ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od 
-- 	from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  
-- 	group by grouping sets ((),(t.dev_week))
-- 	) tmp
	
-- 按元素名称统计动销率
select '元素名称' `分析维度`
	, ele_name `元素`
	, dev_cnt `1-3月终审SPU数`
	, round(ord7_sku_cnt/dev_cnt,4) as `终审7天动销率`, round(ord14_sku_cnt/dev_cnt,4) as `终审14天动销率`, round(ord30_sku_cnt/dev_cnt,4) as `终审30天动销率`
	, ord7_sku_sales `终审7天销售额`, ord14_sku_sales `终审14天销售额`, ord30_sku_sales `终审30天销售额` ,ord30_sku_sales_since_od `首单30天销售额`
	,`1月元素新品销售额`,`2月元素新品销售额`,`3月元素新品销售额` ,Q1元素新品销售额
from ( 
	select t_elem.ele_name
		, count(distinct t.SPU) as dev_cnt
		, count(distinct case when 0 < ord_days and ord_days <= 7  then od.SPU end) as ord7_sku_cnt
		, count(distinct case when 0 < ord_days and ord_days  <= 14 then od.SPU end) as ord14_sku_cnt
		, count(distinct case when 0 < ord_days and ord_days  <= 30 then od.SPU end) as ord30_sku_cnt
		, count(distinct case when 0 < ord_days and ord_days  <= 60 then od.SPU end) as ord60_sku_cnt
		, count(distinct case when 0 < ord_days and ord_days  <= 90 then od.SPU end) as ord90_sku_cnt
		, count(distinct case when 0 < ord_days and ord_days  <= 120 then od.SPU end) as ord120_sku_cnt
		
	
		,sum( case when left(PayTime,7) = '2023-01' then AfterTax_TotalGross end ) `1月元素新品销售额`
		,sum( case when left(PayTime,7) = '2023-02' then AfterTax_TotalGross end ) `2月元素新品销售额`
		,sum( case when left(PayTime,7) = '2023-03' then AfterTax_TotalGross end ) `3月元素新品销售额`
		,sum( case when MONTH(PayTime) <= 3 then AfterTax_TotalGross end ) `Q1元素新品销售额`
		
		, round(sum(case when 0 < ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
		, round(sum(case when 0 < ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
		, round(sum(case when 0 < ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
		, round(sum(case when 0 < ord_days and ord_days <= 60 then AfterTax_TotalGross end)) as ord60_sku_sales
		, round(sum(case when 0 < ord_days and ord_days <= 90 then AfterTax_TotalGross end)) as ord90_sku_sales
		, round(sum(case when 0 < ord_days and ord_days <= 120 then AfterTax_TotalGross end)) as ord120_sku_sales
		, round(sum(case when 0 < ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od 
	from tmp_epp t 
	left join orders od on od.BoxSku =t.BoxSKU  
	join t_elem on t.sku = t_elem.sku -- 一变多
	group by grouping sets ((),(t_elem.ele_name))
	) tmp
order by `元素`