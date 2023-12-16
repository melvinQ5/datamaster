-- 营销类数据集
select 
    created_date
    , api_channel
    , api_account
    , send_cnt as "请求条数"
    , send_succ_cnt as "请求成功条数"
    , send_fail_cnt as "请求失败条数"
from 
(
        select 
                created_date
                , api_channel
                , api_account
                , count( 1 ) as send_cnt
                , count( case when status = 1 then 1 end) as  send_succ_cnt -- "发送成功条数"
                , count( case when status = 2 then 1 end) as send_fail_cnt -- "回调失败条数"
        from 
                (
                select 
                        ( case 
                                when osms.operator = 1 then '腾域'
                                when osms.operator = 2 then '创蓝'
                                when osms.operator = 0 then '未请求'
                                when osms.operator = 3 then '腾域保险'
                        end ) as api_channel
                        , ( case 
                                when osms.operator = 1 then 'ypwnbcs'
                                when osms.operator = 2 then 'M396746_M5630511'
                                when osms.operator = 0 then '未请求'
                                when osms.operator = 3 then 'ypwbx'
                        end ) as api_account
                        , date( to_timestamp( osms.created_at ) ) as created_date
                        , * 
                from  bigdata.ods_sms_marking_send_log osms
                left join ods_sms_marking_task osmt on osms.task_id = osmt.id 
                where osms.created_at BETWEEN extract( epoch from to_timestamp('2022-01-01 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) 
                    and extract( epoch from to_timestamp('2022-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
                        and osms.operator <> 0 
                        and status != 0 --0为未请求
                ) sms_channel
        group by created_date , api_channel ,api_account
) tmp_marking
where api_channel = '创蓝'
order by created_date , api_channel , api_account



-- 营销类数据集
select 
        created_date
        , api_channel
    , send_cnt as "请求条数"
    , send_succ_cnt as "请求成功条数"
    , callback_succ_cnt as "回调成功条数"
    , ( case when send_succ_cnt = 0 then null else callback_succ_cnt::float8 / send_succ_cnt end )  as "回调成功率"
from 
(
        select 
                created_date
                , api_channel
                , count( 1 ) as send_cnt
                , count( case when status = 1 then 1 end) as  send_succ_cnt -- "发送成功条数"
                , count( case when callback_status = 1 then 1 end) as callback_succ_cnt -- "回调成功条数"
        from 
                (
                select 
                        ( case 
                                when osms.operator = 1 then '腾域'
                                when osms.operator = 2 then '创蓝'
                                when osms.operator = 0 then '未请求'
                        end ) as api_channel
                        , date( to_timestamp( osms.created_at ) ) as created_date
                        , * 
                from  bigdata.ods_sms_marking_send_log osms
                left join ods_sms_marking_task osmt on osms.task_id = osmt.id 
                where osms.created_at BETWEEN extract( epoch from to_timestamp('2022-01-01 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) 
                    and extract( epoch from to_timestamp('2022-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
                and osms.operator <> 0
                and title = '7.25营销短信测试' 
                ) sms_channel
        group by created_date , api_channel
) tmp_marking
order by created_date , api_channel
