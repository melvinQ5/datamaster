
with odr as ( -- ODR
select * 
	,round(OrderWithDefects_ord_cnt/monitor_ord_cnt,6)  as OrderDefectRate 
from (
	select department
		,sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
		,sum(case when ItemType=1 then eaaspcd.OrderCount end) as monitor_ord_cnt
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,OrderDefectRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 1 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 60 -- ͳ����
	group by department
	) tmp2
)


, lsr as ( -- LSR
select * 
	,round(LateShipment_ord_cnt/monitor_ord_cnt,3)  as LateShipmentRate 
from (
	select department
		,sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- �ٷ�������
		,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,LateShipmentRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 7 -- ͳ����
	group by department
	) tmp2
)

, cr as ( 
select * 
	,round(OrderCancel_ord_cnt/monitor_ord_cnt,3)  as OrderCancelRate 
from (
	select department
		,sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- ȡ��������
		,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,OrderCancellationRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 7 -- ͳ����
	group by department
	) tmp2
)

, vtr as (    
select * 
	,round(ValidTracking_ord_cnt/monitor_ord_cnt,3)  as ValidTrackingRate -- ��Ч׷����
from (
	select department
		,sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- ��Ч׷�ٶ�����
		,sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,ValidTrackingRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 7 -- ͳ����
	group by department
	) tmp2
)

-- �������� ������������
-- select 
-- 	department
-- 	,avg(case when ODR<>'������' then cast(replace(ODR,'%','') as float) end ) `����ODRƽ��ֵ` 
-- 	,avg(case when TrackingRate<>'������' then TrackingRate end ) `����VTRƽ��ֵ`
-- 	,avg(case when LaterDay10<>'������' then LaterDay10 end ) `����LSRƽ��ֵ`
-- 	,avg(case when RateBeforeShipping<>'������' then RateBeforeShipping end) `����CRƽ��ֵ`
-- 	,avg(case when AccountHealth<>'������' then  AccountHealth end )`����AHRƽ��ֵ`
-- from import_data.ShopPerformance sp 
-- join import_data.mysql_store ms on sp.ShopCode = ms.Code and department='��ٻ�'
-- 	and ReportType ='�ܱ�' and Monday ='2023-02-13'
-- group by department

select email.department 
	,OrderDefectRate `����ODRƽ��ֵ`
	,LateShipmentRate `����LSRƽ��ֵ`
	,OrderCancelRate `����CRƽ��ֵ`
	,ValidTrackingRate `����VTRƽ��ֵ`
from (select department from import_data.mysql_store ms  group by department) email 
left join odr on email.department = odr.department
left join lsr on email.department = lsr.department
left join cr on email.department = cr.department
left join vtr on email.department = vtr.department