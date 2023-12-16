
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	BadDebtAmount ,BadDebtRate)
select '${StartDay}' ,'${ReportType}' ,Team ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,B.FrozenAmountUs
	,ifnull(round(B.FrozenAmountUs / A.TotalGross, 4), 0) as BadDebtRate
from ads_ag_kbh_report_weekly A
    join (
    select
            ifnull(dep2,'快百货') Department ,
           sum(FrozenAmountUs) as FrozenAmountUs
    from ( select *
            , case when Team regexp '成都' then '快百货一部' when Team regexp '泉州' then '快百货二部' end dep2
        from import_data.BadDebtRate where `Date` in (  select max(`Date`) Date from BadDebtRate ) and Department regexp '快'
        and ExceptionNotifyTime >='${StartDay}' and ExceptionNotifyTime <'${NextStartDay}' ) ta
    group by grouping sets ((),(dep2))
	) B on A.Team = B.Department and A.FirstDay = '${StartDay}';


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	BadDebtAmount ,BadDebtRate)
select '${StartDay}' ,'${ReportType}' ,Department ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,B.FrozenAmountUs
	,ifnull(round(B.FrozenAmountUs / A.TotalGross, 4), 0) as BadDebtRate
from ads_ag_kbh_report_weekly A
    join (
    select NodePahtName as Department , sum(FrozenAmountUs) as FrozenAmountUs
    from (select *
            , case when Team regexp '成都1组|成都2组' then '快百货一部' when Team regexp '泉州1组|泉州2组|泉州3组' then '快百货二部' end dep2
            , case when Team = '成都1组' then '快次元-成都销售组' when Team = '成都2组' then '快次方-成都销售组'
                when Team = '泉州1组' then '运营组-泉州1组' when Team = '泉州2组' then '运营组-泉州2组' when Team = '泉州3组' then '运营组-泉州3组'
                end NodePahtName -- 因为wt_store 和mysql_store都是获取最新的账号归属，故这里坏账对应店铺得写死
        from import_data.BadDebtRate where `Date` in (select max(`Date`) Date from BadDebtRate) and Department='快百货'
        and ExceptionNotifyTime >='${StartDay}' and ExceptionNotifyTime <'${NextStartDay}') ta
    group by NodePahtName
	) B on A.Team = B.Department and A.FirstDay = '${StartDay}';



select Department , sum(FrozenAmountUs) as FrozenAmountUs
from import_data.BadDebtRate where `Date` in (  select max(`Date`) Date from BadDebtRate)
 and ExceptionNotifyTime >='2023-10-01' and ExceptionNotifyTime <'2023-10-12'group by Department
