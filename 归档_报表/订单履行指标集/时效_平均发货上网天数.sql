

select avg(deli_days) `平均发货上网天数`
from  
	(select DISTINCT pd.OrderNumber, timestampdiff(second, eaalt.WeightTime ,eaalt.OnlineTime )/86400 AS deli_days 
		,eaalt.WeightTime 
		from 
			( 
			select OrderNumber
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0 
			) od_pre 
		join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber 
		join import_data.erp_logistic_logistics_tracking  eaalt on od_pre.OrderNumber = eaalt.OrderNumber 
		where OnlineTime < '${FristDay}' and OnlineTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
