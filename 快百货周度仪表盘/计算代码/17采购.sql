 -- 采购单数
 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseOrders`)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 , count(distinct OrderNumber) `采购单数`
from  ( -- 当期采购
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='快百货' and level3_name='采购组' ) ds on wp.OrderPerson = ds.staff_name
    where ordertime  <  '${NextStartDay}'  and ordertime >='${StartDay}' -- 多获取10天数据，以便计算各种指标
        and OrderPerson regexp '杜宇|蒲叶波|王泊霖|赵飞燕|农玥怡'  -- 未计算下单人为 义务月结 或 淘宝专用
    ) t_new_purc;

 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseOrders`)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 , count(distinct OrderNumber) `采购单数`
from  ( -- 当期采购
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='快百货' and level3_name='采购组' ) ds on wp.OrderPerson = ds.staff_name
    where ordertime  <  '${NextStartDay}'  and ordertime >='${StartDay}' -- 多获取10天数据，以便计算各种指标
        and OrderPerson regexp '杜宇|蒲叶波|王泊霖|赵飞燕|农玥怡'  -- 未计算下单人为 义务月结 或 淘宝专用
    ) t_new_purc;


-- 采购当天下单率
 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseIn1dRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(distinct case when timestampdiff(second,GenerateTime,OrderTime)<86400 then OrderNumber end)/count(distinct OrderNumber),4)  'today_order_rate'
from  ( -- 当期采购
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson,GenerateTime,OrderTime
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='快百货' and level3_name='采购组' ) ds on wp.OrderPerson = ds.staff_name
    where OrderTime>=date_add('${StartDay}',interval -2 day) and OrderTime<date_add('${NextStartDay}',interval -2 day)
        and WarehouseName = '东莞仓' and OrderPerson regexp '杜宇|蒲叶波|王泊霖|赵飞燕|农玥怡'  -- 未计算下单人为 义务月结 或 淘宝专用
    ) t_new_purc;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseIn1dRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(distinct case when timestampdiff(second,GenerateTime,OrderTime)<86400 then OrderNumber end)/count(distinct OrderNumber),4)  'today_order_rate'
from  ( -- 当期采购
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson,GenerateTime,OrderTime
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='快百货' and level3_name='采购组' ) ds on wp.OrderPerson = ds.staff_name
    where OrderTime>=date_add('${StartDay}',interval -2 day) and OrderTime<date_add('${NextStartDay}',interval -2 day)
        and WarehouseName = '东莞仓' and OrderPerson regexp '杜宇|蒲叶波|王泊霖|赵飞燕|农玥怡'  -- 未计算下单人为 义务月结 或 淘宝专用
    ) t_new_purc;


-- 采购5天到货率
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn5dPurcRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率`
from (
	select
		OrderNumber ,BoxSku
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
		end as in5days_rev_numb -- 满足5天到货的下单号
		, case when instockquantity = 0 and IsComplete = '是' then null else OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
    from import_data.wt_purchaseorder wp
    where OrderTime>=date_add('${StartDay}',interval -5 day) and OrderTime<date_add('${NextStartDay}',interval -5 day)
        and WarehouseName = '东莞仓'
    and OrderPerson regexp '杜宇|蒲叶波|王泊霖|赵飞燕|农玥怡'  -- 未计算下单人为 义务月结 或 淘宝专用
	) tmp;


insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn5dPurcRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率`
from (
	select
		OrderNumber ,BoxSku
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单(没扫描时间，即没有收货表记录)
		end as in5days_rev_numb -- 满足5天到货的下单号
		, case when instockquantity = 0 and IsComplete = '是' then null else OrderNumber end as actual_ord_numb -- 去掉人工完结的下单单号
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='快百货' and level3_name='采购组' ) ds on wp.OrderPerson = ds.staff_name
    where OrderTime>=date_add('${StartDay}',interval -5 day) and OrderTime<date_add('${NextStartDay}',interval -5 day)
        and WarehouseName = '东莞仓' and OrderPerson regexp '杜宇|蒲叶波|王泊霖|赵飞燕|农玥怡'  -- 未计算下单人为 义务月结 或 淘宝专用
	) tmp;