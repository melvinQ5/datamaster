 -- 所有采购过且的sku的 平均采购到货时间 和 最近一次下单时间
 
with tmp1 as (
select   boxsku , sum(rev_days)/count(DISTINCT OrderNumber) `平均采购收货天数`
from (
	select boxsku , OrderNumber ,rev_days
	from ( -- 往前推5天以便计算 5天采购到货率
		select 
			po.OrderNumber
			, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
			when scantime is null and instockquantity > 0 and CompleteTime is not null 
			then timestampdiff(second, ordertime, CompleteTime)/86400  -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
			end as rev_days 
			, po.boxsku
		from import_data.daily_PurchaseOrder po 
		left join import_data.daily_PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
		where 
			CompleteTime > '2000-01-01' and CompleteTime < '${FristDay}' 
			and WarehouseName = '东莞仓' 
		) po_pre
	group by boxsku , OrderNumber ,rev_days
	) tmp
group by boxsku
) 

, tmp2 as (
select boxsku ,max(OrderTime) as max_ordertime ,count(distinct OrderNumber) as order_times
from import_data.daily_PurchaseOrder
group by BoxSku 
)

-- select count(1) from (
select tmp1.* , tmp2.max_ordertime `最近一次采购时间`,tmp2.order_times `采购单数`
from tmp1 left join tmp2 
on tmp1.boxsku = tmp2.boxsku

-- ) t 