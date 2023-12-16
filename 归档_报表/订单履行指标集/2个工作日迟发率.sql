--   计算逻辑
--   step1 将本地支付时间转化成该国国家的时间： OrderCountry_paytime = convert_tz(PayTime, 'Asia/Shanghai',对应国家时区)
--   step2 看该国是星期几，以便确定顺延天数： DAYOFWEEK(该国支付时间) 该函数1表示周天，2表示周一，依次类推
--   	顺延规则：次日下单当日不算（+1），次日起给两天配货（+2），如遇周末则顺延（+2）。
--   	举例：中国时间17日（星期六）11点英国站点下单，亚马逊后台显示该国下单时间为17日3点，后台显示给出配送日期为19日至20日（星期二）
--   step3 以中国时间计算2个工作日内发货，比如 timestampdiff(second, 中国最晚发货时间, 中国实际发货时间) <= 86400 * 2
--   step4 两个工作日内发货率



select 1-round(A_cnt/B_cnt,4) `2个工作日迟发率`  
from 
	( SELECT  B_cnt	
	FROM ( SELECT  count(distinct PlatOrderNumber) B_cnt
		from import_data.ods_orderdetails dod join import_data.mysql_store ms on dod.ShopIrobotId =ms.Code and isdeleted = 0
		where PayTime < date_add('${FristDay}',interval -4 day) and PayTime >= date_add('${FristDay}',interval -7-4 day)
		  and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		) tmp3 -- 付款时间推至4天 留够发货时间
	) tb 
JOIN 
( SELECT  A_cnt		
	FROM ( 
		select count(distinct dod.PlatOrderNumber) as A_cnt  -- 当地两个工作日内发货订单数
		from ( 
			select case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
			      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
			      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
			    end as latest_WeightTime -- 处理工作日
			    ,paytime ,DAYOFWEEK(OrderCountry_paytime)
			    ,PlatOrderNumber ,department 
			from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
			    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime ,department 
				from import_data.ods_orderdetails od
				join import_data.mysql_store ms on od.ShopIrobotId =ms.Code and isdeleted = 0
				left join
					(SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area FROM import_data.JinqinSku where monday='2023-12-20' ) js 
					on js.code=right(od.ShopIrobotId ,2) 
				where od.IsDeleted =0 and PayTime < date_add('${FristDay}',interval -4 day) and PayTime >= date_add('${FristDay}',interval -7-4 day)
					and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
			    ) tmp
			) dod
		left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber 
		where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
		) tmp2
) ta

