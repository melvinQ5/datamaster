

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

,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else '��ٻ�����' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '��'
)

-- ,t_ontimesend as (
-- select tb.department as dep,round(A_cnt/B_cnt,4) `׼ʱ������` 
-- from 
-- 	( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, B_cnt	
-- 	FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
-- 		from import_data.wt_orderdetails dod join t_mysql_store ms on dod.shopcode =ms.Code and isdeleted = 0
-- 		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
-- 		  and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
-- 		 group by grouping sets ((),(ms.department))
-- 		) tmp3 -- ����ʱ������4�� ��������ʱ��
-- 	) tb   
-- LEFT JOIN  
-- ( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, A_cnt		
-- 	FROM ( 
-- 		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- ���������������ڷ���������
-- 		from ( 
-- 			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
-- 			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
-- 			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
-- 			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
-- 			    end as latest_WeightTime -- ��������
-- 			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
-- 			    ,PlatOrderNumber ,department 
-- 			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,shopcode 
-- 			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,ms.department 
-- 				from import_data.wt_orderdetails od
-- 				join t_mysql_store ms on od.shopcode =ms.Code and isdeleted = 0
-- 				left join
-- 					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
-- 					on js.code = right(od.shopcode,2)
-- 				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
-- 					and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
-- 			    ) tmp
-- 			) dod
-- 		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
-- 		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
-- 		group by grouping sets ((),(department))
-- 		) tmp2
-- ) ta
-- ON ta.department =tb.department
-- union 
-- select tb.department as dep,round(A_cnt/B_cnt,4) `׼ʱ������` 
-- from 
-- 	( SELECT '��ٻ�' AS department, B_cnt	
-- 	FROM ( SELECT  count(distinct PlatOrderNumber) B_cnt
-- 		from import_data.wt_orderdetails dod join t_mysql_store ms on dod.shopcode =ms.Code and isdeleted = 0 and ms.department REGEXP '��'
-- 		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
-- 		  and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
-- 		) tmp3 -- ����ʱ������4�� ��������ʱ��
-- 	) tb 
-- LEFT JOIN 
-- ( SELECT  '��ٻ�' AS department, A_cnt		
-- 	FROM ( 
-- 		select count(distinct dod.PlatOrderNumber) as A_cnt  -- ���������������ڷ���������
-- 		from ( 
-- 			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
-- 			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
-- 			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
-- 			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
-- 			    end as latest_WeightTime -- ��������
-- 			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
-- 			    ,PlatOrderNumber ,department 
-- 			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.shopcode ,2)
-- 			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,ms.department 
-- 				from import_data.wt_orderdetails od
-- 				join t_mysql_store ms on od.shopcode =ms.Code and isdeleted = 0 and ms.department REGEXP '��'
-- 				left join
-- 					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
-- 					on js.code=right(od.shopcode ,2) 
-- 				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
-- 					and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
-- 			    ) tmp
-- 			) dod
-- 		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
-- 		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
-- 		) tmp2
-- ) ta
-- ON ta.department =tb.department
-- )

