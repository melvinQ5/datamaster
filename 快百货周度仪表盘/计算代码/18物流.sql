-- �ֿ�24Сʱ�ջ���
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400)
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `�ֿ�24Сʱ�ջ���`
from import_data.daily_PurchaseRev a
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where scantime < date_add('${NextStartDay}',-1)  and scantime >= date_add('${StartDay}',-1)
	 and b.WarehouseName = '��ݸ��' ;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, ScanTime, CompleteTime) <= (1 * 86400)
	then a.PurchaseOrderNo end )/count(distinct a.PurchaseOrderNo),4) `�ֿ�24Сʱ�ջ���`
from import_data.daily_PurchaseRev a
join import_data.daily_PurchaseOrder b on  a.PurchaseOrderNo = b.PurchaseOrderNo
join ( select BoxSku ,projectteam as department from wt_products ) tmp on b.BoxSku = tmp.BoxSku
where scantime < date_add('${NextStartDay}',-1)  and scantime >= date_add('${StartDay}',-1)
	 and b.WarehouseName = '��ݸ��' ;


-- �ֿ�24Сʱ�����
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`InstockIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, CompleteTime, InstockTime) <= (1 * 86400)
	then CompleteNumber end )/count(distinct CompleteNumber),4) `�ֿ�24Сʱ�����`
from import_data.daily_InStockCheck disc
join ( select BoxSku ,projectteam as department from wt_products ) tmp on disc.BoxSku = tmp.BoxSku
where CompleteTime < date_add('${NextStartDay}',-1)  and CompleteTime >= date_add('${StartDay}',-1)
	 and WarehouseName = '��ݸ��';

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`InstockIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct case when timestampdiff(second, CompleteTime, InstockTime) <= (1 * 86400)
	then CompleteNumber end )/count(distinct CompleteNumber),4) `�ֿ�24Сʱ�����`
from import_data.daily_InStockCheck disc
join ( select BoxSku ,projectteam as department from wt_products ) tmp on disc.BoxSku = tmp.BoxSku
where CompleteTime < date_add('${NextStartDay}',-1)  and CompleteTime >= date_add('${StartDay}',-1)
	 and WarehouseName = '��ݸ��';


-- �ֿ�24Сʱ������
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`ShippedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `�ֿ�24Сʱ������`
from import_data.wt_packagedetail dpd
join import_data.mysql_store ms on ms.Code  = dpd.Shopcode
where dpd.CreatedTime < '${NextStartDay}'
		and dpd.CreatedTime >= '${StartDay}';

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`ShippedIn24hRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(case when timestampdiff(second , CreatedTime, WeightTime) <= 86400
		and timestampdiff(second , CreatedTime, WeightTime) > 0 then 1 end)/count(1),4) `�ֿ�24Сʱ������`
from import_data.wt_packagedetail dpd
join import_data.mysql_store ms on ms.Code  = dpd.Shopcode
where dpd.CreatedTime < '${NextStartDay}'
		and dpd.CreatedTime >= '${StartDay}';

-- 2��������  ����7�췢����
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`CreatedPackageIn2dPayRate`,ShippedIn7dPayRate)
select '${StartDay}' ,'${ReportType}' ,dep2 ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`
	,round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from
	(select ifnull(dep2,'��ٻ�') dep2
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	        from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '����'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	group by grouping sets ((),(dep2))
	) tmp1;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`CreatedPackageIn2dPayRate`,ShippedIn7dPayRate)
select '${StartDay}' ,'${ReportType}' ,nodepathname ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(a_gen_in2d/b_gen_in2d,4) `2��������`
	,round(a_deliv_in7d/b_deliv_in7d,4) `����7�췢����`
from
	(select nodepathname
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_gen_in2d -- 2�������ʷ�ĸ
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) then od_pre.OrderNumber end ) b_deliv_in7d -- 7�췢���ʷ�ĸ
		, count(distinct case when date_add(PayTime, 2) < '${NextStartDay}' and date_add(PayTime, 2) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.CreatedTime) <= (86400 * 2)
			then pd.OrderNumber end ) a_gen_in2d -- 2�������ʷ���
		, count(distinct case when date_add(PayTime, 7) < '${NextStartDay}' and date_add(PayTime, 7) >= date_add('${NextStartDay}',interval -7 day) and timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7�충�������ʷ���
	from
		( -- ��ȡ��30�����ݣ����ڷֱ���ǰ��2�졢5�졢7�����ָ��
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	        from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '����'
		where PayTime < '${NextStartDay}' and PayTime >= date_add('${StartDay}',interval -10 day) -- ����ǰԤ��10������ݣ����ں���������ǰ������
		) od_pre
	left join import_data.PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	group by nodepathname
	) tmp1;


-- 10��δ����������
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
DelayShippedOver10dOrders)
select '${StartDay}' ,'${ReportType}' ,ifnull(ms.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, count(distinct PlatOrderNumber ) `10��δ����������`
from import_data.daily_WeightOrders wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	 from import_data.mysql_store where department regexp '��')  ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1)=ms.Code and OrderStatus <> '����'
where wo.CreateDate = '${NextStartDay}' and PayTime < date_add('${NextStartDay}',interval -10 day)
group by grouping sets ((),(dep2));

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
DelayShippedOver10dOrders)
select '${StartDay}' ,'${ReportType}' ,nodepathname ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, count(distinct PlatOrderNumber ) `10��δ����������`
from import_data.daily_WeightOrders wo
join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	 from import_data.mysql_store where department regexp '��')  ms on wo.SUBSTR(shopcode,instr(shopcode,'-')+1)=ms.Code and OrderStatus <> '����'
where wo.CreateDate = '${NextStartDay}' and PayTime < date_add('${NextStartDay}',interval -10 day)
group by nodepathname;


-- ׼ʱ������
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
OnTimeDeliveryRate)
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `׼ʱ������`
from (
	SELECT dep2
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,ms.*
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
		join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	        from import_data.mysql_store where department regexp '��')  ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4
			and date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- ÿ���賿0�������
		) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	group by grouping sets ((),(dep2))
	) tmp2;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
OnTimeDeliveryRate)
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,4)  as `׼ʱ������`
from (
	SELECT NodePathName
		,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- ׼ʱ����������
		,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- ͳ�ƶ�����
	from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd
	join (
		select Id , ShopCode ,OnTimeDeliveryStatus ,ms.*
		from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc
		join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	        from import_data.mysql_store where department regexp '��')  ms on eaaspc.ShopCode =ms.Code
		where AmazonShopHealthStatus != 4
			and date(CreationTime) = DATE_ADD('${NextStartDay}', interval -1 day) -- ÿ���賿0�������
		) tmp
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
		and MetricsType = 3 -- ָ������(1:����ȱ��ָ��,2:�ͻ�����ָ��,3:׷��ָ��,4:�����������ϵָ��,5:�ͻ�����ָ��,6:�˻�������ָ��,7:��Ʒ��ʵ��Ͷ��,8:��Ʒ��ȫͶ��,9:�ϼ�Υ��,10:֪ʶ��ȨͶ��)
		and DateType = 30 -- ͳ����
	group by NodePathName
	) tmp2;