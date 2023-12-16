
select round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a 
join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
where date_add(scantime, 2) < '${FristDay}' and date_add(scantime, 2) >= date_add('${FristDay}',interval -7 day) 
and Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
and ReportType = '周报' and b.WarehouseName = '东莞仓'

