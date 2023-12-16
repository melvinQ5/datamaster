
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	BadDebtAmount ,BadDebtRate)
select '${StartDay}' ,'${ReportType}' ,Team ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,B.FrozenAmountUs
	,ifnull(round(B.FrozenAmountUs / A.TotalGross, 4), 0) as BadDebtRate
from ads_ag_kbh_report_weekly A
    join (
    select
            ifnull(dep2,'��ٻ�') Department ,
           sum(FrozenAmountUs) as FrozenAmountUs
    from ( select *
            , case when Team regexp '�ɶ�' then '��ٻ�һ��' when Team regexp 'Ȫ��' then '��ٻ�����' end dep2
        from import_data.BadDebtRate where `Date` in (  select max(`Date`) Date from BadDebtRate ) and Department regexp '��'
        and ExceptionNotifyTime >='${StartDay}' and ExceptionNotifyTime <'${NextStartDay}' ) ta
    group by grouping sets ((),(dep2))
	) B on A.Team = B.Department and A.FirstDay = '${StartDay}';


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	BadDebtAmount ,BadDebtRate)
select '${StartDay}' ,'${ReportType}' ,Department ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,B.FrozenAmountUs
	,ifnull(round(B.FrozenAmountUs / A.TotalGross, 4), 0) as BadDebtRate
from ads_ag_kbh_report_weekly A
    join (
    select NodePahtName as Department , sum(FrozenAmountUs) as FrozenAmountUs
    from (select *
            , case when Team regexp '�ɶ�1��|�ɶ�2��' then '��ٻ�һ��' when Team regexp 'Ȫ��1��|Ȫ��2��|Ȫ��3��' then '��ٻ�����' end dep2
            , case when Team = '�ɶ�1��' then '���Ԫ-�ɶ�������' when Team = '�ɶ�2��' then '��η�-�ɶ�������'
                when Team = 'Ȫ��1��' then '��Ӫ��-Ȫ��1��' when Team = 'Ȫ��2��' then '��Ӫ��-Ȫ��2��' when Team = 'Ȫ��3��' then '��Ӫ��-Ȫ��3��'
                end NodePahtName -- ��Ϊwt_store ��mysql_store���ǻ�ȡ���µ��˺Ź����������ﻵ�˶�Ӧ���̵�д��
        from import_data.BadDebtRate where `Date` in (select max(`Date`) Date from BadDebtRate) and Department='��ٻ�'
        and ExceptionNotifyTime >='${StartDay}' and ExceptionNotifyTime <'${NextStartDay}') ta
    group by NodePahtName
	) B on A.Team = B.Department and A.FirstDay = '${StartDay}';



select Department , sum(FrozenAmountUs) as FrozenAmountUs
from import_data.BadDebtRate where `Date` in (  select max(`Date`) Date from BadDebtRate)
 and ExceptionNotifyTime >='2023-10-01' and ExceptionNotifyTime <'2023-10-12'group by Department
