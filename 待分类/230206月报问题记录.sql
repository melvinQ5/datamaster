
-- 非4部门的账号在2022年内也有出单，现在需要知道哪些是领科账号，哪些是没有分配完成

select shopcode , sum(totalgross),count(1)
from 
(
	select wo.*
	from import_data.wt_orderdetails wo 
	join (
		select Sku as Code from JinqinSku js where js.BoxSku ='待标注' and js.Monday ='2023-02-07'
		)  ms 
	on wo.shopcode = ms.Code and wo.SettlementTime >= '2023-01-01'
) tmp 
GROUP by shopcode 


select Sku as Code from JinqinSku js where js.BoxSku ='待标注' and js.Monday ='2023-02-08'

select Sku as Code 	
BoxSku 
from JinqinSku js 
group by BoxSku 