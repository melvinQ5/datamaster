
select po.OrderNumber, po.PurchaseOrderNo, po.GenerateTime, po.BoxSku , ifnull(pr.ScanTime, CompleteTime)
from daily_PurchaseRev pr 
join wt_ag_purchaseorder po on po.OrderNumber = pr.OrderNumber -- 昨日更新采购单中能匹配到收获表的采购单



select po.OrderNumber, po.PurchaseOrderNo, po.GenerateTime, po.BoxSku ,pr.ScanTime , ifnull(pr.ScanTime, CompleteTime)
from wt_ag_purchaseorder po 
left join daily_PurchaseRev pr on po.OrderNumber = pr.OrderNumber 
-- 昨日DorisImportTime更新的所有采购单，去匹配到收货表全表。如果匹配不到收货记录，则用采购单表的CompleteTime
