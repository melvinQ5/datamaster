
-- 2天生包率(%)
select '所有部门' department,round(lt2day / total * 100, 2) gen_package_2day_rate 
from
	(
		select count(*) lt2day from
			(
			select distinct(od.OrderNumber), od.PayTime, pd.CreatedTime 
			from import_data.OrderDetails od
			join import_data.PackageDetail pd on pd.OrderNumber = od.OrderNumber
			where date_add(PayTime, 2) >= 'StartDay' and date_add(PayTime, 2) < 'EndDay'
				and pd.WarehouseName = '东莞仓' and od.OrderStatus <> '作废'
				and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			) a
		group by 
	)a,
	(
		select count(*) total from
		(
		select distinct(od.OrderNumber) from import_data.OrderDetails od
		where date_add(PayTime, 2) >= 'StartDay' and date_add(PayTime, 2) < 'EndDay'
		and od.OrderStatus <> '作废' and od.ShipWarehouse = '东莞仓'
		) a
	)b


-- 24小时发货率

select '所有部门' department,round(lt1day / total * 100, 2) delivery_24hour_rate from
(
select count(*) lt1day from import_data.PackageDetail
where CreatedTime >= 'StartDay' and CreatedTime < 'EndDay'
and timestampdiff(second , CreatedTime, WeightTIme) <= 86400
and timestampdiff(second , CreatedTime, WeightTIme) > 0
)a,
(
select count(*) total from import_data.PackageDetail
where CreatedTime >= 'StartDay' and CreatedTime < 'EndDay'
)b

-- 订单5天发货数，这里要用发货时间
select '所有部门' department, count(*) delivery_5day from
(
select distinct(od.OrderNumber) from import_data.OrderDetails od
join import_data.PackageDetail pd on pd.OrderNumber = od.OrderNumber
where date_add(PayTime, 7) >= 'StartDay' and date_add(PayTime, 7) < 'EndDay'
and pd.WarehouseName = '东莞仓'
and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
and timestampdiff(second, paytime, pd.WeightTIme) > 0
) a

-- 平均发货天数，分子

select '所有部门' department, sum(deliveryday) delivery_day_total from
(
select distinct(pd.OrderNumber), timestampdiff(second, op.PayTime, pd.WeightTIme) / 86400 as deliveryday from import_data.PackageDetail pd
join import_data.OrderDetails op on op.OrderNumber = pd.OrderNumber
where weighttIme >= 'StartDay' and weightTIme < 'EndDay'
and pd.WarehouseName = '东莞仓'
and weighttime > '2015-01-01'
) a

-- 发货订单数
-- 修改， 包裹明细表，Ordernumber去重
-- 平均发货天数，分母

select '所有部门' department,count(*) delivery_order_count from
(
select distinct(pd.ordernumber) from import_data.PackageDetail pd
where weighttime >= 'StartDay' and weighttime < 'EndDay' and warehousename = '东莞仓'
) a

-- 发货订单采购金额
-- 修改，主表包裹明细表，维度 称重日期 ，关联订单明细表，取采购金额

select '所有部门' department, sum(pc) delivery_purchase_amount from
(
select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc from import_data.PackageDetail pd
join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
where pd.weighttime >= 'StartDay' and pd.weighttime < 'EndDay'
)a



