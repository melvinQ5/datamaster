
select ShopCode 
	,case AmazonShopHealthStatus 
		when 0 then 'ȫ��'
		when 1 then '����'
		when 2 then '����'
		when 3 then 'Σ��'
		when 4 then '����'
	end API���̽���״̬
	,ms.NodePathName  ,ms.SellUserName 
	,concat(OrderWithDefectsRate,'%')  ODR 
	,concat(ValidTrackingRate,'%')  VTR 
	,concat(LateShipmentRate ,'%') LSR 
	,concat(PreFulfillmentCancellationRate ,'%') CR 
from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
where
	CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- ÿ���賿0�������
order by AmazonShopHealthStatus desc , NodePathName

