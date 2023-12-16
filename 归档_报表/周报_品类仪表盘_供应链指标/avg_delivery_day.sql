-- ƽ������������ͳ���������з����İ����������ƿͻ�֧��ʱ�� avg_delivery_day 
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

, pd as ( -- PackageDetail������ 
select PackageNumber, BoxSku , CreatedTime, WeightTime , OrderNumber
from import_data.PackageDetail pd
)


select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days 
from import_data.OrderDetails od  join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
	WHERE weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp
union all -- ����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '���в�Ʒ' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
	left join pt on pt.BoxSKU = od.BoxSku WHERE weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- ��Ʒ�ࣨ��Ʒ��
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_new=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp 
union all -- ��Ʒ�ࣨ�ص㣩
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	, sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_lead=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp 
union all -- ��Ʒ�ࣨ������
select '������Ŀ' category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_other=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp 
union all -- ��Ʒ�ࣨ��Ʒ��+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '��Ʒ' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_new=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- ��Ʒ�ࣨ�ص㣩+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '�ص�' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_lead=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day) ) tmp group by category
union all -- ��Ʒ�ࣨ������+����Ŀ
select category,'���в���' as department, '�ܱ�' as ReportType, weekofyear('${EndDay}') as static_date, '����' as product_tupe
	,  sum(deli_days)/count(DISTINCT OrderNumber) `ƽ����������`
FROM (select DISTINCT category, pd.OrderNumber, timestampdiff(second, paytime, pd.weighttIme)/86400 AS deli_days from import_data.OrderDetails od  
	join pd on od.OrderNumber =pd.OrderNumber and TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0	
	left join pt on pt.BoxSKU = od.BoxSku  WHERE is_other=1 AND weighttIme < '${EndDay}' and weighttIme >= date_add('${EndDay}',interval -7 day)  ) tmp group by category
