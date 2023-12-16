--truncate table tmp.tmp_review_id_lhy 
-- 每一通外呼拨打，看拨打日期后三天内是否注册，看拨打日期后三天内是否发布

with t_check as ( --获取二审表中的tel_hash
select tel_hash , review_id , call_date , groups , name 
from public.ods_review_collected_information orci 
join tmp.tmp_review_id_lhy tril on orci.id = review_id
)


, reg_user as ( --标注哪些号码在外呼拨打后三天内 已注册
select 
        tc.* 
        , om.id as user_id  
        , to_char(to_timestamp(time), 'YYYY-MM-DD HH24:MI:SS') as reg_time
from t_check tc
left join public.ods_member om on tc.tel_hash = om.tel_hash
where date(to_timestamp(time)) <= date(tc.call_date)+ integer '3' and date(to_timestamp(time)) > date(tc.call_date)
)


, reg_res as ( -- 外呼记录中有注册
select
    tel_hash , review_id , call_date , groups , name 
    , ru2.reg_time 
    , ru2.user_id 
from reg_user ru2
)

-------------------

, pre_issue_res as ( --拨打后三天内的 发布过的招工信息
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
			where date(to_timestamp(time)) <= date(tc.call_date)+ integer '3'  --曾经注册或拨打三天内注册的用户
            ) ru -- 截至拨打后三天内的 已注册用户的 拨打记录
            left join public.ods_gczdw og --所有拨打的手机号中，在拨打后3天内有发布的
                    on og.user_mobile_hash = ru.tel_hash  
                            and date(to_timestamp(add_time)) <= date(call_date)  + integer '3'  
                            and date(to_timestamp(add_time)) > date(call_date) -- 同一个号码被拨打多次
    where og.is_check = 2 --审核通过的信息
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
        ) pir  --每个电话
left join portrait.ads_job_tag_ultimate ajtu on pir.max_job_id = ajtu.job_id   
)


select
    tc.*
    , rr.user_id as "指标1_注册用户"
    , rr.reg_time as "指标1_注册时间(拨打后3天内)"
    , ir.add_timestamp as "指标2_直发时间（拨打后三天内）"
    , ir.jobgz2_agg as "指标2_工种"
    , ir.job_id as "指标2_job_id"
    , pir.reg_date  as "指标2_注册时间"
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