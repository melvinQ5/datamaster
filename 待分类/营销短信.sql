-- Ӫ�������ݼ�
select 
    created_date
    , api_channel
    , api_account
    , send_cnt as "��������"
    , send_succ_cnt as "����ɹ�����"
    , send_fail_cnt as "����ʧ������"
from 
(
        select 
                created_date
                , api_channel
                , api_account
                , count( 1 ) as send_cnt
                , count( case when status = 1 then 1 end) as  send_succ_cnt -- "���ͳɹ�����"
                , count( case when status = 2 then 1 end) as send_fail_cnt -- "�ص�ʧ������"
        from 
                (
                select 
                        ( case 
                                when osms.operator = 1 then '����'
                                when osms.operator = 2 then '����'
                                when osms.operator = 0 then 'δ����'
                                when osms.operator = 3 then '������'
                        end ) as api_channel
                        , ( case 
                                when osms.operator = 1 then 'ypwnbcs'
                                when osms.operator = 2 then 'M396746_M5630511'
                                when osms.operator = 0 then 'δ����'
                                when osms.operator = 3 then 'ypwbx'
                        end ) as api_account
                        , date( to_timestamp( osms.created_at ) ) as created_date
                        , * 
                from  bigdata.ods_sms_marking_send_log osms
                left join ods_sms_marking_task osmt on osms.task_id = osmt.id 
                where osms.created_at BETWEEN extract( epoch from to_timestamp('2022-01-01 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) 
                    and extract( epoch from to_timestamp('2022-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
                        and osms.operator <> 0 
                        and status != 0 --0Ϊδ����
                ) sms_channel
        group by created_date , api_channel ,api_account
) tmp_marking
where api_channel = '����'
order by created_date , api_channel , api_account



-- Ӫ�������ݼ�
select 
        created_date
        , api_channel
    , send_cnt as "��������"
    , send_succ_cnt as "����ɹ�����"
    , callback_succ_cnt as "�ص��ɹ�����"
    , ( case when send_succ_cnt = 0 then null else callback_succ_cnt::float8 / send_succ_cnt end )  as "�ص��ɹ���"
from 
(
        select 
                created_date
                , api_channel
                , count( 1 ) as send_cnt
                , count( case when status = 1 then 1 end) as  send_succ_cnt -- "���ͳɹ�����"
                , count( case when callback_status = 1 then 1 end) as callback_succ_cnt -- "�ص��ɹ�����"
        from 
                (
                select 
                        ( case 
                                when osms.operator = 1 then '����'
                                when osms.operator = 2 then '����'
                                when osms.operator = 0 then 'δ����'
                        end ) as api_channel
                        , date( to_timestamp( osms.created_at ) ) as created_date
                        , * 
                from  bigdata.ods_sms_marking_send_log osms
                left join ods_sms_marking_task osmt on osms.task_id = osmt.id 
                where osms.created_at BETWEEN extract( epoch from to_timestamp('2022-01-01 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) 
                    and extract( epoch from to_timestamp('2022-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) 
                and osms.operator <> 0
                and title = '7.25Ӫ�����Ų���' 
                ) sms_channel
        group by created_date , api_channel
) tmp_marking
order by created_date , api_channel
