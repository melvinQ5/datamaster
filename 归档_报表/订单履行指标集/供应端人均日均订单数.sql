-- 统计期内发货订单数÷（计划1+采购11+物流2+仓储34+客服7人数）÷统计天数  12-19统计人数55

select CEILING(count(distinct dpd.PlatOrderNumber)/55/7)  `供应端人均日均订单数`
from import_data.daily_PackageDetail dpd
join import_data.wt_orderdetails dod 
	on dpd.PlatOrderNumber  = dod.PlatOrderNumber  
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join import_data.mysql_store ms on dod.ShopCode =ms.Code and ms.ShopStatus = '正常'  and dod.IsDeleted = 0 

