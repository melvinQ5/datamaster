/* ά�ȣ���Ŀ�����š��ܱ����ܴΡ�Ʒ��ṹ
-- weekofyear('${EndDay}') ��Ϊ�Ѿ���д��������һ�����Բ���Ҫ�ܴ�+1��
 */
with
-- ��Part1 ���ݼ�����
pt as ( -- product_type ��Ʒ�� (��Ʒ���ص㡢����) group by product_type
select tmp.* ,case when is_new + is_lead = 0 then 1 end as is_other -- ����
from (
	select pc.*
		, case when pc.DevelopLastAuditTime>=date_add('${EndDay}',interval -6 month ) and pc.DevelopLastAuditTime<'${EndDay}' then 1 else 0 end as is_new -- ��Ʒ
		, case when lp.SKU  is not null then 1 else 0 end as is_lead -- �ص�
	from (select pp.id,pp.spu,pp.sku,pp.BoxSKU,bpv.ChineseValueName as category,pp.DevelopLastAuditTime
		from erp_product_products pp
		join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
		join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
		join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
		where ChineseName = 'С�����' and bpv.ChineseValueName is Not null ) pc 
	left join lead_product lp on pc.SKU = lp.SKU ) tmp
)

, od as ( -- ������
select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
join import_data.mysql_store s on s.code = a.ShopIrobotId
where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
	and PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -7 day)
)

, lw as ( -- local_warehouse ���زֱ�
select 
	case when tmp.BoxSKU is null then 0 else 1 end as is_order -- 0=δ������1=�г���
	, TotalPrice, TotalInventory, pt.BoxSKU, pt.category, pt.id as ProductId, pt.is_new, pt.is_lead, pt.is_other
FROM import_data.WarehouseInventory wi
join pt on wi.BoxSku = pt.BoxSKU
left join -- ���ڼ����Ƿ��ܳ���
	(select distinct BoxSku from od) tmp on wi.BoxSku = tmp.BoxSKU 
where WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�'
)

, lw_pre as ( -- local_warehouse ���ڱ��زֱ�
select 
	case when tmp.BoxSKU is null then 0 else 1 end as is_order -- 0=δ������1=�г���
	, TotalPrice, TotalInventory, pt.BoxSKU, pt.category, pt.id as ProductId, pt.is_new, pt.is_lead, pt.is_other
FROM import_data.WarehouseInventory wi
join pt on wi.BoxSku = pt.BoxSKU 
left join -- ���ڼ����Ƿ��ܳ���
	(select distinct BoxSku from od) tmp on wi.BoxSku = tmp.BoxSKU 
where WarehouseName = '��ݸ��' and Monday < date_add('${EndDay}',interval -7 day) and Monday >= date_add('${EndDay}',interval -14 day) and ReportType = '�ܱ�'
)

, po as ( -- PurchaseOrder �ɹ���
select po.* 
	, case when tmp.BoxSKU is null then 0 else 1 end as is_order -- 0=δ������1=�г���
	, sum(Price - DiscountedPrice + (Price - DiscountedPrice)/(PayPrice-Freight)*Freight )over(partition by SupplierId) as supplier_amount -- ��Ӧ�̵��ܹ������(��Ʒ+�˷�)
	, sum(Quantity)over(partition by po.OrderNumber) as total_qy -- ���ʶ����ɹ�����
	, pr.PurchaseOrderNo as is_arrived -- �ѵ���
from (select * from import_data.PurchaseOrder 
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
	) po
left join (select distinct BoxSku from od ) tmp on po.BoxSku = tmp.BoxSKU -- ���ڼ����Ƿ��ܳ���
left join import_data.PurchaseRev pr on pr.PurchaseOrderNo = po.PurchaseOrderNo -- ���ڼ���N�쵽����
)

