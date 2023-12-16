-- �Ա�ָ��
with 
ta as ( -- �ո��ɹ��� δ�޳����ϡ�δ����
select
	dpo.OrderNumber
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then dpo.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then dpo.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else dpo.OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.daily_PurchaseOrder dpo 
left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day) and WarehouseName = '��ݸ��'
)

,tb as ( -- �ɹ����
select 
	OrderNumber
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.wt_purchaseorder wp 
where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day)  -- ���ȡ10�����ݣ��Ա�������ָ��
	and WarehouseName = '��ݸ��' 
)

,daily_new as ( -- �ո��ɹ��� �޳����ϡ�δ���� 
select
	dpo.OrderNumber
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then dpo.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then dpo.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else dpo.OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.daily_PurchaseOrder dpo 
left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day) and WarehouseName = '��ݸ��'
	and paystatus not in ('δ����', 'δ���븶��')
	and dpo.OrderNumber not in (
		select ordernumber from erp_purchase_purchase_chase_invalid_order
		where OrderNumber <> '' and OrderNumber is not null and PurchaseStatus = 0
		)
)

select round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
	,count(distinct in5days_rev_numb) `5�쵽����`
	,count(distinct actual_ord_numb) `ͳ����`
from ta 
union 
select round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
	,count(distinct in5days_rev_numb) `5�쵽����`
	,count(distinct actual_ord_numb) `ͳ����`
from daily_new
union 
select 
	round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
	,count(distinct in5days_rev_numb) `5�쵽����`
	,count(distinct actual_ord_numb) `ͳ����`
from tb 

