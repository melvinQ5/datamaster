
select 
	round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from (
select 
	dpo.OrderNumber,dpo.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then dpo.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then dpo.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else dpo.OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
where ordertime >= date_add('${FristDay}',interval -7-5 day) and ordertime < date_add('${FristDay}',interval -5 day) and WarehouseName = '��ݸ��'
) tmp 
