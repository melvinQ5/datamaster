
-- ��4���ŵ��˺���2022����Ҳ�г�����������Ҫ֪����Щ������˺ţ���Щ��û�з������

select shopcode , sum(totalgross),count(1)
from 
(
	select wo.*
	from import_data.wt_orderdetails wo 
	join (
		select Sku as Code from JinqinSku js where js.BoxSku ='����ע' and js.Monday ='2023-02-07'
		)  ms 
	on wo.shopcode = ms.Code and wo.SettlementTime >= '2023-01-01'
) tmp 
GROUP by shopcode 


select Sku as Code from JinqinSku js where js.BoxSku ='����ע' and js.Monday ='2023-02-08'

select Sku as Code 	
BoxSku 
from JinqinSku js 
group by BoxSku 