
-- --------------------------����-------------
with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select department as dep from import_data.mysql_store
union
select split_part(NodePathNameFull,'>',2) from import_data.mysql_store
union
select NodePathName from import_data.mysql_store
)

-- ׼ʱ������
,ontimesend as (
select tb.department,round(A_cnt/B_cnt,4) `׼ʱ������` 
from 
	( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, B_cnt	
	FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
		 group by grouping sets ((),(department))
		) tmp3 -- ����ʱ������4�� ��������ʱ��
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- ���������������ڷ���������
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- ��������
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department 
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,department 
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
					and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
union 
select tb.department,round(A_cnt/B_cnt,4) `׼ʱ������` -- `2�������շ�����` 
from 
	( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, B_cnt	
	FROM ( SELECT left(ms.NodePathName,3) as department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
		 group by grouping sets ((),(left(NodePathName,3)))
		) tmp3 -- ����ʱ������4�� ��������ʱ��
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- ���������������ڷ���������
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- ��������
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,left(NodePathName,3) as department
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
					and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
union 
select tb.department,round(A_cnt/B_cnt,4) `׼ʱ������` -- `2�������շ�����` 
from 
	( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, B_cnt	
	FROM ( SELECT NodePathName as department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code 
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
		 group by grouping sets ((),(NodePathName))
		) tmp3 -- ����ʱ������4�� ��������ʱ��
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- ���������������ڷ���������
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- ��������
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,NodePathName as department
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
					and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0��ʾ ������������ʱ���͹�����
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
),


-- ׼ʱ��Ͷ��
OnTimeDeliveryRate as (
select CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `׼ʱ��Ͷ��`
from (
	SELECT department
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,department
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	 	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and to_date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	group by grouping sets ((),(department))
) tmp2
union 
select CASE WHEN NodePathName IS NULL THEN '��˾' ELSE NodePathName END AS NodePathName
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as OnTimeDeliveryRate -- ׼ʱ��Ͷ��
from (
	SELECT NodePathName
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
		-- ItemType (1:����ȱ����,2:1: ���淴����,3:2: ����ѷ�̳ǽ��ױ�������,4:3: ���ÿ��ܸ���,5:1: �ӳ���,6:2: ȡ����,7:3: �˿���,8:1: ��Ч׷����,9:2: ׼ʱ������,10:1: �ͻ�����ָ��,11:�˻���������,12:1: �����˻�������,13:2: �ӳٻظ���,14:3: ��Ч�ܾ���)
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,NodePathName
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	 	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
		where AmazonShopHealthStatus != 4 
			and CreationTime >='${NextStartDay}' and CreationTime < DATE_ADD('${NextStartDay}', interval 1 day) -- ÿ���賿0�������
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	group by grouping sets ((),(NodePathName))
) tmp2
) 


-- ��������������
-- select lt.*
-- from  -- �켣������ʱ�� ò��ֻ�ܵ�0128
-- left join ( select department , count(distinct case when OnLineHour <= 72 then PackageNumber end ) 
-- from erp_logistic_logistics_tracking lt
-- join import_data.mysql_store ms on lt.ShopCode =ms.Code 
-- where lt.WeightTime >= DATE_ADD('${StartDay}', interval -3 day) and lt.WeightTime  <  DATE_ADD( '${NextStartDay}' , interval -3 day) 
-- group by department
-- ) 

-- �ɹ����� �ɹ���� �ɹ��˷�
, purchase as (
select case when department IS NULL THEN '��˾' ELSE department END AS department 
	,round(sum(Price - DiscountedPrice)) `�ɹ���Ʒ���` , round(sum(SkuFreight)) `�ɹ��˷�`	,count(distinct OrderNumber) `�ɹ�����`
	,round(count(distinct OrderNumber)/datediff('${NextStartDay}','${StartDay}')) `�վ��ɹ�����`
from wt_purchaseorder wp 
join (select BoxSku , projectteam as department  from import_data.wt_products where IsDeleted = 0 ) wp2 
	on wp.BoxSku =wp2.BoxSku 
where ordertime  <  '${NextStartDay}'  and ordertime >= '${StartDay}' and WarehouseName = '��ݸ��' 
group by grouping sets ((),(department))
) 


-- �ɹ�3�쵽����
-- , purchase2warehouse as (
select 
	case when department IS NULL THEN '��˾' ELSE department END AS department
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�3�쵽����` 
from (
select 
	dpo.OrderNumber,dpo.BoxSku ,department
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 3 then dpo.OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
	when scantime is null and instockquantity > 0 and CompleteTime is not null 
	and timestampdiff(second, ordertime, CompleteTime) < 86400 * 3 then dpo.OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
	end as in5days_rev_numb -- ����5�쵽�����µ���
	, case when instockquantity = 0 and IsComplete = '��' then null else dpo.OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber
join ( select BoxSku ,projectteam as department from wt_products ) tmp on dpo.BoxSku = tmp.BoxSku
where ordertime >= date_add('${StartDay}',interval -3 day) and ordertime < date_add('${NextStartDay}',interval -3 day) and WarehouseName = '��ݸ��'
) tmp 
group by grouping sets ((),(department))
) 

-- �ɹ�ƽ����������
, avg_purchase2warehouse_time as (
select case when department IS NULL THEN '��˾' ELSE department END AS department
	, sum(rev_days)/count(DISTINCT OrderNumber) `ƽ���ɹ��ջ�����`
from (
	select OrderNumber ,department ,rev_days
	from ( 
		select 
			dpo.OrderNumber ,department
			, case when scantime is not null then timestampdiff(second, ordertime, scantime)/86400  -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
				when scantime is null and instockquantity > 0 and CompleteTime is not null 
				then timestampdiff(second, ordertime, CompleteTime)/86400  -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
				end as rev_days
		from import_data.daily_PurchaseOrder dpo left join import_data.daily_PurchaseRev  pr on dpo.OrderNumber = pr.OrderNumber
		left join ( select BoxSku ,projectteam as department from wt_products ) tmp on dpo.BoxSku = tmp.BoxSku
		where CompleteTime < '${NextStartDay}' and CompleteTime >= '${StartDay}' and WarehouseName = '��ݸ��' 
		) po_pre
	where rev_days is not null 
	group by department ,OrderNumber ,rev_days
	) tmp 
group by grouping sets ((department))
)


-- ������ ����5�췢���� ����7�췢����
, ordersend as (
select department 
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
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
			,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${NextStartDay}',interval -7-10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
	group by grouping sets ((),(department))
) tmp1
union 
select dep2 
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  
	(select dep2 
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
				,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
			where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
			) od_pre 
		left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
		group by dep2
	) tmp1
union 
select NodePathName 
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`, round(a_deliv_in5d/b_deliv_in5d,4) `����5�췢����`, round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from  
	(select NodePathName 
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
				,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
			from import_data.wt_orderdetails wo 
			join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����' and ms.department = '��ٻ�'  and wo.IsDeleted = 0 
			where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
			) od_pre 
		left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
		group by NodePathName
	) tmp1
) ,
-- group by grouping sets ((),(department))


-- 24Сʱ������
sendIn24h as (
select 
	case when department is null THEN '��˾' ELSE department END AS department
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${NextStartDay}' 
		and dpd.CreatedTime >= '${StartDay}'
join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
group by grouping sets ((),(department))
union 
select 
	case when NodePathName is null THEN '��˾' ELSE NodePathName END AS NodePathName
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400 
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `24Сʱ������`
from import_data.daily_PackageDetail dpd
join import_data.daily_OrderDetails dod 
	on dpd.OrderNumber = dod.OrderNumber 
		and dpd.CreatedTime < '${NextStartDay}' 
		and dpd.CreatedTime >= '${StartDay}'
join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
group by grouping sets ((),(NodePathName))
) ,

-- 24Сʱ�ջ���
receiveIn24h as (
select
	case when department is null THEN '��˾' ELSE department END AS department
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400) 
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `24Сʱ�ջ���`
from import_data.daily_PurchaseRev a 
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo 
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where date_add(scantime, 1) < '${NextStartDay}'  and date_add(scantime, 1) >= '${StartDay}'
	 and b.WarehouseName = '��ݸ��'
group by grouping sets ((),(department))
) , 


