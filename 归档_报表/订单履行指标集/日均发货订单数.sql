-- �վ��������� 

select ceiling(count(distinct dpd.PlatOrderNumber)/7)  `�վ�����������`
from import_data.daily_PackageDetail dpd
join import_data.wt_orderdetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join import_data.mysql_store ms on dod.ShopCode =ms.Code and ms.ShopStatus = '����' and dod.IsDeleted = 0 


