--������ר���û�����
--        ��������������ר�����ֵ��й���Ϣ
--        �� ��������������ר�����ֵ��һ���Ƭ���û���
--        �� �鿴��2�μ����ϰ�������ר�����ֵ��й���Ϣ
--        �� �鿴��2�μ����ϰ�������ר�����ֵ��һ���Ƭ
--        ���û�



-- �½��û��������Ƿ�����ר���û�
create table tmp.tmp_wlzq_user_lhy (
    user_id int8 ,
    reg_time int8 ,
    is_logistic int8 ,
    is_issue_resume int8 ,
    is_issue_info int8 ,
    get_resume_numb int8 ,
    get_info_numb int8
) 

--ɾ����
truncate table tmp.tmp_wlzq_user_lhy 

-- --�鿴��2�μ����ϰ�������ר�����ֵ��й���Ϣ���һ���Ƭ���û�
insert into tmp.tmp_wlzq_user_lhy  
with get_info_numb as ( --�鿴��������ר���й���Ϣ���û�
select 
        oec.user_id 
from         
        (        
        select user_id , target_id 
        from public.ods_expense_calendar oec 
        where 
            time < extract( epoch from  to_timestamp( '2022-07-29 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
            and expense_type in (1,13)
        ) oec 
join 
        (
        select job_id 
        from tmp.tmp_wlzq_info_lhy
        where 
        	is_logistic = 1 
        	and jobgz2_agg in ( '��������˾��','���˹�/װж��','Ѻ��Ա','��ݷּ�/���Ա' ) 
        ) twil on oec.target_id = twil.job_id 
group by oec.user_id having count(target_id) >= 2
)
--select count(1) from get_info_numb

, get_resume_numb as ( --�鿴��������ר���һ���Ƭ���û�
select 
        oec.user_id 
from         
        (        
        select user_id , target_id 
        from public.ods_expense_calendar oec 
        where 
                time < extract( epoch from  to_timestamp( '2022-07-27 ' || '00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
                and expense_type in (2,14)
        ) oec 
join 
        (
        select resume_id  
        from tmp.tmp_wlzq_resume_lhy
        where is_logistic = 1
        and jobgz2_agg in ( '��������˾��','���˹�/װж��','Ѻ��Ա','��ݷּ�/���Ա' ) 
        ) twil on oec.target_id = twil.resume_id 
group by oec.user_id having count(target_id) >= 2
)


select 
        om.id as user_id 
        , om.time as reg_time
        , case when 
                rs.user_id is not null 
                or info.user_id is not null
                or grs.user_id is not null 
                or ginfo.user_id is not null
                then 1 else 0 
        end as is_logistic
        , case when rs.user_id is not null then 1 end as is_issue_resume
        , case when info.user_id is not null then 1 end as is_issue_info
        , case when grs.user_id is not null then 1 end as get_resume_numb
        , case when ginfo.user_id is not null then 1 end as get_info_numb
from public.ods_member om 
left join 
        ( select user_id from tmp.tmp_wlzq_resume_lhy where is_logistic = 1 group by user_id ) rs
        on om.id = rs.user_id
left join 
        ( select user_id from tmp.tmp_wlzq_info_lhy where is_logistic = 1 group by user_id ) info
        on om.id = info.user_id 
left join get_resume_numb grs on om.id = grs.user_id 
left join get_info_numb ginfo on om.id = ginfo.user_id 


--select count(1) from tmp.tmp_wlzq_user_lhy where is_logistic = 1  --2491748

