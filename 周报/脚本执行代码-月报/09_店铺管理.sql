
-- 超标店铺数 统计表
with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union select '商厨汇' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)


,t_mysql_store as (  -- 组织架构临时改变前
select 
	Code 
	,case when NodePathName regexp '泉州' then '快百货二部' 
		when NodePathName regexp '成都' then '快百货一部'  else department 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from mysql_store
)

, t_normal_shop as ( 
select CASE WHEN department IS NULL THEN '公司' ELSE department END AS dep 
	, count( case when ShopStatus='正常' then code end ) `正常店铺数` 
	, count( case when ShopStatus='异常' then code end ) `异常店铺数` 
	, count( case when ShopStatus='弃用' then code end ) `弃用店铺数` 
	, count( case when ShopStatus='休假中' then code end ) `休假中店铺数` 
	, count( case when ShopStatus='关闭' then code end ) `关闭店铺数` 
from  t_mysql_store
group by grouping sets ((),(department))
union 
select '快百货' as department 
	, count( case when ShopStatus='正常' then code end ) `正常店铺数` 
	, count( case when ShopStatus='异常' then code end ) `异常店铺数` 
	, count( case when ShopStatus='弃用' then code end ) `弃用店铺数` 
	, count( case when ShopStatus='休假中' then code end ) `休假中店铺数` 
	, count( case when ShopStatus='关闭' then code end ) `关闭店铺数` 
from t_mysql_store
where department regexp '快' 
union
select NodePathName 
	, count( case when ShopStatus='正常' then code end ) `正常店铺数` 
	, count( case when ShopStatus='异常' then code end ) `异常店铺数` 
	, count( case when ShopStatus='弃用' then code end ) `弃用店铺数` 
	, count( case when ShopStatus='休假中' then code end ) `休假中店铺数` 
	, count( case when ShopStatus='关闭' then code end ) `关闭店铺数` 
from t_mysql_store where department regexp '快' 
group by NodePathName 
) 

,BadShop as (
select  CASE WHEN department IS NULL THEN '公司' ELSE department END AS dep  
	,count(distinct case when '${NextStartDay}' >= '2023-02-01' and monitor <> '未超标' then shopcode end ) `任一超标店铺数`
from 
(
select 
	case when  LateShipmentRate/100 > 0.03 then '迟发率超3%'
		when OrderWithDefectsRate/100 > 0.008 then '订单缺陷率超0.8%'
		when PreFulfillmentCancellationRate/100 > 0.02 then '取消率超2%'
		when ValidTrackingRate/100 < 0.96 and  ValidTrackingRate/100 > 0 then '有效追踪率低于96%'
		else '未超标'
	end as monitor
	, eaaspcd.shopcode 
	, eaaspcd.LateShipmentRate ,OrderWithDefectsRate ,PreFulfillmentCancellationRate ,ValidTrackingRate
	, department
from import_data.erp_amazon_amazon_shop_performance_check eaaspcd 
join t_mysql_store ms on eaaspcd.ShopCode =ms.Code 
where AmazonShopHealthStatus != 4 
		and CreationTime >=DATE_ADD('${NextStartDay}', interval -1 day)  and CreationTime < '${NextStartDay}'
	) tmp 
group by grouping sets ((),(department))
)

-- , email as ( -- 因塞盒邮件系统更新机制，暂无法获取邮件数据
-- select CASE WHEN ms.department  IS NULL THEN '公司' ELSE ms.department  END AS dep  
-- 	,round(count(1)/datediff('${NextStartDay}','${StartDay}'),0) `日均邮件数`
-- from import_data.daily_Email de 
-- join t_mysql_store ms on de.Src =ms.Code 
-- where CollectionTme  <  '${NextStartDay}'  and CollectionTme >= '${StartDay}'
-- group by grouping sets ((),(ms.department)) 
-- union 
-- SELECT split_part(NodePathNameFull,'>',2)
-- 	,round(count(1)/datediff('${NextStartDay}','${StartDay}'),0) `日均邮件数`from import_data.daily_Email de 
-- join t_mysql_store ms on de.Src =ms.Code 
-- where CollectionTme  <  '${NextStartDay}'  and CollectionTme >= '${StartDay}'
-- group by split_part(NodePathNameFull,'>',2)
-- union 
-- SELECT NodePathName
-- 	,round(count(1)/datediff('${NextStartDay}','${StartDay}'),0) `日均邮件数`from import_data.daily_Email de 
-- join t_mysql_store ms on de.Src =ms.Code 
-- where CollectionTme  <  '${NextStartDay}'  and CollectionTme >= '${StartDay}'
-- group by NodePathName
-- )

