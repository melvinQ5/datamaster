
select 
	round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from (
select 
	dpo.OrderNumber,dpo.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then dpo.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then dpo.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else dpo.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
where ordertime >= date_add('${FristDay}',interval -7-5 day) and ordertime < date_add('${FristDay}',interval -5 day) and WarehouseName = '东莞仓'
) tmp 
