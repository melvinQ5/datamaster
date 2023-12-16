
with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)


, t_new_purc as ( -- 当期采购
select 
	wp.BoxSku ,OrderNumber ,ordertime ,WarehouseName ,Price ,SkuFreight ,DiscountedPrice ,Quantity
	,instockquantity ,CompleteTime ,IsComplete ,scantime
	,wpt.projectteam as department ,wpt.IsDeleted as wpt_isdeleted
from import_data.wt_purchaseorder wp 
join ( select BoxSku ,projectteam ,IsDeleted from wt_products ) wpt on wp.BoxSku = wpt.BoxSku
where ordertime  <  '${NextStartDay}'  and ordertime >= date_add('${StartDay}',interval -10 day) -- 多获取10天数据，以便计算各种指标
	and WarehouseName = '东莞仓' 
)

-- step2 派生指标 = 统计期+叠加维度+原子指标
-- 采购单数 采购金额 采购运费 (CNY)
, t_purc_amount as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,round(sum(Price - DiscountedPrice)) `采购产品金额` 
	,round(sum(SkuFreight)) `采购运费`	
	,count(distinct OrderNumber) `采购单数`
	,round(count(distinct OrderNumber)/datediff('${NextStartDay}','${StartDay}')) `日均采购单数`
from t_new_purc 
-- where wpt_isdeleted = 0 -- 有少量boxsku在产品库已删除，同时有采购记录
group by grouping sets ((),(department))
) 

-- 零散采购
, t_scattered_purc as ( 
select case when department IS NULL THEN '公司' ELSE department END AS dep
	, count(distinct case when total_qy <3 then OrderNumber end) `零散采购单数`
from 
	( select department ,OrderNumber
		, sum(Quantity) as total_qy -- 单笔订单采购件数
	from t_new_purc
	where ordertime >= '${StartDay}' and ordertime < '${NextStartDay}' 
	group by department ,OrderNumber
	) temp 
where total_qy < 3
group by grouping sets ((),(department))
)

-- 采购N天到货率
, t_ontime_rev as (
select 
	case when department IS NULL THEN '公司' ELSE department END AS dep
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from (
	select 
		OrderNumber ,BoxSku ,department
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
		end as in5days_rev_numb -- 满足5天到货的下单号
		, case when instockquantity = 0 and IsComplete = '是' then null else OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
	from t_new_purc
	where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day) 
	) tmp 
group by grouping sets ((),(department))
)

-- 采购平均到货天数
, t_avg_rev_days as (
select case when department IS NULL THEN '公司' ELSE department END AS dep
	, round(avg(rev_days),1) `平均采购收货天数`
from (
	select 
		OrderNumber ,wp.BoxSku ,projectteam as department
		,timestampdiff(second, ordertime, CompleteTime)/86400  as rev_days
	from import_data.wt_purchaseorder wp 
	join ( select BoxSku ,projectteam from wt_products ) wpt on wp.BoxSku = wpt.BoxSku
	where  CompleteTime < '${NextStartDay}' and CompleteTime >= '${StartDay}'
	) tmp 
group by grouping sets ((),(department))
)	

-- step3 派生指标数据集
, t_merge as (
select t_key.dep `团队` 
 	,`采购产品金额`
 	,`采购运费`
 	,`采购单数`
 	,`日均采购单数`
 	,`采购5天到货率` 
 	,`平均采购收货天数`
 	,`零散采购单数`
--  	,`申请缺货SKU数`
--  	,`申请缺货未发订单数`
from t_key
left join t_purc_amount on t_key.dep = t_purc_amount.dep
left join t_ontime_rev on t_key.dep = t_ontime_rev.dep
left join t_avg_rev_days on t_key.dep = t_avg_rev_days.dep
left join t_scattered_purc on t_key.dep = t_scattered_purc.dep
)


-- step4 复合指标 = 派生指标叠加计算
select 
	'${NextStartDay}' `统计日期`
	,t_merge.*
	,round(`零散采购单数`/`采购单数`,4) `零散采购占比` 
from t_merge
order by `团队` desc 







