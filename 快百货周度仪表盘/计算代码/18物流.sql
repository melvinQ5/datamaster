-- 仓库24小时收货率
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400)
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `仓库24小时收货率`
from import_data.daily_PurchaseRev a
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where scantime < date_add('${NextStartDay}',-1)  and scantime >= date_add('${StartDay}',-1)
	 and b.WarehouseName = '东莞仓' ;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400)
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `仓库24小时收货率`
from import_data.daily_PurchaseRev a
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where scantime < date_add('${NextStartDay}',-1)  and scantime >= date_add('${StartDay}',-1)
	 and b.WarehouseName = '东莞仓' ;


-- 仓库24小时入库率
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`InstockIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, CompleteTime, InstockTime) <= (1 * 86400)
	then CompleteNumber end )/count(distinct CompleteNumber),4) `仓库24小时入库率`
from import_data.daily_InStockCheck disc
join ( select BoxSku ,projectteam as department from wt_products ) tmp on disc.BoxSku = tmp.BoxSku
where CompleteTime < date_add('${NextStartDay}',-1)  and CompleteTime >= date_add('${StartDay}',-1)
	 and WarehouseName = '东莞仓';

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`InstockIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, CompleteTime, InstockTime) <= (1 * 86400)
	then CompleteNumber end )/count(distinct CompleteNumber),4) `仓库24小时入库率`
from import_data.daily_InStockCheck disc
join ( select BoxSku ,projectteam as department from wt_products ) tmp on disc.BoxSku = tmp.BoxSku
where CompleteTime < date_add('${NextStartDay}',-1)  and CompleteTime >= date_add('${StartDay}',-1)
	 and WarehouseName = '东莞仓';


-- 仓库24小时发货率
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`ShippedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `仓库24小时发货率`
from import_data.wt_packagedetail dpd
join import_data.mysql_store ms on ms.Code  = dpd.Shopcode
where dpd.CreatedTime < '${NextStartDay}'
		and dpd.CreatedTime >= '${StartDay}';

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`ShippedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `仓库24小时发货率`
from import_data.wt_packagedetail dpd
join import_data.mysql_store ms on ms.Code  = dpd.Shopcode
where dpd.CreatedTime < '${NextStartDay}'
		and dpd.CreatedTime >= '${StartDay}';

-- 2天生包率  订单7天发货率
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`CreatedPackageIn2dPayRate`,ShippedIn7dPayRate)
select '${StartDay}' ,'${ReportType}' ,dep2 ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(a_gen_in2d/b_gen_in2d,4) `2天生包率`
	,round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from
	(select ifnull(dep2,'快百货') dep2
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
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
	group by grouping sets ((),(dep2))
	) tmp1;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`CreatedPackageIn2dPayRate`,ShippedIn7dPayRate)
select '${StartDay}' ,'${ReportType}' ,nodepathname ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(a_gen_in2d/b_gen_in2d,4) `2天生包率`
	,round(a_deliv_in7d/b_deliv_in7d,4) `订单7天发货率`
from
	(select nodepathname
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2天生包率分母
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7天发货率分母
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2天生包率分子
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
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
	group by nodepathname
	) tmp1;


-- 10天未发货订单数
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
DelayShippedOver10dOrders)
select '${StartDay}' ,'${ReportType}' ,ifnull(ms.dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, count(distinct PlatOrderNumber ) `10天未发货订单数`
from import_data.daily_WeightOrders wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	 from import_data.mysql_store where department regexp '快')  ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1)=ms.Code and OrderStatus <> '作废'
where wo.CreateDate = '${NextStartDay}' and PayTime < date_add('${NextStartDay}',interval -10 day)
group by grouping sets ((),(dep2));

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
DelayShippedOver10dOrders)
select '${StartDay}' ,'${ReportType}' ,nodepathname ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, count(distinct PlatOrderNumber ) `10天未发货订单数`
from import_data.daily_WeightOrders wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	 from import_data.mysql_store where department regexp '快')  ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1)=ms.Code and OrderStatus <> '作废'
where wo.CreateDate = '${NextStartDay}' and PayTime < date_add('${NextStartDay}',interval -10 day)
group by nodepathname;


-- 准时交货率
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
OnTimeDeliveryRate)
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `准时交货率`
from (
	SELECT dep2
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,ms.*
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
		join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	        from import_data.mysql_store where department regexp '快')  ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4
			and date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- 每天凌晨0点后跑数
		) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 30 -- 统计期
	group by grouping sets ((),(dep2))
	) tmp2;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
OnTimeDeliveryRate)
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `准时交货率`
from (
	SELECT NodePathName
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,ms.*
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
		join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	        from import_data.mysql_store where department regexp '快')  ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4
			and date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- 每天凌晨0点后跑数
		) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
		and DateType = 30 -- 统计期
	group by NodePathName
	) tmp2;