-- ����ʽ�ռ��
warehouse_stat as (
select a.department
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`),0) `���زֿ���ʽ�ռ��`
	, round((`��;��Ʒ�ɹ����`+`��;��Ʒ�ɹ��˷�`+`�ڲֲ�Ʒ���`)/`���������ɹ����`*datediff('${NextStartDay}','${StartDay}'),1) `�����ת����`
	,`���������ɹ����`
	,`�ڲ�sku����`,`�ڲ�sku��` 
	,`��;��Ʒ�ɹ����`, `��;��Ʒ�ɹ��˷�` , `�ڲֲ�Ʒ���`
from
(
select case when department is null THEN '��˾' ELSE department END AS department
	, sum(Price - DiscountedPrice) `��;��Ʒ�ɹ����` , ifnull(sum(SkuFreight),0) `��;��Ʒ�ɹ��˷�`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp 
	join ( select BoxSku ,projectteam as department from wt_products ) tmp on wp.BoxSku = tmp.BoxSku 
	where ordertime < '${NextStartDay}'
		and isOnWay = "��" and WarehouseName = '��ݸ��'
	) tmp	
group by grouping sets ((),(department))
) a 

left join (
	SELECT case when department is null THEN '��˾' ELSE department END AS department  
		,sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���`, sum(ifnull(TotalInventory,0)) `�ڲ�sku����`, count(*) `�ڲ�sku��` 
	FROM ( -- local_warehouse ���زֱ�
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products ) tmp on wi.BoxSku = tmp.BoxSku 
		where WarehouseName = '��ݸ��' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
		)  tmp 
	group by grouping sets ((),(department))
) b on a.department = b.department

