
-- 账号分月
select ShopIrobotId ,left(PayTime,7) ,COUNT(distinct PlatOrderNumber)
from ods_orderdetails where TransactionType ='付款' and ShopIrobotId regexp 'FR|ES' and PayTime >='2022-01-01' and PayTime < '2023-10-01' and IsDeleted=0
group by ShopIrobotId , left(PayTime,7)
order by ShopIrobotId , left(PayTime,7)


-- 账号
select right(ShopIrobotId,2) 站点 , ShopIrobotId  店铺 ,COUNT(distinct PlatOrderNumber) 订单量
from ods_orderdetails where TransactionType ='付款' and ShopIrobotId regexp 'FR|ES' and PayTime >='2022-01-01' and PayTime < '2023-10-01' and IsDeleted=0
group by ShopIrobotId
order by 站点,ShopIrobotId