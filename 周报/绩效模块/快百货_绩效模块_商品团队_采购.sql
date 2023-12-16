--  见美编N天
 
with 
t_new_purc as ( -- 当期采购
select 
	wp.BoxSku ,wp.OrderPerson ,OrderNumber ,ordertime ,WarehouseName ,Price ,SkuFreight ,DiscountedPrice ,Quantity
	,instockquantity ,CompleteTime ,IsComplete ,scantime
	,wpt.projectteam as department ,wpt.IsDeleted as wpt_isdeleted
	, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
		end as in5days_rev_numb -- 满足5天到货的下单号
	, case when instockquantity = 0 and IsComplete = '是' then null else OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
from import_data.wt_purchaseorder wp 
join ( select BoxSku ,projectteam ,IsDeleted from wt_products where projectteam = '快百货') wpt on wp.BoxSku = wpt.BoxSku
where ordertime >= '${StartDay}' and ordertime < '${NextStartDay}'
	and WarehouseName = '东莞仓'
	and OrderPerson in ('蒲叶波','余小梅','赵飞燕','农玥怡','王泊霖')
)

-- 统计
select 
	replace(concat(right(to_date('${StartDay}'),5),
		'至',right(to_date(date_add('${NextStartDay}' ,-1)),5)),'-','') `下单时间范围`
	, CURRENT_DATE()  `统计日期`
	, OrderPerson `采购下单人员`
	, count(distinct actual_ord_numb) `统计下单数`
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from t_new_purc
group by OrderPerson



