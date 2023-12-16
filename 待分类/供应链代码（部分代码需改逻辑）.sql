/* 维度：类目、部门、周报、周次、品类结构
-- weekofyear('${EndDay}') 因为已经填写的是下周一，所以不需要周次+1了
 */
with
-- 【Part1 数据集处理】
pt as ( -- product_type 产品表 (新品、重点、其他) group by product_type
select tmp.* ,case when is_new + is_lead = 0 then 1 end as is_other -- 其他
from (
	select pc.*
		, case when pc.DevelopLastAuditTime>=date_add('${EndDay}',interval -6 month ) and pc.DevelopLastAuditTime<'${EndDay}' then 1 else 0 end as is_new -- 新品
		, case when lp.SKU  is not null then 1 else 0 end as is_lead -- 重点
	from (select pp.id,pp.spu,pp.sku,pp.BoxSKU,bpv.ChineseValueName as category,pp.DevelopLastAuditTime
		from erp_product_products pp
		join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
		join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
		join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
		where ChineseName = '小组类别' and bpv.ChineseValueName is Not null ) pc 
	left join lead_product lp on pc.SKU = lp.SKU ) tmp
)

, od as ( -- 订单表
select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
join import_data.mysql_store s on s.code = a.ShopIrobotId
where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
	and PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -7 day)
)

, lw as ( -- local_warehouse 本地仓表
select 
	case when tmp.BoxSKU is null then 0 else 1 end as is_order -- 0=未出单，1=有出单
	, TotalPrice, TotalInventory, pt.BoxSKU, pt.category, pt.id as ProductId, pt.is_new, pt.is_lead, pt.is_other
FROM import_data.WarehouseInventory wi
join pt on wi.BoxSku = pt.BoxSKU
left join -- 用于计算是否本周出单
	(select distinct BoxSku from od) tmp on wi.BoxSku = tmp.BoxSKU 
where WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报'
)


, po as ( -- PurchaseOrder 采购表
select po.* 
	, case when tmp.BoxSKU is null then 0 else 1 end as is_order -- 0=未出单，1=有出单
	, sum(Price - DiscountedPrice + (Price - DiscountedPrice)/(PayPrice-Freight)*Freight )over(partition by SupplierId) as supplier_amount -- 供应商当周供货金额(产品+运费)
	, sum(Quantity)over(partition by po.OrderNumber) as total_qy -- 单笔订单采购件数
	, sum(Price - DiscountedPrice)over(PARTITION BY OrderNumber,BoxSku) AS ord_product_price -- 采购单产品金额（不含运费）
from (select * from import_data.PurchaseOrder 
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
	) po
left join (select distinct BoxSku from od ) tmp on po.BoxSku = tmp.BoxSKU -- 用于计算是否本周出单
)

, pd as ( -- PackageDetail包裹表 
select PackageNumber, BoxSku , CreatedTime, WeightTime , OrderNumber
from import_data.PackageDetail pd
)

