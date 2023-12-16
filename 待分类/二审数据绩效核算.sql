--truncate table tmp.tmp_review_id_lhy 
-- ÿһͨ������򣬿��������ں��������Ƿ�ע�ᣬ���������ں��������Ƿ񷢲�

with t_check as ( --��ȡ������е�tel_hash
select tel_hash , review_id , call_date , groups , name 
from public.ods_review_collected_information orci 
join tmp.tmp_review_id_lhy tril on orci.id = review_id
)


, reg_user as ( --��ע��Щ�������������������� ��ע��
select 
        tc.* 
        , om.id as user_id  
        , to_char(to_timestamp(time), 'YYYY-MM-DD HH24:MI:SS') as reg_time
from t_check tc
left join public.ods_member om on tc.tel_hash = om.tel_hash
where date(to_timestamp(time)) <= date(tc.call_date)+ integer '3' and date(to_timestamp(time)) > date(tc.call_date)
)


, reg_res as ( -- �����¼����ע��
select
    tel_hash , review_id , call_date , groups , name 
    , ru2.reg_time 
    , ru2.user_id 
from reg_user ru2
)

-------------------

, pre_issue_res as ( --����������ڵ� ���������й���Ϣ
    select
        tel_hash , review_id  , groups , name , call_date
        , to_timestamp( add_time) as add_timestamp
        , og.id as job_id 
        , reg_date
    from 
            ( 
            select 
            	tc.tel_hash , review_id  , groups , name , call_date
            	, date(to_timestamp(om.time)) as reg_date
            from t_check tc 
            left join public.ods_member om on tc.tel_hash = om.tel_hash
			where date(to_timestamp(time)) <= date(tc.call_date)+ integer '3'  --����ע��򲦴�������ע����û�
            ) ru -- ��������������ڵ� ��ע���û��� �����¼
            left join public.ods_gczdw og --���в�����ֻ����У��ڲ����3�����з�����
                    on og.user_mobile_hash = ru.tel_hash  
                            and date(to_timestamp(add_time)) <= date(call_date)  + integer '3'  
                            and date(to_timestamp(add_time)) > date(call_date) -- ͬһ�����뱻������
    where og.is_check = 2 --���ͨ������Ϣ
)


, issue_res as (
select 
	pir.* 
	, ajtu.jobgz2_agg 
	, to_timestamp(ajtu.issue_time)  as add_timestamp 
	, ajtu.job_id 
from 
        (
        select  review_id , max(job_id) as max_job_id  
        from pre_issue_res 
        group by review_id
        ) pir  --ÿ���绰
left join portrait.ads_job_tag_ultimate ajtu on pir.max_job_id = ajtu.job_id   
)


select
    tc.*
    , rr.user_id as "ָ��1_ע���û�"
    , rr.reg_time as "ָ��1_ע��ʱ��(�����3����)"
    , ir.add_timestamp as "ָ��2_ֱ��ʱ�䣨����������ڣ�"
    , ir.jobgz2_agg as "ָ��2_����"
    , ir.job_id as "ָ��2_job_id"
    , pir.reg_date  as "ָ��2_ע��ʱ��"
from  t_check tc
left join reg_res  rr on tc.review_id = rr.review_id
left join issue_res ir on tc.review_id = ir.review_id
left join 
	(
	    select  review_id , reg_date
	    from pre_issue_res 
	    group by review_id , reg_date
    ) pir
	on tc.review_id = pir.review_id