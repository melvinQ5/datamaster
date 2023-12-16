
select round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
	and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from import_data.daily_PackageDetail dpd
join import_data.wt_orderdetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${FristDay}' 
		and dpd.CreatedTime >= date_add('${FristDay}',interval -7 day) 
join import_data.mysql_store ms on dod.ShopCode =ms.Code and ms.ShopStatus = '正常' and dod.IsDeleted = 0 
