
select 
	count(DISTINCT PlatOrderNumber) `AZ�˿����`
--	, sum(ro.RefundUSDPrice) `AZ�˿���`
FROM import_data.daily_RefundOrders ro
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department  = '��ٻ�'
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp 
	on tmp.shopcode = ro.OrderSource
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 = 'AZ�˿�'

