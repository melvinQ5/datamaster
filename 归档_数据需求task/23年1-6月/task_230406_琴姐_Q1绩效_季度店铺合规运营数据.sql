
-- ord 

select
	'ODR' `指标`
	,round(OrderWithDefects_ord_cnt/monitor_ord_cnt,6)  as `计算结果` -- 有效追踪率
	,OrderWithDefects_ord_cnt `符合条件订单数`
	,monitor_ord_cnt `平台监控订单数`
from (
select
	sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
	,sum(case when ItemType=1 then eaaspcd.OrderCount end) as monitor_ord_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OrderDefectRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常'  and ms.Department = '快百货'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 1 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 90 -- 统计期
) tmp2

union 
-- 迟发率
select 'LSR'
	,round(LateShipment_ord_cnt/monitor_ord_cnt,6)  as LateShipmentRate 
	,LateShipment_ord_cnt
	,monitor_ord_cnt 
from (
select
	sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- 迟发订单数
	,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,LateShipmentRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '快百货'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 30 -- 统计期
) tmp2

union 
-- 取消率
select 'CR' 
	,round(OrderCancel_ord_cnt/monitor_ord_cnt,6)  as OrderCancelRate 
	,OrderCancel_ord_cnt
	,monitor_ord_cnt
from (
select
	sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- 取消订单数
	,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OrderCancellationRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '快百货'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 30 -- 统计期
) tmp2

UNION 
-- 有效追踪率
-- 当MetricsType = 3（追踪指标数据）的时候，OrderCount为null，因此使用 分子/比率=分母
select 'VTR'
	,round(ValidTracking_ord_cnt/monitor_ord_cnt,3)  as ValidTrackingRate -- 有效追踪率
	,ValidTracking_ord_cnt
	,monitor_ord_cnt
from (
select
	sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- 有效追踪订单数
	,round(sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end),0) as monitor_ord_cnt -- 统计订单数
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,ValidTrackingRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '快百货'
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 30 -- 统计期
) tmp2

UNION 
select 'AHR'
	,round(avg( case when AccountHealth is not null then AccountHealth end),2)    
	,''
	,''
from import_data.ShopPerformance sp 
join import_data.mysql_store ms on sp.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department = '快百货'
where Monday = '2023-03-27'
