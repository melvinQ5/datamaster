
select BoxSku 
	, case when max_ordertime < '2022-08-24' then '0824以前' 
	when max_ordertime >= '2022-08-24' then '0824及以后' end as `分类`
	, max_ordertime `最后采购下单时间`
from 
(
select js.BoxSku, max(OrderTime) as max_ordertime 
from import_data.JinqinSku js 
join import_data.daily_PurchaseOrder dpo on js.BoxSku = dpo.BoxSku and js.Monday = '2022-11-25'
group by js.BoxSku
) tmp 