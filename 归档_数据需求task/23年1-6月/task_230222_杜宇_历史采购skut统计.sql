 -- ���вɹ����ҵ�sku�� ƽ���ɹ�����ʱ�� �� ���һ���µ�ʱ��
 
with tmp1 as (
select   boxsku , sum(rev_days)/count(DISTINCT OrderNumber) `ƽ���ɹ��ջ�����`
from (
	select boxsku , OrderNumber ,rev_days
	from ( -- ��ǰ��5���Ա���� 5��ɹ�������
		select 
			po.OrderNumber
			, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
			when scantime is null and instockquantity > 0 and CompleteTime is not null 
			then timestampdiff(second, ordertime, CompleteTime)/86400  -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
			end as rev_days 
			, po.boxsku
		from import_data.daily_PurchaseOrder po 
		left join import_data.daily_PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
		where 
			CompleteTime > '2000-01-01' and CompleteTime < '${FristDay}' 
			and WarehouseName = '��ݸ��' 
		) po_pre
	group by boxsku , OrderNumber ,rev_days
	) tmp
group by boxsku
) 

, tmp2 as (
select boxsku ,max(OrderTime) as max_ordertime ,count(distinct OrderNumber) as order_times
from import_data.daily_PurchaseOrder
group by BoxSku 
)

-- select count(1) from (
select tmp1.* , tmp2.max_ordertime `���һ�βɹ�ʱ��`,tmp2.order_times `�ɹ�����`
from tmp1 left join tmp2 
on tmp1.boxsku = tmp2.boxsku

-- ) t 