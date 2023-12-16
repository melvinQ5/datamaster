select
   a.build_date as 日期,
   a.publish_zg_cn as 发布招工人数,
   a.publish_zg as 发布招工条数,
   b.publish_zh_cn as 发布找活人数,
   b.publish_zh as 发布找活条数,
   c.view_zg_cn as 查看招工人数,
   c.view_zg as 查看招工次数,
   c.view_zg_integral as 查看招工消耗积分,
   d.view_zh_cn as 查看找活人数,
   d.view_zh as 查看找活次数,
   d.view_zh_integral as 查看找活消耗积分
from
(
    select
        build_date,
        count(1) as publish_zg_cn,
        sum(publish_num) as publish_zg
    from
    (
        select
            to_char(TO_TIMESTAMP(add_time),'yyyy-mm-dd') as build_date,
            user_id,
            count(1) publish_num
        from
        (
            select
                user_id,job_id,add_time
            from
            (
                select
                    user_id,
                    id as job_id,
                    add_time,
                    UNNEST(string_to_array(profession,',')) as gongzhong_id
                from ods_gczdw
                where add_time>=extract(epoch from cast('${startdate} 00:00:00' as TIMESTAMPTZ )) and  
                add_time<=extract(epoch from cast('${enddate} 23:59:59' as TIMESTAMPTZ ))
                and user_id!=0 and is_check=2
            )as a --招工信息
            where a.gongzhong_id in (select id::text from ods_gongzhong where (pid=73 or id=73))
            group by
                user_id,job_id,add_time
        )as a
        group by
            to_char(TO_TIMESTAMP(add_time),'yyyy-mm-dd'),
            user_id
    )as a
    group by
        build_date
)as a
inner join
(
    select
        build_date,
        count(1) as publish_zh_cn,
        sum(publish_num) as publish_zh
    from
    (
        select
            to_char(TO_TIMESTAMP(time),'yyyy-mm-dd') as build_date,
            user_id,
            count(1) publish_num
        from
        (
            select
                user_id,job_id,time
            from
            (
                select
                    user_id,
                    id as job_id,
                    time,
                    UNNEST(string_to_array(occupations,',')) as gongzhong_id
                from ods_resume
                where time>=extract(epoch from cast('${startdate} 00:00:00' as TIMESTAMPTZ )) and  
                time<=extract(epoch from cast('${enddate} 23:59:59' as TIMESTAMPTZ ))
                and user_id is not null
            )as a
            where a.gongzhong_id in (select id::text from ods_gongzhong where (pid=73 or id=73))
            group by
                user_id,job_id,time
        )as a
        group by
            to_char(TO_TIMESTAMP(time),'yyyy-mm-dd'),
            user_id
    )as a
    group by
        build_date
)as b
on a.build_date=b.build_date
inner join
(
    select
        build_date,
        count(1) as view_zg_cn,
        sum(view_zg) as view_zg,
        sum(expense_integral) as view_zg_integral
    from
    (
        select
            to_char(TO_TIMESTAMP(time),'yyyy-mm-dd') as build_date,
            user_id,
            count(1) view_zg,
            sum(expense_integral) as expense_integral
        from
        (
            select
                a.user_id,a.target_id,a.time,a.expense_integral
            from
            (
                select
                    a.user_id,
                    a.target_id,
                    a.time,
                    a.expense_integral
                from
                (
                    select
                        user_id,target_id,time,expense_integral
                    from ods_expense_calendar
                    where time>=extract(epoch from cast('${startdate} 00:00:00' as TIMESTAMPTZ))
                    and time<=extract(epoch from cast('${enddate} 23:59:59' as TIMESTAMPTZ ))
                    and expense_type in (1,13)
                )as a
                inner join
                (
                    select
                        job_id
                    from
                    (
                        select
                            id as job_id,
                            UNNEST(string_to_array(profession,',')) as gongzhong_id
                        from ods_gczdw
                        where is_check=2
                    )as a
                    where a.gongzhong_id in (select id::text from ods_gongzhong where (pid=73 or id=73))
                    group by
                        job_id
                )as  b
                on a.target_id=b.job_id
            )as a
        )as a
        group by
            to_char(TO_TIMESTAMP(time),'yyyy-mm-dd'),
            user_id
    )as a
    group by
        build_date
)as c
on a.build_date=c.build_date
inner join
(
    select
        build_date,
        count(1) as view_zh_cn,
        sum(view_zg) as view_zh,
        sum(expense_integral) as view_zh_integral
    from
    (
        select
            to_char(TO_TIMESTAMP(time),'yyyy-mm-dd') as build_date,
            user_id,
            count(1) view_zg,
            sum(expense_integral) as expense_integral
        from
        (
            select
                a.user_id,a.target_id,a.time,a.expense_integral
            from
            (
                select
                    a.user_id,
                    a.target_id,
                    a.time,
                    a.expense_integral
                from
                (
                    select
                        user_id,target_id,time,expense_integral
                    from ods_expense_calendar
                    where time>=extract(epoch from cast('${startdate} 00:00:00' as TIMESTAMPTZ))
                    and time<=extract(epoch from cast('${enddate} 23:59:59' as TIMESTAMPTZ ))
                    and expense_type in (2,14)
                )as a
                inner join
                (
                    select
                        job_id
                    from
                    (
                        select
                            id as job_id,
                            UNNEST(string_to_array(occupations,',')) as gongzhong_id
                        from ods_resume
                    )as a
                    where a.gongzhong_id in (select id::text from ods_gongzhong where (pid=73 or id=73))
                    group by
                        job_id
                )as  b
                on a.target_id=b.job_id
            )as a
        )as a
        group by
            to_char(TO_TIMESTAMP(time),'yyyy-mm-dd'),
            user_id
    )as a
    group by
        build_date
)as d
on a.build_date=d.build_date