, t_order_sku as (
select CASE WHEN ms.department IS NULL THEN '��˾' ELSE ms.department END AS dep
	,ceiling(count(distinct dpd.PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}'))  `�վ�����������`
from import_data.daily_PackageDetail dpd
join import_data.wt_orderdetails wo 
	on dpd.OrderNumber = wo.OrderNumber 
		and dpd.WeightTime  < '${NextStartDay}' 
		and dpd.WeightTime >= '${StartDay}'
join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����' and wo.IsDeleted = 0 
group by grouping sets ((),(ms.department))
)

,t_pay2send_days as (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(avg(diff_days),1) `ƽ�����������`
from  
	(select DISTINCT department ,pd.PlatOrderNumber
		, timestampdiff(second, paytime, pd.WeightTime)/86400 AS diff_days 
	from 
		( 
		select PlatOrderNumber , PayTime ,ms.Department 
		from import_data.wt_orderdetails wo 
		join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
		) od_pre 
	join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
	where WeightTime < '${NextStartDay}'  and WeightTime >= '${StartDay}' 
	) tmp1
group by grouping sets ((),(department))
)

,t_send2deli_days as (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(avg(diff_days),1) `ƽ��������Ͷ����`
from (
	select distinct Department ,eaalt.OrderNumber
		, timestampdiff(second, PayTime ,eaalt.DeliverTime  )/86400 as diff_days 
	from 
		( 
		select OrderNumber ,PayTime ,ms.Department 
		from import_data.wt_orderdetails wo 
		join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
		group by OrderNumber ,PayTime ,ms.Department
		) od_pre 
	join import_data.erp_logistic_logistics_tracking  eaalt on od_pre.OrderNumber = eaalt.OrderNumber 
	where DeliverTime < '${NextStartDay}'  and DeliverTime >= '${StartDay}' 
	) tmp
group by grouping sets ((),(department))
)


-- ׼ʱ������
,t_ontime_deli_rate as (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `׼ʱ������`
from (
	SELECT department
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	 	join t_mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and to_date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	group by grouping sets ((),(department))
	) tmp2
union 
select department
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `׼ʱ������`
from (
	SELECT '��ٻ�' department
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	 	join t_mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and to_date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- ÿ���賿0�������
			and department REGEXP '��'
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	) tmp2
	
) 

,t_send2online_days as ( -- ��ָ�����÷�Χ��ͳ���������İ�����������ʱЧ���
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(avg(deli_days),2) `ƽ��������������` 
from  
	(select DISTINCT department ,pd.OrderNumber
		, timestampdiff(second, eaalt.WeightTime ,eaalt.OnlineTime )/86400 AS deli_days 
		from 
			( 
			select OrderNumber ,ms.Department 
			from import_data.wt_orderdetails wo 
			join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
			) od_pre 
		join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber 
		join import_data.erp_logistic_logistics_tracking  eaalt on od_pre.OrderNumber = eaalt.OrderNumber 
		where OnlineTime < '${NextStartDay}'  and OnlineTime >= '${StartDay}' 
	) tmp1
group by grouping sets ((),(department))
) 

-- ����3��������
,t_online_inXdays as ( 
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(count(distinct case when OnLineHour <= 72 then PackageNumber end )/count(distinct PackageNumber),4) `����3��������`
from erp_logistic_logistics_tracking lt
		join t_mysql_store ms on lt.ShopCode =ms.Code 
		where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
group by grouping sets ((),(department))
)


,t_pay2gen_days as (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	,round(avg(gen_days),1) `ƽ��������������`
from  
	(select DISTINCT department ,pd.PlatOrderNumber, timestampdiff(second, paytime, pd.CreatedTime)/86400 AS gen_days 
		from 
			( 
			select PlatOrderNumber , PayTime ,ms.department
			from import_data.wt_orderdetails wo 
			join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0
			) od_pre 
		join import_data.PackageDetail pd on od_pre.PlatOrderNumber =pd.PlatOrderNumber 
		where CreatedTime < '${NextStartDay}'  and CreatedTime >= '${StartDay}' 
	) tmp1
group by grouping sets ((),(department))
)


-- ������ ����5�췢���� ����7�췢����
, t_ordersend_stat as (
select department as dep
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`
	,round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`
	,round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  
	(select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department  
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
			then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from 
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime 
			,ms.* 
		from import_data.wt_orderdetails wo 
		join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����' 
			and wo.IsDeleted = 0 and wo.TransactionType = '����'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
	group by grouping sets ((),(department))
	) tmp1
union 
select department as dep
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`
	,round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`
	,round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  
	(select '��ٻ�' AS department  
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
			then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5�충�������ʷ���
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from 
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime 
			,ms.* 
		from import_data.wt_orderdetails wo 
		join t_mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.department REGEXP '��'
			and wo.IsDeleted = 0 and wo.TransactionType = '����'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
	) tmp1
)

-- ͣ��״̬δ���������� (����ͳ����δ�����Ҷ�������ͣ����Ʒ�Ķ�����)
,t_backorder  as (
select  CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	, count (1) `ͣ��δ����������`
from (
	select PlatOrderNumber ,department
	from import_data.daily_WeightOrders dwo
	join (select BoxSku , ProjectTeam as department from import_data.wt_products wp -- 2=ͣ�� 0=���� 3=ͣ�� 4=��ʱȱ�� 5=���
		where ProductStatus = 2 ) wp 
		on dwo.BoxSku = wp.BoxSku and dwo.CreateDate =  current_date() --  date_add(current_date(),-1) 
	group by PlatOrderNumber ,department
	) tmp 
group by grouping sets ((),(department))
)

,t_delay_10days_ord as (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS dep
	, count(distinct PlatOrderNumber ) `10��δ����������`
from import_data.daily_WeightOrders wo
join t_mysql_store ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1) =ms.Code
where wo.CreateDate = '${NextStartDay}' and OrderStatus <> '����'
	and PayTime >= date_add('${NextStartDay}',interval -20 day)
	and PayTime < date_add('${NextStartDay}',interval -10 day)
group by grouping sets ((),(department))
union 
select '��ٻ�' AS dep
	, count(distinct PlatOrderNumber ) `10��δ����������`
from import_data.daily_WeightOrders wo
join t_mysql_store ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1) =ms.Code
where wo.CreateDate = '${NextStartDay}' and OrderStatus <> '����'
	and PayTime >= date_add('${NextStartDay}',interval -20 day)
	and PayTime < date_add('${NextStartDay}',interval -10 day)
	and ms.department REGEXP '��'
)

