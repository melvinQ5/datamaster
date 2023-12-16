-- ÿ��user_id ��¼�������й�����Ҫÿ���û���Ч��ͳ�Ƶ� ��ֹʱ���

with sms_user as (
select
        user_id_tail
        , user_id
        , summary 
        , case 
--                when user_id_tail = 0 and summary='�����ϰ�' then '2022-08-01 08:00:00'
--                when user_id_tail = 1 and summary='�����ϰ�' then '2022-08-02 08:00:00'
--                when user_id_tail = 2 and summary='�����ϰ�' then '2022-08-03 09:00:00'
--                when user_id_tail = 3 and summary='�����ϰ�' then '2022-08-04 09:10:00'
                when user_id_tail = 4 and summary='�����ϰ�' then '2022-08-05 08:00:00'
--                when user_id_tail = 5 and summary='�����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 6 and summary='�����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 7 and summary='�����ϰ�' then '2022-08-02 08:00:00'
--                when user_id_tail = 8 and summary='�����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 9 and summary='�����ϰ�' then '2022-08-0 ::'

--                when user_id_tail = 0 and summary='�ǹ����ϰ�' then '2022-08-01 08:00:00'
--                when user_id_tail = 1 and summary='�ǹ����ϰ�' then '2022-08-02 08:00:00'
--                when user_id_tail = 2 and summary='�ǹ����ϰ�' then '2022-08-03 08:00:00'
--                when user_id_tail = 3 and summary='�ǹ����ϰ�' then '2022-08-04 08:00:00'
                when user_id_tail = 4 and summary='�ǹ����ϰ�' then '2022-08-05 08:00:00'
--                when user_id_tail = 5 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 6 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 7 and summary='�ǹ����ϰ�' then '2022-08-02 08:00:00'
--                when user_id_tail = 8 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 9 and summary='�ǹ����ϰ�' then '2022-08-0 ::'

        end as start_time --ͳ�ƿ�ʼ����������ʱ�䣩
        , case
--                when user_id_tail = 0 and summary='�����ϰ�' then '2022-08-02 10:00:00'
--                when user_id_tail = 1 and summary='�����ϰ�' then '2022-08-03 10:05:00'
--                when user_id_tail = 2 and summary='�����ϰ�' then '2022-08-04 09:08:00'
--                when user_id_tail = 3 and summary='�����ϰ�' then '2022-08-05 09:18:00'
                when user_id_tail = 4 and summary='�����ϰ�' then '2022-08-06 09:12:00'
--                when user_id_tail = 5 and summary='�����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 7 and summary='�����ϰ�' then '2022-08-03 10:05:00'
--                when user_id_tail = 6 and summary='�����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 8 and summary='�����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 9 and summary='�����ϰ�' then '2022-08-0 ::'
                
--                when user_id_tail = 0 and summary='�ǹ����ϰ�' then '2022-08-02 10:07:00'
--                when user_id_tail = 1 and summary='�ǹ����ϰ�' then '2022-08-03 10:05:00'
--                when user_id_tail = 2 and summary='�ǹ����ϰ�' then '2022-08-04 09:00:00'
--                when user_id_tail = 3 and summary='�ǹ����ϰ�' then '2022-08-05 09:01:00'
                when user_id_tail = 4 and summary='�ǹ����ϰ�' then '2022-08-06 09:01:00'
--                when user_id_tail = 5 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 6 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 7 and summary='�ǹ����ϰ�' then '2022-08-03 10:05:00'
--                when user_id_tail = 8 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
--                when user_id_tail = 9 and summary='�ǹ����ϰ�' then '2022-08-0 ::'
                
        end as end_time --ͳ�ƽ�����ĩ������ʱ��+24Сʱ��
from tmp.tmp_rfm_user_lhy 
)

, open_app as ( --�����е�¼���û�
select user_id , add_time  from public.ods_member_login_log_formal
where add_time between extract ( epoch from  to_timestamp( '2022-08-01 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
        and extract ( epoch from to_timestamp('2022-08-10 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
--        and "source"  in ( 'ios' , 'android' )
)

, issue_info as ( --�����з���
select user_id , add_time , id as job_id  from public.ods_gczdw 
where add_time between extract ( epoch from  to_timestamp( '2022-08-01 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
        and extract ( epoch from to_timestamp('2022-08-10 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
        and is_check = 2
        and user_id > 0
)


-- ��������
--select  user_id_tail
--        , summary
--        , count(1)
--from tmp.tmp_rfm_user_lhy 
--group by user_id_tail
--        , summary 
--order by summary
--        , user_id_tail 

-- ��¼����
--select 
--        user_id_tail
--        , summary
--        , count(1)
--from 
--        (
--        select
--                user_id_tail
--                , summary
--                , oa.user_id
--        from open_app oa 
--        join sms_user su on oa.user_id = su.user_id  
--        where add_time between extract ( epoch from to_timestamp(start_time, 'YYYY-MM-DD HH24:MI:SS'))
--                                and extract ( epoch from to_timestamp(end_time, 'YYYY-MM-DD HH24:MI:SS'))
--        group by 
--                user_id_tail
--                , summary 
--                , oa.user_id 
--        ) tmp1
--group by 
--        user_id_tail
--        , summary 
--order by summary
--        , user_id_tail  

-- ��������
select 
    user_id_tail
        , summary 
        , count(distinct tmp1.user_id) as issue_users_a  
    , count(job_id) as issue_cnt_a
from 
    (select ii.user_id , job_id , user_id_tail , summary 
    from issue_info ii
        join sms_user su on ii.user_id = su.user_id  
                where add_time between extract ( epoch from to_timestamp(start_time, 'YYYY-MM-DD HH24:MI:SS'))
                                        and extract ( epoch from to_timestamp(end_time, 'YYYY-MM-DD HH24:MI:SS'))
        group by user_id_tail , ii.user_id , job_id , summary
    )  tmp1 
group by 
        user_id_tail
        , summary
order by summary
        , user_id_tail  
           