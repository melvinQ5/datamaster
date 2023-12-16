with 
week1_worker as (
select 
user_id 
, max_add_time 
--count(1)
from tmp.tmp_sms2_week1_worker -- worker_pack_332万名单_2022年7月1日-7月14日（最后活跃时间）
)


, week2_worker as (
select 
user_id
, max_add_time 
--count(1) 
from tmp.tmp_sms2_week2_worker -- worker_pack_40万名单_2021年6月2日-2022年1月1日（最后活跃时间）
)
--truncate table tmp.tmp_sms2_week2_worker


, week3_worker as (
select 
user_id
, max_add_time 
--count(1) 
from tmp.tmp_sms2_week3_worker --worker_pack_24万名单_2021-06-01之前（最后活跃时间）
)

, open_app as ( --近期有登录的用户
select user_id , add_time  from public.ods_member_login_log_formal
where add_time between extract ( epoch from  to_timestamp( '2022-07-26 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
        and extract ( epoch from to_timestamp('2022-07-31 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
--        and "source"  in ( 'ios' , 'android' )
) 

-- 登录
--------------------week1 332万 工友 登录
, user_106w as (
select 
--	count(1) as open_app_cnt_a  
	tmp1.user_id  
	, max_add_time
from week1_worker ww
join
	(
	select user_id 
	from open_app
	where add_time between extract ( epoch from  to_timestamp( '2022-07-28 ' || '08:10:00', 'YYYY-MM-DD HH24:MI:SS')) 
	and extract ( epoch from to_timestamp('2022-07-31 '||'11:00:00', 'YYYY-MM-DD HH24:MI:SS'))
	group by user_id
	)  tmp1 
        on ww.user_id =tmp1.user_id
)
--------------------week2 40万 工友 登录

, user_2k as (
select 
	user_id 
	, max_add_time 
from week2_worker ww
join
        (select user_id 
        from open_app
        where add_time between extract ( epoch from  to_timestamp( '2022-07-27 ' || '08:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
        and extract ( epoch from to_timestamp('2022-07-28 '||'09:14:00', 'YYYY-MM-DD HH24:MI:SS'))
    group by user_id
        )  tmp1 
        on ww.user_id =tmp1.user_id
)

--------------------week3 24万 工友 登录

, user_7b as (
select 
	user_id
	, max_add_time 
	, '24万工友'
from week3_worker ww
join
        (select user_id 
        from open_app
        where add_time between extract ( epoch from  to_timestamp( '2022-07-26 ' || '08:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
        and extract ( epoch from to_timestamp('2022-07-27 '||'13:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    group by user_id
        )  tmp1 
        on ww.user_id =tmp1.user_id
)


--剩余积分
--历史查看招工次数
--充值次数/金额
--最后一次登录时间（精确至天即可）
--刷新找活名片次数
--加急/置顶找活名片次数
--工种
--有无名片
--累计消耗积分数

select 
	user_id
	, max_add_time
	, summary 
	, integral
from public.ods_member om
left join user_106w on om.id = user_106w.user_id
left join user_2k on om.id = user_2k.user_id 
left join user_7b on om.id = user_7b.user_id
where user_106w is not null 
	or user_2k is not null 
	or user_7b is not null 
	
	












