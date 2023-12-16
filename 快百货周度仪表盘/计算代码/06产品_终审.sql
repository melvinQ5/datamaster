insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewDevSpuCnt ,NewDevSkuCnt ,NewDevSpuCnt_ele ,SpuSkuRate )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `����SPU��` 
	,count(distinct wp.sku ) `����SkU��` 
	,count(distinct case when tag.spu is not null then tag.spu end) `����SPU��-����`
	,round(count(distinct wp.sku ) / count(distinct wp.spu ) ,2) `��Ʒ�������`
from wt_products wp 
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '�ļ�'
	group by spu ) tag on wp.spu = tag.spu 
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}' and ProjectTeam = '��ٻ�'
group by ProjectTeam
union all 
select '${StartDay}' ,'${ReportType}' ,dep2 ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `����SPU��` 
	,count(distinct wp.sku ) `����SkU��` 
	,count(distinct case when tag.spu is not null then tag.spu end) `����SPU��-����`
	,round(count(distinct wp.sku ) / count(distinct wp.spu ) ,2) `��Ʒ�������`
from wt_products wp 
join ( select split(NodePathNameFull,'>')[2] as dep2 ,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName	,name ,department
	from view_roles where ProductRole ='����' ) vr on wp.DevelopUserName = vr.name
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '�ļ�'
	group by spu ) tag on wp.spu = tag.spu 
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}' and ProjectTeam = '��ٻ�'
group by dep2;

-- ��90����Ʒ
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewSpuCntIn90dDev ,StopSkuRateIn30dDev )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `��90������SPU��`
	,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `��ƷSKUͣ��ռ��`
from wt_products wp
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�'
group by ProjectTeam
union all
select '${StartDay}' ,'${ReportType}' ,dep2 ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `��90������SPU��`
    ,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `��ƷSKUͣ��ռ��`
from wt_products wp
left join ( select substr(NodePathNameFull,5,5) as dep2 ,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName	,name ,department
	from view_roles where ProductRole ='����' ) vr on wp.DevelopUserName = vr.name
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�'
    and dep2 regexp '��ٻ�һ��|��ٻ�����'
group by dep2;


-- ��3������Ʒ
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewSpuCntIn90dDev ,StopSkuRateIn30dDev )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `��90������SPU��`
	,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `��ƷSKUͣ��ռ��`
from wt_products wp
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�'
    and date_add(wp.DevelopLastAuditTime , interval - 8 hour) >=  DATE_ADD( DATE_ADD('${NextStartDay}',interval -day('${NextStartDay}')+1 day) ,interval -2 month)
group by ProjectTeam
union all
select '${StartDay}' ,'${ReportType}' ,dep2 ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `��90������SPU��`
    ,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `��ƷSKUͣ��ռ��`
from wt_products wp
left join ( select substr(NodePathNameFull,5,5) as dep2 ,case when  NodePathName = '��Ʒ��' then '�����-��Ʒ��' else NodePathName end NodePathName	,name ,department
	from view_roles where ProductRole ='����' ) vr on wp.DevelopUserName = vr.name
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�'
    and dep2 regexp '��ٻ�һ��|��ٻ�����'
group by dep2;


