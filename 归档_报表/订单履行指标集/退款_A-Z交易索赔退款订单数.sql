
select 
	count(DISTINCT PlatOrderNumber) `AZ退款订单数`
--	, sum(ro.RefundUSDPrice) `AZ退款金额`
FROM import_data.daily_RefundOrders ro
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department  = '快百货'
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp 
	on tmp.shopcode = ro.OrderSource
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 = 'AZ退款'

