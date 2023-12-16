-- 多久找到一份工作

with 
charge_user as ( --一个月前充值的用户的工友 （历史发布过找活名片或查看过招工信息的）
select op.user_id 
from public.ods_pay op
join (select * from portrait.ads_resume_tag_ultimate artu where respub_class = '直发' and gz0_agg = '物流运输类') wlzqu
--join ( select * from tmp.tmp_wlzq_user_lhy where is_issue_resume = 1  ) wlzqu
        on op.user_id = wlzqu.user_id
where status = 2 and paymoney > 0

and pay_time between extract( epoch from  to_timestamp( '2022-06-25 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
                and extract( epoch from  to_timestamp( '2022-06-25 ' || '23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
group by op.user_id 
)

, user_inte as ( -- 当前剩余积分x的
select 
        id as user_id , integral  
--        count(1)
from public.ods_member om 
--where  integral >= 10
where  integral >= 2 and  integral <= 15
--where  integral >15
--        time between extract( epoch from  to_timestamp( '2022-06-25 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
--                and extract( epoch from  to_timestamp( '2022-07-26 ' || '23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
)

, pre_user_pack as ( 
select ui.user_id ,ui.integral
from user_inte ui 
join charge_user cu on ui.user_id = cu.user_id 
)


--select  count(1) from pre_user_pack 

-- 不同剩余积分的人数分布
--select integral , count(1) cnt  from pre_user_pack
--group by integral order by integral 

-- X天内未登录
, lost_user as (
select user_id , max_login_time 
from 
        (
        select user_id , max( evt_time ) as max_login_time 
        from public.dwd_user_login dul 
        group by user_id 
        ) tmp1 
where max_login_time < extract( epoch from  to_timestamp( '2022-07-21 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
)


--select  count(1) from charge_user 


, pre_user_pack_2 as ( --一个月前充值 且当前剩余x积分 且近x天未登录
select ui.user_id , ui.integral , max_login_time
from pre_user_pack ui 
join lost_user lu on ui.user_id = lu.user_id 
)
--select  count(1) from pre_user_pack_2 


-- 最后一次查看距今天数
select 
		avg(gap) as R_avg 
		, percentile_cont(0.5) within group (order by gap) as R50 
		, percentile_cont(0.75) within group (order by gap) as R75
        , percentile_cont(0.25) within group (order by gap) as R25
        
        
from
( select  date(to_timestamp( max_login_time)) -date('2022-06-25')   as gap  from pre_user_pack_2 ) tmp1






-- 不同剩余积分的人数分布
--select integral , count(1) cnt  from user_pack
--where max_getnumb_time < extract( epoch from  to_timestamp( '2022-07-21 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
--group by integral order by integral 

--select count(1) as cnt from user_pack 
