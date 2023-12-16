-- `�ɹ��˷�` po_Freight 
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


select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from (select distinct(PurchaseOrderNo), Freight fr from po where IsComplete = '��' and InstockQuantity = 0 ) a 
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where IsComplete = '��' and InstockQuantity = 0 ) tmp 
group by category 
union all -- ��Ʒ��(��Ʒ)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1 and IsComplete = '��' and InstockQuantity = 0  ) tmp 
union all -- ��Ʒ��(�ص�)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '��' and InstockQuantity = 0  ) tmp 
union all -- ��Ʒ��(����)
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '��' and InstockQuantity = 0 ) tmp 
union all -- ��Ʒ��(��Ʒ)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_new=1  and IsComplete = '��' and InstockQuantity = 0 ) tmp 
group by category 
union all -- ��Ʒ��(�ص�)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_lead=1 and IsComplete = '��' and InstockQuantity = 0 ) tmp 
group by category 
union all -- ��Ʒ��(����)+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe, ifnull(sum(fr),0) `�ɹ��˷�` 
from ( select (Price - DiscountedPrice)/ord_product_price*Freight as fr , category from po left join pt on pt.BoxSKU = po.BoxSKU where is_other=1 and IsComplete = '��' and InstockQuantity = 0 ) tmp 
group by category 