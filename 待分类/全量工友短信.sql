with 
week1_worker as (
select 
user_id 
, max_add_time 
--count(1)
from tmp.tmp_sms2_week1_worker -- worker_pack_332������_2022��7��1��-7��14�գ�����Ծʱ�䣩
)


, week2_worker as (
select 
user_id
, max_add_time 
--count(1) 
from tmp.tmp_sms2_week2_worker -- worker_pack_40������_2021��6��2��-2022��1��1�գ�����Ծʱ�䣩
)
--truncate table tmp.tmp_sms2_week2_worker


, week3_worker as (
select 
user_id
, max_add_time 
--count(1) 
from tmp.tmp_sms2_week3_worker --worker_pack_24������_2021-06-01֮ǰ������Ծʱ�䣩
)

, open_app as ( --�����е�¼���û�
select user_id , add_time  from public.ods_member_login_log_formal
where add_time between extract ( epoch from  to_timestamp( '2022-07-26 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS')) 
        and extract ( epoch from to_timestamp('2022-07-31 '||'23:59:59', 'YYYY-MM-DD HH24:MI:SS'))
--        and "source"  in ( 'ios' , 'android' )
) 

-- ��¼
--------------------week1 332�� ���� ��¼
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
--------------------week2 40�� ���� ��¼

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

--------------------week3 24�� ���� ��¼

, user_7b as (
select 
	user_id
	, max_add_time 
	, '24����'
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


--ʣ�����
--��ʷ�鿴�й�����
--��ֵ����/���
--���һ�ε�¼ʱ�䣨��ȷ���켴�ɣ�
--ˢ���һ���Ƭ����
--�Ӽ�/�ö��һ���Ƭ����
--����
--������Ƭ
--�ۼ����Ļ�����

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
	
	












