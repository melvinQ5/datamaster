-- 48Сʱ�ջ���,����0<����ʱ��-ɨ��ʱ��<=2�Ĳɹ���ȥ�غ��������ͳ�Ʒ�Χ����������������֮���ɨ��ģ��������������48Сʱ rev_48_rate 
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