left join (	
	select case when department is null THEN '��˾' ELSE department END AS department 
		, round(sum(pc)) `���������ɹ����` 
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,department
		from import_data.daily_PackageDetail pd 
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.ods_orderdetails od 
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0 
				and TransactionType ='����' and orderstatus != '����' and totalgross > 0  
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' and pd.WarehouseName='��ݸ��'
		) a 
	group by grouping sets ((),(department))
) c on a.department = c.department
) ,


-- ���϶����� , �վ�������
-- ����ʱ��Ϊ��7��Ķ�����״̬=������ƥ���˿�ԭ���ֲ��ǿͻ�����ȡ���Ķ���
OrderCancelRate as (
SELECT case when department IS NULL THEN '��˾' ELSE department END AS department 
	,round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber  end)/count(distinct PlatOrderNumber),4) as `���϶�����`
	,round(count(DISTINCT CASE when OrderStatus != '����' and TransactionType ='����' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `�վ�������`
from import_data.ods_orderdetails oo  
join import_data.mysql_store ms on oo.ShopIrobotId  =ms.Code 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and TransactionType <>'����'
group by grouping sets ((department))
union 
SELECT case when NodePathName IS NULL THEN '��˾' ELSE NodePathName END AS NodePathName 
	,round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `���϶�����`
	,round(count(DISTINCT CASE when OrderStatus != '����' and TransactionType ='����' and OrderTotalPrice >0 then OrderNumber end)/ DATEDIFF('${NextStartDay}','${StartDay}'),0)  as `�վ�������`
from import_data.ods_orderdetails oo  
join import_data.mysql_store ms on oo.ShopIrobotId  =ms.Code 
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and TransactionType <>'����'
group by grouping sets ((NodePathName))
)

, over10orders as ( -- 10��δ���������� =  ͳ��T-10~T-20δ������������ͳ��T-10~T-20�վ��������
select  Department, count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end) `10��δ��������`
--  	,count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end)/(count(distinct  PlatOrderNumber)/10) `10��δ��������`
from ods_orderdetails wo 
join import_data.mysql_store ms on wo.ShopIrobotId  =ms.Code 
where IsDeleted = 0 and PayTime < date_add(CURRENT_DATE(),-10) and PayTime >= date_add(CURRENT_DATE(),interval -10-10 day) 
	and TransactionType ="����" and OrderStatus !='����'
group by Department 
union 
select  left(NodePathName,3) as department, count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end) `10��δ��������`
--  	,count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end)/(count(distinct  PlatOrderNumber)/10) `10��δ��������`
from ods_orderdetails wo 
join import_data.mysql_store ms on wo.ShopIrobotId  =ms.Code 
where IsDeleted = 0 and PayTime < date_add(CURRENT_DATE(),-10) and PayTime >= date_add(CURRENT_DATE(),interval -10-10 day) 
	and TransactionType ="����" and OrderStatus !='����'
group by left(NodePathName,3)
union 
select  NodePathName as department, count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end) `10��δ��������`
--  	,count(distinct case when ShipTime = '2000-01-01 00:00:00'then PlatOrderNumber end)/(count(distinct  PlatOrderNumber)/10) `10��δ��������`
from ods_orderdetails wo 
join import_data.mysql_store ms on wo.ShopIrobotId  =ms.Code 
where IsDeleted = 0 and PayTime < date_add(CURRENT_DATE(),-10) and PayTime >= date_add(CURRENT_DATE(),interval -10-10 day) 
	and TransactionType ="����" and OrderStatus !='����'
group by grouping sets ((NodePathName)) 

-- ֱ��ʹ���µı�
select  Department, count(distinct PlatOrderNumber ) `10��δ��������`
from daily_WeightOrders wo
join import_data.mysql_store ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1) =ms.Code
where CreateDate = '${EndDay}' and OrderStatus <> '����'
	and PayTime >= date_add('${EndDay}',interval -20 day)
	and PayTime < date_add('${EndDay}',interval -10 day)
group by Department

)

-- ͣ��״̬δ���������� (����ͳ����δ�����Ҷ�������ͣ����Ʒ�Ķ�����)
-- , t_stop_sku_order as (
-- select department , count (1) from (
-- select PlatOrderNumber ,department
-- from import_data.daily_WeightOrders dwo
-- join (select BoxSku , ProjectTeam as department from import_data.wt_products wp -- 2=ͣ�� 0=���� 3=ͣ�� 4=��ʱȱ�� 5=���
-- 	where ProductStatus = 2 ) wp 
-- 	on dwo.BoxSku = wp.BoxSku and dwo.CreateDate = current_date()
-- group by PlatOrderNumber ,department
-- ) tmp 
-- group by department
-- )

select *
from (
select t_key.dep ,`׼ʱ��Ͷ��` , `׼ʱ������` ,`�ɹ���Ʒ���`,`�ɹ��˷�`, `�ɹ�����`,`�վ��ɹ�����`,`�ɹ�3�쵽����` ,`ƽ���ɹ��ջ�����`
	,`2��������` ,`����5�췢����` ,`����7�췢����` ,`24Сʱ������`,`24Сʱ�ջ���`,`���زֿ���ʽ�ռ��`, `�����ת����`
	,`�ڲ�sku����`,`�ڲ�sku��` ,`��;��Ʒ�ɹ����`, `��;��Ʒ�ɹ��˷�` , `�ڲֲ�Ʒ���` ,`���϶�����` ,`�վ�������`,`10��δ��������`
from t_key
left join ontimesend on t_key.dep = ontimesend.department
left join OnTimeDeliveryRate on t_key.dep = OnTimeDeliveryRate.department
left join purchase on t_key.dep = purchase.department
left join purchase2warehouse on t_key.dep = purchase2warehouse.department
left join avg_purchase2warehouse_time on t_key.dep = avg_purchase2warehouse_time.department
left join ordersend on t_key.dep = ordersend.department
left join sendIn24h on t_key.dep = sendIn24h.department
left join receiveIn24h on t_key.dep = receiveIn24h.department
left join warehouse_stat on t_key.dep = warehouse_stat.department
left join OrderCancelRate on t_key.dep = OrderCancelRate.department
left join over10orders on t_key.dep = over10orders.department 
-- where t_key.department regexp '��'
-- where t_key.department regexp '������|TMH����1��|TMH����3��'
) tmp
order by dep desc

