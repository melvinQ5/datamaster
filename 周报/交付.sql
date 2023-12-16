
-- --------------------------交付-------------
with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select department as dep from import_data.mysql_store
union
select split_part(NodePathNameFull,'>',2) from import_data.mysql_store
union
select NodePathName from import_data.mysql_store
)

-- 准时发货率
,ontimesend as (
select tb.department,round(A_cnt/B_cnt,4) `准时发货率` 
from 
	( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, B_cnt	
	FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		 group by grouping sets ((),(department))
		) tmp3 -- 付款时间推至4天 留够发货时间
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- 当地两个工作日内发货订单数
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- 处理工作日
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department 
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,department 
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
					and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
union 
select tb.department,round(A_cnt/B_cnt,4) `准时发货率` -- `2个工作日发货率` 
from 
	( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, B_cnt	
	FROM ( SELECT left(ms.NodePathName,3) as department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		 group by grouping sets ((),(left(NodePathName,3)))
		) tmp3 -- 付款时间推至4天 留够发货时间
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- 当地两个工作日内发货订单数
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- 处理工作日
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,left(NodePathName,3) as department
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
					and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
union 
select tb.department,round(A_cnt/B_cnt,4) `准时发货率` -- `2个工作日发货率` 
from 
	( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, B_cnt	
	FROM ( SELECT NodePathName as department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code 
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		 group by grouping sets ((),(NodePathName))
		) tmp3 -- 付款时间推至4天 留够发货时间
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- 当地两个工作日内发货订单数
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- 处理工作日
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,NodePathName as department
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
					and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
),


-- 准时妥投率
OnTimeDeliveryRate as (
select CASE WHEN department IS NULL THEN '公司' ELSE department END AS department
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `准时妥投率`
from (
	SELECT department
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	 	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and to_date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 30 -- 统计期
	group by grouping sets ((),(department))
) tmp2
union 
select CASE WHEN NodePathName IS NULL THEN '公司' ELSE NodePathName END AS NodePathName
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as OnTimeDeliveryRate -- 准时妥投率
from (
	SELECT NodePathName
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,NodePathName
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	 	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 30 -- 统计期
	group by grouping sets ((),(NodePathName))
) tmp2
) 


-- 物流三天上网率
-- select lt.*
-- from  -- 轨迹表按发货时间 貌似只跑到0128
-- left join ( select department , count(distinct case when OnLineHour <= 72 then PackageNumber end ) 
-- from erp_logistic_logistics_tracking lt
-- join import_data.mysql_store ms on lt.ShopCode =ms.Code 
-- where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
-- group by department
-- ) 

-- 采购单数 采购金额 采购运费
, purchase as (
select case when department IS NULL THEN '公司' ELSE department END AS department 
	,round(sum(Price - DiscountedPrice)) `采购产品金额` , round(sum(SkuFreight)) `采购运费`	,count(distinct OrderNumber) `采购单数`
	,round(count(distinct OrderNumber)/datediff('${NextStartDay}','${StartDay}')) `日均采购单数`
from wt_purchaseorder wp 
join (select BoxSku , projectteam as department  from import_data.wt_products where IsDeleted = 0 ) wp2 
	on wp.BoxSku =wp2.BoxSku 
where ordertime  <  '${NextStartDay}'  and ordertime >= '${StartDay}' and WarehouseName = '东莞仓' 
group by grouping sets ((),(department))
) 


-- 采购3天到货率
-- , purchase2warehouse as (
select 
	case when department IS NULL THEN '公司' ELSE department END AS department
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购3天到货率` 
from (
select 
	dpo.OrderNumber,dpo.BoxSku ,department
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 3 then dpo.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 3 then dpo.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
	end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else dpo.OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
join ( select BoxSku ,projectteam as department from wt_products ) tmp on dpo.BoxSku = tmp.BoxSku
where ordertime >= date_add('${StartDay}',interval -3 day) and ordertime < date_add('${NextStartDay}',interval -3 day) and WarehouseName = '东莞仓'
) tmp 
group by grouping sets ((),(department))
) 

-- 采购平均到货天数
, avg_purchase2warehouse_time as (
select case when department IS NULL THEN '公司' ELSE department END AS department
	, sum(rev_days)/count(DISTINCT OrderNumber) `平均采购收货天数`
from (
	select OrderNumber ,department ,rev_days
	from ( 
		select 
			dpo.OrderNumber ,department
			, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
				when scantime is null and instockquantity > 0 and CompleteTime is not null 
				then timestampdiff(second, ordertime, CompleteTime)/86400  -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
				end as rev_days
		from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev  pr on dpo.OrderNumber = pr.OrderNumber
		left join ( select BoxSku ,projectteam as department from wt_products ) tmp on dpo.BoxSku = tmp.BoxSku
		where CompleteTime < '${NextStartDay}' and CompleteTime >= '${StartDay}' and WarehouseName = '东莞仓' 
		) po_pre
	where rev_days is not null 
	group by department ,OrderNumber ,rev_days
	) tmp 
group by grouping sets ((department))
)


-- 生包率 订单5天发货率 订单7天发货率
, ordersend as (
select department 
	,round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from  
	(select CASE WHEN department IS NULL THEN '公司' ELSE department END AS department  
	, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from 
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime 
			,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0 
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${NextStartDay}',interval -7-10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
	group by grouping sets ((),(department))
) tmp1
union 
select dep2 
	,round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from  
	(select dep2 
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
		from 
			( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
			select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime 
				,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常'  and wo.IsDeleted = 0 
			where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
			) od_pre 
		left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
		group by dep2
	) tmp1
union 
select NodePathName 
	,round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from  
	(select NodePathName 
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
		from 
			( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
			select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime 
				,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常' and ms.department = '快百货'  and wo.IsDeleted = 0 
			where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
			) od_pre 
		left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
		group by NodePathName
	) tmp1
) ,
-- group by grouping sets ((),(department))


-- 24小时发货率
sendIn24h as (
select 
	case when department is null THEN '公司' ELSE department END AS department
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${NextStartDay}' 
		and dpd.CreatedTime >= '${StartDay}'
join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
group by grouping sets ((),(department))
union 
select 
	case when NodePathName is null THEN '公司' ELSE NodePathName END AS NodePathName
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24小时发货率`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${NextStartDay}' 
		and dpd.CreatedTime >= '${StartDay}'
join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
group by grouping sets ((),(NodePathName))
) ,

-- 24小时收货率
receiveIn24h as (
select
	case when department is null THEN '公司' ELSE department END AS department
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400) 
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `24小时收货率`
from import_data.daily_PurchaseRev a 
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where date_add(scantime, 1) < '${NextStartDay}'  and date_add(scantime, 1) >= '${StartDay}'
	 and b.WarehouseName = '东莞仓'
group by grouping sets ((),(department))
) , 


-- 库存资金占用
warehouse_stat as (
select a.department
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`),0) `本地仓库存资金占用`
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额`*datediff('${NextStartDay}','${StartDay}'),1) `库存周转天数`
	,`发货订单采购金额`
	,`在仓sku件数`,`在仓sku数` 
	,`在途产品采购金额`, `在途产品采购运费` , `在仓产品金额`
from
(
select case when department is null THEN '公司' ELSE department END AS department
	, sum(Price - DiscountedPrice) `在途产品采购金额` , ifnull(sum(SkuFreight),0) `在途产品采购运费`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp 
	join ( select BoxSku ,projectteam as department from wt_products ) tmp on wp.BoxSku = tmp.BoxSku 
	where ordertime < '${NextStartDay}'
		and isOnWay = "是" and WarehouseName = '东莞仓'
	) tmp	
group by grouping sets ((),(department))
) a 

