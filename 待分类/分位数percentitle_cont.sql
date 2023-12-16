-- 最近一周（天）用户发布的招工信息到首条曝光的时间

with res as (
	select zhaogong_id , (min_exposure_time - issue_time)::int8 as expos_interval 
	from  
	(
		select dzecd.zhaogong_id , ajtu.issue_time , min(dzecd.create_time) min_exposure_time
		from 
			(
			select job_id , issue_time from portrait.ads_job_tag_ultimate ajtu 
			where 
--				issue_time between extract ( epoch from  to_timestamp( '2022-07-14 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
--		     		and extract ( epoch from to_timestamp('2022-07-20 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
		     	issue_time between extract ( epoch from  to_timestamp( '2022-07-07 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
		     		and extract ( epoch from to_timestamp('2022-07-13 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))   
--		     	issue_time between extract ( epoch from  to_timestamp( '2022-07-01 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
--		     		and extract ( epoch from to_timestamp('2022-07-06 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
		     	and ajtu.jobgz0_agg like '%工程类%' and is_check = 2
			) ajtu --审核过的 工程类信息
		join 
			(
			select	zhaogong_id , create_time  
			from bigdata.dwd_zhaogong_exposure_click_di
--			where pt between  '20220714' and '20220720'
			where pt between  '20220707' and '20220713'
--			where pt between  '20220701' and '20220706'
				and action = 'view'
		--	limit 10
			) dzecd --曝光事实表
		on ajtu.job_id = dzecd.zhaogong_id 
		group by dzecd.zhaogong_id , ajtu.issue_time 
	) tmp1
)
--select max(expos_interval) from res 
select 
	avg(expos_interval) as avg_expos_interval
	, percentile_cont(0.25) within group (order by expos_interval) as perc25_expos_interval
	, percentile_cont(0.5) within group (order by expos_interval)  as media_expos_interval
	, percentile_cont(0.75) within group (order by expos_interval) as perc75_expos_interval
	, percentile_cont(0.95) within group (order by expos_interval) as perc95_expos_interval
	, percentile_cont(1) within group (order by expos_interval) as perc100_expos_interval
from res 

--, t_sort as (
--select *, row_number()over(order by expos_interval) as sort 
--from res 
--)  
--
--select avg_expos_interval , median_expos_interval
--from 
--(
--select 
--	avg(expos_interval) as avg_expos_interval
----	, percentile_cont(0.5) within group (order by expos_interval) as media_expos_interval
--from res 
--) res1
--join 
--(
--select expos_interval as median_expos_interval
--from t_sort 
--where sort = (select max(sort)/2 from t_sort)
--) res2 on 1=1

