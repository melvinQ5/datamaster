
-- ׼ʱ������ = ͳ�����ڸ���ķ��Ϸ���ʱЧ�Ķ����� �� ͳ�����ڸ�����ܶ������� 
-- ��ĸ������ʱ����ͳ�����ڵĸ������ ��������ʱ����ǰ��4�죬ɸѡ���δ���ϡ�����������0��
-- ���ӣ�����ʱ����ͳ�����ڵģ������������գ����ù�����ʵ��˳��n�죩�ڷ��������� ����������ʱ����ǰ��4�죬


--   step1 ����˳������n = ���س�ŵ����ʱ�� - ���ظ���ʱ�� ����������������й�����ʱ���ϣ��õ��й�������ʱ�䣺 ��
-- 		�� ������֧��ʱ��ת���ɸù����ҵĸ���ʱ�䣺 OrderCountry_paytime = convert_tz(PayTime, 'Asia/Shanghai',��Ӧ����ʱ��)
--   	�� ˳������n ,���������ù������ڼ����Ա�ȷ��˳�������Ƕ��٣�
--   	˳�ӹ��򣺴����µ����ղ��㣨+1��������������������+2����������ĩ��˳�ӣ�+2����
--   	�������й�ʱ��17�գ���������11��Ӣ��վ���µ�������ѷ��̨��ʾ�ù��µ�ʱ��Ϊ17��3�㣬��̨��ʾ������������Ϊ19����20�գ����ڶ���
--   step2 ���Ϸ���ʱЧ�Ķ�����Χ���й���������ʱ�� < ��ŵ����ʱ��( ���ж�������ʱ�� + ˳������n ) 
-- 		���й�ʱ�����2���������ڷ��������� timestampdiff(second, �й�������ʱ��, �й�ʵ�ʷ���ʱ��) <= 86400 * 2
--   step3 ׼ʱ������ = ͳ�����ڸ���ķ��Ϸ���ʱЧ�Ķ����� �� ͳ�����ڸ�����ܶ�������

select tb.department,round(A_cnt/B_cnt,4) `׼ʱ������` 
from 
	( SELECT CASE WHEN department IS NULL THEN '��˾' ELSE department END AS department, B_cnt	
	FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and IsDeleted = 0 
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
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(PayTime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( PayTime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( PayTime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( PayTime,interval 1+2+1 day )
			    end as latest_WeightTime -- �������� �й�������ʱ��
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department 
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,department 
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and IsDeleted=0 
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area 
					FROM import_data.JinqinSku where monday='2023-12-20' ) js 
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
