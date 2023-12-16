-- 使用方法
-- FristDay 赋值为本周一2022-12-26，则统计的是上周19日-25日
-- 通过 department in ('dep1','dep2','dep3','dep4') 来跑是 所有部门、还是GM、还是PM
-- PM 则替换 dep2 为销售二部，dep3为销售三部，其余任意替换成0等其他字符即可（因为用的 in )

with t1 as (

select 1-A_cnt/B_cnt `2个工作日迟发率` 
from 
(select count(distinct dod.PlatOrderNumber) as A_cnt  
from 
	(select 
		case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
		end as latest_WeightTime ,paytime ,DAYOFWEEK(OrderCountry_paytime)
		,PlatOrderNumber
	from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
		,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime
		from import_data.daily_OrderDetails  od
		join ( -- 只看店铺状态非冻结的订单数据
			select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
			and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
			) tmp on tmp.shopcode = od.ShopIrobotId
		left join
			(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area	
			FROM import_data.JinqinSku where monday='2023-12-20' ) js on js.code=right(od.ShopIrobotId ,2) 
		where PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
			and TransactionType ='付款' and totalgross > 1  
		) tmp
	)dod
left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber  
where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
) A
,(SELECT count(distinct PlatOrderNumber) B_cnt
from import_data.daily_OrderDetails dod 
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = dod.ShopIrobotId
where 
	PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
	and TransactionType ='付款' and totalgross > 1
) B  -- 付款时间推至本周三及往前滚7天， 留够发货时间

)

