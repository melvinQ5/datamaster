
select 
	avg(gen_days) `平均付款生包天数`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days 
		from 
			( 
			select PlatOrderNumber , PayTime
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where CreatedTime < '${FristDay}' and CreatedTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1