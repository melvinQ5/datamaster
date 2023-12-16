	
select  sum(rev_days)/count(DISTINCT OrderNumber) `ƽ���ɹ��ջ�����`
from (
select OrderNumber ,rev_days
from ( -- ��ǰ��5���Ա���� 5��ɹ�������
select 
	po.OrderNumber
	, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	then timestampdiff(second, ordertime, CompleteTime)/86400  -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as rev_days -- ����5�쵽�����µ���
from import_data.daily_PurchaseOrder po left join import_data.daily_PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where CompleteTime  >= date_add('${FristDay}',interval -7 day) and CompleteTime < '${FristDay}' 
	and WarehouseName = '��ݸ��' 
)po_pre
group by OrderNumber ,rev_days
) tmp