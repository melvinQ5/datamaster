
with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select '��˾' as dep
union select '��ٻ�' 
union 
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union 
select NodePathName from import_data.mysql_store where department regexp '��' 
)


, t_new_purc as ( -- ���ڲɹ�
select 
	wp.BoxSku ,OrderNumber ,ordertime ,WarehouseName ,Price ,SkuFreight ,DiscountedPrice ,Quantity
	,instockquantity ,CompleteTime ,IsComplete ,scantime
	,wpt.projectteam as department ,wpt.IsDeleted as wpt_isdeleted
from import_data.wt_purchaseorder wp 
join ( select BoxSku ,projectteam ,IsDeleted from wt_products ) wpt on wp.BoxSku = wpt.BoxSku
where ordertime  <  '${NextStartDay}'  and ordertime >= date_add('${StartDay}',interval -10 day) -- ���ȡ10�����ݣ��Ա�������ָ��
	and WarehouseName = '��ݸ��' 
)

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
-- �ɹ����� �ɹ���� �ɹ��˷� (CNY)
, t_purc_amount as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,round(sum(Price - DiscountedPrice)) `�ɹ���Ʒ���` 
	,round(sum(SkuFreight)) `�ɹ��˷�`	
	,count(distinct OrderNumber) `�ɹ�����`
	,round(count(distinct OrderNumber)/datediff('${NextStartDay}','${StartDay}')) `�վ��ɹ�����`
from t_new_purc 
-- where wpt_isdeleted = 0 -- ������boxsku�ڲ�Ʒ����ɾ����ͬʱ�вɹ���¼
group by grouping sets ((),(department))
) 

-- ��ɢ�ɹ�
, t_scattered_purc as ( 
select case when department IS NULL THEN '��˾' ELSE department END AS dep
	, count(distinct case when total_qy <3 then OrderNumber end) `��ɢ�ɹ�����`
from 
	( select department ,OrderNumber
		, sum(Quantity) as total_qy -- ���ʶ����ɹ�����
	from t_new_purc
	where ordertime >= '${StartDay}' and ordertime < '${NextStartDay}' 
	group by department ,OrderNumber
	) temp 
where total_qy < 3
group by grouping sets ((),(department))
)

-- �ɹ�N�쵽����
, t_ontime_rev as (
select 
	case when department IS NULL THEN '��˾' ELSE department END AS dep
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����` 
from (
	select 
		OrderNumber ,BoxSku ,department
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
		end as in5days_rev_numb -- ����5�쵽�����µ���
		, case when instockquantity = 0 and IsComplete = '��' then null else OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
	from t_new_purc
	where ordertime >= date_add('${StartDay}',interval -5 day) and ordertime < date_add('${NextStartDay}',interval -5 day) 
	) tmp 
group by grouping sets ((),(department))
)

-- �ɹ�ƽ����������
, t_avg_rev_days as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep
	, round(avg(rev_days),1) `ƽ���ɹ��ջ�����`
from (
	select 
		OrderNumber ,wp.BoxSku ,projectteam as department
		,timestampdiff(second, ordertime, CompleteTime)/86400  as rev_days
	from import_data.wt_purchaseorder wp 
	join ( select BoxSku ,projectteam from wt_products ) wpt on wp.BoxSku = wpt.BoxSku
	where  CompleteTime < '${NextStartDay}' and CompleteTime >= '${StartDay}'
	) tmp 
group by grouping sets ((),(department))
)	

-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep `�Ŷ�` 
 	,`�ɹ���Ʒ���`
 	,`�ɹ��˷�`
 	,`�ɹ�����`
 	,`�վ��ɹ�����`
 	,`�ɹ�5�쵽����` 
 	,`ƽ���ɹ��ջ�����`
 	,`��ɢ�ɹ�����`
--  	,`����ȱ��SKU��`
--  	,`����ȱ��δ��������`
from t_key
left join t_purc_amount on t_key.dep = t_purc_amount.dep
left join t_ontime_rev on t_key.dep = t_ontime_rev.dep
left join t_avg_rev_days on t_key.dep = t_avg_rev_days.dep
left join t_scattered_purc on t_key.dep = t_scattered_purc.dep
)


-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	'${NextStartDay}' `ͳ������`
	,t_merge.*
	,round(`��ɢ�ɹ�����`/`�ɹ�����`,4) `��ɢ�ɹ�ռ��` 
from t_merge
order by `�Ŷ�` desc 







