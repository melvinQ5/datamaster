-- 迟发率
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
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' 
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 2 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2