insert into import_data.ads_ag_staff_kbh_report_weekly (`FirstDay`, `AnalysisType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
 SpuCnt ,SpuStopCnt)
select 
	'${StartDay}' ,concat(ifnull(ProjectTeam,'��˾'),'x�ܱ�') ,ifnull(ProjectTeam,'��˾') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 
	,count(distinct case when ProductStatus != 2 then SKU end ) `��Ʒ��SPU��` -- SpuCnt
-- 	,count(distinct case when ProductStatus != 2 then SPU end ) `��Ʒ��SKU��`
	,count(distinct case when date_add(ProductStopTime, INTERVAL - 8 hour) >= '${StartDay}'
		and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}' then SPU end ) `̭��SPU��` --  SpuStopCnt 
from import_data.erp_product_products epp 
where IsDeleted = 0 and DevelopLastAuditTime is not null 
group by grouping sets ((),(ProjectTeam))


