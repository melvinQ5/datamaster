            select '周报' as ReportType , left(date_add(week_begin_date,interval -7 day),10) start_date ,left(week_begin_date,10) as next_start_date , '2' as NewProdMonths
            from dim_date where full_date >= '2023-09-04' and full_date <= '2023-12-11' and day_name = 'Monday'
            union all
            select distinct '月报' as ReportType ,left(DATE_ADD(full_date,interval -day(full_date)+1 day),10) as start_date
                ,case when month(full_date) = month('2023-12-15') then '2023-12-15' else left(date_add( DATE_ADD(full_date,interval -day(full_date)+1 day),interval 1 month),10)  end as next_start_date
                , '2' as NewProdMonths
               from dim_date where full_date > date_add('2023-12-15',interval -3 month) and full_date < '2023-12-15' order by ReportType,start_date;