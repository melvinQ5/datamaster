-- ContactResponseTime ��ʱ�ظ�ָ��
select
	count( distinct case when ContactResponseTimeStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- �������
	,count( distinct case when ContactResponseTimeStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
	,count( distinct case when ContactResponseTimeStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,round(avg(case when AverageResponseTimeInHours>0 then eaaspcd.AverageResponseTimeInHours end),1) as AverageResponseTimeInHours -- �����ۼ�
	,count( distinct case when ResponseTimeGreaterThan24Hours>0 then tmp.ShopCode  end) as ResponseUnder24HoursRate_shop_cnt
	,count( distinct case when NoResponseForContactsOlderThan24Hours>0 then tmp.ShopCode  end) as NoResponseForContactsOlderThan24Hours_shop_cnt
	-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
join (
	select Id , ShopCode ,ContactResponseTimeStatus
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
	where CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day)  -- ÿ���賿0�������
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 4 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
	and DateType = 7 -- ͳ����

	
