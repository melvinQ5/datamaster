-- ����ҵ�һ�ݹ���

with 
charge_user as ( --һ����ǰ��ֵ���û��Ĺ��� ����ʷ�������һ���Ƭ��鿴���й���Ϣ�ģ�
select op.user_id 
from public.ods_pay op
join (select * from portrait.ads_resume_tag_ultimate artu where respub_class = 'ֱ��' and gz0_agg = '����������') wlzqu
--join ( select * from tmp.tmp_wlzq_user_lhy where is_issue_resume = 1  ) wlzqu
        on op.user_id = wlzqu.user_id
where status = 2 and paymoney > 0

and pay_time between extract( epoch from  to_timestamp( '2022-06-25 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
                and extract( epoch from  to_timestamp( '2022-06-25 ' || '23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
group by op.user_id 
)

, user_inte as ( -- ��ǰʣ�����x��
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

-- ��ͬʣ����ֵ������ֲ�
--select integral , count(1) cnt  from pre_user_pack
--group by integral order by integral 

-- X����δ��¼
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


, pre_user_pack_2 as ( --һ����ǰ��ֵ �ҵ�ǰʣ��x���� �ҽ�x��δ��¼
select ui.user_id , ui.integral , max_login_time
from pre_user_pack ui 
join lost_user lu on ui.user_id = lu.user_id 
)
--select  count(1) from pre_user_pack_2 


-- ���һ�β鿴�������
select 
		avg(gap) as R_avg 
		, percentile_cont(0.5) within group (order by gap) as R50 
		, percentile_cont(0.75) within group (order by gap) as R75
        , percentile_cont(0.25) within group (order by gap) as R25
        
        
from
( select  date(to_timestamp( max_login_time)) -date('2022-06-25')   as gap  from pre_user_pack_2 ) tmp1






-- ��ͬʣ����ֵ������ֲ�
--select integral , count(1) cnt  from user_pack
--where max_getnumb_time < extract( epoch from  to_timestamp( '2022-07-21 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
--group by integral order by integral 

--select count(1) as cnt from user_pack 
