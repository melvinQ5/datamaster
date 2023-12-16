-- 采购5天到货率 purchase_arrived_5day_rate
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


, po_pre as ( -- 往前推5天以便计算 5天采购到货率
select 
	po.OrderNumber,po.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then po.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then po.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else po.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.PurchaseOrder po left join import_data.PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where date_add(ordertime, 5)  >= date_add('${EndDay}',interval -7 day) and date_add(ordertime, 5) < '${EndDay}' 
	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
)


select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU group by category 
union all -- 分品类（新品）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_new=1 
union all -- 分品类（重点）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_lead=1 
union all -- 分品类（其他）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_other=1 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_new=1 group by category 
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_lead=1 group by category  
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_other=1 group by category

