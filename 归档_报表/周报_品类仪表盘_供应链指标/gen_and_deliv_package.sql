-- gen_and_deliv_package 两天生包率\5天发货率\7天发货率
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


, od_pre as ( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
join import_data.mysql_store s on s.code = a.ShopIrobotId
where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
	and PayTime < '${EndDay}' and date_add(PayTime,10) >= date_add('${EndDay}',interval -7 day) -- 再往前预留10天的数据，便于后续计算往前推天数
)



select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
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