-- 【Part2 单一指标】
, purc as ( -- 采购单数\散采购单数\供应商数量\供应商数（供货>1000元)\千元供应商供货金额
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU group by category 
union all -- 分品类（新品）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU  where is_new=1 
union all -- 分品类（重点）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU  where is_lead=1 
union all -- 分品类（其他）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU  where is_other=1 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 group by category 
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 group by category  
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, count(distinct(OrderNumber)) `采购单数` , count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
	, count(distinct(SupplierId)) `供应商数量`, count(distinct case when supplier_amount>1000 then SupplierId end) `供应商数（供货>1000元)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `对应供货金额`, sum(Price - DiscountedPrice) `总供货金额`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 group by category  
)

/*
instockquantity = 0 and IsComplete = '否'，采购在途
instockquantity = 0 and IsComplete = '是'，手工完结，实际没有到货
instockquantity > 0 and IsComplete = '否'，部分sku已到货，比如周报11月7日的OrderNumber =2877728
instockquantity > 0 and IsComplete = '是'，已到货
*/

-- , po_pre as ( -- 往前推5天以便计算 5天采购到货率 
-- select 
-- 	po.OrderNumber,po.BoxSku 
-- 	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then pr.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
-- 	when scantime is null and instockquantity > 0 and CompleteTIme is not null 
-- 	and timestampdiff(second, ordertime, CompleteTIme) < 86400 * 5 then pr.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单
-- 	end as in5days_rev_numb -- 满足5天到货的下单号
-- 	, case when instockquantity = 0 and IsComplete = '是' then null else po.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
-- from import_data.PurchaseOrder po
-- left join (select OrderNumber, max(scantime) as scantime from import_data.PurchaseRev group by OrderNumber) pr 
-- 	on po.OrderNumber = pr.OrderNumber
-- where ordertime  >= date_add('${EndDay}',interval -12 day) and ordertime < date_add('${EndDay}',interval -5 day)
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
-- ) 
-- 
-- , purchase_arrived_5day_rate as ( -- 采购五天到货率
-- select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre
-- union all -- 分类目
-- select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU group by category 
-- union all -- 分品类（新品）
-- select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率`
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_new=1 
-- union all -- 分品类（重点）
-- select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_lead=1 
-- union all -- 分品类（其他）
-- select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_other=1 
-- union all -- 分品类（新品）+分类目
-- select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_new=1 group by category 
-- union all -- 分品类（重点）+分类目
-- select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_lead=1 group by category  
-- union all -- 分品类（其他）+分类目
-- select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
-- 	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
-- from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_other=1 group by category  
-- )
-- /* 
-- , not_delivery_10day as ( -- 统计时近10天未发货订单 / 统计期日均订单数  -- 只有6月17日之后没有满足条件的数据
-- select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
-- 	, count(distinct case when timestampdiff(second, PayTime, ShipTime) >= 86400*10 then PlatOrderNumber end) `10天未发货订单数`
-- 	, count(distinct case when timestampdiff(second, PayTime, ShipTime) >= 86400*10  then PlatOrderNumber end)/ count(distinct PlatOrderNumber) as `10天未发货订单占比` 
-- from od 
-- )
-- */


, od_pre as ( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
join import_data.mysql_store s on s.code = a.ShopIrobotId
where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
	and PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -30 day)
)

, gen_and_deliv_package as (-- 两天生包率\5天发货率\7天发货率
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber  left join pt on pt.BoxSKU = od_pre.BoxSKU ) tmp
union all -- 分类目
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU group by category ) tmp
union all -- 分品类（新品）
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from  (select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_new=1 ) tmp
union all -- 分品类（重点）
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_lead=1 ) tmp
union all -- 分品类（其他）
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_other=1 ) tmp
union all -- 分品类（新品）+分类目
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_new=1 group by category ) tmp
union all -- 分品类（重点）+分类目
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_lead=1 group by category ) tmp
union all -- 分品类（其他）+分类目
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
	, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率` 
from  (select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_other=1 group by category ) tmp
)



-- -- 物流轨迹表 数据未更新 目前只有到10月28日的数据
-- -- , pd as ( -- 供应商 三天上网率= 上网时长<72h的包裹数 / 总包裹数 （上周五到本周四发货订单中）
-- -- select round(count(distinct eaalt.PackageNumber)/count(distinct pd.PackageNumber),4) `包裹可查率`
-- -- 	, round(count(distinct case when OnlineHour < 72 then eaalt.PackageNumber end) / count(distinct eaalt.PackageNumber),4) `三天上网率`
-- -- from import_data.PackageDetail pd
-- -- left join ( select PackageNumber , OnlineHour from import_data.erp_amazon_amazon_logistics_tracking ) eaalt 
-- -- 	on pd.PackageNumber = eaalt.PackageNumber 
-- -- where pd.weighttime < date_add('${EndDay}',interval -3 day)  and pd.weighttime >= date_add('${EndDay}',interval -10 day) 
-- -- )

, avg_gen_day AS ( -- 平均生包天数
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber) tmp
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU ) tmp group by category
union all -- 分品类（新品）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_new=1  ) tmp 
union all -- 分品类（重点）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_lead=1  ) tmp 
union all -- 分品类（其他）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_other=1 ) tmp 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_newr=1 ) tmp group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_lead=1 ) tmp group by category
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, sum(gen_days)/count(DISTINCT OrderNumber) `平均生包天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_other=1 ) tmp group by category
)

