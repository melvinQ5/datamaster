-- �ɹ�����\ɢ�ɹ�����\��Ӧ������\��Ӧ����������>1000Ԫ)\ǧԪ��Ӧ�̹������
with
pt as ( 
select tmp.* ,case when is_new + is_lead = 0 then 1 end as is_other -- ����
from (
	select pc.*
		, case when pc.DevelopLastAuditTime>='2022-10-01' then 1 else 0 end as is_new -- ��Ʒ
		, case when lp.SKU  is not null then 1 else 0 end as is_lead -- �ص�
	from (select pp.id,pp.spu,pp.sku,pp.BoxSKU,bpv.ChineseValueName as category,pp.DevelopLastAuditTime
		from erp_product_products pp
		join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
		join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
		join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
		where ChineseName = 'С�����' and bpv.ChineseValueName is Not null ) pc 
	left join lead_product lp on pc.SKU = lp.SKU ) tmp
)

, po as ( -- PurchaseOrder �ɹ���
select * , sum(Price - DiscountedPrice + (Price - DiscountedPrice)/ord_product_price*Freight )over(partition by SupplierId) as supplier_amount -- ��Ӧ�̵��ܹ������(��Ʒ+�˷�)
from 
( select po.* 
	, sum(Quantity)over(partition by po.OrderNumber) as total_qy -- ���ʶ����ɹ�����
	, sum(Price - DiscountedPrice)over(PARTITION BY OrderNumber) AS ord_product_price -- �ɹ�����Ʒ�������˷ѣ�
from (select * from import_data.PurchaseOrder 
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
	) po
) temp 
)


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
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 group by category  
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, count(distinct(OrderNumber)) `�ɹ�����` , count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
	, count(distinct(SupplierId)) `��Ӧ������`, count(distinct case when supplier_amount>1000 then SupplierId end) `��Ӧ����������>1000Ԫ)` 
	, sum(case when supplier_amount>1000 then Price - DiscountedPrice end) `��Ӧ�������`, sum(Price - DiscountedPrice) `�ܹ������`
	from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 group by category  