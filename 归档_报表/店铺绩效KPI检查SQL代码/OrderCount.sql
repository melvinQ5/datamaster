-- ������
select 
	count( distinct ShopCode) shop_cnt 
from (
	select tmp.ShopCode 
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode 
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		where CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	) tmp 

-- �������Ƿ�����
-- 	mysql_store ���������� 6��δ�� ���̽�����
-- 	mysql_store �쳣������ 33��δ�� ���̽�����
SELECT e.*
from  mysql_store ms 
left join import_data.erp_amazon_amazon_shop_performance_check e
on e.ShopCode =ms.Code 
where e.id is not null and ms.ShopStatus ='�쳣'
