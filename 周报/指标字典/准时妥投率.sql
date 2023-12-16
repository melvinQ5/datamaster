
-- erp���̽�����
-- ����  erp_amazon_amazon_shop_performance_check, ����ȫ���� erp_amazon_amazon_shop_performance_check_sync
-- �����Ӧ������ϸ����������:V2=48,V1=47,V2��Ҫ��¼����AHR�÷�ָ�꣬V1��Ҫ��¼����ָ�꣬��ƽ̨APIԭ���޷���V1V2�ϲ���������ѯë����IT�������٣����󷽣�
-- ��ϸ��V1��erp_amazon_amazon_shop_performance_check_detail
-- ��ϸ��V1ȫ����erp_amazon_amazon_shop_performance_check_detail_sync

-- ׼ʱ������
-- OrderCountΪnull�����ʹ�� ����/����=��ĸ
-- ׼ʱ�����ʲ������� count=0 rate=0, �����ȫ�����,�൱��ֻ��¼�˲�׼ʱ���ⲿ�ֵĽ����ʣ�
select *
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,2)  as OnTimeDeliveryRate -- ׼ʱ������
from (
select
	sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
	,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd
join (
	select Id , ShopCode
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department='��ٻ�'
	where ReportType = 47  and AmazonShopHealthStatus != 4
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2


select eaaspcd.*
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd
join (
	select Id , ShopCode
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department='��ٻ�'
	where ReportType = 48  and AmazonShopHealthStatus != 4
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����

