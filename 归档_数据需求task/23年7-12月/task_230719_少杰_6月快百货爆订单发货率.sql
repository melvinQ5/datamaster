
select '6月快百货' 统计范围 ,round(a_gen_in2d/b_gen_in2d,4) `2天生包率`
	,round(a_deliv_in5d/b_deliv_in5d,4) `订单5天发货率`
from
	(select count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	from
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	        from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '付款'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	) tmp1



select '6月快百货爆旺款' 统计范围 , round(a_gen_in2d/b_gen_in2d,4) `爆旺款2天生包率`
	,round(a_deliv_in5d/b_deliv_in5d,4) `爆旺款订单5天发货率`
from
	(select count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in5d -- 5天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 5) < '${NextStartDay}' and date_add(PayTime, 5) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	from
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	        from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '付款'
		join ( select spu from import_data.dep_kbh_product_level  where Department = '快百货'  and prod_level regexp '爆款|旺款' group by spu ) dkpl on dkpl.SPU = wo.Product_SPU
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- 再往前预留10天的数据，便于后续计算往前推天数
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	) tmp1