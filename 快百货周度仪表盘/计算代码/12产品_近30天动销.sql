insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuSaleCntIn30d ,SpuUnitSaleIn30d )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct Product_SPU) 近30天动销SPU数
    ,round(sum((totalgross)/ExchangeUSD)/count(distinct Product_SPU),2) 近30天动销SPU单产
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '其他'  and asin <>''  and ms.department regexp '快'
group by grouping sets ((),(ms.dep2));


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuSaleCntIn30d ,SpuUnitSaleIn30d )
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct Product_SPU) 近30天动销SPU数
    ,round(sum((totalgross)/ExchangeUSD)/count(distinct Product_SPU),2) 近30天动销SPU单产
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms  on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '其他'  and asin <>''  and ms.department regexp '快'
group by NodePathName;


-- 近30天SPU动销率
insert into ads_ag_kbh_report_weekly (team ,FirstDay ,ReportType ,Staff,
	SpuSaleRateIn30d )
select team ,FirstDay ,ReportType ,Staff
    ,round(ifnull(SpuSaleCntIn30d,0)/(ifnull(SpuCnt,0)+ifnull(SpuStopCnt,0)),4) SpuSaleRateIn30d
from ads_ag_kbh_report_weekly;

