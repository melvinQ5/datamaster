select
    c2 原采购单号 ,c3 原产品sku ,c1 原完结状态
    ,PurchaseOrderNo ,BoxSku
     ,case when Quantity - InstockQuantity > 0 then '否' else  IsComplete end  新完结状态
     ,Quantity,InstockQuantity ,InstockTime
from manual_table_duplicate m
join daily_PurchaseOrder dp on m.c1='否' and m.c2 =dp.PurchaseOrderNo and m.c3 =dp.BoxSku
