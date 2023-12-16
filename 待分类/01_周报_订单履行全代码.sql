-- ʹ�÷���
-- FristDay ��ֵΪ����һ2022-12-26����ͳ�Ƶ�������19��-25��
-- ͨ�� department in ('dep1','dep2','dep3','dep4') ������ ���в��š�����GM������PM
-- PM ���滻 dep2 Ϊ���۶�����dep3Ϊ�������������������滻��0�������ַ����ɣ���Ϊ�õ� in )

with t1 as (

select 1-A_cnt/B_cnt `2�������ճٷ���` 
from 
(select count(distinct dod.PlatOrderNumber) as A_cnt  
from 
	(select 
		case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
		end as latest_WeightTime ,paytime ,DAYOFWEEK(OrderCountry_paytime)
		,PlatOrderNumber
	from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
		,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime
		from import_data.daily_OrderDetails  od
		join ( -- ֻ������״̬�Ƕ���Ķ�������
			select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
			and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
			) tmp on tmp.shopcode = od.ShopIrobotId
		left join
			(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area	
			FROM import_data.JinqinSku where monday='2023-12-20' ) js on js.code=right(od.ShopIrobotId ,2) 
		where PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
			and TransactionType ='����' and totalgross > 1  
		) tmp
	)dod
left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber  
where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
) A
,(SELECT count(distinct PlatOrderNumber) B_cnt
from import_data.daily_OrderDetails dod 
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = dod.ShopIrobotId
where 
	PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
	and TransactionType ='����' and totalgross > 1
) B  -- ����ʱ����������������ǰ��7�죬 ��������ʱ��

)

