insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	RefundRate )
select '${StartDay}' ,'${ReportType}' ,Department ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,ifnull(round(B.refunds / A.TotalGross, 4), 0) as RefundRate
from ads_ag_kbh_report_weekly A
join (
	select ifnull(ms.dep2,'快百货') Department
     ,abs(round(sum(RefundUSDPrice),2)) refunds
    from daily_RefundOrders rf
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
        from import_data.mysql_store where department regexp '快')  ms on ms.code=rf.OrderSource and ms.department='快百货'
    where  RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='已退款'
    group by grouping sets ((),(ms.dep2))
	union all
	select NodePathName  ,abs(round(sum(RefundUSDPrice),2)) refunds
	from daily_RefundOrders rf
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
        from import_data.mysql_store where department regexp '快')  ms on ms.code=rf.OrderSource and ms.department='快百货'
    where  RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='已退款'
	group by NodePathName
	) B on A.Team = B.Department and A.FirstDay =  '${StartDay}' ;