left join (
	SELECT case when department is null THEN '公司' ELSE department END AS department  
		,sum(ifnull(TotalPrice,0)) `在仓产品金额`, sum(ifnull(TotalInventory,0)) `在仓sku件数`, count(*) `在仓sku数` 
	FROM ( -- local_warehouse 本地仓表
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products ) tmp on wi.BoxSku = tmp.BoxSku 
		where WarehouseName = '东莞仓' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
		)  tmp 
	group by grouping sets ((),(department))
) b on a.department = b.department

left join (	
	select case when department is null THEN '公司' ELSE department END AS department 
		, round(sum(pc)) `发货订单采购金额` 
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,department
		from import_data.daily_PackageDetail pd 
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.ods_orderdetails od 
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0 
				and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' and pd.WarehouseName='东莞仓'
		) a 
	group by grouping sets ((),(department))
) c on a.department = c.department
) ,


-- 作废订单率 , 日均订单数
-- 付款时间为近7天的订单，状态=作废且匹配退款原因种不是客户主动取消的订单
OrderCancelRate as (
SELECT case when department IS NULL THEN '公司' ELSE department END AS department 
	,round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber  end)/count(distinct PlatOrderNumber),4) as `作废订单率`
	,round(count(DISTINCT CASE when OrderStatus != '作废' and TransactionType ='付款' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `日均订单数`
from import_data.ods_orderdetails oo  
join import_data.mysql_store ms on oo.ShopIrobotId  =ms.Code 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and TransactionType <>'其他'
group by grouping sets ((department))
union 
SELECT case when NodePathName IS NULL THEN '公司' ELSE NodePathName END AS NodePathName 
	,round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `作废订单率`
	,round(count(DISTINCT CASE when OrderStatus != '作废' and TransactionType ='付款' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `日均订单数`
from import_data.ods_orderdetails oo  
join import_data.mysql_store ms on oo.ShopIrobotId  =ms.Code 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and TransactionType <>'其他'
group by grouping sets ((NodePathName))
)

, over10orders as ( -- 10天未发货订单比 =  统计T-10~T-20未发货订单数÷统计T-10~T-20日均付款订单数
select  Department, count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end) `10天未发订单数`
--  	,count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end)/(count(distinct  PlatOrderNumber)/10) `10天未发订单比`
from ods_orderdetails wo 
join import_data.mysql_store ms on wo.ShopIrobotId  =ms.Code 
where IsDeleted = 0 and PayTime < date_add(CURRENT_DATE(),-10) and PayTime >= date_add(CURRENT_DATE(),interval -10-10 day) 
	and TransactionType ="付款" and OrderStatus !='作废'
group by Department 
union 
select  left(NodePathName,3) as department, count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end) `10天未发订单数`
--  	,count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end)/(count(distinct  PlatOrderNumber)/10) `10天未发订单比`
from ods_orderdetails wo 
join import_data.mysql_store ms on wo.ShopIrobotId  =ms.Code 
where IsDeleted = 0 and PayTime < date_add(CURRENT_DATE(),-10) and PayTime >= date_add(CURRENT_DATE(),interval -10-10 day) 
	and TransactionType ="付款" and OrderStatus !='作废'
