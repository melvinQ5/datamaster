select 
	full_date ����
	,week_num_in_year �ܴ�
	,week_begin_date ���ڿ�ʼ����
	,week_end_date ���ڽ�������
	,day_of_week ���ڼ�
	,day_abbrev ������д
	,day_num_in_month ���µڼ���
	,`month` �·�
	,month_abbrev �·���д
from dim_date dd 
WHERE `year` = '2023'
order by full_date 
