select count(distinct PlatOrderNumber) `ѯ�������ʼ��Ķ�����`
from import_data.daily_Email de 
join import_data.mysql_store ms on de.Src =ms.Code and ms.ShopStatus = '����'  
where  ReplyTime < '${FristDay}' and ReplyTime >= date_add('${FristDay}',interval -7 day) 
and MailCategory like '%����%' or MailCategory like '%����%' or MailCategory like '%Shipping%'