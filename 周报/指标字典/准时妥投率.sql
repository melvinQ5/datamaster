
-- erp店铺健康表
-- 主表  erp_amazon_amazon_shop_performance_check, 主表全量表： erp_amazon_amazon_shop_performance_check_sync
-- 主表对应两份明细表，报告类型:V2=48,V1=47,V2主要记录店铺AHR得分指标，V1主要记录其他指标，因平台API原因，无法将V1V2合并，具体咨询毛俊（IT）、金琴（需求方）
-- 明细表V1：erp_amazon_amazon_shop_performance_check_detail
-- 明细表V1全量表：erp_amazon_amazon_shop_performance_check_detail_sync

-- 准时交货率
-- OrderCount为null，因此使用 分子/比率=分母
-- 准时交货率部分数据 count=0 rate=0, 如果对全表计算,相当于只记录了不准时的这部分的交货率？
select *
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,2)  as OnTimeDeliveryRate -- 准时交货率
from (
select
	sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
	,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd
join (
	select Id , ShopCode
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department='快百货'
	where ReportType = 47  and AmazonShopHealthStatus != 4
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2


select eaaspcd.*
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd
join (
	select Id , ShopCode
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.Department='快百货'
	where ReportType = 48  and AmazonShopHealthStatus != 4
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期

