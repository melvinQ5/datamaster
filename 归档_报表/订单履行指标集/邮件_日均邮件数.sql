select round(count(1)/7,0) `�վ��ʼ���`
from import_data.daily_Email de 
join import_data.mysql_store ms on de.Src =ms.Code and ms.ShopStatus = '����'  
where  CollectionTme  < '${FristDay}' and CollectionTme >= date_add('${FristDay}',interval -7 day) 