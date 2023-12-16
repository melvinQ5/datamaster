insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuSaleCntIn30d ,SpuUnitSaleIn30d )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct Product_SPU) ��30�춯��SPU��
    ,round(sum((totalgross)/ExchangeUSD)/count(distinct Product_SPU),2) ��30�춯��SPU����
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '����'  and asin <>''  and ms.department regexp '��'
group by grouping sets ((),(ms.dep2));


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuSaleCntIn30d ,SpuUnitSaleIn30d )
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct Product_SPU) ��30�춯��SPU��
    ,round(sum((totalgross)/ExchangeUSD)/count(distinct Product_SPU),2) ��30�춯��SPU����
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    and TransactionType <> '����'  and asin <>''  and ms.department regexp '��'
group by NodePathName;


-- ��30��SPU������
insert into ads_ag_kbh_report_weekly (team ,FirstDay ,ReportType ,Staff,
	SpuSaleRateIn30d )
select team ,FirstDay ,ReportType ,Staff
    ,round(ifnull(SpuSaleCntIn30d,0)/(ifnull(SpuCnt,0)+ifnull(SpuStopCnt,0)),4) SpuSaleRateIn30d
from ads_ag_kbh_report_weekly;

