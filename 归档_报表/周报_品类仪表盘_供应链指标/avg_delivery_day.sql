-- 平均发货天数，统计上周所有发货的包裹，不限制客户支付时间 avg_delivery_day 
with
pt as ( 
select tmp.* ,case when is_new + is_lead = 0 then 1 end as is_other -- 其他
from (
	select pc.*
		, case when pc.DevelopLastAuditTime>='2022-10-01' then 1 else 0 end as is_new -- 新品
		, case when lp.SKU  is not null then 1 else 0 end as is_lead -- 重点
	from (select pp.id,pp.spu,pp.sku,pp.BoxSKU,bpv.ChineseValueName as category,pp.DevelopLastAuditTime
		from erp_product_products pp
		join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
		join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
		join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
		where ChineseName = '小组类别' and bpv.ChineseValueName is Not null ) pc 
	left join lead_product lp on pc.SKU = lp.SKU ) tmp
)

, pd as ( -- PackageDetail包裹表 
select PackageNumber, BoxSku , CreatedTime, WeightTime , OrderNumber
from import_data.PackageDetail pd
)


select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days 
from import_data.OrderDetails od  join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
	WHERE weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
	left join pt on pt.BoxSKU = od.BoxSku WHERE weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- 分品类（新品）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_new=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp 
union all -- 分品类（重点）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_lead=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp 
union all -- 分品类（其他）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_other=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_new=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_lead=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_other=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp group by category
