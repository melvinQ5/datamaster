-- ������ϸ�� ���ز��˷�Ϊ�ö��������˷ѣ����Ƿ�̯��sku�˷�
select *
from import_data.OrderDetails od2 
where OrderNumber in (
select OrderNumber
from import_data.OrderDetails od 
group by OrderNumber having count(distinct BoxSku)>1)