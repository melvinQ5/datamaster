-- 筛选平台订单迟发考核对应店铺的订单计算

select round(a_gen_in2d/b_gen_in2d,4) `2天生包率`, round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`, round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from  
	(select 
	count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
	, count(distinct case when date_add(PayTime, 2) < '${FristDay}' and date_add(PayTime, 2) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2) 
		then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
	, count(distinct case when date_add(PayTime, 5) < '${FristDay}' and date_add(PayTime, 5) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	, count(distinct case when date_add(PayTime, 7) < '${FristDay}' and date_add(PayTime, 7) >= date_add('${FristDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7) 
		and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
	from 
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime ,ms.department
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '正常' and wo.IsDeleted = 0 
		where PayTime < '${FristDay}' and PayTime >= date_add('${FristDay}',interval -7-10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre 
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku 
) tmp1
