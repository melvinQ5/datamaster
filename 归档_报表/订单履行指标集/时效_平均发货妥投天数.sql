-- ������Ͷ�İ���ƽ����Ͷ����
select 
	sum(deli_days)/count(DISTINCT OrderNumber) `ƽ��������Ͷ����`
-- 	,avg(deli_days) `ƽ��������Ͷ����`
from (
	select distinct eaalt.OrderNumber, timestampdiff(second, eaalt.WeightTime ,eaalt.DeliverTime  )/86400 as deli_days 
		from import_data.daily_PackageDetail dpd 
		join ( 
			select OrderNumber
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
			) od_pre on dpd.OrderNumber = od_pre.OrderNumber
		join import_data.erp_logistic_logistics_tracking  eaalt on od_pre.OrderNumber = eaalt.OrderNumber 
		where eaalt.DeliverTime  < '${FristDay}' and eaalt.DeliverTime  >= date_add('${FristDay}',interval -7 day) 
	) tmp
