

-- ��������  daily_InStockCheck
select left(CompleteTime,7) `����ʱ��`,count(distinct CompleteNumber) `ȥ����������` ,count(1) `�м�¼��`
from import_data.daily_InStockCheck disc 
group by left(CompleteTime,7)
order by left(CompleteTime,7) 


-- �ɹ�����
SELECT left(CompleteTime,7),count(1)
from import_data.daily_PurchaseOrder dpo 
group by left(CompleteTime,7)
order by left(CompleteTime,7)
