
select ShopCode 
	,case AmazonShopHealthStatus 
		when 0 then '全部'
		when 1 then '正常'
		when 2 then '警告'
		when 3 then '危险'
		when 4 then '冻结'
	end API店铺健康状态
	,ms.NodePathName  ,ms.SellUserName 
	,concat(OrderWithDefectsRate,'%')  ODR 
	,concat(ValidTrackingRate,'%')  VTR 
	,concat(LateShipmentRate ,'%') LSR 
	,concat(PreFulfillmentCancellationRate ,'%') CR 
from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '快百货'
where
	CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
order by AmazonShopHealthStatus desc , NodePathName