, pd as ( -- PackageDetail������ ���������켣��
select PackageNumber, BoxSku , CreatedTime, WeightTime , OrderNumber
from import_data.PackageDetail pd
-- left join ( select PackageNumber , OnlineHour from import_data.erp_amazon_amazon_logistics_tracking ) eaalt 
-- 	on pd.PackageNumber = eaalt.PackageNumber 
)

-- ��Part2 ��һָ�꡿
, purc as ( -- �ɹ�����\ɢ�ɹ�����\��Ӧ������\��Ӧ����������>1000Ԫ)\ǧԪ��Ӧ�̹������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU group by category 
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU  where is_new=1 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU  where is_lead=1 
union all -- ��Ʒ�ࣨ������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU  where is_other=1 
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 group by category 
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 group by category  
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 group by category  
)

, po_pre as ( -- ��ǰ��5���Ա���� 5��ɹ�������
select 
	po.PurchaseOrderNo,po.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then pr.PurchaseOrderNo -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and ((instockquantity > 0) or ( CompleteTime is not null and IsComplete = '��' )) 
	and timestampdiff(second, ordertime, CompleteTIme) < 86400 * 5 then pr.PurchaseOrderNo -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	end as in5days_rev_numb -- ����5�쵽���Ĳɹ�����
from import_data.PurchaseOrder po
left join import_data.PurchaseRev pr on po.PurchaseOrderNo = pr.PurchaseOrderNo -- ���ڼ���N�쵽����
where date_add(ordertime, 5)  >= date_add('${EndDay}',interval -7 day) and date_add(ordertime, 5) < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
) 

