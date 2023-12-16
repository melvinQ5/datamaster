-- 近60天订单缺陷率 （每周跑一版滚动更新） 每个店铺的统计订单总数，超阈值订单数

select
	count( distinct case when OrderDefectRateStatus=2  then tmp.ShopCode  end) as warning_shop_cnt
	,count( distinct case when OrderDefectRateStatus=3  then tmp.ShopCode  end) as danger_shop_cnt
	,count( distinct case when OrderDefectRateStatus=4  then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=1 then eaaspcd.Count  end) as OrderWithDefects_ord_cnt
	,count( distinct case when ItemType=1 and eaaspcd.Count>0 then tmp.ShopCode  end) as OrderWithDefects_shop_cnt
	,sum(case when ItemType=2 then eaaspcd.Count  end) as NegativeFeedbacks_ord_cnt
	,count( distinct case when ItemType=2 and eaaspcd.Count>0 then tmp.ShopCode  end) as NegativeFeedbacks_shop_cnt
	,sum(case when ItemType=3 then eaaspcd.Count  end) as TradingClaims_ord_cnt
	,count( distinct case when ItemType=3 and eaaspcd.Count>0 then tmp.ShopCode  end) as TradingClaims_shop_cnt
	,sum(case when ItemType=4 then eaaspcd.Count  end) as RefuseClaims_ord_cnt
	,count( distinct case when ItemType=4 and eaaspcd.Count>0 then tmp.ShopCode  end) as RefuseClaims_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
join (
	select Id , ShopCode ,OrderDefectRateStatus
	from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
	where CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 1 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 60 -- 统计期

