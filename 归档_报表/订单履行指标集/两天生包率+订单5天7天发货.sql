-- ɸѡƽ̨�����ٷ����˶�Ӧ���̵Ķ�������

select round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  
	(select 
	count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from 
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime ,ms.department
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����' and wo.IsDeleted = 0 
		where PayTime < '${FristDay}' and PayTime >= date_add('${FristDay}',interval -7-10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
) tmp1
