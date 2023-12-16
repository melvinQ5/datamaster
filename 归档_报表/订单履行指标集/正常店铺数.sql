-- 店铺数

select count( distinct ShopCode) MonitorShopCount
from import_data.erp_amazon_amazon_shop_performance_check_sync  eaaspc 
join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code AND ms.ShopStatus = '正常'
where AmazonShopHealthStatus != 4 
and CreationTime <'${FristDay}' and CreationTime >= DATE_ADD('${FristDay}', interval -7 day) -- 每天凌晨0点后跑数


-- 使用紫鸟表计算
--  select WEEKOFYEAR(Monday)+1 
--  		,count(DISTINCT case when SiteStatus in ('正常','停用风险') then ShopCode end)
--  from import_data.ShopPerformance sp 
--  join import_data.mysql_store ms on sp.ShopCode =ms.Code and department in ('销售二部','销售三部')
--  where ReportType ="周报"
--  group by WEEKOFYEAR(Monday)+1 
--  order by WEEKOFYEAR(Monday)+1


