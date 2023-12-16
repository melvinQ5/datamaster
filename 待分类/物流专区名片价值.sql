--物流专区用户的名片
select  
        getnumb_date
        , count(case when is_logistic = 1 then 1 end ) as times_wl 
        , count(distinct case when is_logistic = 1 then  tmp2.user_id end ) as users_wl 
        , count(case when is_logistic = 0 then 1 end ) as times_others 
        , count(distinct case when is_logistic = 0 then  tmp2.user_id end ) as users_others 
from 
        (
                select *  
                from 
                (
                select 
                        user_id --查看人
                        , target_id 
                        , date(to_timestamp( time )) as getnumb_date 
--                        , row_number()over(partition by user_id order by time desc ) as sort 
                from public.ods_expense_calendar oec 
                where time between extract ( epoch from to_timestamp('2022-05-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
                        and extract ( epoch from to_timestamp('2022-07-26 23:59:59','YYYY-MM-DD HH24:MI:SS'))
                        and expense_type in ( 2 , 14 )
                ) tmp1
--                where sort = 1 --取最后一条
        ) tmp2 
        join ( 
        	select resume_id , is_logistic 
        	from tmp.tmp_wlzq_resume_lhy
        	where jobgz2_agg in ( '物流货运司机','搬运工/装卸工','押运员','快递分拣/快递员' ) 
        
        ) twrl  
        	on tmp2.target_id = twrl.resume_id 
group by getnumb_date 
order by getnumb_date desc 

-- 只含物流4个工种的名片被查看次数
select  
        getnumb_date
        , count( 1  ) as times_wl 
        , count(distinct tmp2.user_id ) as users_wl 
from 
        (
                select *  
                from 
                (
                select 
                        user_id --查看人
                        , target_id 
                        , date(to_timestamp( time )) as getnumb_date 
--                        , row_number()over(partition by user_id order by time desc ) as sort 
                from public.ods_expense_calendar oec 
                where time between extract ( epoch from to_timestamp('2022-05-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
                        and extract ( epoch from to_timestamp('2022-07-26 23:59:59','YYYY-MM-DD HH24:MI:SS'))
                        and expense_type in ( 2 , 14 )
                ) tmp1
--                where sort = 1 --取最后一条
        ) tmp2 
        join ( 
        	select resume_id , is_logistic 
        	from tmp.tmp_wlzq_resume_lhy
        	where jobgz2_agg in ( '物流货运司机','搬运工/装卸工','押运员','快递分拣/快递员' ) 
        
        ) twrl  
        	on tmp2.target_id = twrl.resume_id 
group by getnumb_date 
order by getnumb_date desc 




--工程类名片
select  
        getnumb_date
        , count( 1  ) as times_wl 
        , count(distinct tmp2.user_id ) as users_wl 
from 
        (
                select *  
                from 
                (
                select 
                        user_id --查看人
                        , target_id 
                        , date(to_timestamp( time )) as getnumb_date 
--                        , row_number()over(partition by user_id order by time desc ) as sort 
                from public.ods_expense_calendar oec 
                where time between extract ( epoch from to_timestamp('2022-05-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
                        and extract ( epoch from to_timestamp('2022-07-26 23:59:59','YYYY-MM-DD HH24:MI:SS'))
                        and expense_type in ( 2 , 14 )
                ) tmp1
--                where sort = 1 --取最后一条
        ) tmp2 
        join ( select resume_id from portrait.ads_resume_tag_ultimate artu where gz0_agg = '工程类') twrl  
        	on tmp2.target_id = twrl.resume_id 
group by getnumb_date 
order by getnumb_date desc 



-- 物流货运司机
select  
        jobgz2_agg
        , count(1) as times 
        , count(distinct tmp2.user_id) as users 
from 
        (
                select *  
                from 
                (
                select 
                        user_id 
                        , target_id 
                        , date(to_timestamp( time )) as getnumb_date 
--                        , row_number()over(partition by user_id order by time desc ) as sort 
                from public.ods_expense_calendar oec 
                where time between extract ( epoch from to_timestamp('2022-06-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
                        and extract ( epoch from to_timestamp('2022-06-30 23:59:59','YYYY-MM-DD HH24:MI:SS'))
                        and expense_type in ( 1,13 )
                ) tmp1
--                where sort = 1 --取最后一条
        ) tmp2 
        join portrait.ads_job_tag_ultimate ajtu on tmp2.target_id = ajtu.job_id 
        where jobgz2_agg in ('物流货运司机','搬运工/装卸工', '押运员','快递分拣/快递员')
group by jobgz2_agg



-- 每天查看包含物流工种信息的用户
with user_pack as (
select 
        case when 
                jobgz2_agg like '物流货运司机' 
                or jobgz2_agg like '搬运工/装卸工'
                or jobgz2_agg like '押运员'
                or jobgz2_agg like '快递分拣/快递员'
                then '物流专区' else '非物流专区' end as jobgz_type1
        , case 
                when jobgz2_agg like '物流货运司机' then '物流货运司机'
                when jobgz2_agg like '搬运工/装卸工' then '搬运工/装卸工'
                when jobgz2_agg like '押运员' then '押运员'
                when jobgz2_agg like '快递分拣/快递员' then '快递分拣/快递员'
                 else '非物流专区' end as jobgz_type2
                , tmp2.*
                , ajtu.jobgz2_agg 
from 
(
    select *  
    from 
    (
            select 
                    user_id --查看人
                    , target_id 
                    , date(to_timestamp( time )) as getnumb_date 
            from public.ods_expense_calendar oec 
            where time between extract ( epoch from to_timestamp('2022-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
                    and extract ( epoch from to_timestamp('2022-07-24 23:59:59','YYYY-MM-DD HH24:MI:SS'))
                    and expense_type in ( 1,13 )
    ) tmp1
) tmp2 
join portrait.ads_job_tag_ultimate ajtu on tmp2.target_id = ajtu.job_id 
)

select  
        getnumb_date
        , jobgz_type1
        , jobgz_type2
        , count(1) as times 
        , count(distinct user_id) as users 
        , count(1)::numeric  / count(distinct user_id) as per_getnumb
from user_pack
group by getnumb_date , jobgz_type1 , jobgz_type2 
