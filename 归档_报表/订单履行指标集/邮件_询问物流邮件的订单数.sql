select count(distinct PlatOrderNumber) `询问物流邮件的订单数`
from import_data.daily_Email de 
join import_data.mysql_store ms on de.Src =ms.Code and ms.ShopStatus = '正常'  
where  ReplyTime < '${FristDay}' and ReplyTime >= date_add('${FristDay}',interval -7 day) 
and MailCategory like '%交期%' or MailCategory like '%丢包%' or MailCategory like '%Shipping%'