-- gen_and_deliv_package ����������\5�췢����\7�췢����
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


, od_pre as ( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
from import_data.OrderDetails a
join import_data.mysql_store s on s.code = a.ShopIrobotId
where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
	and PayTime < '${EndDay}' and date_add(PayTime,10) >= date_add('${EndDay}',interval -7 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
)



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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
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
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${EndDay}' and date_add(PayTime, 2) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${EndDay}' and date_add(PayTime, 5) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${EndDay}' and date_add(PayTime, 7) >= date_add('${EndDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from od_pre left join pd on od_pre.OrderNumber =pd.OrderNumber left join pt on pt.BoxSKU = od_pre.BoxSKU where is_other=1 group by category ) tmp

