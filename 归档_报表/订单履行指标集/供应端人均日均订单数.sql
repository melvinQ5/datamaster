-- ͳ�����ڷ����������£��ƻ�1+�ɹ�11+����2+�ִ�34+�ͷ�7��������ͳ������  12-19ͳ������55

select CEILING(count(distinct dpd.PlatOrderNumber)/55/7)  `��Ӧ���˾��վ�������`
from import_data.daily_PackageDetail dpd
join import_data.wt_orderdetails dod 
	on dpd.PlatOrderNumber  = dod.PlatOrderNumber  
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join import_data.mysql_store ms on dod.ShopCode =ms.Code and ms.ShopStatus = '����'  and dod.IsDeleted = 0 

