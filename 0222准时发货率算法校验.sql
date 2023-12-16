
-- 准时发货率 = 统计期内付款的符合发货时效的订单数 ÷ 统计期内付款的总订单数。 
-- 分母：付款时间在统计期内的付款订单数 （按付款时间往前推4天，筛选付款、未作废、订单金额大于0）
-- 分子：付款时间在统计期内的，且两个工作日（按该国星期实际顺延n天）内发货订单数 订单表按付款时间往前推4天，


--   step1 计算顺延天数n = 当地承诺发货时间 - 当地付款时间 （把这个天数加在中国付款时间上，得到中国最晚发货时间： ）
-- 		① 将本地支付时间转化成该国国家的付款时间： OrderCountry_paytime = convert_tz(PayTime, 'Asia/Shanghai',对应国家时区)
--   	② 顺延天数n ,做法：看该国是星期几，以便确定顺延天数是多少，
--   	顺延规则：次日下单当日不算（+1），次日起给两天配货（+2），如遇周末则顺延（+2）。
--   	举例：中国时间17日（星期六）11点英国站点下单，亚马逊后台显示该国下单时间为17日3点，后台显示给出配送日期为19日至20日（星期二）
--   step2 符合发货时效的订单范围：中国订单发货时间 < 承诺发货时间( 塞盒订单发货时间 + 顺延天数n ) 
-- 		以中国时间计算2个工作日内发货，比如 timestampdiff(second, 中国最晚发货时间, 中国实际发货时间) <= 86400 * 2
--   step3 准时发货率 = 统计期内付款的符合发货时效的订单数 ÷ 统计期内付款的总订单数。

select tb.department,round(A_cnt/B_cnt,4) `准时发货率` 
from 
	( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, B_cnt	
	FROM ( SELECT ms.department, count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and IsDeleted = 0 
		where PayTime < date_add('${NextStartDay}',interval -4 day) and PayTime >= date_add('${StartDay}',interval -4 day)
		  and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		 group by grouping sets ((),(department))
		) tmp3 -- 付款时间推至4天 留够发货时间
	) tb 
LEFT JOIN 
( SELECT CASE WHEN department IS NULL THEN '公司' ELSE department END AS department, A_cnt		
	FROM ( 
		select department, count(distinct dod.PlatOrderNumber) as A_cnt  -- 当地两个工作日内发货订单数
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(PayTime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( PayTime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( PayTime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( PayTime,interval 1+2+1 day )
			    end as latest_WeightTime -- 处理工作日 中国最晚发货时间
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
					and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
		group by grouping sets ((),(department))
		) tmp2
) ta
ON ta.department =tb.department
