
-- ��������� ͳ�Ʊ�
with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select '��˾' as dep
union select '��ٻ�' 
union select '�̳���' 
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
from mysql_store
)

, t_normal_shop as ( 
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep 
	, count( case when ShopStatus='����' then code end ) `����������` 
	, count( case when ShopStatus='�쳣' then code end ) `�쳣������` 
	, count( case when ShopStatus='����' then code end ) `���õ�����` 
	, count( case when ShopStatus='�ݼ���' then code end ) `�ݼ��е�����` 
	, count( case when ShopStatus='�ر�' then code end ) `�رյ�����` 
from  t_mysql_store
group by grouping sets ((),(department))
union 
select '��ٻ�' as department 
	, count( case when ShopStatus='����' then code end ) `����������` 
	, count( case when ShopStatus='�쳣' then code end ) `�쳣������` 
	, count( case when ShopStatus='����' then code end ) `���õ�����` 
	, count( case when ShopStatus='�ݼ���' then code end ) `�ݼ��е�����` 
	, count( case when ShopStatus='�ر�' then code end ) `�رյ�����` 
from t_mysql_store
where department regexp '��' 
union
select NodePathName 
	, count( case when ShopStatus='����' then code end ) `����������` 
	, count( case when ShopStatus='�쳣' then code end ) `�쳣������` 
	, count( case when ShopStatus='����' then code end ) `���õ�����` 
	, count( case when ShopStatus='�ݼ���' then code end ) `�ݼ��е�����` 
	, count( case when ShopStatus='�ر�' then code end ) `�رյ�����` 
from t_mysql_store where department regexp '��' 
group by NodePathName 
) 

,BadShop as (
select  CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep  
	,count(distinct case when '${NextStartDay}' >= '2023-02-01' and monitor <> 'δ����' then shopcode end ) `��һ���������`
from 
(
select 
	case when  LateShipmentRate/100 > 0.03 then '�ٷ��ʳ�3%'
		when OrderWithDefectsRate/100 > 0.008 then '����ȱ���ʳ�0.8%'
		when PreFulfillmentCancellationRate/100 > 0.02 then 'ȡ���ʳ�2%'
		when ValidTrackingRate/100 < 0.96 and  ValidTrackingRate/100 > 0 then '��Ч׷���ʵ���96%'
		else 'δ����'
	end as monitor
	, eaaspcd.shopcode 
	, eaaspcd.LateShipmentRate ,OrderWithDefectsRate ,PreFulfillmentCancellationRate ,ValidTrackingRate
	, department
from import_data.erp_amazon_amazon_shop_performance_check eaaspcd 
join t_mysql_store ms on eaaspcd.ShopCode =ms.Code 
where AmazonShopHealthStatus != 4 
		and CreationTime >=DATE_ADD('${NextStartDay}', interval -1 day)  and CreationTime < '${NextStartDay}'
	) tmp 
group by grouping sets ((),(department))
)

-- , email as ( -- �������ʼ�ϵͳ���»��ƣ����޷���ȡ�ʼ�����
-- select CASE WHEN ms.department  IS NULL THEN '��˾' ELSE ms.department  END AS dep  
-- 	,round(count(1)/datediff('${NextStartDay}','${StartDay}'),0) `�վ��ʼ���`
-- from import_data.daily_Email de 
-- join t_mysql_store ms on de.Src =ms.Code 
-- where CollectionTme  <  '${NextStartDay}'  and CollectionTme >= '${StartDay}'
-- group by grouping sets ((),(ms.department)) 
-- union 
-- SELECT split_part(NodePathNameFull,'>',2)
-- 	,round(count(1)/datediff('${NextStartDay}','${StartDay}'),0) `�վ��ʼ���`from import_data.daily_Email de 
-- join t_mysql_store ms on de.Src =ms.Code 
-- where CollectionTme  <  '${NextStartDay}'  and CollectionTme >= '${StartDay}'
-- group by split_part(NodePathNameFull,'>',2)
-- union 
-- SELECT NodePathName
-- 	,round(count(1)/datediff('${NextStartDay}','${StartDay}'),0) `�վ��ʼ���`from import_data.daily_Email de 
-- join t_mysql_store ms on de.Src =ms.Code 
-- where CollectionTme  <  '${NextStartDay}'  and CollectionTme >= '${StartDay}'
-- group by NodePathName
-- )

