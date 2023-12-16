with ms as
 ( select distinct  accountcode ,code,site  from wt_store where accountcode regexp 'SK-EU|NK-NA|NW-AU|RI-NA|RI-JP|NQ-EU|MP-JP|OX-EU|RM-NA|A04-NA|YA-NA' )

select  AccountCode ,code as shopcode ,site  ,count(distinct PlatOrderNumber) 220901至231212订单量
from ms
left join ods_orderdetails wo
on wo.ShopIrobotId =ms.Code and IsDeleted = 0  and paytime >= '2022-09-01' and paytime < '2023-12-13' and TransactionType='付款'
group by AccountCode, shopcode ,site
order by AccountCode ,shopcode ,site ,220901至231212订单量 desc