, AverageResponseTimeInHours as (

select * 
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- ״̬�쳣���̱���
from (
select
	count( distinct case when ContactResponseTimeStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt 
	,count( distinct case when ContactResponseTimeStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- �������
	,count( distinct case when ContactResponseTimeStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when ContactResponseTimeStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,round(avg(case when AverageResponseTimeInHours>0 then eaaspcd.AverageResponseTimeInHours end),1) as AverageResponseTimeInHours -- �����ۼ�
	,count( distinct case when ResponseTimeGreaterThan24Hours>0 then tmp.ShopCode  end) as ResponseUnder24HoursRate_shop_cnt
	,count( distinct case when NoResponseForContactsOlderThan24Hours>0 then tmp.ShopCode  end) as NoResponseForContactsOlderThan24Hours_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,ContactResponseTimeStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 4 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2
)

, LateShipmentRate  as (
select * 
	,round(LateShipment_ord_cnt/monitor_ord_cnt,3)  as LateShipmentRate 
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- ״̬�쳣���̱���
from (
select
	count( distinct case when LateShipmentRateStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt 
	,count( distinct case when LateShipmentRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt 
	,count( distinct case when LateShipmentRateStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when LateShipmentRateStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- �ٷ�������
	,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=5 and eaaspcd.Count>0 then tmp.ShopCode  end) as LateShipment_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,LateShipmentRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2
)

, OnTimeDeliveryRate as (
select *
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,2)  as OnTimeDeliveryRate -- ׼ʱ������
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- ״̬�쳣���̱���
from (
select
	count( distinct case when OnTimeDeliveryStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt -- ����+Σ�գ��������ƶ���
	,count( distinct case when OnTimeDeliveryStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- �������
	,count( distinct case when OnTimeDeliveryStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when OnTimeDeliveryStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
	,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=9 and eaaspcd.Count>0 then tmp.ShopCode  end) as OnTimeDelivery_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OnTimeDeliveryStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2
)

, OrderCancellationRate as (
select * 
	,round(OrderCancel_ord_cnt/monitor_ord_cnt,3)  as OrderCancelRate 
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- ״̬�쳣���̱���
from (
select
	count( distinct case when OrderCancellationRateStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt 
	,count( distinct case when OrderCancellationRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- �������
	,count( distinct case when OrderCancellationRateStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when OrderCancellationRateStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- ȡ��������
	,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=6 and eaaspcd.Count>0 then tmp.ShopCode  end) as OrderCancel_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OrderCancellationRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2
)

, ValidTrackingRate as (
select * 
	,round(ValidTracking_ord_cnt/monitor_ord_cnt,3)  as ValidTrackingRate -- ��Ч׷����
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as ValidTracking_Shop_Rate -- ��Ч׷�ٵ��̱���
from (
select
	count( distinct case when ValidTrackingRateStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt -- �������
	,count( distinct case when ValidTrackingRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- �������
	,count( distinct case when ValidTrackingRateStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when ValidTrackingRateStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- ��Ч׷�ٶ�����
	,sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count(distinct case when ItemType=8 and eaaspcd.Count>0 then tmp.ShopCode  end) as ValidTracking_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,ValidTrackingRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2
)

, t2 as (
select round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  (select 
	count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
	, count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from 
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
		from import_data.OrderDetails a
		join (
			select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
			) tmp on tmp.shopcode = a.ShopIrobotId
		join import_data.mysql_store s on s.code = a.ShopIrobotId
		where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			and PayTime < '${FristDay}' and date_add(PayTime,10) >= date_add('${FristDay}',interval -7 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  
) tmp1
)

, t3 as (
SELECT  
	round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `���϶�����`
from import_data.daily_OrderDetails dod 
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = dod.ShopIrobotId
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) 
	and PayTime < '${FristDay}'
)

, t4 as ( -- ��Ϊ�����վ� ����
select CEILING(count(distinct dpd.PlatOrderNumber)/55)  `��Ӧ���˾��վ�������`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.PlatOrderNumber  = dod.PlatOrderNumber  
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp 
	on tmp.shopcode = dod.ShopIrobotId
)

, t5 as(
select ceiling(count(distinct dpd.PlatOrderNumber)/7)  `�վ�����������`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp 
	on tmp.shopcode = dod.ShopIrobotId
)

, t6 as (
select round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
	and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${FristDay}' 
		and dpd.CreatedTime >= date_add('${FristDay}',interval -7 day) 
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp 
	on tmp.shopcode = dod.ShopIrobotId
)

, t7 as (
select round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48Сʱ�ջ���`
from import_data.PurchaseRev a 
join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
where date_add(scantime, 2) < '${FristDay}' and date_add(scantime, 2) >= date_add('${FristDay}',interval -7 day) 
and Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
and ReportType = '�ܱ�' and b.WarehouseName = '��ݸ��'
)

, t8 as (
select sum(diff_days)/count(DISTINCT PlatOrderNumber) `ƽ�����������`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, paytime, pd.WeightTime)/86400 AS diff_days 
		from 
			( 
			select PlatOrderNumber , PayTime
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where WeightTime < '${FristDay}' and WeightTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

, t9 as (
select 
	sum(diff_days)/count(DISTINCT PlatOrderNumber) `ƽ��������Ͷ����`
-- 	,avg(deli_days) `ƽ��������Ͷ����`
from (
	select distinct eaalt.PlatOrderNumber, timestampdiff(second, PayTime ,eaalt.DeliverTime  )/86400 as diff_days 
		from 
			( 
			select PlatOrderNumber ,PayTime
			from import_data.daily_OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
			) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			) od_pre 
		join import_data.erp_amazon_amazon_logistics_tracking eaalt on od_pre.PlatOrderNumber = eaalt.PlatOrderNumber 
		where DeliverTime < '${FristDay}' and DeliverTime >= date_add('${FristDay}',interval -7 day) 
	) tmp
)

,t10 as (
select sum(gen_days)/count(DISTINCT PlatOrderNumber) `ƽ��������������`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days 
		from 
			( 
			select PlatOrderNumber , PayTime
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where CreatedTime < '${FristDay}' and CreatedTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

,t11 as (
select sum(deli_days)/count(DISTINCT PlatOrderNumber) `ƽ��������������`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, WeightTime ,eaalt.OnlineTime )/86400 AS deli_days 
		,WeightTime ,eaalt.SendTime 
		from 
			( 
			select PlatOrderNumber
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		join import_data.erp_amazon_amazon_logistics_tracking eaalt on pd.PlatOrderNumber = eaalt.PlatOrderNumber 
		where OnlineTime < '${FristDay}' and OnlineTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

, t12 as (
select 
	sum(deli_days)/count(DISTINCT PlatOrderNumber) `ƽ��������Ͷ����`
-- 	,avg(deli_days) `ƽ��������Ͷ����`
from (
	select distinct eaalt.PlatOrderNumber, timestampdiff(second, eaalt.SendTime ,eaalt.DeliverTime  )/86400 as deli_days 
		from import_data.daily_PackageDetail dpd 
		join ( 
			select PlatOrderNumber
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
			) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			) od_pre on dpd.PlatOrderNumber = od_pre.PlatOrderNumber
		join import_data.erp_amazon_amazon_logistics_tracking eaalt on od_pre.PlatOrderNumber = eaalt.PlatOrderNumber 
		where eaalt.DeliverTime  < '${FristDay}' and eaalt.DeliverTime  >= date_add('${FristDay}',interval -7 day) 
	) tmp
)

, t13 as (
select sum(deli_days)/count(DISTINCT PlatOrderNumber) `ƽ��������������`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, CreatedTime, WeightTime)/86400 AS deli_days 
		from 
			( 
			select PlatOrderNumber
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '����'and OrderStatus <> '����' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where weightTime < '${FristDay}' and weightTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

, t14 as (
select  sum(rev_days)/count(DISTINCT OrderNumber) `ƽ���ɹ��ջ�����`
from (
select OrderNumber ,rev_days
from ( -- ��ǰ��5���Ա���� 5��ɹ�������
select 
	po.OrderNumber
	, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	then timestampdiff(second, ordertime, CompleteTime)/86400  -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as rev_days -- ����5�쵽�����µ���
from import_data.daily_PurchaseOrder po left join import_data.daily_PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where CompleteTime >= date_add('${FristDay}',interval -7 day) and CompleteTime < '${FristDay}' 
	and WarehouseName = '��ݸ��' 
)po_pre
group by OrderNumber ,rev_days
) tmp
)

, t15 as ( -- ����������
select count( distinct ShopCode) MonitorShopCount
from import_data.erp_amazon_amazon_shop_performance_check_sync  eaaspc 
join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
where AmazonShopHealthStatus != 4 
and CreationTime <'${FristDay}' and CreationTime >= DATE_ADD('${FristDay}', interval -7 day)
)

, t16 as ( 
select 
	count(DISTINCT PlatOrderNumber) `AZ�˿����`
--	, sum(ro.RefundUSDPrice) `AZ�˿���`
FROM import_data.daily_RefundOrders ro
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp 
	on tmp.shopcode = ro.OrderSource
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 = 'AZ�˿�'
)

,t17 as (
select a/b `�ǿͻ�ԭ���˿���` from 
(select sum(ro.RefundUSDPrice) a FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = s.code
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 not in ('�ͻ�����ԭ��', '������ȡ������') 
-- 	and IsShipment ='��'  -- �����Ƿ񷢻�
) A
,(SELECT sum(TotalGross/ExchangeUSD ) b
from import_data.daily_OrderDetails dod  
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = dod.ShopIrobotId 
where PayTime >= DATE_ADD('${FristDay}', interval -7 day) and PayTime < '${FristDay}' 
	and TransactionType ='����' and OrderStatus <> '����' and OrderTotalPrice>0
) B 
)

,t18 as (
select  
	sum(case when RefundReason1 ='�ִ���ԭ��' then RefundUSDPrice/ord_gross end) `�ִ�ԭ���˿���`
	,sum(case when RefundReason1 ='����ԭ��' then RefundUSDPrice/ord_gross end) `����ԭ���˿���`
	,sum(case when RefundReason1 ='��������' then RefundUSDPrice/ord_gross end) `���������˿���`
-- 	,sum(case when RefundReason1 ='��Ʒԭ��' then RefundUSDPrice/ord_gross end)`��Ʒԭ���˿���`
	,sum(case when RefundReason1 ='ȱ��' then RefundUSDPrice/ord_gross end) `ȱ��ԭ���˿���`
	,sum(case when RefundReason1 ='�ۺ�' then RefundUSDPrice/ord_gross end) `�ۺ�ԭ���˿���`
-- 	,sum(case when RefundReason1 ='�ͻ�ԭ��' then RefundUSDPrice/ord_gross end) `�������ɿͻ�ԭ���˿���`
from 
(select ro.RefundReason1 ,ro.RefundUSDPrice
FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = s.code
where RefundDate >= DATE_ADD('${FristDay}', interval -30 day) 
	and RefundDate < '${FristDay}' 
	and RefundReason2  not in ('�ͻ�����ԭ��', '������ȡ������') 
-- 	and IsShipment ='��'  -- �����Ƿ񷢻�
) A
,(SELECT sum(TotalGross/ExchangeUSD ) ord_gross
from import_data.daily_OrderDetails dod  
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = dod.ShopIrobotId 
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) and PayTime < '${FristDay}' 
	and TransactionType ='����' and OrderStatus <> '����' and OrderTotalPrice>0
) B 
)

,t19 as (
SELECT 
	count(case when timestampdiff(second, CollectionTme , ReplyTime) <= 86400 then 1 end) /count(1) `24Сʱ�ظ���`
	,count(case when timestampdiff(second, CollectionTme , ReplyTime) > 86400 then 1 end) `��24Сʱ�ظ��ʼ���`
from import_data.daily_Email de 
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = de.Src 
where CollectionTme  >= DATE_ADD('${FristDay}', interval -7 day) and CollectionTme < '${FristDay}' 
)

,t20 as (
select round(count(1)/7,0) `�վ��ʼ���`
from import_data.daily_Email de 
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = de.Src 
where  CollectionTme  < '${FristDay}' and CollectionTme >= date_add('${FristDay}',interval -7 day) 
)

,t21 as (
select count(distinct PlatOrderNumber) `ѯ�������ʼ��Ķ�����`
from import_data.daily_Email de 
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = de.Src 
where  ReplyTime < '${FristDay}' and ReplyTime >= date_add('${FristDay}',interval -7 day) 
and MailCategory like '%����%' or MailCat
egory like '%����%' or MailCategory like '%Shipping%'
)

,t22 as (
select  round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from ( -- ��ǰ��5���Ա���� 5��ɹ�������
select 
	po.OrderNumber,po.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then po.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then po.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else po.OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.PurchaseOrder po left join import_data.PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where date_add(ordertime, 5)  >= date_add('${FristDay}',interval -7 day) and date_add(ordertime, 5) < '${FristDay}' 
	and WarehouseName = '��ݸ��' and Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) and ReportType = '�ܱ�' 
)po_pre
)

select * from t1 ,LateShipmentRate ,OnTimeDeliveryRate, OrderCancellationRate ,ValidTrackingRate,t2
t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22
