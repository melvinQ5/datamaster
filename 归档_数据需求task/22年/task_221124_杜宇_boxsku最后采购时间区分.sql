
select BoxSku 
	, case when max_ordertime < '2022-08-24' then '0824��ǰ' 
	when max_ordertime >= '2022-08-24' then '0824���Ժ�' end as `����`
	, max_ordertime `���ɹ��µ�ʱ��`
from 
(
select js.BoxSku, max(OrderTime) as max_ordertime 
from import_data.JinqinSku js 
join import_data.daily_PurchaseOrder dpo on js.BoxSku = dpo.BoxSku and js.Monday = '2022-11-25'
group by js.BoxSku
) tmp 