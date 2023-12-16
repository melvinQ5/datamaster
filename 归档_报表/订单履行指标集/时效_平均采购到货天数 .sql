	
select  sum(rev_days)/count(DISTINCT OrderNumber) `平均采购收货天数`
from (
select OrderNumber ,rev_days
from ( -- 往前推5天以便计算 5天采购到货率
select 
	po.OrderNumber
	, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	then timestampdiff(second, ordertime, CompleteTime)/86400  -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as rev_days -- 满足5天到货的下单号
from import_data.daily_PurchaseOrder po left join import_data.daily_PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where CompleteTime  >= date_add('${FristDay}',interval -7 day) and CompleteTime < '${FristDay}' 
	and WarehouseName = '东莞仓' 
)po_pre
group by OrderNumber ,rev_days
) tmp