group by left(NodePathName,3)
union 
select  NodePathName as department, count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end) `10天未发订单数`
--  	,count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end)/(count(distinct  PlatOrderNumber)/10) `10天未发订单比`
from ods_orderdetails wo 
join import_data.mysql_store ms on wo.ShopIrobotId  =ms.Code 
where IsDeleted = 0 and PayTime < date_add(CURRENT_DATE(),-10) and PayTime >= date_add(CURRENT_DATE(),interval -10-10 day) 
	and TransactionType ="付款" and OrderStatus !='作废'
group by grouping sets ((NodePathName)) 

-- 直接使用新的表
select  Department, count(distinct PlatOrderNumber ) `10天未发订单数`
from daily_WeightOrders wo
join import_data.mysql_store ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1) =ms.Code
where CreateDate = '${EndDay}' and OrderStatus <> '作废'
	and PayTime >= date_add('${EndDay}',interval -20 day)
	and PayTime < date_add('${EndDay}',interval -10 day)
group by Department

)

-- 停产状态未发货订单数 (截至统计期未发货且订单包含停产产品的订单数)
-- , t_stop_sku_order as (
-- select department , count (1) from (
-- select PlatOrderNumber ,department
-- from import_data.daily_WeightOrders dwo
-- join (select BoxSku , ProjectTeam as department from import_data.wt_products wp -- 2=停产 0=正常 3=停售 4=暂时缺货 5=清仓
-- 	where ProductStatus = 2 ) wp 
-- 	on dwo.BoxSku = wp.BoxSku and dwo.CreateDate = current_date()
-- group by PlatOrderNumber ,department
-- ) tmp 
-- group by department
-- )

select *
from (
select t_key.dep ,`准时妥投率` , `准时发货率` ,`采购产品金额`,`采购运费`, `采购单数`,`日均采购单数`,`采购3天到货率` ,`平均采购收货天数`
	,`2天生包率` ,`订单5天发货率` ,`订单7天发货率` ,`24小时发货率`,`24小时收货率`,`本地仓库存资金占用`, `库存周转天数`
	,`在仓sku件数`,`在仓sku数` ,`在途产品采购金额`, `在途产品采购运费` , `在仓产品金额` ,`作废订单率` ,`日均订单数`,`10天未发订单数`
from t_key
left join ontimesend on t_key.dep = ontimesend.department
left join OnTimeDeliveryRate on t_key.dep = OnTimeDeliveryRate.department
left join purchase on t_key.dep = purchase.department
left join purchase2warehouse on t_key.dep = purchase2warehouse.department
left join avg_purchase2warehouse_time on t_key.dep = avg_purchase2warehouse_time.department
left join ordersend on t_key.dep = ordersend.department
left join sendIn24h on t_key.dep = sendIn24h.department
left join receiveIn24h on t_key.dep = receiveIn24h.department
left join warehouse_stat on t_key.dep = warehouse_stat.department
left join OrderCancelRate on t_key.dep = OrderCancelRate.department
left join over10orders on t_key.dep = over10orders.department 
-- where t_key.department regexp '快'
-- where t_key.department regexp '特卖汇|TMH销售1组|TMH销售3组'
) tmp
order by dep desc

