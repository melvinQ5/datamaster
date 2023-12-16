 -- �ɹ�����
 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseOrders`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 , count(distinct OrderNumber) `�ɹ�����`
from  ( -- ���ڲɹ�
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='��ٻ�' and level3_name='�ɹ���' ) ds on wp.OrderPerson = ds.staff_name
    where ordertime  <  '${NextStartDay}'  and ordertime >='${StartDay}' -- ���ȡ10�����ݣ��Ա�������ָ��
        and OrderPerson regexp '����|��Ҷ��|������|�Է���|ũ�h��'  -- δ�����µ���Ϊ �����½� �� �Ա�ר��
    ) t_new_purc;

 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseOrders`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 , count(distinct OrderNumber) `�ɹ�����`
from  ( -- ���ڲɹ�
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='��ٻ�' and level3_name='�ɹ���' ) ds on wp.OrderPerson = ds.staff_name
    where ordertime  <  '${NextStartDay}'  and ordertime >='${StartDay}' -- ���ȡ10�����ݣ��Ա�������ָ��
        and OrderPerson regexp '����|��Ҷ��|������|�Է���|ũ�h��'  -- δ�����µ���Ϊ �����½� �� �Ա�ר��
    ) t_new_purc;


-- �ɹ������µ���
 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseIn1dRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(distinct case when timestampdiff(second,GenerateTime,OrderTime)<86400 then OrderNumber end)/count(distinct OrderNumber),4)  'today_order_rate'
from  ( -- ���ڲɹ�
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson,GenerateTime,OrderTime
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='��ٻ�' and level3_name='�ɹ���' ) ds on wp.OrderPerson = ds.staff_name
    where OrderTime>=date_add('${StartDay}',interval -2 day) and OrderTime<date_add('${NextStartDay}',interval -2 day)
        and WarehouseName = '��ݸ��' and OrderPerson regexp '����|��Ҷ��|������|�Է���|ũ�h��'  -- δ�����µ���Ϊ �����½� �� �Ա�ר��
    ) t_new_purc;

insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`PurchaseIn1dRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(distinct case when timestampdiff(second,GenerateTime,OrderTime)<86400 then OrderNumber end)/count(distinct OrderNumber),4)  'today_order_rate'
from  ( -- ���ڲɹ�
    select OrderNumber ,Price ,SkuFreight ,DiscountedPrice,OrderPerson,GenerateTime,OrderTime
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='��ٻ�' and level3_name='�ɹ���' ) ds on wp.OrderPerson = ds.staff_name
    where OrderTime>=date_add('${StartDay}',interval -2 day) and OrderTime<date_add('${NextStartDay}',interval -2 day)
        and WarehouseName = '��ݸ��' and OrderPerson regexp '����|��Ҷ��|������|�Է���|ũ�h��'  -- δ�����µ���Ϊ �����½� �� �Ա�ר��
    ) t_new_purc;


-- �ɹ�5�쵽����
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn5dPurcRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����`
from (
	select
		OrderNumber ,BoxSku
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
		end as in5days_rev_numb -- ����5�쵽�����µ���
		, case when instockquantity = 0 and IsComplete = '��' then null else OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
    from import_data.wt_purchaseorder wp
    where OrderTime>=date_add('${StartDay}',interval -5 day) and OrderTime<date_add('${NextStartDay}',interval -5 day)
        and WarehouseName = '��ݸ��'
    and OrderPerson regexp '����|��Ҷ��|������|�Է���|ũ�h��'  -- δ�����µ���Ϊ �����½� �� �Ա�ר��
	) tmp;


insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
`RecivedIn5dPurcRate`)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `�ɹ�5�쵽����`
from (
	select
		OrderNumber ,BoxSku
		, case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then OrderNumber -- ��ɨ��ʱ�䣬��ɨ��ʱ�� - ����ʱ��С��5�� �Ĳɹ�����
		when scantime is null and instockquantity > 0 and CompleteTime is not null
		and timestampdiff(second, ordertime, CompleteTime) < 86400 * 5 then OrderNumber -- û��ɨ��ʱ�䣬�������������, �����ʱ�� - ����ʱ��С��5�� �Ĳɹ�����(ûɨ��ʱ�䣬��û���ջ����¼)
		end as in5days_rev_numb -- ����5�쵽�����µ���
		, case when instockquantity = 0 and IsComplete = '��' then null else OrderNumber end as actual_ord_numb -- ȥ���˹������µ�����
    from import_data.wt_purchaseorder wp
--     left join ( select staff_name, level2_name,level3_name from import_data.dim_staff where  department='��ٻ�' and level3_name='�ɹ���' ) ds on wp.OrderPerson = ds.staff_name
    where OrderTime>=date_add('${StartDay}',interval -5 day) and OrderTime<date_add('${NextStartDay}',interval -5 day)
        and WarehouseName = '��ݸ��' and OrderPerson regexp '����|��Ҷ��|������|�Է���|ũ�h��'  -- δ�����µ���Ϊ �����½� �� �Ա�ר��
	) tmp;