,t_receiveIn24h as ( -- �ֿ�24Сʱ�ջ�
select case when department is null THEN '��˾' ELSE department END AS dep
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400) 
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `�ֿ�24Сʱ�ջ���`
from import_data.daily_PurchaseRev a 
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where scantime < date_add('${NextStartDay}',-1)  and scantime >= date_add('${StartDay}',-1)
	 and b.WarehouseName = '��ݸ��'
group by grouping sets ((),(department))
) 

,t_instockIn24h as ( -- �ֿ�24Сʱ���
select case when department is null THEN '��˾' ELSE department END AS dep
	, round(count(distinct case when timestampdiff(second, CompleteTime, InstockTime) <= (1 * 86400) 
	then CompleteNumber end )/count(distinct CompleteNumber),4) `�ֿ�24Сʱ�����`
from import_data.daily_InStockCheck disc 
join ( select BoxSku ,projectteam as department from wt_products ) tmp on disc.BoxSku = tmp.BoxSku
where CompleteTime < date_add('${NextStartDay}',-1)  and CompleteTime >= date_add('${StartDay}',-1)
	 and WarehouseName = '��ݸ��'
group by grouping sets ((),(department))
)

,t_sendIn24h as ( -- �ֿ�24Сʱ����
select 
	case when department is null THEN '��˾' ELSE department END AS dep
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `�ֿ�24Сʱ������`
from import_data.wt_packagedetail dpd
join import_data.mysql_store ms on ms.Code  = dpd.Shopcode 
where dpd.CreatedTime < '${NextStartDay}' 
		and dpd.CreatedTime >= '${StartDay}'
group by grouping sets ((),(department))
)


-- step3 ����ָ�����ݼ�
, t_merge as (
select 
	'${NextStartDay}' `ͳ������`
	,t_key.dep `�Ŷ�`
	,`�ֿ�24Сʱ�ջ���`
	,`�ֿ�24Сʱ�����`
	,`�ֿ�24Сʱ������`
	,`����7�췢����`
	,`����5�췢����`
-- 	,`׼ʱ������`
	,`ƽ�����������`
	,`2��������`
	,`ƽ��������������`
	,`����3��������`
	,`׼ʱ������`
	,`ƽ��������Ͷ����`	
	,`ͣ��δ����������`
	,`10��δ����������`
	,`�վ�����������`
from t_key
-- left join t_ontimesend on t_key.dep = t_ontimesend.dep
left join t_order_sku on t_key.dep = t_order_sku.dep
left join t_pay2send_days on t_key.dep = t_pay2send_days.dep
left join t_send2deli_days on t_key.dep = t_send2deli_days.dep
left join t_pay2gen_days on t_key.dep = t_pay2gen_days.dep
left join t_online_inXdays on t_key.dep = t_online_inXdays.dep
left join t_ordersend_stat on t_key.dep = t_ordersend_stat.dep
left join t_backorder on t_key.dep = t_backorder.dep
left join t_delay_10days_ord on t_key.dep = t_delay_10days_ord.dep
left join t_ontime_deli_rate on t_key.dep = t_ontime_deli_rate.dep
left join t_instockIn24h on t_key.dep = t_instockIn24h.dep
left join t_receiveIn24h on t_key.dep = t_receiveIn24h.dep
left join t_sendIn24h on t_key.dep = t_sendIn24h.dep
)

select * from t_merge order by `�Ŷ�` desc 

	