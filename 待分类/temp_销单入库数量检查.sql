

-- 销单入库表  daily_InStockCheck
select left(CompleteTime,7) `销单时间`,count(distinct CompleteNumber) `去重销单号数` ,count(1) `行记录数`
from import_data.daily_InStockCheck disc 
group by left(CompleteTime,7)
order by left(CompleteTime,7) 


-- 采购单表
SELECT left(CompleteTime,7),count(1)
from import_data.daily_PurchaseOrder dpo 
group by left(CompleteTime,7)
order by left(CompleteTime,7)
