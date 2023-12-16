SELECT 
	count(case when timestampdiff(second, CollectionTme , ReplyTime) <= 86400 then 1 end) /count(1) `24Сʱ�ظ���`
	,count(case when timestampdiff(second, CollectionTme , ReplyTime) > 86400 then 1 end) `��24Сʱ�ظ��ʼ���`
from import_data.daily_Email de 
join import_data.mysql_store ms on de.Src =ms.Code and ms.ShopStatus = '����'  
where CollectionTme  >= DATE_ADD('${FristDay}', interval -7 day) and CollectionTme < '${FristDay}' 