, AverageResponseTimeInHours as (

select * 
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- 状态异常店铺比例
from (
select
	count( distinct case when ContactResponseTimeStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt 
	,count( distinct case when ContactResponseTimeStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- 最新情况
	,count( distinct case when ContactResponseTimeStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when ContactResponseTimeStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,round(avg(case when AverageResponseTimeInHours>0 then eaaspcd.AverageResponseTimeInHours end),1) as AverageResponseTimeInHours -- 滚动累计
	,count( distinct case when ResponseTimeGreaterThan24Hours>0 then tmp.ShopCode  end) as ResponseUnder24HoursRate_shop_cnt
	,count( distinct case when NoResponseForContactsOlderThan24Hours>0 then tmp.ShopCode  end) as NoResponseForContactsOlderThan24Hours_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,ContactResponseTimeStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 4 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2
)

, LateShipmentRate  as (
select * 
	,round(LateShipment_ord_cnt/monitor_ord_cnt,3)  as LateShipmentRate 
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- 状态异常店铺比例
from (
select
	count( distinct case when LateShipmentRateStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt 
	,count( distinct case when LateShipmentRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt 
	,count( distinct case when LateShipmentRateStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when LateShipmentRateStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=5 then eaaspcd.Count end) as LateShipment_ord_cnt -- 迟发订单数
	,sum(case when ItemType=5 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=5 and eaaspcd.Count>0 then tmp.ShopCode  end) as LateShipment_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,LateShipmentRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2
)

, OnTimeDeliveryRate as (
select *
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,2)  as OnTimeDeliveryRate -- 准时交货率
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- 状态异常店铺比例
from (
select
	count( distinct case when OnTimeDeliveryStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt -- 警告+危险，不含疑似冻结
	,count( distinct case when OnTimeDeliveryStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- 最新情况
	,count( distinct case when OnTimeDeliveryStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when OnTimeDeliveryStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
	,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=9 and eaaspcd.Count>0 then tmp.ShopCode  end) as OnTimeDelivery_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OnTimeDeliveryStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2
)

, OrderCancellationRate as (
select * 
	,round(OrderCancel_ord_cnt/monitor_ord_cnt,3)  as OrderCancelRate 
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- 状态异常店铺比例
from (
select
	count( distinct case when OrderCancellationRateStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt 
	,count( distinct case when OrderCancellationRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- 最新情况
	,count( distinct case when OrderCancellationRateStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when OrderCancellationRateStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=6 then eaaspcd.Count  end) as OrderCancel_ord_cnt -- 取消订单数
	,sum(case when ItemType=6 then eaaspcd.OrderCount end) as monitor_ord_cnt -- 统计订单数
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=6 and eaaspcd.Count>0 then tmp.ShopCode  end) as OrderCancel_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OrderCancellationRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2
)

, ValidTrackingRate as (
select * 
	,round(ValidTracking_ord_cnt/monitor_ord_cnt,3)  as ValidTrackingRate -- 有效追踪率
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as ValidTracking_Shop_Rate -- 有效追踪店铺比例
from (
select
	count( distinct case when ValidTrackingRateStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt -- 最新情况
	,count( distinct case when ValidTrackingRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- 最新情况
	,count( distinct case when ValidTrackingRateStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when ValidTrackingRateStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=8 then eaaspcd.Count  end) as ValidTracking_ord_cnt -- 有效追踪订单数
	,sum(case when ItemType=8 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count(distinct case when ItemType=8 and eaaspcd.Count>0 then tmp.ShopCode  end) as ValidTracking_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,ValidTrackingRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2
)

, t2 as (
select round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from  (select 
	count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from 
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
		from import_data.OrderDetails a
		join (
			select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
			) tmp on tmp.shopcode = a.ShopIrobotId
		join import_data.mysql_store s on s.code = a.ShopIrobotId
		where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			and PayTime < '${FristDay}' and date_add(PayTime,10) >= date_add('${FristDay}',interval -7 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  
) tmp1
)

, t3 as (
SELECT  
	round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `作废订单率`
from import_data.daily_OrderDetails dod 
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = dod.ShopIrobotId
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) 
	and PayTime < '${FristDay}'
)

, t4 as ( -- 改为不算日均 算周
select CEILING(count(distinct dpd.PlatOrderNumber)/55)  `供应端人均日均订单数`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.PlatOrderNumber  = dod.PlatOrderNumber  
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp 
	on tmp.shopcode = dod.ShopIrobotId
)

, t5 as(
select ceiling(count(distinct dpd.PlatOrderNumber)/7)  `日均发货订单数`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.WeightTime  < '${FristDay}' 
		and dpd.WeightTime >= date_add('${FristDay}',interval -7 day) 
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp 
	on tmp.shopcode = dod.ShopIrobotId
)

, t6 as (
select round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
	and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${FristDay}' 
		and dpd.CreatedTime >= date_add('${FristDay}',interval -7 day) 
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp 
	on tmp.shopcode = dod.ShopIrobotId
)

, t7 as (
select round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (2 * 86400) then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `48小时收货率`
from import_data.PurchaseRev a 
join import_data.PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
where date_add(scantime, 2) < '${FristDay}' and date_add(scantime, 2) >= date_add('${FristDay}',interval -7 day) 
and Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) 
and ReportType = '周报' and b.WarehouseName = '东莞仓'
)

, t8 as (
select sum(diff_days)/count(DISTINCT PlatOrderNumber) `平均付款发货天数`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, paytime, pd.WeightTime)/86400 AS diff_days 
		from 
			( 
			select PlatOrderNumber , PayTime
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where WeightTime < '${FristDay}' and WeightTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

, t9 as (
select 
	sum(diff_days)/count(DISTINCT PlatOrderNumber) `平均付款妥投天数`
-- 	,avg(deli_days) `平均发货妥投天数`
from (
	select distinct eaalt.PlatOrderNumber, timestampdiff(second, PayTime ,eaalt.DeliverTime  )/86400 as diff_days 
		from 
			( 
			select PlatOrderNumber ,PayTime
			from import_data.daily_OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
			) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			) od_pre 
		join import_data.erp_amazon_amazon_logistics_tracking eaalt on od_pre.PlatOrderNumber = eaalt.PlatOrderNumber 
		where DeliverTime < '${FristDay}' and DeliverTime >= date_add('${FristDay}',interval -7 day) 
	) tmp
)

,t10 as (
select sum(gen_days)/count(DISTINCT PlatOrderNumber) `平均付款生包天数`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days 
		from 
			( 
			select PlatOrderNumber , PayTime
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where CreatedTime < '${FristDay}' and CreatedTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

,t11 as (
select sum(deli_days)/count(DISTINCT PlatOrderNumber) `平均发货上网天数`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, WeightTime ,eaalt.OnlineTime )/86400 AS deli_days 
		,WeightTime ,eaalt.SendTime 
		from 
			( 
			select PlatOrderNumber
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		join import_data.erp_amazon_amazon_logistics_tracking eaalt on pd.PlatOrderNumber = eaalt.PlatOrderNumber 
		where OnlineTime < '${FristDay}' and OnlineTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

, t12 as (
select 
	sum(deli_days)/count(DISTINCT PlatOrderNumber) `平均发货妥投天数`
-- 	,avg(deli_days) `平均发货妥投天数`
from (
	select distinct eaalt.PlatOrderNumber, timestampdiff(second, eaalt.SendTime ,eaalt.DeliverTime  )/86400 as deli_days 
		from import_data.daily_PackageDetail dpd 
		join ( 
			select PlatOrderNumber
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
			) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			) od_pre on dpd.PlatOrderNumber = od_pre.PlatOrderNumber
		join import_data.erp_amazon_amazon_logistics_tracking eaalt on od_pre.PlatOrderNumber = eaalt.PlatOrderNumber 
		where eaalt.DeliverTime  < '${FristDay}' and eaalt.DeliverTime  >= date_add('${FristDay}',interval -7 day) 
	) tmp
)

, t13 as (
select sum(deli_days)/count(DISTINCT PlatOrderNumber) `平均生包发货天数`
from  
	(select DISTINCT pd.PlatOrderNumber, timestampdiff(second, CreatedTime, WeightTime)/86400 AS deli_days 
		from 
			( 
			select PlatOrderNumber
			from import_data.OrderDetails a
			join (
				select DISTINCT ShopCode 
				from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
				join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
				where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
				) tmp on tmp.shopcode = a.ShopIrobotId
			join import_data.mysql_store s on s.code = a.ShopIrobotId
			where TransactionType = '付款'and OrderStatus <> '作废' and OrderTotalPrice > 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where weightTime < '${FristDay}' and weightTime >= date_add('${FristDay}',interval -7 day) 
	) tmp1
)

, t14 as (
select  sum(rev_days)/count(DISTINCT OrderNumber) `平均采购收货天数`
from (
select OrderNumber ,rev_days
from ( -- 往前推5天以便计算 5天采购到货率
select 
	po.OrderNumber
	, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	then timestampdiff(second, ordertime, CompleteTime)/86400  -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as rev_days -- 满足5天到货的下单号
from import_data.daily_PurchaseOrder po left join import_data.daily_PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where CompleteTime >= date_add('${FristDay}',interval -7 day) and CompleteTime < '${FristDay}' 
	and WarehouseName = '东莞仓' 
)po_pre
group by OrderNumber ,rev_days
) tmp
)

, t15 as ( -- 正常店铺数
select count( distinct ShopCode) MonitorShopCount
from import_data.erp_amazon_amazon_shop_performance_check_sync  eaaspc 
join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
where AmazonShopHealthStatus != 4 
and CreationTime <'${FristDay}' and CreationTime >= DATE_ADD('${FristDay}', interval -7 day)
)

, t16 as ( 
select 
	count(DISTINCT PlatOrderNumber) `AZ退款订单数`
--	, sum(ro.RefundUSDPrice) `AZ退款金额`
FROM import_data.daily_RefundOrders ro
join (
	select DISTINCT ShopCode 
			from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
			join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
			where AmazonShopHealthStatus != 4 
				and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp 
	on tmp.shopcode = ro.OrderSource
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 = 'AZ退款'
)

,t17 as (
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
from import_data.daily_OrderDetails dod  
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = dod.ShopIrobotId 
where PayTime >= DATE_ADD('${FristDay}', interval -7 day) and PayTime < '${FristDay}' 
	and TransactionType ='付款' and OrderStatus <> '作废' and OrderTotalPrice>0
) B 
)

,t18 as (
select  
	sum(case when RefundReason1 ='仓储部原因' then RefundUSDPrice/ord_gross end) `仓储原因退款率`
	,sum(case when RefundReason1 ='物流原因' then RefundUSDPrice/ord_gross end) `物流原因退款率`
	,sum(case when RefundReason1 ='订单问题' then RefundUSDPrice/ord_gross end) `订单问题退款率`
-- 	,sum(case when RefundReason1 ='产品原因' then RefundUSDPrice/ord_gross end)`产品原因退款率`
	,sum(case when RefundReason1 ='缺货' then RefundUSDPrice/ord_gross end) `缺货原因退款率`
	,sum(case when RefundReason1 ='售后' then RefundUSDPrice/ord_gross end) `售后原因退款率`
-- 	,sum(case when RefundReason1 ='客户原因' then RefundUSDPrice/ord_gross end) `非无理由客户原因退款率`
from 
(select ro.RefundReason1 ,ro.RefundUSDPrice
FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = s.code
where RefundDate >= DATE_ADD('${FristDay}', interval -30 day) 
	and RefundDate < '${FristDay}' 
	and RefundReason2  not in ('客户个人原因', '无理由取消订单') 
-- 	and IsShipment ='否'  -- 不管是否发货
) A
,(SELECT sum(TotalGross/ExchangeUSD ) ord_gross
from import_data.daily_OrderDetails dod  
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = dod.ShopIrobotId 
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) and PayTime < '${FristDay}' 
	and TransactionType ='付款' and OrderStatus <> '作废' and OrderTotalPrice>0
) B 
)

,t19 as (
SELECT 
	count(case when timestampdiff(second, CollectionTme , ReplyTime) <= 86400 then 1 end) /count(1) `24小时回复率`
	,count(case when timestampdiff(second, CollectionTme , ReplyTime) > 86400 then 1 end) `超24小时回复邮件数`
from import_data.daily_Email de 
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = de.Src 
where CollectionTme  >= DATE_ADD('${FristDay}', interval -7 day) and CollectionTme < '${FristDay}' 
)

,t20 as (
select round(count(1)/7,0) `日均邮件数`
from import_data.daily_Email de 
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = de.Src 
where  CollectionTme  < '${FristDay}' and CollectionTme >= date_add('${FristDay}',interval -7 day) 
)

,t21 as (
select count(distinct PlatOrderNumber) `询问物流邮件的订单数`
from import_data.daily_Email de 
join ( -- 只看店铺状态非冻结的订单数据
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('${dep1}','${dep2}','${dep3}','${dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
	) tmp on tmp.shopcode = de.Src 
where  ReplyTime < '${FristDay}' and ReplyTime >= date_add('${FristDay}',interval -7 day) 
and MailCategory like '%交期%' or MailCat
egory like '%丢包%' or MailCategory like '%Shipping%'
)

,t22 as (
select  round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from ( -- 往前推5天以便计算 5天采购到货率
select 
	po.OrderNumber,po.BoxSku 
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then po.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then po.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else po.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.PurchaseOrder po left join import_data.PurchaseRev  pr on po.OrderNumber = pr.OrderNumber
where date_add(ordertime, 5)  >= date_add('${FristDay}',interval -7 day) and date_add(ordertime, 5) < '${FristDay}' 
	and WarehouseName = '东莞仓' and Monday < '${FristDay}' and Monday >= date_add('${FristDay}',interval -7 day) and ReportType = '周报' 
)po_pre
)

select * from t1 ,LateShipmentRate ,OnTimeDeliveryRate, OrderCancellationRate ,ValidTrackingRate,t2
t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22