-- 呆滞库存占比 
-- 针对 InventoryAgeAmount180 + InventoryAgeAmount270 数据，判断可售天数
-- with tmp as (
-- select wi.boxsku
-- 	, SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver) `超过180天库存总数`
-- 	, a.salesvolun6month `近6个月销量`,a.daily180 `近180天日均销量`
-- 	, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver))/a.daily180,0) `可售天数` 
-- 	, round((SUM(wi.InventoryAgeOver))/a.daily180,0) `大于365天部分的可售天数` 
-- 	, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365))/a.daily180,0) `180到365的可售天数` 
-- from import_data.WarehouseInventory  wi
-- left join 
-- 	(select op.boxsku
-- 		,sum(op.SaleCount) salesvolun6month
-- 		,round(sum(op.SaleCount)/180,2) daily180 -- 180天日均销量
-- 	from import_data.OrderProfitSettle op
-- 	where op.SettlementTime>=date_add('2023-01-01',interval -5 month) and op.SettlementTime<'2023-02-01'
-- 	and op.ShipWarehouse='东莞仓' 
-- 	group by op.boxsku) a 
-- on wi.boxsku=a.boxsku
-- where  wi.ReportType='月报' and wi.monday='2023-01-01' 
-- group by wi.boxsku,a.salesvolun6month,a.daily180 having `超过180天库存总数`>0
-- ) 
-- 
-- , daizhi as (  -- 呆滞库存
-- select 
-- 	sum(case 
-- 		when InventoryAgeOver>0 then InventoryAgeOver 
-- 		when InventoryAge270*InventoryAge365 > 0 and `可售天数` > 365 then (InventoryAge270+InventoryAge365)
-- 		when InventoryAge270*InventoryAge365 > 0 and `可售天数` > 180 and `可售天数` <=365  then (InventoryAge270+InventoryAge365)*0.5
-- 	end) `呆滞库存`
-- from import_data.WarehouseInventory wi 
-- left join tmp on wi.BoxSku = tmp.BoxSku
-- where wi.ReportType='月报' and wi.monday='2023-01-01' 
-- ) 
-- 
-- , lw as (
-- select (`采购产品金额`+`采购运费`+`在仓产品金额`) as `库存资金占用`
-- from
-- (
-- select sum(Price - DiscountedPrice) `采购产品金额` , sum(SkuFreight) `采购运费`
-- from (
-- 	select Price ,DiscountedPrice , SkuFreight
-- 	from wt_purchaseorder wp 
-- 	where ordertime  < '${NextStartDay}' and ordertime >= date_add('${NextStartDay}',interval -1 month) 
-- 		and isOnWay = "是"
-- 	) tmp
-- ) a 
-- , (
-- 	SELECT  sum(ifnull(TotalPrice,0)) `在仓产品金额`, sum(ifnull(TotalInventory,0)) `在仓sku件数`, count(*) `在仓sku数` 
-- 	FROM ( -- local_warehouse 本地仓表
-- 		select TotalPrice, TotalInventory
-- 		FROM import_data.WarehouseInventory wi
-- 		where WarehouseName = '东莞仓' and TotalInventory > 0
-- 			and Monday  < '${NextStartDay}' and Monday >= date_add('${NextStartDay}',interval -1 month) 
-- 		and ReportType = '月报'
-- 		)  tmp 
-- ) b 
-- )
-- 
-- select `呆滞库存`/`库存资金占用`  -- 0.02
-- from lw,daizhi 采购产品金额
-- 
-- 
--  	
-- select * 
-- from ods_orderdetails wo 
-- where IsDeleted = 0 and PayTime < '2023-01-31' and PayTime >= '2023-01-01' and ShipmentStatus = '未发货'
-- 	and TransactionType ="付款" and OrderStatus !='作废'