, avg_delivery_day AS ( -- 平均发货天数
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber 
	WHERE weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU WHERE weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- 分品类（新品）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_new=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp 
union all -- 分品类（重点）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_lead=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp 
union all -- 分品类（其他）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_other=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_newr=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_lead=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `平均发货天数`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from od join pd on od.OrderNumber =pd.OrderNumber
	left join pt on pt.BoxSKU = od_pre.BoxSKU  WHERE is_other=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp group by category
)

, delivery_24hour_rate as ( -- 24小时发货率 = 当周生包在24小时发货数/当周生包数
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) 
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) group by category
union all -- 分品类（新品）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day)  and is_new=1 
union all -- 分品类（重点）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day)  and is_lead=1 
union all -- 分品类（其他）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day)  and is_other=1 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) and is_new=1 group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) and is_lead=1 group by category
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) and is_other=1 group by category
)
-- 
, rev_48_rate as ( -- 48小时收货率,计算0<销单时间-扫描时间<=2的采购单去重后的总数，统计范围是上周六到这周五之间的扫描的，给本周五的留够48小时
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓'
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '所有产品' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' group by category
union all -- 分品类（新品）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' and is_new=1 
union all -- 分品类（重点）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' and is_lead=1 
union all -- 分品类（其他）
select '所有类目' category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' and is_other=1 
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' and is_new=1 group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' and is_lead=1 group by category
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' and b.WarehouseName = '东莞仓' and is_other=1 group by category
) 

-- 月度计算
-- , sku_purchase_times as (-- SKU月度采购频次=近4周sku下采购单次数），采购频次高的SKU，考虑优化提高单次采购量
-- select '所有类目' category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '所有产品' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp 
-- union all -- 分类目
-- select category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '所有产品' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU group by category 
-- union all -- 分品类（新品）
-- select '所有类目' category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '新品' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new=1 
-- union all -- 分品类（重点）
-- select '所有类目' category,'所有部门' as department, '月报' as ReportType,date_add('${EndDay}',interval -1 month) as static_date, '重点' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead=1 
-- union all -- 分品类（其他）
-- select '所有类目' category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '其他' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other=1 
-- union all -- 分品类（新品）+分类目
-- select category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '新品' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new=1 group by category 
-- union all -- 分品类（重点）+分类目
-- select category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '重点' as product_tupe, round(avg(cnt),2) `月度SKU采购频次` 
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead=1 group by category 
-- union all -- 分品类（其他）+分类目
-- select category,'所有部门' as department, '月报' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '其他' as product_tupe, round(avg(cnt),2) `月度SKU采购频次`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '月报' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other=1 group by category 
-- )

, po_product as ( -- 在途`采购产品金额`
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po where IsComplete = '否' and InstockQuantity = 0
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where IsComplete = '否' and InstockQuantity = 0 group by category 
union all -- 分品类（新品）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and IsComplete = '否' and InstockQuantity = 0
union all -- 分品类（重点）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '否' and InstockQuantity = 0
union all -- 分品类（其他）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '否' and InstockQuantity = 0
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and IsComplete = '否' and InstockQuantity = 0  group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '否' and InstockQuantity = 0 group by category 
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '否' and InstockQuantity = 0 group by category 
)


, po_Freight as ( -- 在途`采购运费`
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from (select distinct PurchaseOrderNo, Freight fr from po where IsComplete = '否' and InstockQuantity = 0) a 
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category 
	from po left join pt on pt.BoxSKU = po.BoxSKU where IsComplete = '否' and InstockQuantity = 0 ) tmp 
