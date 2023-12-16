/*ͳ��ʱ��ʹ�÷�ʽ��EndDay �����ܵ���һ���ʲ����ܴ�+1 */
-- ָ��1 ������
with 
a1 as ( -- �ڲֲ�Ʒ���
SELECT weekofyear('${EndDay}') as static_date, sum(TotalPrice) `�ڲֲ�Ʒ���`
FROM import_data.WarehouseInventory wi
where TotalInventory > 0 and WarehouseName = '��ݸ��' and Monday = date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�'
)

, a2 as ( -- �ɹ���Ʒ���  ���ģ�"���״̬Ϊ�� �� �����=0"��ʾ��;
select weekofyear('${EndDay}') as static_date, sum(Price - DiscountedPrice) `�ɹ���Ʒ���`  
from import_data.PurchaseOrder po
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday = date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
	and IsComplete = '��' and InstockQuantity = 0)
	
, a3 as (-- �ɹ��˷�  ���ģ�"���״̬Ϊ�� �� �����=0"��ʾ��;
select weekofyear('${EndDay}') as static_date, ifnull(sum(fr),0) `�ɹ��˷�` 
from (select distinct PurchaseOrderNo , Freight fr from import_data.PurchaseOrder 
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '��ݸ��' and Monday = date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
	and IsComplete = '��' and InstockQuantity = 0) tmp
)

, b as ( -- �����������  ���ģ�on����������Ҫ����boxsku
select  weekofyear('${EndDay}') as static_date
	, round(sum(abs(od.PurchaseCosts))) `���������ɹ����` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku 
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)  
) 

select 
	`�ڲֲ�Ʒ���`+`�ɹ���Ʒ���`+`�ɹ��˷�` as `���ؿ����`
	, round((`�ڲֲ�Ʒ���`+`�ɹ���Ʒ���`+`�ɹ��˷�`)/`���������ɹ����`*7) as `�����ת����`
from a1,a2,a3,b



-- ָ��2 5��ɹ������� 
-- ���ģ����Ӽ��㣨��û��ɨ��ʱ�䣬ɸ�����������0������ʱ�䲻Ϊ�գ�������ʱ��-�µ�ʱ�䣩����ĸ���㣨�޵�ֻ�����˹�����¼���µ��ţ�
select weekofyear('${EndDay}') as static_date
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from (
	select 
		case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then pr.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		when scantime is null and instockquantity > 0 and CompleteTIme is not null 
		and timestampdiff(second, ordertime, CompleteTIme) < 86400 * 5 then pr.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		end as in5days_rev_numb -- ����5�쵽�����µ���
		, case when instockquantity = 0 and IsComplete = '��' then null else po.OrderNumber end as actual_ord_numb -- ȥ��ֻ�����˹������µ�����
	from import_data.PurchaseOrder po
	left join (select OrderNumber, max(scantime) as scantime from import_data.PurchaseRev group by OrderNumber) pr 
		on po.OrderNumber = pr.OrderNumber
	where date_add(ordertime, 5)  >= date_add('${EndDay}',interval -7 day) and date_add(ordertime, 5) < '${EndDay}' 
		and WarehouseName = '��ݸ��' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '�ܱ�' 
) tmp

/* �������� ���ڲɹ�����ļ�¼����
instockquantity = 0 and IsComplete = '��'���ɹ���;
instockquantity = 0 and IsComplete = '��'���ֹ���ᣬʵ��û�е���
instockquantity > 0 and IsComplete = '��'������sku�ѵ����������ܱ�11��7�յ�OrderNumber =2877728
instockquantity > 0 and IsComplete = '��'���ѵ���
*/
	