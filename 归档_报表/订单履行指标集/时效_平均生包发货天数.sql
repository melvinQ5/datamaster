

select sum(deli_days)/count(DISTINCT PlatOrderNumber) `平均生包发货天数`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, CreatedTime, WeightTime)/86400 AS deli_days 
		from 
			( 
			select PlatOrderNumber
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0 
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where weightTime < '${FristDay}' and weightTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1