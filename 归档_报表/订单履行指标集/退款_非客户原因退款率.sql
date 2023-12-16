-- 退款时间=统计周次，且退款原因不等于客户主动取消的原因的订单金额/总订单金额
select a/b `非客户原因退款率` from 
(select sum(ro.RefundUSDPrice) a FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = s.code
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 not in ('客户个人原因', '无理由取消订单') 
-- 	and IsShipment ='否'  -- 不管是否发货
) A
,(SELECT sum(TotalGross/ExchangeUSD ) b
from import_data.wt_orderdetails dod  
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
-- 	and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = dod.shopcode 
where PayTime >= DATE_ADD('${FristDay}', interval -7 day) and PayTime < '${FristDay}' 
	and isdeleted = 0
	and TransactionType ='付款' and OrderStatus <> '作废' and OrderTotalPrice>0
) B 
