insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuStopCnt )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count( distinct wp.spu ) `停产SPU数`
from import_data.wt_products wp
where date_add(ProductStopTime, INTERVAL - 8 hour) >= '${StartDay}'
	and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}' and ProjectTeam = '快百货' and IsDeleted=0 and ProductStatus = 2
group by ProjectTeam;

