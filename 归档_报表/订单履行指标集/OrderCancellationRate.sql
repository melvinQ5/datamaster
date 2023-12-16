-- ȡ����
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
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' 
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����
) tmp2