, purchase_arrived_5day_rate as ( -- �ɹ����쵽����
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU group by category 
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����`
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_new=1 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_lead=1 
union all -- ��Ʒ�ࣨ������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_other=1 
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_new=1 group by category 
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_lead=1 group by category  
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct PurchaseOrderNo),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_other=1 group by category  
)
-- /* 
-- , not_delivery_10day as ( -- ͳ��ʱ��10��δ�������� / ͳ�����վ�������  -- ֻ��6��17��֮��û����������������
-- select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
-- 	, count(distinct case when timestampdiff(second, PayTime, ShipTime) >= 86400*10 then PlatOrderNumber end) `10��δ����������`
-- 	, count(distinct case when timestampdiff(second, PayTime, ShipTime) >= 86400*10  then PlatOrderNumber end)/ count(distinct PlatOrderNumber) as `10��δ��������ռ��` 
-- from od 
-- )
-- */


, od_pre as ( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
join import_data.mysql_store s on s.code = a.ShopIrobotId
where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
	and PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -30 day)
)

, gen_and_deliv_package as (-- ����������\5�췢����\7�췢����
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber  left join pt on pt.BoxSKU = od_pre.BoxSKU ) tmp
union all -- ����Ŀ
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU group by category ) tmp
union all -- ��Ʒ�ࣨ��Ʒ��
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_new=1 ) tmp
union all -- ��Ʒ�ࣨ�ص㣩
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_lead=1 ) tmp
union all -- ��Ʒ�ࣨ������
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_other=1 ) tmp
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_new=1 group by category ) tmp
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_lead=1 group by category ) tmp
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,department,ReportType,static_date,product_tupe, round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_other=1 group by category ) tmp
)



-- -- �����켣�� ����δ���� Ŀǰֻ�е�10��28�յ�����
-- -- , pd as ( -- ��Ӧ�� ����������= ����ʱ��<72h�İ����� / �ܰ����� �������嵽�����ķ��������У�
-- -- select round(count(distinct eaalt.PackageNumber)/count(distinct pd.PackageNumber),4) `�����ɲ���`
-- -- 	, round(count(distinct case when OnlineHour < 72 then eaalt.PackageNumber end) / count(distinct eaalt.PackageNumber),4) `����������`
-- -- from import_data.PackageDetail pd
-- -- left join ( select PackageNumber , OnlineHour from import_data.erp_amazon_amazon_logistics_tracking ) eaalt 
-- -- 	on pd.PackageNumber = eaalt.PackageNumber 
-- -- where pd.weighttime < date_add('${EndDay}',interval -3 day)  and pd.weighttime >= date_add('${EndDay}',interval -10 day) 
-- -- )


, delivery_24hour_rate as ( -- 24Сʱ������ = ����������24Сʱ������/����������
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) 
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) group by category
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day)  and is_new=1 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day)  and is_lead=1 
union all -- ��Ʒ�ࣨ������
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day)  and is_other=1 
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) and is_new=1 group by category
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) and is_lead=1 group by category
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from pd left join pt on pt.BoxSKU = pd.BoxSKU where CreatedTime < '${EndDay}' and CreatedTime >= date_add('${EndDay}',interval -7 day) and is_other=1 group by category
)
-- 
, rev_48_rate as ( -- 48Сʱ�ջ���,����0<����ʱ��-ɨ��ʱ��<=2�Ĳɹ���ȥ�غ��������ͳ�Ʒ�Χ����������������֮���ɨ��ģ��������������48Сʱ
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��'
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' group by category
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' and is_new=1 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' and is_lead=1 
union all -- ��Ʒ�ࣨ������
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' and is_other=1 
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' and is_new=1 group by category
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' and is_lead=1 group by category
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo left join pt on pt.BoxSKU = b.BoxSKU
where date_add(scantime, 2) < '${EndDay}' and date_add(scantime, 2) >= date_add('${EndDay}',interval -7 day) 
	and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��' and is_other=1 group by category
) 

-- �¶ȼ���
-- , sku_purchase_times as (-- SKU�¶Ȳɹ�Ƶ��=��4��sku�²ɹ������������ɹ�Ƶ�θߵ�SKU�������Ż���ߵ��βɹ���
-- select '������Ŀ' category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '���в�Ʒ' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp 
-- union all -- ����Ŀ
-- select category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '���в�Ʒ' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU group by category 
-- union all -- ��Ʒ�ࣨ��Ʒ��
-- select '������Ŀ' category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '��Ʒ' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new=1 
-- union all -- ��Ʒ�ࣨ�ص㣩
-- select '������Ŀ' category,'���в���' as department, '�±�' as ReportType,date_add('${EndDay}',interval -1 month) as static_date, '�ص�' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead=1 
-- union all -- ��Ʒ�ࣨ������
-- select '������Ŀ' category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '����' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other=1 
-- union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
-- select category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '��Ʒ' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new=1 group by category 
-- union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
-- select category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '�ص�' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��` 
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead=1 group by category 
-- union all -- ��Ʒ�ࣨ������+����Ŀ
-- select category,'���в���' as department, '�±�' as ReportType, date_add('${EndDay}',interval -1 month) as static_date, '����' as product_tupe, round(avg(cnt),2) `�¶�SKU�ɹ�Ƶ��`
-- from (select BoxSku , count(distinct PurchaseOrderNo) cnt from import_data.PurchaseOrder where ordertime >= date_add('${EndDay}',interval -1 month) and ordertime < '${EndDay}' 
-- 	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -1 month) and ReportType = '�±�' group by BoxSku	
-- 	) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other=1 group by category 
-- )

, po_product as ( -- `�ɹ���Ʒ���`
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po where !(IsComplete = '��' and InstockQuantity = 0)
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where !(IsComplete = '��' and InstockQuantity = 0) group by category 
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and !(IsComplete = '��' and InstockQuantity = 0)
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and !(IsComplete = '��' and InstockQuantity = 0)
union all -- ��Ʒ�ࣨ������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and !(IsComplete = '��' and InstockQuantity = 0)
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and !(IsComplete = '��' and InstockQuantity = 0)  group by category
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and !(IsComplete = '��' and InstockQuantity = 0) group by category 
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, sum(Price - DiscountedPrice) `�ɹ���Ʒ���` from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and !(IsComplete = '��' and InstockQuantity = 0) group by category 
)


, po_Freight as ( -- `�ɹ��˷�`
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from (select distinct(PurchaseOrderNo), Freight fr from po where !(IsComplete = '��' and InstockQuantity = 0)) a 
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
group by category 
union all -- ��Ʒ��(��Ʒ)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
union all -- ��Ʒ��(�ص�)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
union all -- ��Ʒ��(����)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
union all -- ��Ʒ��(��Ʒ)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
group by category 
union all -- ��Ʒ��(�ص�)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
group by category 
union all -- ��Ʒ��(����)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/(PayPrice-Freight)*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and !(IsComplete = '��' and InstockQuantity = 0) ) tmp 
group by category 
)
-- 
-- 
, delivery_purchase_amount as ( -- `���������ɹ����usd`
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts/ExchangeUSD) pc 
	from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day) ) a  
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc 
	from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU group by category
union all -- ��Ʒ��(��Ʒ)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU where pt.is_new = 1
union all -- ��Ʒ��(�ص�)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU where pt.is_lead = 1
union all -- ��Ʒ��(����)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU where pt.is_other = 1
union all -- ��Ʒ��(��Ʒ)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU where pt.is_new = 1 group by category
union all -- ��Ʒ��(�ص�)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU where pt.is_new = 1 group by category
union all -- ��Ʒ��(����)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, round(sum(pc)) `���������ɹ����usd` 
from ( select distinct pd.OrderNumber,od.BoxSku,abs(od.PurchaseCosts/ExchangeUSD) pc from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
	where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)) od 
left join pt on od.BoxSku = pt.BoxSKU where pt.is_new = 1 group by category
)
-- 
-- 
, local_w as (  -- �ڲֲ�Ʒ��sku��������sku�� 
SELECT '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum(TotalPrice) `�ڲֲ�Ʒ���`, sum(TotalInventory) `�ڲ�sku����`, count(*) `�ڲ�sku��` FROM lw where TotalInventory > 0
union all -- ����Ŀ
SELECT category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum(TotalPrice) `�ڲֲ�Ʒ���`, sum(TotalInventory) `�ڲ�sku����`, count(*) `�ڲ�sku��`FROM lw where TotalInventory > 0 group by category
union all -- ��Ʒ��
SELECT '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, product_tupe
	, sum(TotalPrice) `�ڲֲ�Ʒ���`, sum(TotalInventory) `�ڲ�sku����`, count(*) `�ڲ�sku��`
	from (select *, '��Ʒ' as product_tupe from lw where is_new=1 
		union all select *, '�ص�' as product_tupe from lw where is_lead=1 
		union all select *, '����' as product_tupe from lw where is_other=1 ) tmp
	where TotalInventory > 0
	group by product_tupe
union all -- ��Ʒ��+����Ŀ
SELECT category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, product_tupe
	, sum(TotalPrice) `�ڲֲ�Ʒ���`, sum(TotalInventory) `�ڲ�sku����`, count(*) `�ڲ�sku��`
	from (select *, '��Ʒ' as product_tupe from lw where is_new = 1 
		union all select *, '�ص�' as product_tupe from lw where is_lead = 1 
		union all select *, '����' as product_tupe from lw where is_other = 1) tmp
	where TotalInventory > 0
	group by category, product_tupe
)