-- 紫鸟数据任务暂停
-- , spider_data as (
-- select CASE WHEN department  IS NULL THEN '公司' ELSE department  END AS dep  
-- 	,count(case when odr_over=1 then ShopCode end ) `ODR超标店铺数`
-- 	,count(case when vtr_over=1 then ShopCode end ) `VTR超标店铺数`
-- 	,count(case when lsr_over=1 then ShopCode end ) `LSR超标店铺数`
-- 	,count(case when cr_over=1 then ShopCode end ) `CR超标店铺数`
-- 	,count(case when ahr_over=1 then ShopCode end ) `AHR超标店铺数`
-- from (
-- 	select 
-- 		department ,shopcode
-- 		,case when ODR<>'不适用' and cast(replace(ODR,'%','') as float)>=0.8 then 1 end odr_over 
-- 		,case when TrackingRate<>'不适用' and cast(replace(TrackingRate,'%','') as float)<=0.96 then 1 end vtr_over  
-- 		,case when LaterDay10<>'不适用' and cast(replace(LaterDay10,'%','') as float)>=3 then 1 end lsr_over
-- 		,case when RateBeforeShipping<>'不适用' and cast(replace(RateBeforeShipping,'%','') as float)>=2 then 1 end cr_over 
-- 		,case when AccountHealth<>'不适用' and cast(replace(AccountHealth,'%','') as float)<=200 then 1 end ahr_over 
-- 	from import_data.ShopPerformance sp 
-- 	join t_mysql_store ms on sp.ShopCode = ms.Code and ms.ShopStatus ='正常'
-- 		and ReportType ='周报' and Monday ='${StartDay}'
-- 	) tmp
-- group by grouping sets ((),(department))
-- )

-- API数据
-- , spider_data as (
-- select  CASE WHEN department IS NULL THEN '公司' ELSE department END AS dep  
-- 	,count(distinct case when '${NextStartDay}' >= '2023-02-01' and monitor <> '未超标' then shopcode end ) `任一超标店铺数`
-- from 
-- (
-- select 
-- 	case when  LateShipmentRate/100 > 0.03 then '迟发率超3%'
-- 		when OrderWithDefectsRate/100 > 0.008 then '订单缺陷率超0.8%'
-- 		when PreFulfillmentCancellationRate/100 > 0.02 then '取消率超2%'
-- 		when ValidTrackingRate/100 < 0.96 and  ValidTrackingRate/100 > 0 then '有效追踪率低于96%'
-- 		else '未超标'
-- 	end as monitor
-- 	, eaaspcd.shopcode 
-- 	, eaaspcd.LateShipmentRate ,OrderWithDefectsRate ,PreFulfillmentCancellationRate ,ValidTrackingRate
-- 	, department
-- from import_data.erp_amazon_amazon_shop_performance_check eaaspcd 
-- join t_mysql_store ms on eaaspcd.ShopCode =ms.Code 
-- where AmazonShopHealthStatus != 4 
-- 		and CreationTime >=DATE_ADD('${NextStartDay}', interval -1 day)  and CreationTime < '${NextStartDay}'
-- ) tmp 
-- group by grouping sets ((),(department))
-- )

,OrderCancelRate as (
SELECT case when ms.department IS NULL THEN '公司' ELSE ms.department END AS dep 
	,round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber  end)/count(distinct PlatOrderNumber),4) as `作废订单率`
	,round(count(DISTINCT CASE when OrderStatus != '作废' and TransactionType ='付款' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `日均订单数`
from import_data.wt_orderdetails  wo  
join t_mysql_store ms on wo.ShopCode  =ms.Code and wo.IsDeleted = 0
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' 
group by grouping sets ((),(ms.department))
union 
SELECT '快百货' as department
	,round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `作废订单率`
	,round(count(DISTINCT CASE when OrderStatus != '作废' and TransactionType ='付款' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `日均订单数`
from import_data.wt_orderdetails  wo  
join t_mysql_store ms on wo.ShopCode  =ms.Code and wo.IsDeleted = 0 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and ms.department regexp '快'  
union 
SELECT NodePathName
	,round(count(DISTINCT CASE when OrderStatus = '作废' and memo not like '%客户取消%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `作废订单率`
	,round(count(DISTINCT CASE when OrderStatus != '作废' and TransactionType ='付款' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `日均订单数`
from import_data.wt_orderdetails  wo   
join t_mysql_store ms on wo.ShopCode  =ms.Code and wo.IsDeleted = 0 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and ms.department regexp '快' 
group by NodePathName
)

select 
	'${NextStartDay}' `统计日期`
	,t_key.dep `团队`
	,`正常店铺数`
	,`异常店铺数`
	,`休假中店铺数`
	,`关闭店铺数`
	,`弃用店铺数`
-- 	,`日均邮件数` 
	,`任一超标店铺数`
-- 	,`ODR超标店铺数`
-- 	,`VTR超标店铺数`
-- 	,`LSR超标店铺数`
-- 	,`CR超标店铺数`
-- 	,`AHR超标店铺数`
-- 	,`24小时邮件回复率`
-- 	,`超24小时回复店铺数`
-- 	,`超24小时回复邮件数`
-- 	,`询问物流邮件的订单数`
	,`作废订单率`
from t_key
-- left join email on t_key.dep = email.dep
left join BadShop on t_key.dep = BadShop.dep
left join t_normal_shop on t_key.dep = t_normal_shop.dep
-- left join spider_data on t_key.dep = spider_data.dep
left join OrderCancelRate on t_key.dep = OrderCancelRate.dep
order by `团队` desc

