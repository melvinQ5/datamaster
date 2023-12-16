with 
-- step1 数据源处理 
t_mysql_store as (  -- 组织架构临时改变前
select 
	Code 
	,case when NodePathName regexp '泉州' then '快百货二部' 
		when NodePathName regexp '成都' then '快百货一部'  else department 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store
)

 -- 明细
select  OnLineHour , PackageNumber ,lt.*
-- select count(distinct PackageNumber)
from erp_logistic_logistics_tracking lt
join t_mysql_store ms on lt.ShopCode =ms.Code 
where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
-- 	and !(OnLineHour < 72)
-- 	and (OnLineHour is null or OnlineTime = '')
	
	
-- -- 统计
-- select CASE WHEN department IS NULL THEN '公司' ELSE department END AS dep
-- 	,round(count(distinct case when OnLineHour <= 72 then PackageNumber end )/count(distinct PackageNumber),4) `物流3天上网率`
-- from erp_logistic_logistics_tracking lt
-- 		join t_mysql_store ms on lt.ShopCode =ms.Code 
-- 		where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
-- group by grouping sets ((),(department))