-- 物流比价、版本比价
(
-- 维度：维度渠道
-- 统计期：历史所有
-- 指标：计算指标及对每个指标进行物流渠道排名
-- 平均时效、标准时效对比、总包裹数、妥投率、标准妥投率、异常包裹数、单价成本CNY

-- 指标：退款率(退款原因为物流商原因的退款金额/已发货订单金额)、排名
select B.TransportType ,a/b `物流原因退款率` 
from (SELECT TransportType ,sum(TotalGross/ExchangeUSD ) b
	from import_data.OrderDetails dod  
	where TransactionType ='付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 and shiptime >'2000-01-01' 
	group by TransportType
	) B 
left join 
	(select TransportType ,sum(ro.RefundUSDPrice) a 
	FROM import_data.daily_RefundOrders ro
	where  RefundReason1 = '物流原因' and ShipDate>'2000-01-01' 
	group by TransportType 
	) A on B.TransportType = A.TransportType

-- select RefundReason1 , RefundReason2 ,count(1)
-- from import_data.RefundOrders ro 
-- group by RefundReason1 , RefundReason2 
	
-- 基础指标
select TransportId ,TransportType 
		,round(avg(DeliverHour)/24,1) avg_deliver_cost -- 平均时效
		,count(PackageNumber) TotalPackageCount -- 包裹数
		,count(case when TrackingStatus=7 then PackageNumber end ) DeliveryPackageCnt-- 妥投包裹数
		,count(case when Deliverhuor < StandardMaxTime and Deliverhuorand > 0 then PackageNumber end ) DeliveryInStdPackageCnt -- 标准时效内妥投包裹数
		,sum(PackageFeight) TotalPackageFeight -- 总运费
		,sum(PackageTotalWeight) TotalPackageTotalWeight -- 总重量
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
group by TransportId ,TransportType

-- 异常包裹：异常追踪表只放可能异常和查询不到的包裹
select TransportId ,TransportType ,count(PackageNumber) ExceptionPackageCnt -- 异常包裹数
from import_data.erp_logistic_logistic_exception_trackings ellet 
join import_data.erp_logstic_logistics_tracking ellt on ellet.Id  = ellt.LogisticTrackingId 
group by TransportId ,TransportType

-- 计算指标
-- 标准时效对比 = 标准时效-平均时效  StandardMaxTime - avg_deliver_cost
-- 妥投率=妥投包裹数/总包裹数
-- 标准妥投率=标准时效内妥投包裹书/总包裹数
-- 单价成本CNY=包裹总运费/包裹总重量
-- 各指标排名计算 row_number()
)

