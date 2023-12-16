SELECT 
	count(case when timestampdiff(second, CollectionTme , ReplyTime) <= 86400 then 1 end) /count(1) `24小时回复率`
	,count(case when timestampdiff(second, CollectionTme , ReplyTime) > 86400 then 1 end) `超24小时回复邮件数`
from import_data.daily_Email de 
join import_data.mysql_store ms on de.Src =ms.Code and ms.ShopStatus = '正常'  
where CollectionTme  >= DATE_ADD('${FristDay}', interval -7 day) and CollectionTme < '${FristDay}' 