-- ��������������ͣ
-- , spider_data as (
-- select CASE WHEN department  IS NULL THEN '��˾' ELSE department  END AS dep  
-- 	,count(case when odr_over=1 then ShopCode end ) `ODR���������`
-- 	,count(case when vtr_over=1 then ShopCode end ) `VTR���������`
-- 	,count(case when lsr_over=1 then ShopCode end ) `LSR���������`
-- 	,count(case when cr_over=1 then ShopCode end ) `CR���������`
-- 	,count(case when ahr_over=1 then ShopCode end ) `AHR���������`
-- from (
-- 	select 
-- 		department ,shopcode
-- 		,case when ODR<>'������' and cast(replace(ODR,'%','') as float)>=0.8 then 1 end odr_over 
-- 		,case when TrackingRate<>'������' and cast(replace(TrackingRate,'%','') as float)<=0.96 then 1 end vtr_over  
-- 		,case when LaterDay10<>'������' and cast(replace(LaterDay10,'%','') as float)>=3 then 1 end lsr_over
-- 		,case when RateBeforeShipping<>'������' and cast(replace(RateBeforeShipping,'%','') as float)>=2 then 1 end cr_over 
-- 		,case when AccountHealth<>'������' and cast(replace(AccountHealth,'%','') as float)<=200 then 1 end ahr_over 
-- 	from import_data.ShopPerformance sp 
-- 	join t_mysql_store ms on sp.ShopCode = ms.Code and ms.ShopStatus ='����'
-- 		and ReportType ='�ܱ�' and Monday ='${StartDay}'
-- 	) tmp
-- group by grouping sets ((),(department))
-- )

-- API����
-- , spider_data as (
-- select  CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep  
-- 	,count(distinct case when '${NextStartDay}' >= '2023-02-01' and monitor <> 'δ����' then shopcode end ) `��һ���������`
-- from 
-- (
-- select 
-- 	case when  LateShipmentRate/100 > 0.03 then '�ٷ��ʳ�3%'
-- 		when OrderWithDefectsRate/100 > 0.008 then '����ȱ���ʳ�0.8%'
-- 		when PreFulfillmentCancellationRate/100 > 0.02 then 'ȡ���ʳ�2%'
-- 		when ValidTrackingRate/100 < 0.96 and  ValidTrackingRate/100 > 0 then '��Ч׷���ʵ���96%'
-- 		else 'δ����'
-- 	end as monitor
-- 	, eaaspcd.shopcode 
-- 	, eaaspcd.LateShipmentRate ,OrderWithDefectsRate ,PreFulfillmentCancellationRate ,ValidTrackingRate
-- 	, department
-- from import_data.erp_amazon_amazon_shop_performance_check eaaspcd 
-- join t_mysql_store ms on eaaspcd.ShopCode =ms.Code 
-- where AmazonShopHealthStatus != 4 
-- 		and CreationTime >=DATE_ADD('${NextStartDay}', interval -1 day)  and CreationTime < '${NextStartDay}'
-- ) tmp 
-- group by grouping sets ((),(department))
-- )

,OrderCancelRate as (
SELECT case when ms.department IS NULL THEN '��˾' ELSE ms.department END AS dep 
	,round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber  end)/count(distinct PlatOrderNumber),4) as `���϶�����`
	,round(count(DISTINCT CASE when OrderStatus != '����' and TransactionType ='����' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `�վ�������`
from import_data.wt_orderdetails  wo  
join t_mysql_store ms on wo.ShopCode  =ms.Code and wo.IsDeleted = 0
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' 
group by grouping sets ((),(ms.department))
union 
SELECT '��ٻ�' as department
	,round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `���϶�����`
	,round(count(DISTINCT CASE when OrderStatus != '����' and TransactionType ='����' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `�վ�������`
from import_data.wt_orderdetails  wo  
join t_mysql_store ms on wo.ShopCode  =ms.Code and wo.IsDeleted = 0 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and ms.department regexp '��'  
union 
SELECT NodePathName
	,round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `���϶�����`
	,round(count(DISTINCT CASE when OrderStatus != '����' and TransactionType ='����' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `�վ�������`
from import_data.wt_orderdetails  wo   
join t_mysql_store ms on wo.ShopCode  =ms.Code and wo.IsDeleted = 0 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and ms.department regexp '��' 
group by NodePathName
)

select 
	'${NextStartDay}' `ͳ������`
	,t_key.dep `�Ŷ�`
	,`����������`
	,`�쳣������`
	,`�ݼ��е�����`
	,`�رյ�����`
	,`���õ�����`
-- 	,`�վ��ʼ���` 
	,`��һ���������`
-- 	,`ODR���������`
-- 	,`VTR���������`
-- 	,`LSR���������`
-- 	,`CR���������`
-- 	,`AHR���������`
-- 	,`24Сʱ�ʼ��ظ���`
-- 	,`��24Сʱ�ظ�������`
-- 	,`��24Сʱ�ظ��ʼ���`
-- 	,`ѯ�������ʼ��Ķ�����`
	,`���϶�����`
from t_key
-- left join email on t_key.dep = email.dep
left join BadShop on t_key.dep = BadShop.dep
left join t_normal_shop on t_key.dep = t_normal_shop.dep
-- left join spider_data on t_key.dep = spider_data.dep
left join OrderCancelRate on t_key.dep = OrderCancelRate.dep
order by `�Ŷ�` desc

