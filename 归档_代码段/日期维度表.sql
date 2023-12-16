select 
	full_date 日期
	,week_num_in_year 周次
	,week_begin_date 星期开始日期
	,week_end_date 星期结束日期
	,day_of_week 星期几
	,day_abbrev 星期缩写
	,day_num_in_month 当月第几天
	,`month` 月份
	,month_abbrev 月份缩写
from dim_date dd 
WHERE `year` = '2023'
order by full_date 
