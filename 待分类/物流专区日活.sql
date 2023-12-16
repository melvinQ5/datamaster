
-- 物流专区日活
select 
	date(to_timestamp( evt_time)) evt_date 
	, count( distinct dul.user_id ) 
	, count(case when is_issue_resume = 1 then 1 end ) as "发布找活人数"
	, count(case when is_issue_info = 1 then 1 end ) as "发布招工人数"
	, count(case when get_resume_numb = 1 then 1 end ) as "查看找活人数"
	, count(case when get_info_numb = 1 then 1 end ) as "查看招工人数"
	, count(distinct case when  
		is_issue_resume is null  
		and get_info_numb is null  
		and (is_issue_info = 1 or get_resume_numb = 1) 
		then dul.user_id end ) as "纯老板用户日活"
	, count(distinct case when 
		(is_issue_resume = 1 
		or get_info_numb = 1 ) 
		and is_issue_info is null  
		and get_resume_numb is null  
		then dul.user_id end ) as "纯工友日活"
from public.dwd_user_login dul 
join 
	( select * from tmp.tmp_wlzq_user_lhy where is_logistic = 1 ) wlzqu
	on dul.user_id = wlzqu.user_id
left join public.ods_member om on om.id =dul.user_id 
where evt_time between extract ( epoch from  to_timestamp( '2022-01-01 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
	and extract ( epoch from to_timestamp('2022-07-29 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
--	and  om.source ='android' or om."source" ='ios'
group by evt_date
order by evt_date desc 

 
