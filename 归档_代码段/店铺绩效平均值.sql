
with odr as ( -- ODR
select * 
	,round(OrderWithDefects_ord_cnt/monitor_ord_cnt,6)  as OrderDefectRate 
from (
	select department
		,sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
		,sum(case when ItemType=1 then eaaspcd.OrderCount end) as monitor_ord_cnt
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,OrderDefectRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 1 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 60 -- 统计期
	group by department
	) tmp2
)


, lsr as ( -- LSR
select * 
	,round(LateShipment_ord_cnt/monitor_ord_cnt,3)  as LateShipmentRate 
from (
	select department
		,sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- 迟发订单数
		,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,LateShipmentRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 7 -- 统计期
	group by department
	) tmp2
)

, cr as ( 
select * 
	,round(OrderCancel_ord_cnt/monitor_ord_cnt,3)  as OrderCancelRate 
from (
	select department
		,sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- 取消订单数
		,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,OrderCancellationRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 7 -- 统计期
	group by department
	) tmp2
)

, vtr as (    
select * 
	,round(ValidTracking_ord_cnt/monitor_ord_cnt,3)  as ValidTrackingRate -- 有效追踪率
from (
	select department
		,sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- 有效追踪订单数
		,sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode ,ValidTrackingRateStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 7 -- 统计期
	group by department
	) tmp2
)

-- 紫鸟数据 待处理脏数据
-- select 
-- 	department
-- 	,avg(case when ODR<>'不适用' then cast(replace(ODR,'%','') as float) end ) `店铺ODR平均值` 
-- 	,avg(case when TrackingRate<>'不适用' then TrackingRate end ) `店铺VTR平均值`
-- 	,avg(case when LaterDay10<>'不适用' then LaterDay10 end ) `店铺LSR平均值`
-- 	,avg(case when RateBeforeShipping<>'不适用' then RateBeforeShipping end) `店铺CR平均值`
-- 	,avg(case when AccountHealth<>'不适用' then  AccountHealth end )`店铺AHR平均值`
-- from import_data.ShopPerformance sp 
-- join import_data.mysql_store ms on sp.ShopCode = ms.Code and department='快百货'
-- 	and ReportType ='周报' and Monday ='2023-02-13'
-- group by department

select email.department 
	,OrderDefectRate `店铺ODR平均值`
	,LateShipmentRate `店铺LSR平均值`
	,OrderCancelRate `店铺CR平均值`
	,ValidTrackingRate `店铺VTR平均值`
from (select department from import_data.mysql_store ms  group by department) email 
left join odr on email.department = odr.department
left join lsr on email.department = lsr.department
left join cr on email.department = cr.department
left join vtr on email.department = vtr.department