, local_w_pre as (  -- �ڲֲ�Ʒ��sku��������sku�� ������� static_date ���ܱ�,�Ա����left join�Ƕ����һ����
SELECT '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum(TotalPrice) `�����ڲֲ�Ʒ���`  FROM lw_pre where TotalInventory > 0
union all -- ����Ŀ
SELECT category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum(TotalPrice) `�����ڲֲ�Ʒ���`  FROM lw_pre where TotalInventory > 0 group by category
union all -- ��Ʒ��
SELECT '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, product_tupe
	, sum(TotalPrice) `�����ڲֲ�Ʒ���` 
	from (select *, '��Ʒ' as product_tupe from lw_pre where is_new=1 
		union all select *, '�ص�' as product_tupe from lw_pre where is_lead=1 
		union all select *, '����' as product_tupe from lw_pre where is_other=1 ) tmp
	where TotalInventory > 0
	group by product_tupe
union all -- ��Ʒ��+����Ŀ
SELECT category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, product_tupe
	, sum(TotalPrice) `�����ڲֲ�Ʒ���` 
	from (select *, '��Ʒ' as product_tupe from lw_pre where is_new = 1 
		union all select *, '�ص�' as product_tupe from lw_pre where is_lead = 1 
		union all select *, '����' as product_tupe from lw_pre where is_other = 1) tmp
	where TotalInventory > 0
	group by category, product_tupe
)


, noorder as ( -- ����δ����SKU�ʽ�ռ�á�sku���������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw group by category
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw where is_new = 1
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw where is_lead = 1
union all -- ��Ʒ�ࣨ������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw where is_other = 1
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw where is_new = 1 group by category
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw where is_lead = 1 group by category
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, sum( case when is_order=0 then TotalPrice end) `δ����sku�ʽ�ռ��`, count( distinct case when is_order=0 then BoxSKU end ) `δ����sku��`, sum( case when is_order=0 then TotalInventory end ) `δ����SKU�ܿ����`
from lw where is_other = 1 group by category
)
-- 
, sku_noorder_publish as ( -- �����ڲ�δ����SKU���ܿ���SKU��������δ����SKU������������10��
SELECT '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1
	group by lw.BoxSKU ) tmp 
union all -- ����Ŀ
SELECT category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1
	group by lw.BoxSKU, lw.category) tmp 
group by category
union all -- ��Ʒ��(��Ʒ)
SELECT '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_new = 1 
	group by lw.BoxSKU, lw.category) tmp 
union all -- ��Ʒ��(�ص�)
SELECT '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_lead = 1 
	group by lw.BoxSKU, lw.category) tmp 
union all -- ��Ʒ��(����)
SELECT '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_other = 1 
	group by lw.BoxSKU, lw.category) tmp
union all -- ��Ʒ��(��Ʒ)+����Ŀ
SELECT category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_new = 1 
	group by lw.BoxSKU, lw.category) tmp 
group by category
union all -- ��Ʒ��(�ص�)+����Ŀ
SELECT category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_lead = 1 
	group by lw.BoxSKU, lw.category) tmp 
group by category
union all -- ��Ʒ��(����)+����Ŀ
SELECT category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, count(distinct BoxSKU ) `����δ����SKU���ܿ���SKU��`
	, count(distinct case when cnt > 10 then BoxSKU end) `���ܿ���>10����δ����SKU��`
from ( SELECT lw.category, lw.BoxSKU , count(1) cnt  FROM import_data.erp_amazon_amazon_listing al join lw on lw.ProductId = al.ProductId and lw.is_order = 0
	where PublicationDate < '${EndDay}' and PublicationDate >= date_add('${EndDay}',interval -7 day) and ListingStatus = 1 and lw.is_other = 1 
	group by lw.BoxSKU, lw.category) tmp 
group by category
)
-- 
, lw_sku_sale_rate as ( -- �����ڲ�SKU������ = ȥ��(�����ڲֳ���SKU+���ܲɹ�����SKU) / ȥ��(�����ڲ�SKU+���ܲɹ�SKU+�����ڲֳ���SKU+���ܲɹ�����SKU)
select '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, count(distinct case when is_order = 1 then BoxSKU end)/count(distinct BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp
union all -- ����Ŀ
select category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU group by category
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new = 1 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead = 1 
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other = 1
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'��Ʒ' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_new = 1 group by category
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'�ص�' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_lead = 1 group by category
union all -- ��Ʒ�ࣨ������+����Ŀ
select category, '���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'����' as product_tupe
	, count(distinct case when is_order = 1 then tmp.BoxSKU end)/count(distinct tmp.BoxSKU)  `�����ڲ�SKU������`
from (select BoxSKU , is_order from po union select BoxSKU, is_order from lw) tmp left join pt on pt.BoxSKU = tmp.BoxSKU where is_other = 1 group by category
)


