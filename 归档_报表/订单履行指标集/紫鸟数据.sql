select `����ȱ����` ,`׼ʱ��Ͷ��` ,`��Ч׷����` ,`���淴��������` ,`�������ⶩ����` ,`�ܸ����ⶩ����`
from (
select sum(ifnull(orderdefects,0)) / sum(ifnull(ordertotal,0)) `����ȱ����`
from import_data.ShopPerformance sp 
) t1,
( select avg(if(res1>100,res1/100/100,res1/100)) `׼ʱ��Ͷ��`
from (
	select cast(REPLACE(REPLACE(DeliveryRate,' ',''),'%','') as float) as res1
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '�ܱ�' and DeliveryRate <> '������' and DeliveryRate is not null and length(DeliveryRate) <> 0
	) tmp
) t2,
( select avg(if(res1>100,res1/100/100,res1/100)) `��Ч׷����`
from (
	select cast(REPLACE(REPLACE(TrackingRate,' ',''),'%','') as float) as res1
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '�ܱ�' and TrackingRate <> '������' and TrackingRate is not null and length(TrackingRate) <> 0
	) tmp
) t3,
( select round(sum(if(res1>100,res1/100/100*OrderTotal,res1/100*OrderTotal)),0) `���淴��������`
from (
	select cast(REPLACE(REPLACE(NegativeFeedback,' ',''),'%','') as float) as res1 ,OrderTotal
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '�ܱ�' and NegativeFeedback <> '������' and NegativeFeedback is not null and length(NegativeFeedback) <> 0
	) tmp
) t4,
( select round(sum(if(res1>100,res1/100/100*OrderTotal,res1/100*OrderTotal)),0) `�������ⶩ����`
from (
	select cast(REPLACE(REPLACE(AssuranceClaims,' ',''),'%','') as float) as res1 ,OrderTotal
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '�ܱ�' and AssuranceClaims <> '������' and AssuranceClaims is not null and length(AssuranceClaims) <> 0
	) tmp
) t5,
( select round(sum(if(res1>100,res1/100/100*OrderTotal,res1/100*OrderTotal)),0) `�ܸ����ⶩ����`
from (
	select cast(REPLACE(REPLACE(CreditCardClaim,' ',''),'%','') as float) as res1 ,OrderTotal
	from import_data.ShopPerformance sp2 
	join import_data.mysql_store ms on sp2.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
		and ReportType = '�ܱ�' and CreditCardClaim <> '������' and CreditCardClaim is not null and length(CreditCardClaim) <> 0
	) tmp
) t6