-- 工作台
(

-- 指标卡1 总包裹数 平均妥投率 标准妥投率
select TransportId ,TransportType 
		,round(avg(DeliverHour)/24,1) avg_deliver_cost -- 平均时效
		,count(PackageNumber) TotalPackageCount -- 包裹数
		,count(case when TrackingStatus=7 then PackageNumber end ) DeliveryPackageCnt-- 妥投包裹数
		,count(case when Deliverhuor < StandardMaxTime and Deliverhuorand > 0 then PackageNumber end ) DeliveryInStdPackageCnt -- 标准时效内妥投包裹数
		,sum(PackageFeight) TotalPackageFeight -- 总运费
		,sum(PackageTotalWeight) TotalPackageWeight -- 总重量
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
group by TransportId ,TransportType


-- 指标卡2 总异常包裹 异常包裹率
select 
	count(ellet.PackageNumber) ExceptionPackageCnt -- 异常包裹数
	,round(count(ellet.PackageNumber)/count(ellt.PackageNumber),2) -- 异常包裹率
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistic_exception_trackings ellet on ellet.Id  = ellt.LogisticTrackingId 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'

-- 指标卡3 平均时效
-- 指标卡4 总运费额 运费额占订单金额比
-- 指标卡5 平均上网率（上网包裹数/总包裹数）、 标准上网率（24小时内上网占比）


-- 图表1 物流异常榜单 （异常物流包裹数降序 前11名）
select 
	ExceptionType
	,count(ellet.PackageNumber) ExceptionPackageCnt -- 异常包裹数
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistic_exception_trackings ellet on ellet.Id  = ellt.LogisticTrackingId 
group by ExceptionType
order by ExceptionPackageCnt desc 
limit 11 



-- 图表2 包裹分布情况 不同物流状态的包裹占比和包裹数
select TrackingStatus ,count(PackageNumber) StatusPackageCnt
from import_data.erp_logstic_logistics_tracking ellt 
group by TrackingStatus 


-- 图表3 平均上网时效（近一周）
select round(sum(OnLineHour)/count(PackageNumber),1) AvgOnlineHour
from import_data.erp_logstic_logistics_tracking ellt 
where OnlineTime  >= CURRENT_DATE()-7 

-- 图表4 物流妥投榜单 
select MerchantId, MerchantName ,TransportId ,TransportType
		,round(avg(DeliverHour)/24,1) avg_deliver_cost -- 平均时效
		,count(PackageNumber) TotalPackageCount -- 包裹数
		,count(case when TrackingStatus=7 then PackageNumber end ) DeliveryPackageCnt-- 妥投包裹数
		,count(case when Deliverhuor < StandardMaxTime and Deliverhuorand > 0 then PackageNumber end ) DeliveryInStdPackageCnt -- 标准时效内妥投包裹数
		,sum(PackageFeight) TotalPackageFeight -- 总运费
		,sum(PackageTotalWeight) TotalPackageTotalWeight -- 总重量
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
group by MerchantId, MerchantName ,TransportId ,TransportType

)

-- 趋势看板_包裹分布
(
-- 指标卡1 平均重量
select 
	sum(PackageTotalWeight) TotalPackageTotalWeight -- 总重量
	,count(PackageNumber) TotalPackageCount -- 包裹数
	,sum(PackageTotalWeight)/count(PackageNumber) avgPackageWeight  -- 平均重量
from import_data.erp_logstic_logistics_tracking ellt 
left join import_data.erp_logistic_logistics_transports ellt2 on ellt.TransportId = ellt2.Id 
where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'

-- 图表1 重量区间 x 发货日期 的包裹数 
select TransportId ,TransportType  ,WeightBins ,WeightDate ,count(1)  `发货包裹数`
from 
	(select TransportTypeCode ,TransportType ,ReceiverCountryCnName ,to_date(WeightTime) WeightDate
			,case when PackageTotalWeight <=10 then '10g以下'
				when PackageTotalWeight >10 and PackageTotalWeight <=30 then '11-30g'
				when PackageTotalWeight >31 and PackageTotalWeight <=50 then '31-50g'
				when PackageTotalWeight >51 and PackageTotalWeight <=100 then '51-100g'
				when PackageTotalWeight >101 and PackageTotalWeight <=200 then '101-200g'
				when PackageTotalWeight >201 and PackageTotalWeight <=500 then '201-500g'
				when PackageTotalWeight >501 and PackageTotalWeight <=1000 then '501-1000g'
				when PackageTotalWeight >1000  then '1000g以上'
			end WeightBins
			,PackageNumber
		from import_data.erp_logstic_logistics_tracking
		where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
	group by TransportId ,TransportType  ,WeightBins ,PackageNumber ,to_date(WeightTime)
	) tmp 

)

-- 趋势看板_趋势分布
(
-- 维度 目的地国家 x 发货日期 ；物流商 x 发货日期 ；物流渠道 x 发货日期 
-- 指标 包裹重量，平均包裹重，包裹数，异常包裹数，异常包裹率，妥投率，标准妥投率，上网率，
-- 指标 24小时标准上网率，总运费额，平均运费单价，订单数，订单金额，平均包裹金额，订单利润率，退款率

)


