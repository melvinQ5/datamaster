select round(count(1)/7,0) `日均邮件数`
from import_data.daily_Email de 
join import_data.mysql_store ms on de.Src =ms.Code and ms.ShopStatus = '正常'  
where  CollectionTme  < '${FristDay}' and CollectionTme >= date_add('${FristDay}',interval -7 day) 