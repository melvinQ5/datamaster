-- ContactResponseTime 及时回复指标
select
	count( distinct case when ContactResponseTimeStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- 最新情况
	,count( distinct case when ContactResponseTimeStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
	,count( distinct case when ContactResponseTimeStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,round(avg(case when AverageResponseTimeInHours>0 then eaaspcd.AverageResponseTimeInHours end),1) as AverageResponseTimeInHours -- 滚动累计
	,count( distinct case when ResponseTimeGreaterThan24Hours>0 then tmp.ShopCode  end) as ResponseUnder24HoursRate_shop_cnt
	,count( distinct case when NoResponseForContactsOlderThan24Hours>0 then tmp.ShopCode  end) as NoResponseForContactsOlderThan24Hours_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
join (
	select Id , ShopCode ,ContactResponseTimeStatus
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
	where CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day)  -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 4 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期

	
