with 
-- step1 ����Դ���� 
t_key as ( -- �������ά��
select '��˾' as dep
union select '��ٻ�' 
union
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union
select NodePathName from import_data.mysql_store where department regexp '��' 
)

,t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
select 
	Code 
	,case when NodePathName regexp 'Ȫ��' then '��ٻ�����' 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store
)

,t_online_inXdays as ( 
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(count(distinct case when OnLineHour <= 72 then PackageNumber end )/count(distinct PackageNumber),4) `����3��������`
from erp_logistic_logistics_tracking lt
		join t_mysql_store ms on lt.ShopCode =ms.Code 
		where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
group by grouping sets ((),(department))
)

,t_detail as (
select lt.*
from erp_logistic_logistics_tracking lt
join t_mysql_store ms on lt.ShopCode =ms.Code 
where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
)

select 
	case when OnLineHour <= 72 then 'С��72h' end ��������
	,* 
from t_detail
