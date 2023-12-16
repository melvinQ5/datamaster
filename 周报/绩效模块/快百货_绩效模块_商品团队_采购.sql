--  ������N��
 
with 
t_new_purc as ( -- ���ڲɹ�
select 
	wp.BoxSku ,wp.OrderPerson ,OrderNumber ,ordertime ,WarehouseName ,Price ,SkuFreight ,DiscountedPrice ,Quantity
	,instockquantity ,CompleteTime ,IsComplete ,scantime
	,wpt.projectteam as department ,wpt.IsDeleted as wpt_isdeleted
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
		end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.wt_purchaseorder wp 
join ( select BoxSku ,projectteam ,IsDeleted from wt_products where projectteam = '��ٻ�') wpt on wp.BoxSku = wpt.BoxSku
where ordertime >= '${StartDay}' and ordertime < '${NextStartDay}'
	and WarehouseName = '��ݸ��'
	and OrderPerson in ('��Ҷ��','��С÷','�Է���','ũ�h��','������')
)

-- ͳ��
select 
	replace(concat(right(to_date('${StartDay}'),5),
		'��',right(to_date(date_add('${NextStartDay}' ,-1)),5)),'-','') `�µ�ʱ�䷶Χ`
	, CURRENT_DATE()  `ͳ������`
	, OrderPerson `�ɹ��µ���Ա`
	, count(distinct actual_ord_numb) `ͳ���µ���`
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from t_new_purc
group by OrderPerson



