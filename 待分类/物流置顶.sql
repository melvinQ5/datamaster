--select *
--from public.ods_top_information oti 
--join tmp.tmp_wlzq_info_lhy twil on oti.information_id = twil.job_id 
--

--
with top_info as 
(
select 
	oti.id as top_id
	,date(to_timestamp(oti."time")) as top_day
	,oti."time" as top_time
	,information_id
	,oti.user_id 
--	,to_char(to_timestamp(om."time"),'YYYY-MM-DD HH24:MI:SS') as reg_time
    ,oti.expend_integral 
--	,case 
--		when top_province_ids != '' and top_city_ids != '' then '置顶省和市'
--		when top_province_ids != '' then '置顶省'
--		when top_city_ids != '' then '置顶市'
--	  end as top_scope
from public.ods_top_information oti 
join 
	( 
	select * from tmp.tmp_wlzq_info_lhy 
	where is_just_logistic = 1 
	) ajtu on oti.information_id = ajtu.job_id 
left join public.ods_member om on oti.user_id = om.id 
where oti."time" between extract(epoch from to_timestamp('2022-05-01'||' 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
	and extract(epoch from to_timestamp('2022-07-28'||' 23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
)

, ckzg as 
(
select 
	target_id
	,oec.expense_integral
	,"time" as ck_time
from public.ods_expense_calendar oec
where oec.expense_type in (1,13)
)

select 
	top_day as 置顶日期
	,sum(case when top_time + 3600 * 1 >= ck_time then 1 else 0 end) as 被查看数
	,sum(case when top_time + 3600 * 1 >= ck_time then expense_integral else 0 end) as 查看消耗金额
    , sum(expend_integral) as 置顶消耗金额 
from top_info
left join ckzg on top_info.information_id = ckzg.target_id
group by top_day
order by top_day desc 
