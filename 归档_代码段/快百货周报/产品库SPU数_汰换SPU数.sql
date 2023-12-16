insert into import_data.ads_ag_staff_kbh_report_weekly (`FirstDay`, `AnalysisType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
 SpuCnt ,SpuStopCnt)
select 
	'${StartDay}' ,concat(ifnull(ProjectTeam,'公司'),'x周报') ,ifnull(ProjectTeam,'公司') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 
	,count(distinct case when ProductStatus != 2 then SKU end ) `产品库SPU数` -- SpuCnt
-- 	,count(distinct case when ProductStatus != 2 then SPU end ) `产品库SKU数`
	,count(distinct case when date_add(ProductStopTime, INTERVAL - 8 hour) >= '${StartDay}'
		and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}' then SPU end ) `汰换SPU数` --  SpuStopCnt 
from import_data.erp_product_products epp 
where IsDeleted = 0 and DevelopLastAuditTime is not null 
group by grouping sets ((),(ProjectTeam))