-- ���Ϳ��ռ�� 
-- ��� InventoryAgeAmount180 + InventoryAgeAmount270 ���ݣ��жϿ�������
-- with tmp as (
-- select wi.boxsku
-- 	, SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver) `����180��������`
-- 	, a.salesvolun6month `��6��������`,a.daily180 `��180���վ�����`
-- 	, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver))/a.daily180,0) `��������` 
-- 	, round((SUM(wi.InventoryAgeOver))/a.daily180,0) `����365�첿�ֵĿ�������` 
-- 	, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365))/a.daily180,0) `180��365�Ŀ�������` 
-- from import_data.WarehouseInventory  wi
-- left join 
-- 	(select op.boxsku
-- 		,sum(op.SaleCount) salesvolun6month
-- 		,round(sum(op.SaleCount)/180,2) daily180 -- 180���վ�����
-- 	from import_data.OrderProfitSettle op
-- 	where op.SettlementTime>=date_add('2023-01-01',interval -5 month) and op.SettlementTime<'2023-02-01'
-- 	and op.ShipWarehouse='��ݸ��' 
-- 	group by op.boxsku) a 
-- on wi.boxsku=a.boxsku
-- where  wi.ReportType='�±�' and wi.monday='2023-01-01' 
-- group by wi.boxsku,a.salesvolun6month,a.daily180 having `����180��������`>0
-- ) 
-- 
-- , daizhi as (  -- ���Ϳ��
-- select 
-- 	sum(case 
-- 		when InventoryAgeOver>0 then InventoryAgeOver 
-- 		when InventoryAge270*InventoryAge365 > 0 and `��������` > 365 then (InventoryAge270+InventoryAge365)
-- 		when InventoryAge270*InventoryAge365 > 0 and `��������` > 180 and `��������` <=365  then (InventoryAge270+InventoryAge365)*0.5
-- 	end) `���Ϳ��`
-- from import_data.WarehouseInventory wi 
-- left join tmp on wi.BoxSku = tmp.BoxSku
-- where wi.ReportType='�±�' and wi.monday='2023-01-01' 
-- ) 
-- 
-- , lw as (
-- select (`�ɹ���Ʒ���`+`�ɹ��˷�`+`�ڲֲ�Ʒ���`) as `����ʽ�ռ��`
-- from
-- (
-- select sum(Price - DiscountedPrice) `�ɹ���Ʒ���` , sum(SkuFreight) `�ɹ��˷�`
-- from (
-- 	select Price ,DiscountedPrice , SkuFreight
-- 	from wt_purchaseorder wp 
-- 	where ordertime  < '${NextStartDay}' and ordertime >= date_add('${NextStartDay}',interval -1 month) 
-- 		and isOnWay = "��"
-- 	) tmp
-- ) a 
-- , (
-- 	SELECT  sum(ifnull(TotalPrice,0)) `�ڲֲ�Ʒ���`, sum(ifnull(TotalInventory,0)) `�ڲ�sku����`, count(*) `�ڲ�sku��` 
-- 	FROM ( -- local_warehouse ���زֱ�
-- 		select TotalPrice, TotalInventory
-- 		FROM import_data.WarehouseInventory wi
-- 		where WarehouseName = '��ݸ��' and TotalInventory > 0
-- 			and Monday  < '${NextStartDay}' and Monday >= date_add('${NextStartDay}',interval -1 month) 
-- 		and ReportType = '�±�'
-- 		)  tmp 
-- ) b 
-- )
-- 
-- select `���Ϳ��`/`����ʽ�ռ��`  -- 0.02
-- from lw,daizhi �ɹ���Ʒ���
-- 
-- 
--  	
-- select * 
-- from ods_orderdetails wo 
-- where IsDeleted = 0 and PayTime < '2023-01-31' and PayTime >= '2023-01-01' and ShipmentStatus = 'δ����'
-- 	and TransactionType ="����" and OrderStatus !='����'