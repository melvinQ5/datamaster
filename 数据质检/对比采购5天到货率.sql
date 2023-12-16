-- 对比指标
with 
ta as ( -- 日更采购表 未剔除作废、未付款
select
	dpo.OrderNumber
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then dpo.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then dpo.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else dpo.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.daily_PurchaseOrder dpo 
left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day) and WarehouseName = '东莞仓'
)

,tb as ( -- 采购宽表
select 
	OrderNumber
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.wt_purchaseorder wp 
where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day)  -- 多获取10天数据，以便计算各种指标
	and WarehouseName = '东莞仓' 
)

,daily_new as ( -- 日更采购表 剔除作废、未付款 
select
	dpo.OrderNumber
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then dpo.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then dpo.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else dpo.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.daily_PurchaseOrder dpo 
left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day) and WarehouseName = '东莞仓'
	and paystatus not in ('未付款', '未申请付款')
	and dpo.OrderNumber not in (
		select ordernumber from erp_purchase_purchase_chase_invalid_order
		where OrderNumber <> '' and OrderNumber is not null and PurchaseStatus = 0
		)
)

select round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
	,count(distinct in5days_rev_numb) `5天到货数`
	,count(distinct actual_ord_numb) `统计数`
from ta 
union 
select round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
	,count(distinct in5days_rev_numb) `5天到货数`
	,count(distinct actual_ord_numb) `统计数`
from daily_new
union 
select 
	round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
	,count(distinct in5days_rev_numb) `5天到货数`
	,count(distinct actual_ord_numb) `统计数`
from tb 