-- 趋势看板_包裹全程时效、节点时效（待上网，运输途中，到达待取，派送途中，成功签收）
(
-- 维度
-- 指标
select TransportId ,TransportType  ,TimeBins ,WeightDate ,count(1)  `发货包裹数`
from 
	(select TransportTypeCode ,TransportType ,ReceiverCountryCnName ,to_date(WeightTime) WeightDate
			,case 
				when DeliverHour > 0 and DeliverHour <= 5*24 then '0-5天'
				when DeliverHour > 5*24 and DeliverHour <= 10*24 then '6-10天'
				when DeliverHour > 10*24 and DeliverHour <= 15*24 then '11-15天'
				when DeliverHour > 15*24 and DeliverHour <= 20*24 then '16-20天'
				when DeliverHour > 20*24 and DeliverHour <= 25*24 then '21-25天'
				when DeliverHour > 25*24 and DeliverHour <= 30*24 then '26-30天'
				when DeliverHour > 30*24  then '30天以上'
			end TimeBins
			,PackageNumber
		from import_data.erp_logstic_logistics_tracking
		where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
	group by TransportId ,TransportType  ,TimeBins ,PackageNumber ,to_date(WeightTime)
	) tmp 

-- 开始节点选“运输途中”，结束节点选“派送途中”  ，计算时效指标= 派送途中时间-
-- 展示最近1个月
	
)


-- 趋势看板_包裹运费（运费分区间）
(

select TransportId ,TransportType  ,TimeBins ,WeightDate ,count(1)  `发货包裹数`
from 
	(select TransportTypeCode ,TransportType ,ReceiverCountryCnName ,to_date(WeightTime) WeightDate
			,case 
				when PackageFeight > 0 and PackageFeight <= 5 then '0-5'
				when PackageFeight > 5 and PackageFeight <= 20 then '5-20'
				when PackageFeight > 20 and PackageFeight <= 50 then '20-50'
				when PackageFeight > 50 and PackageFeight <= 100 then '50-100'
				when PackageFeight > 100 and PackageFeight <= 200 then '100-200'
				when PackageFeight > 200 and PackageFeight <= 500 then '200-500'
				when PackageFeight > 500  then '500以上'
			end TimeBins
			,PackageNumber
		from import_data.erp_logstic_logistics_tracking ellt 
		join import_data.wt_orderdetails wo on ellt.PlatOrderNumber = d 
		where WeightTime >= '{StartTime}'  and WeightTime <	= '{EndTime}'
	group by TransportId ,TransportType  ,TimeBins ,PackageNumber ,to_date(WeightTime)
	) tmp 

)


-- 上网时效分析  
-- （erp_amazon_amazon_logistics_tracking 是一张临时表，正式系统上线后会被替换为 erp_logstic_logistics_tracking）
select to_date(WeightTime) `发货日期`, LogisticName `物流商`, wp.TransportType `物流渠道`,wp.WarehouseName `发货仓库` 
	,count(distinct wp.PackageNumber ) `包裹总数`
	,sum(PackageTotalWeight) `包裹总重量g` 
	,round(sum(PackageFeight),2) `包裹总运费CNY`
	,count(distinct case when wp.OnlineHour < 24 then wp.PackageNumber end) `24小时内上网包裹数`
	,count(distinct case when wp.OnlineHour >= 24 and wp.OnlineHour < 48 then wp.PackageNumber end) `48小时内上网包裹数`
	,count(distinct case when wp.OnlineHour >= 48 and wp.OnlineHour < 72 then wp.PackageNumber end) `72小时内上网包裹数`
	,count(distinct case when wp.OnlineHour > 72 then wp.PackageNumber end) `超72小时网包裹数`
	,count(distinct case when wp.OnlineHour is null then wp.PackageNumber end) `未上网包裹数`
from import_data.wt_packagedetail wp 
join import_data.erp_amazon_amazon_logistics_tracking eaalt on wp.PackageNumber  = eaalt.PackageNumber -- 使用目前有跑的17track数据
group by LogisticName , wp.TransportType ,wp.WarehouseName, to_date(WeightTime)
