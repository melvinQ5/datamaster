
select po.OrderNumber, po.PurchaseOrderNo, po.GenerateTime, po.BoxSku , ifnull(pr.ScanTime, CompleteTime)
from daily_PurchaseRev pr 
join wt_ag_purchaseorder po on po.OrderNumber = pr.OrderNumber -- ���ո��²ɹ�������ƥ�䵽�ջ��Ĳɹ���



select po.OrderNumber, po.PurchaseOrderNo, po.GenerateTime, po.BoxSku ,pr.ScanTime , ifnull(pr.ScanTime, CompleteTime)
from wt_ag_purchaseorder po 
left join daily_PurchaseRev pr on po.OrderNumber = pr.OrderNumber 
-- ����DorisImportTime���µ����вɹ�����ȥƥ�䵽�ջ���ȫ�����ƥ�䲻���ջ���¼�����òɹ������CompleteTime
