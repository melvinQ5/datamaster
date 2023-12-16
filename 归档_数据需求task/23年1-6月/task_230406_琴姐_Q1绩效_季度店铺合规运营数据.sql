
-- ord 

select
	'ODR' `ָ��`
	,round(OrderWithDefects_ord_cnt/monitor_ord_cnt,6)  as `������` -- ��Ч׷����
	,OrderWithDefects_ord_cnt `��������������`
	,monitor_ord_cnt `ƽ̨��ض�����`
from (
select
	sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
	,sum(case when ItemType=1 then eaaspcd.OrderCount end) as monitor_ord_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OrderDefectRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����'  and ms.Department = '��ٻ�'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 1 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 90 -- ͳ����
) tmp2

union 
-- �ٷ���
select 'LSR'
	,round(LateShipment_ord_cnt/monitor_ord_cnt,6)  as LateShipmentRate 
	,LateShipment_ord_cnt
	,monitor_ord_cnt 
from (
select
	sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- �ٷ�������
	,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,LateShipmentRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 30 -- ͳ����
) tmp2

union 
-- ȡ����
select 'CR' 
	,round(OrderCancel_ord_cnt/monitor_ord_cnt,6)  as OrderCancelRate 
	,OrderCancel_ord_cnt
	,monitor_ord_cnt
from (
select
	sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- ȡ��������
	,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- ͳ�ƶ�����
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OrderCancellationRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 30 -- ͳ����
) tmp2

UNION 
-- ��Ч׷����
-- ��MetricsType = 3��׷��ָ�����ݣ���ʱ��OrderCountΪnull�����ʹ�� ����/����=��ĸ
select 'VTR'
	,round(ValidTracking_ord_cnt/monitor_ord_cnt,3)  as ValidTrackingRate -- ��Ч׷����
	,ValidTracking_ord_cnt
	,monitor_ord_cnt
from (
select
	sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- ��Ч׷�ٶ�����
	,round(sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end),0) as monitor_ord_cnt -- ͳ�ƶ�����
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,ValidTrackingRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 30 -- ͳ����
) tmp2

UNION 
select 'AHR'
	,round(avg( case when AccountHealth is not null then AccountHealth end),2)    
	,''
	,''
from import_data.ShopPerformance sp 
join import_data.mysql_store ms on sp.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
where Monday = '2023-03-27'
