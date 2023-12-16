-- ������Ͷ�İ���ƽ����Ͷ����
select 
	avg(diff_days) `ƽ��������Ͷ����`
from (
	select distinct eaalt.OrderNumber, timestampdiff(second, PayTime ,eaalt.DeliverTime  )/86400 as diff_days 
		from 
			( 
			select OrderNumber ,PayTime
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
			) od_pre 
		join import_data.erp_logistic_logistics_tracking  eaalt on od_pre.OrderNumber = eaalt.OrderNumber 
		where DeliverTime < '${FristDay}' and DeliverTime >= date_add('${FristDay}',interval -7 day) 
	) tmp

