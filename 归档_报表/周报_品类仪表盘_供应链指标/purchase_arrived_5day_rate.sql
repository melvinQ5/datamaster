-- �ɹ�5�쵽���� purchase_arrived_5day_rate
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


, po_pre as ( -- ��ǰ��5���Ա���� 5��ɹ�������
select 
	po.OrderNumber,po.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then po.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then po.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else po.OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.PurchaseOrder po left join import_data.PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where date_add(ordertime, 5)  >= date_add('${EndDay}',interval -7 day) and date_add(ordertime, 5) < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
)


select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date,'���в�Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU group by category 
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_new=1 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_lead=1 
union all -- ��Ʒ�ࣨ������
select '������Ŀ' as category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU  where is_other=1 
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_new=1 group by category 
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_lead=1 group by category  
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from po_pre left join pt on pt.BoxSKU = po_pre.BoxSKU where is_other=1 group by category

