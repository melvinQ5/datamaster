
-- �˺ŷ���
select ShopIrobotId ,left(PayTime,7) ,COUNT(distinct PlatOrderNumber)
from ods_orderdetails where TransactionType ='����' and ShopIrobotId regexp 'FR|ES' and PayTime >='2022-01-01' and PayTime < '2023-10-01' and IsDeleted=0
group by ShopIrobotId , left(PayTime,7)
order by ShopIrobotId , left(PayTime,7)


-- �˺�
select right(ShopIrobotId,2) վ�� , ShopIrobotId  ���� ,COUNT(distinct PlatOrderNumber) ������
from ods_orderdetails where TransactionType ='����' and ShopIrobotId regexp 'FR|ES' and PayTime >='2022-01-01' and PayTime < '2023-10-01' and IsDeleted=0
group by ShopIrobotId
order by վ��,ShopIrobotId