select
    c2 ԭ�ɹ����� ,c3 ԭ��Ʒsku ,c1 ԭ���״̬
    ,PurchaseOrderNo ,BoxSku
     ,case when Quantity - InstockQuantity > 0 then '��' else  IsComplete end  �����״̬
     ,Quantity,InstockQuantity ,InstockTime
from manual_table_duplicate m
join daily_PurchaseOrder dp on m.c1='��' and m.c2 =dp.PurchaseOrderNo and m.c3 =dp.BoxSku