group by category 
union all -- 分品类(新品)
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and IsComplete = '否' and InstockQuantity = 0 ) tmp 
union all -- 分品类(重点)
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '否' and InstockQuantity = 0 ) tmp 
union all -- 分品类(其他)
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '否' and InstockQuantity = 0 ) tmp 
union all -- 分品类(新品)+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '新品' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and IsComplete = '否' and InstockQuantity = 0 ) tmp 
group by category 
union all -- 分品类(重点)+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '重点' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '否' and InstockQuantity = 0 ) tmp 
group by category 
union all -- 分品类(其他)+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, '其他' as product_tupe, ifnull(sum(fr),0) `采购运费` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '否' and InstockQuantity = 0 ) tmp 
group by category 
)


, delivery_purchase_amount as ( -- `发货订单采购金额usd`
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku 
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)  
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) group by category
union all -- 分品类(新品)
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku  left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) and  pt.is_new = 1
union all -- 分品类(重点)
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) and  pt.is_lead = 1
union all -- 分品类(其他)
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) and  pt.is_other = 1
union all -- 分品类(新品)+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd`
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) and  pt.is_new = 1 group by category
union all -- 分品类(重点)+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) and  pt.is_lead = 1 group by category
union all -- 分品类(其他)+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, round(sum(abs(od.PurchaseCosts/ExchangeUSD))) `发货订单采购金额usd` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku left join pt on od.BoxSku = pt.BoxSKU
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) and  pt.is_other = 1 group by category
)


, local_w as (  -- 在仓产品金额，sku库存件数，sku数 
SELECT '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, sum(TotalPrice) `在仓产品金额`, sum(TotalInventory) `在仓sku件数`, count(*) `在仓sku数` FROM lw where TotalInventory > 0
union all -- 分类目
SELECT category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, sum(TotalPrice) `在仓产品金额`, sum(TotalInventory) `在仓sku件数`, count(*) `在仓sku数`FROM lw where TotalInventory > 0 group by category
union all -- 分品类
SELECT '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, product_tupe
	, sum(TotalPrice) `在仓产品金额`, sum(TotalInventory) `在仓sku件数`, count(*) `在仓sku数`
	from (select *, '新品' as product_tupe from lw where is_new=1 
		union all select *, '重点' as product_tupe from lw where is_lead=1 
		union all select *, '其他' as product_tupe from lw where is_other=1 ) tmp
	where TotalInventory > 0
	group by product_tupe
union all -- 分品类+分类目
SELECT category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date, product_tupe
	, sum(TotalPrice) `在仓产品金额`, sum(TotalInventory) `在仓sku件数`, count(*) `在仓sku数`
	from (select *, '新品' as product_tupe from lw where is_new = 1 
		union all select *, '重点' as product_tupe from lw where is_lead = 1 
		union all select *, '其他' as product_tupe from lw where is_other = 1) tmp
	where TotalInventory > 0
	group by category, product_tupe
)


, noorder as ( -- 本周未出单SKU资金占用、sku数、库存数
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw
union all -- 分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw group by category
union all -- 分品类（新品）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw where is_new = 1
union all -- 分品类（重点）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw where is_lead = 1
union all -- 分品类（其他）
select '所有类目' as category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw where is_other = 1
union all -- 分品类（新品）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw where is_new = 1 group by category
union all -- 分品类（重点）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw where is_lead = 1 group by category
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `未出单sku资金占用`, count( distinct case when is_order=0 then BoxSKU end ) `未出单sku数`, sum( case when is_order=0 then TotalInventory end ) `未出单SKU总库存数`
from lw where is_other = 1 group by category
)
-- 
, sku_noorder_publish as ( -- 本周在仓未出单SKU本周刊登SKU数、本周未出单SKU刊登条数大于10条
SELECT '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1
	group by lw.BoxSKU ) tmp 
union all -- 分类目
SELECT category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1
	group by lw.BoxSKU, lw.category) tmp 
group by category
union all -- 分品类(新品)
SELECT '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_new = 1 
	group by lw.BoxSKU, lw.category) tmp 
union all -- 分品类(重点)
SELECT '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_lead = 1 
	group by lw.BoxSKU, lw.category) tmp 
union all -- 分品类(其他)
SELECT '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_other = 1 
	group by lw.BoxSKU, lw.category) tmp
union all -- 分品类(新品)+分类目
SELECT category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_new = 1 
	group by lw.BoxSKU, lw.category) tmp 
group by category
union all -- 分品类(重点)+分类目
SELECT category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_lead = 1 
	group by lw.BoxSKU, lw.category) tmp 
group by category
union all -- 分品类(其他)+分类目
SELECT category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, count(distinct BoxSKU ) `本周未出单SKU本周刊登SKU数`
	, count(distinct case when cnt > 10 then BoxSKU end) `本周刊登>10条的未出单SKU数`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_other = 1 
	group by lw.BoxSKU, lw.category) tmp 
group by category
)


, lw_sku_sale_rate as ( -- 当周在仓SKU动销率 = 去重(本周在仓出单SKU+本周采购出单SKU) / 去重(本周在仓SKU+本周采购SKU+本周在仓出单SKU+本周采购出单SKU)
select '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, count(distinct case when is_order = 1 then BoxSKU end)/count(distinct BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp
union all -- 分类目
select category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'所有产品' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU group by category
union all -- 分品类（新品）
select '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new = 1 
union all -- 分品类（重点）
select '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead = 1 
union all -- 分品类（新品）
select '所有类目' as category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other = 1
union all -- 分品类（新品）+分类目
select category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'新品' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new = 1 group by category
union all -- 分品类（重点）+分类目
select category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'重点' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead = 1 group by category
union all -- 分品类（其他）+分类目
select category, '所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `当周在仓SKU动销率`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other = 1 group by category
)


, metric_set as (
select lw.category, lw.department, lw.ReportType, lw.static_date, lw.product_tupe
-- 	, spt.`月度SKU采购频次`
	, gadp.`2天生包率` , gadp.`订单5天发货率`, gadp.`订单7天发货率`, d2r.`24小时发货率`, r4r.`48小时收货率`, agd.`平均生包天数`,adld.`平均发货天数`
	, purc.`采购单数`, purc.`零散采购单数`, purc.`供应商数量`, purc.`供应商数（供货>1000元)`, purc.`对应供货金额`, purc.`总供货金额`, pa5r.`采购5天到货率`
	, lw.`在仓产品金额`, lw.`在仓sku件数`, lw.`在仓sku数`, pp.`采购产品金额`, pf.`采购运费`, dpa.`发货订单采购金额usd`
	, n.`未出单sku资金占用`, n.`未出单sku数`, n.`未出单SKU总库存数`, snp.`本周未出单SKU本周刊登SKU数`, snp.`本周刊登>10条的未出单SKU数`, lssr.`当周在仓SKU动销率`
from local_w lw
left join po_product pp 
	on lw.category=pp.category and lw.department=pp.department 
	and lw.ReportType=pp.ReportType and lw.static_date=pp.static_date and lw.product_tupe=pp.product_tupe
left join po_Freight pf
	on lw.category=pf.category and lw.department=pf.department 
	and lw.ReportType=pf.ReportType and lw.static_date=pf.static_date and lw.product_tupe=pf.product_tupe
left join delivery_purchase_amount dpa 
	on lw.category=dpa.category and lw.department=dpa.department 
	and lw.ReportType=dpa.ReportType and lw.static_date=dpa.static_date and lw.product_tupe=dpa.product_tupe
left join noorder n on lw.category=n.category and lw.department=n.department 
	and lw.ReportType=n.ReportType and lw.static_date=n.static_date and lw.product_tupe=n.product_tupe
left join sku_noorder_publish snp on lw.category=snp.category and lw.department=snp.department 
	and lw.ReportType=snp.ReportType and lw.static_date=snp.static_date and lw.product_tupe=snp.product_tupe
left join lw_sku_sale_rate lssr on lw.category=lssr.category and lw.department=lssr.department 
	and lw.ReportType=lssr.ReportType and lw.static_date=lssr.static_date and lw.product_tupe=lssr.product_tupe 
left join purc on lw.category=purc.category and lw.department=purc.department 
	and lw.ReportType=purc.ReportType and lw.static_date=purc.static_date and lw.product_tupe=purc.product_tupe 
left join gen_and_deliv_package gadp on lw.category=gadp.category and lw.department=gadp.department 
	and lw.ReportType=gadp.ReportType and lw.static_date=gadp.static_date and lw.product_tupe=gadp.product_tupe 
left join delivery_24hour_rate d2r on lw.category=d2r.category and lw.department=d2r.department 
	and lw.ReportType=d2r.ReportType and lw.static_date=d2r.static_date and lw.product_tupe=d2r.product_tupe 
left join rev_48_rate r4r on lw.category=r4r.category and lw.department=r4r.department 
	and lw.ReportType=r4r.ReportType and lw.static_date=r4r.static_date and lw.product_tupe=r4r.product_tupe 
-- left join sku_purchase_times spt on lw.category=spt.category and lw.department=spt.department 
-- 	and lw.ReportType=spt.ReportType and lw.static_date=spt.static_date and lw.product_tupe=spt.product_tupe 
left join purchase_arrived_5day_rate pa5r on lw.category=pa5r.category and lw.department=pa5r.department 
	and lw.ReportType=pa5r.ReportType and lw.static_date=pa5r.static_date and lw.product_tupe=pa5r.product_tupe 
LEFT JOIN avg_gen_day agd on lw.category=agd.category and lw.department=agd.department 
	and lw.ReportType=agd.ReportType and lw.static_date=agd.static_date and lw.product_tupe=agd.product_tupe 
LEFT JOIN avg_delivery_day adld on lw.category=adld.category and lw.department=adld.department 
	and lw.ReportType=adld.ReportType and lw.static_date=adld.static_date and lw.product_tupe=adld.product_tupe 
)


-- -- 【第3部分 复合计算指标】
select category, department, ReportType, static_date, product_tupe
	, `订单5天发货率`, `订单7天发货率`, `2天生包率`, `采购5天到货率`, `48小时收货率`, `平均生包天数`, `平均发货天数`, `24小时发货率`, `采购单数`, `零散采购单数`, `供应商数量`, `供应商数（供货>1000元)`
	, round(`对应供货金额`/usdratio) as `对应供货金额`  , round(`总供货金额`/usdratio) as `总供货金额` 
-- 	, `月度SKU采购频次`
	, round(`零散采购单数`/`采购单数`,4) as `零散采购占比`
	, round((`在仓产品金额`+`采购产品金额`+`采购运费`)/usdratio) as `本地库存金额`
	, round((`在仓产品金额`+`采购产品金额`+`采购运费`)) as `本地库存金额rmb`
	, round((`在仓产品金额`+`采购产品金额`+`采购运费`)/usdratio/`发货订单采购金额usd`*7)  as `本地仓库存周转天数`
	, round(`当周在仓SKU动销率`,4) as `当周在仓SKU动销率`
	, `在仓sku件数`, `在仓sku数`, round(`未出单sku资金占用`/usdratio) as `未出单sku资金占用`, `未出单sku数`, `未出单SKU总库存数`, `本周未出单SKU本周刊登SKU数`, `本周刊登>10条的未出单SKU数`
from metric_set m,(select usdratio from import_data.Basedata where firstday = date_add('${EndDay}',interval -7 day) and reporttype = '周报' limit 1) b 
order by category, department, ReportType, static_date, product_tupe
