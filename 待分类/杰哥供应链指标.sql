
-- 2��������(%)
select '���в���' department,round(lt2day / total * 100, 2) gen_package_2day_rate 
from
	(
		select count(*) lt2day from
			(
			select distinct(od.OrderNumber), od.PayTime, pd.CreatedTime 
			from import_data.OrderDetails od
			join import_data.PackageDetail pd on pd.OrderNumber = od.OrderNumber
			where date_add(PayTime, 2) >= 'StartDay' and date_add(PayTime, 2) < 'EndDay'
				and pd.WarehouseName = '��ݸ��' and od.OrderStatus <> '����'
				and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			) a
		group by 
	)a,
	(
		select count(*) total from
		(
		select distinct(od.OrderNumber) from import_data.OrderDetails od
		where date_add(PayTime, 2) >= 'StartDay' and date_add(PayTime, 2) < 'EndDay'
		and od.OrderStatus <> '����' and od.ShipWarehouse = '��ݸ��'
		) a
	)b


-- 24Сʱ������

select '���в���' department,round(lt1day / total * 100, 2) delivery_24hour_rate from
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

-- ����5�췢����������Ҫ�÷���ʱ��
select '���в���' department, count(*) delivery_5day from
(
select distinct(od.OrderNumber) from import_data.OrderDetails od
join import_data.PackageDetail pd on pd.OrderNumber = od.OrderNumber
where date_add(PayTime, 7) >= 'StartDay' and date_add(PayTime, 7) < 'EndDay'
and pd.WarehouseName = '��ݸ��'
and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
and timestampdiff(second, paytime, pd.WeightTIme) > 0
) a

-- ƽ����������������

select '���в���' department, sum(deliveryday) delivery_day_total from
(
select distinct(pd.OrderNumber), timestampdiff(second, op.PayTime, pd.WeightTIme) / 86400 as deliveryday from import_data.PackageDetail pd
join import_data.OrderDetails op on op.OrderNumber = pd.OrderNumber
where weighttIme >= 'StartDay' and weightTIme < 'EndDay'
and pd.WarehouseName = '��ݸ��'
and weighttime > '2015-01-01'
) a

-- ����������
-- �޸ģ� ������ϸ��Ordernumberȥ��
-- ƽ��������������ĸ

select '���в���' department,count(*) delivery_order_count from
(
select distinct(pd.ordernumber) from import_data.PackageDetail pd
where weighttime >= 'StartDay' and weighttime < 'EndDay' and warehousename = '��ݸ��'
) a

-- ���������ɹ����
-- �޸ģ����������ϸ��ά�� �������� ������������ϸ��ȡ�ɹ����

select '���в���' department, sum(pc) delivery_purchase_amount from
(
select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc from import_data.PackageDetail pd
join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber
where pd.weighttime >= 'StartDay' and pd.weighttime < 'EndDay'
)a



