with 
-- step1 ����Դ���� 
t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
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

 -- ��ϸ
select  OnLineHour , PackageNumber ,lt.*
-- select count(distinct PackageNumber)
from erp_logistic_logistics_tracking lt
join t_mysql_store ms on lt.ShopCode =ms.Code 
where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
-- 	and !(OnLineHour < 72)
-- 	and (OnLineHour is null or OnlineTime = '')
	
	
-- -- ͳ��
-- select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
-- 	,round(count(distinct case when OnLineHour <= 72 then PackageNumber end )/count(distinct PackageNumber),4) `����3��������`
-- from erp_logistic_logistics_tracking lt
-- 		join t_mysql_store ms on lt.ShopCode =ms.Code 
-- 		where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
-- group by grouping sets ((),(department))