-- `采购产品金额`  po_product 
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

, po as ( -- PurchaseOrder 采购表
select * , sum(Price - DiscountedPrice + (Price - DiscountedPrice)/ord_product_price*Freight )over(partition by SupplierId) as supplier_amount -- 供应商当周供货金额(产品+运费)
from 
( select po.* 
	, sum(Quantity)over(partition by po.OrderNumber) as total_qy -- 单笔订单采购件数
	, sum(Price - DiscountedPrice)over(PARTITION BY OrderNumber) AS ord_product_price -- 采购单产品金额（不含运费）
from (select * from import_data.PurchaseOrder 
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
	) po
) temp 
)

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
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '否' and InstockQuantity = 0  group by category 
union all -- 分品类（其他）+分类目
select category,'所有部门' as department, '周报' as ReportType, weekofyear('${EndDay}') as static_date,'其他' as product_tupe
	, sum(Price - DiscountedPrice) `采购产品金额` from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '否' and InstockQuantity = 0  group by category 


