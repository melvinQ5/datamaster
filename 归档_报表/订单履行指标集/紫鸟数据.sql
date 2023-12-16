select `订单缺陷率` ,`准时妥投率` ,`有效追踪率` ,`负面反馈订单数` ,`交易索赔订单数` ,`拒付索赔订单数`
from (
select sum(ifnull(orderdefects,0)) / sum(ifnull(ordertotal,0)) `订单缺陷率`
from import_data.ShopPerformance sp 
) t1,
( select avg(if(res1>100,res1/100/100,res1/100)) `准时妥投率`
from (
	select cast(REPLACE(REPLACE(DeliveryRate,' ',''),'%','') as float) as res1
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '周报' and DeliveryRate <> '不适用' and DeliveryRate is not null and length(DeliveryRate) <> 0
	) tmp
) t2,
( select avg(if(res1>100,res1/100/100,res1/100)) `有效追踪率`
from (
	select cast(REPLACE(REPLACE(TrackingRate,' ',''),'%','') as float) as res1
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '周报' and TrackingRate <> '不适用' and TrackingRate is not null and length(TrackingRate) <> 0
	) tmp
) t3,
( select round(sum(if(res1>100,res1/100/100*OrderTotal,res1/100*OrderTotal)),0) `负面反馈订单数`
from (
	select cast(REPLACE(REPLACE(NegativeFeedback,' ',''),'%','') as float) as res1 ,OrderTotal
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '周报' and NegativeFeedback <> '不适用' and NegativeFeedback is not null and length(NegativeFeedback) <> 0
	) tmp
) t4,
( select round(sum(if(res1>100,res1/100/100*OrderTotal,res1/100*OrderTotal)),0) `交易索赔订单数`
from (
	select cast(REPLACE(REPLACE(AssuranceClaims,' ',''),'%','') as float) as res1 ,OrderTotal
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '周报' and AssuranceClaims <> '不适用' and AssuranceClaims is not null and length(AssuranceClaims) <> 0
	) tmp
) t5,
( select round(sum(if(res1>100,res1/100/100*OrderTotal,res1/100*OrderTotal)),0) `拒付索赔订单数`
from (
	select cast(REPLACE(REPLACE(CreditCardClaim,' ',''),'%','') as float) as res1 ,OrderTotal
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '周报' and CreditCardClaim <> '不适用' and CreditCardClaim is not null and length(CreditCardClaim) <> 0
	) tmp
) t6