, metric_set as (
select lw.category, lw.department, lw.ReportType, lw.static_date, lw.product_tupe
-- 	, spt.`�¶�SKU�ɹ�Ƶ��`
	, gadp.`2��������` , gadp.`����5�췢����`, gadp.`����7�췢����`, d2r.`24Сʱ������`, r4r.`48Сʱ�ջ���`
	, purc.`�ɹ�����`, purc.`��ɢ�ɹ�����`, purc.`��Ӧ������`, purc.`��Ӧ����������>1000Ԫ)`, purc.`��Ӧ�������`, purc.`�ܹ������`, pa5r.`�ɹ�5�쵽����`
	, lw.`�ڲֲ�Ʒ���`, lwp.`�����ڲֲ�Ʒ���`, lw.`�ڲ�sku����`, lw.`�ڲ�sku��`, pp.`�ɹ���Ʒ���`, pf.`�ɹ��˷�`, dpa.`���������ɹ����usd`
	, n.`δ����sku�ʽ�ռ��`, n.`δ����sku��`, n.`δ����SKU�ܿ����`, snp.`����δ����SKU���ܿ���SKU��`, snp.`���ܿ���>10����δ����SKU��`, lssr.`�����ڲ�SKU������`
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
left join local_w_pre lwp on lw.category=lwp.category and lw.department=lwp.department 
	and lw.ReportType=lwp.ReportType and lw.static_date=lwp.static_date and lw.product_tupe=lwp.product_tupe 
left join purchase_arrived_5day_rate pa5r on lw.category=pa5r.category and lw.department=pa5r.department 
	and lw.ReportType=pa5r.ReportType and lw.static_date=pa5r.static_date and lw.product_tupe=pa5r.product_tupe 
)


-- -- ����3���� ���ϼ���ָ�꡿
select category, department, ReportType, static_date, product_tupe
	, `����5�췢����`, `����7�췢����`, `2��������`, `�ɹ�5�쵽����`, `48Сʱ�ջ���`, `24Сʱ������`, `�ɹ�����`, `��ɢ�ɹ�����`, `��Ӧ������`, `��Ӧ����������>1000Ԫ)`
	, round(`��Ӧ�������`/usdratio) as `��Ӧ�������`  , round(`�ܹ������`/usdratio) as `�ܹ������` 
-- 	, `�¶�SKU�ɹ�Ƶ��`
	, round(`��ɢ�ɹ�����`/`�ɹ�����`,4) as `��ɢ�ɹ�ռ��`
	, round((`�ڲֲ�Ʒ���`+`�ɹ���Ʒ���`+`�ɹ��˷�`)/usdratio) as `���ؿ����`
	, round((`�ڲֲ�Ʒ���`+`�����ڲֲ�Ʒ���`)/2/usdratio/`���������ɹ����usd`*7)  as `���زֿ����ת����`
	, round(`�����ڲ�SKU������`,4) as `�����ڲ�SKU������`
	, `�ڲ�sku����`, `�ڲ�sku��`, round(`δ����sku�ʽ�ռ��`/usdratio) as `δ����sku�ʽ�ռ��`, `δ����sku��`, `δ����SKU�ܿ����`, `����δ����SKU���ܿ���SKU��`, `���ܿ���>10����δ����SKU��`
from metric_set m,(select usdratio from import_data.Basedata where firstday = date_add('${EndDay}',interval -7 day) and reporttype = '�ܱ�' limit 1) b 
order by category, department, ReportType, static_date, product_tupe
