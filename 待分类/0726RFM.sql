-- 第一步 使用全量短信结果 最后发布时间22年内的用户作为优质样本,通过计算RFM值的每20%分位 以及平均分,确定评分标准

--with 
--user_pack as ( --从测试名单表中取数
--select 
--	user_id 
--	, max_pay_time as last_issue_add_time  --最后发布时间
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
---------- 求分位置
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
--, rfm_bins as ( -- 由上一步的每20%分位值得出
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
--        avg(R_lastTimes2Yestoday_bins) as R_lastTimes2Yestoday_avg  --使用优质样本的平均分作为标准,而不是全量样本
--        , avg(F_issue_inXdays_cnt_bins) as F_issue_inXdays_cnt_avg
--        , avg(M_paied_numb_inXdays_bins) as M_paied_numb_inXdays_cnt_avg 
--from rfm_bins
----)
--------------

-- 第二步 使用全量老板计算RFM值,并评级
with 
pre_user_pack as (
select 
	user_id 
	, max(date(to_timestamp(add_time))) as last_issue_add_time  --最后发布时间
from public.ods_gczdw og 
where is_check = 2 and user_id > 0 
group by user_id
)

, user_pack as ( --排除发过工厂类
select pup.*
from pre_user_pack pup
left join
        (
        select user_id 
        from portrait.ads_job_tag_ultimate
        where jobgz0_agg like '%工厂类%'
        group by user_id 
        ) tmp2 --所有发过工厂类的用户
on pup.user_id = tmp2.user_id
where tmp2.user_id is null 
)


, paied_numb as (
select target_id , count(1) as view_count_n
from public.ods_expense_calendar oec 
where expense_type in ( 1,13 )  --查看招工
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


, rfm_avg as (--使用优质样本的平均分作为标准,而不是全量样本
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
        case when R_lastTimes2Yestoday_bins >= R_lastTimes2Yestoday_avg then '高' else '低' end as R_class 
        , case when F_issue_inXdays_cnt_bins >= F_issue_inXdays_cnt_avg then '高' else '低' end as F_class          
        , case when M_paied_numb_inXdays_bins >= M_paied_numb_inXdays_cnt_avg then '高' else '低' end as M_class 
        , *
from rfm_bins join rfm_avg on 1=1
)

--, rfm_res as (  -- rfm明细
select 
        user_id 
        , case when R_class ='低' and F_class = '高' and M_class='高' then '重要价值用户'
                when R_class ='低' and F_class = '高' and M_class='低' then '一般价值用户'
                when R_class ='高' and F_class = '高' and M_class='高' then '重要保持用户'
                when R_class ='高' and F_class = '高' and M_class='低' then '一般保持用户'
                when R_class ='高' and F_class = '低' and M_class='高' then '重要挽留用户'
                when R_class ='高' and F_class = '低' and M_class='低' then '一般挽留用户'
                when R_class ='低' and F_class = '低' and M_class='高' then '重要发展用户'
                when R_class ='低' and F_class = '低' and M_class='低' then '一般发展用户'
        END as user_bins
        , R_class as "R评级"
        , F_class as "F评级"
        , M_class as "M评级"
        , R_lastTimes2Yestoday as "最近一次发布时间"
        , F_issue_inXdays_cnt as "近x天发布条数"
        , M_paied_numb_inXdays_cnt as "近x天发布信息的被查看次数" 
        , query_date as "取数日期"
        , R_lastTimes2Yestoday_bins as "R分数"
        , F_issue_inXdays_cnt_bins as "F分数"
        , M_paied_numb_inXdays_bins as "M分数"
        , R_lastTimes2Yestoday_avg as "R值平均数"
        , F_issue_inXdays_cnt_avg as "F值平均数"
        , M_paied_numb_inXdays_cnt_avg as "M值平均数"
from rfm_end
)

--select  --rfm统计
--	user_bins 
--	, count(1) as "用户数"
--	, sum("近x天发布条数") as "发布信息条数"
--	, sum("近x天发布信息的被查看次数" ) as "发布信息被查看次数"
--	from rfm_res
--group by user_bins 


select  --rfm统计 -- 每种类型的R\F\M 的高，最大最小值
	user_bins
	, min("最近一次发布时间") as R_min
	, max("最近一次发布时间") as R_max
	, min("近x天发布条数") as F_min
	, max("近x天发布条数") as F_max
	, min("近x天发布信息的被查看次数") as M_min
	, max("近x天发布信息的被查看次数") as M_max
from rfm_res
group by user_bins