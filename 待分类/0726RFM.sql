-- ��һ�� ʹ��ȫ�����Ž�� ��󷢲�ʱ��22���ڵ��û���Ϊ��������,ͨ������RFMֵ��ÿ20%��λ �Լ�ƽ����,ȷ�����ֱ�׼

--with 
--user_pack as ( --�Ӳ�����������ȡ��
--select 
--	user_id 
--	, max_pay_time as last_issue_add_time  --��󷢲�ʱ��
--from tmp.tmp_sms_week1_boss
--)
--
--, paied_numb as (
--select target_id , count(1) as view_count_n
--from public.ods_expense_calendar oec 
--where time < extract ( epoch from to_timestamp('2022-07-15 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
--	and expense_type in ( 1,13 )
--group by target_id
--)
--
--, index_info_in60days as ( 
--select 
--    og.user_id  
--    , count ( 1 ) as issue_in60days_cnt --F 
--    , sum( view_count_n ) as paied_numb_in60days_cnt --M
--from public.ods_gczdw og
--join user_pack up on og.user_id = up.user_id  
--join paied_numb pn on og.id = pn.target_id
--where add_time < extract ( epoch from to_timestamp('2022-07-15 00:00:00','YYYY-MM-DD HH24:MI:SS')) 
--group by og.user_id 
--)
--
--, rfm_mark as (
--select 
--        up.user_id 
--        , current_date as query_date 
--        , date('2022-07-15') - date( up.last_issue_add_time ) as R_lastTimes2Yestoday
--        , iii.issue_in60days_cnt as F_issue_inXdays_cnt
--        , iii.paied_numb_in60days_cnt as M_paied_numb_inXdays_cnt
--from user_pack up 
--left join index_info_in60days iii on up.user_id = iii.user_id  
--)
----
----
---------- ���λ��
------select min(R_lastTimes2Yestoday) from rfm_mark
----
----select 
----	percentile_cont(0.2) within group (order by R_lastTimes2Yestoday) as R5_4
----	, percentile_cont(0.4) within group (order by R_lastTimes2Yestoday) as R4_3
----	, percentile_cont(0.6) within group (order by R_lastTimes2Yestoday) as R3_2
----	, percentile_cont(0.8) within group (order by R_lastTimes2Yestoday) as R2_1
----
----	
----	, percentile_cont(0.2) within group (order by F_issue_inXdays_cnt) as F1_2
----	, percentile_cont(0.4) within group (order by F_issue_inXdays_cnt) as F2_3
----	, percentile_cont(0.6) within group (order by F_issue_inXdays_cnt) as F3_4
----	, percentile_cont(0.8) within group (order by F_issue_inXdays_cnt) as F4_5
----
----	
----	, percentile_cont(0.2) within group (order by M_paied_numb_inXdays_cnt) as M1_2
----	, percentile_cont(0.4) within group (order by M_paied_numb_inXdays_cnt) as M2_3
----	, percentile_cont(0.6) within group (order by M_paied_numb_inXdays_cnt) as M3_3
----	, percentile_cont(0.8) within group (order by M_paied_numb_inXdays_cnt) as M4_5
----from rfm_mark
--
--
--, rfm_bins as ( -- ����һ����ÿ20%��λֵ�ó�
--select 
--        *
--        , case 
--                        when R_lastTimes2Yestoday >=1  and R_lastTimes2Yestoday <=17 then 5
--                        when R_lastTimes2Yestoday >=18  and R_lastTimes2Yestoday <=42 then 4
--                        when R_lastTimes2Yestoday >=43  and R_lastTimes2Yestoday <=79 then 3
--                        when R_lastTimes2Yestoday >=80  and R_lastTimes2Yestoday <=128 then 2
--                        when R_lastTimes2Yestoday >=129  then 1
--                end as R_lastTimes2Yestoday_bins
--        , case 
--                        when F_issue_inXdays_cnt >=8 then 5
--                        when F_issue_inXdays_cnt >=4 and F_issue_inXdays_cnt <=7 then 4
--                        when F_issue_inXdays_cnt = 3 then 3
--                        when F_issue_inXdays_cnt = 2 then 2
--                        when F_issue_inXdays_cnt = 1 then 1
--                end as F_issue_inXdays_cnt_bins
--        , case 
--                        when M_paied_numb_inXdays_cnt >=76 then 5
--                        when M_paied_numb_inXdays_cnt >=32 and M_paied_numb_inXdays_cnt <=76 then 4
--                        when M_paied_numb_inXdays_cnt >=15 and M_paied_numb_inXdays_cnt <=31 then 3
--                        when M_paied_numb_inXdays_cnt >=6  and M_paied_numb_inXdays_cnt <=14 then 2
--                        when M_paied_numb_inXdays_cnt >=0  and M_paied_numb_inXdays_cnt <=5 then 1
--                end as M_paied_numb_inXdays_bins
--from  rfm_mark 
--)
--
--
----, rfm_avg as (
--select         
--        avg(R_lastTimes2Yestoday_bins) as R_lastTimes2Yestoday_avg  --ʹ������������ƽ������Ϊ��׼,������ȫ������
--        , avg(F_issue_inXdays_cnt_bins) as F_issue_inXdays_cnt_avg
--        , avg(M_paied_numb_inXdays_bins) as M_paied_numb_inXdays_cnt_avg 
--from rfm_bins
----)
--------------

-- �ڶ��� ʹ��ȫ���ϰ����RFMֵ,������
with 
pre_user_pack as (
select 
	user_id 
	, max(date(to_timestamp(add_time))) as last_issue_add_time  --��󷢲�ʱ��
from public.ods_gczdw og 
where is_check = 2 and user_id > 0 
group by user_id
)

, user_pack as ( --�ų�����������
select pup.*
from pre_user_pack pup
left join
        (
        select user_id 
        from portrait.ads_job_tag_ultimate
        where jobgz0_agg like '%������%'
        group by user_id 
        ) tmp2 --���з�����������û�
on pup.user_id = tmp2.user_id
where tmp2.user_id is null 
)


, paied_numb as (
select target_id , count(1) as view_count_n
from public.ods_expense_calendar oec 
where expense_type in ( 1,13 )  --�鿴�й�
group by target_id
)

, index_info_in60days as ( 
select 
    og.user_id  
    , count ( 1 ) as issue_in60days_cnt --F 
    , sum( view_count_n ) as paied_numb_in60days_cnt --M
from public.ods_gczdw og
join user_pack up on og.user_id = up.user_id  
join paied_numb pn on og.id = pn.target_id
group by og.user_id 
)

, rfm_mark as (
select 
        up.user_id 
        , current_date as query_date 
        , current_date - date( up.last_issue_add_time ) as R_lastTimes2Yestoday
        , iii.issue_in60days_cnt as F_issue_inXdays_cnt
        , iii.paied_numb_in60days_cnt as M_paied_numb_inXdays_cnt
from user_pack up 
left join index_info_in60days iii on up.user_id = iii.user_id  
)


, rfm_bins as (
select 
        *
        , case 
                        when R_lastTimes2Yestoday >=1  and R_lastTimes2Yestoday <=17 then 5
                        when R_lastTimes2Yestoday >=18  and R_lastTimes2Yestoday <=42 then 4
                        when R_lastTimes2Yestoday >=43  and R_lastTimes2Yestoday <=79 then 3
                        when R_lastTimes2Yestoday >=80  and R_lastTimes2Yestoday <=128 then 2
                        when R_lastTimes2Yestoday >=129  then 1
                end as R_lastTimes2Yestoday_bins
        , case 
                        when F_issue_inXdays_cnt >=8 then 5
                        when F_issue_inXdays_cnt >=4 and F_issue_inXdays_cnt <=7 then 4
                        when F_issue_inXdays_cnt = 3 then 3
                        when F_issue_inXdays_cnt = 2 then 2
                        when F_issue_inXdays_cnt = 1 then 1
                end as F_issue_inXdays_cnt_bins
        , case 
                        when M_paied_numb_inXdays_cnt >=76 then 5
                        when M_paied_numb_inXdays_cnt >=32 and M_paied_numb_inXdays_cnt <=76 then 4
                        when M_paied_numb_inXdays_cnt >=15 and M_paied_numb_inXdays_cnt <=31 then 3
                        when M_paied_numb_inXdays_cnt >=6  and M_paied_numb_inXdays_cnt <=14 then 2
                        when M_paied_numb_inXdays_cnt >=0  and M_paied_numb_inXdays_cnt <=5 then 1
                end as M_paied_numb_inXdays_bins
from  rfm_mark 
)


, rfm_avg as (--ʹ������������ƽ������Ϊ��׼,������ȫ������
select         
--        avg(R_lastTimes2Yestoday_bins) as R_lastTimes2Yestoday_avg  
--        , avg(F_issue_inXdays_cnt_bins) as F_issue_inXdays_cnt_avg
--        , avg(M_paied_numb_inXdays_bins) as M_paied_numb_inXdays_cnt_avg 
        3.018933 as R_lastTimes2Yestoday_avg  
        , 2.531664 as F_issue_inXdays_cnt_avg
        , 2.982043 as M_paied_numb_inXdays_cnt_avg 
--from rfm_bins
)

, rfm_end as (
select 
        case when R_lastTimes2Yestoday_bins >= R_lastTimes2Yestoday_avg then '��' else '��' end as R_class 
        , case when F_issue_inXdays_cnt_bins >= F_issue_inXdays_cnt_avg then '��' else '��' end as F_class          
        , case when M_paied_numb_inXdays_bins >= M_paied_numb_inXdays_cnt_avg then '��' else '��' end as M_class 
        , *
from rfm_bins join rfm_avg on 1=1
)

--, rfm_res as (  -- rfm��ϸ
select 
        user_id 
        , case when R_class ='��' and F_class = '��' and M_class='��' then '��Ҫ��ֵ�û�'
                when R_class ='��' and F_class = '��' and M_class='��' then 'һ���ֵ�û�'
                when R_class ='��' and F_class = '��' and M_class='��' then '��Ҫ�����û�'
                when R_class ='��' and F_class = '��' and M_class='��' then 'һ�㱣���û�'
                when R_class ='��' and F_class = '��' and M_class='��' then '��Ҫ�����û�'
                when R_class ='��' and F_class = '��' and M_class='��' then 'һ�������û�'
                when R_class ='��' and F_class = '��' and M_class='��' then '��Ҫ��չ�û�'
                when R_class ='��' and F_class = '��' and M_class='��' then 'һ�㷢չ�û�'
        END as user_bins
        , R_class as "R����"
        , F_class as "F����"
        , M_class as "M����"
        , R_lastTimes2Yestoday as "���һ�η���ʱ��"
        , F_issue_inXdays_cnt as "��x�췢������"
        , M_paied_numb_inXdays_cnt as "��x�췢����Ϣ�ı��鿴����" 
        , query_date as "ȡ������"
        , R_lastTimes2Yestoday_bins as "R����"
        , F_issue_inXdays_cnt_bins as "F����"
        , M_paied_numb_inXdays_bins as "M����"
        , R_lastTimes2Yestoday_avg as "Rֵƽ����"
        , F_issue_inXdays_cnt_avg as "Fֵƽ����"
        , M_paied_numb_inXdays_cnt_avg as "Mֵƽ����"
from rfm_end
)

--select  --rfmͳ��
--	user_bins 
--	, count(1) as "�û���"
--	, sum("��x�췢������") as "������Ϣ����"
--	, sum("��x�췢����Ϣ�ı��鿴����" ) as "������Ϣ���鿴����"
--	from rfm_res
--group by user_bins 


select  --rfmͳ�� -- ÿ�����͵�R\F\M �ĸߣ������Сֵ
	user_bins
	, min("���һ�η���ʱ��") as R_min
	, max("���һ�η���ʱ��") as R_max
	, min("��x�췢������") as F_min
	, max("��x�췢������") as F_max
	, min("��x�췢����Ϣ�ı��鿴����") as M_min
	, max("��x�췢����Ϣ�ı��鿴����") as M_max
from rfm_res
group by user_bins