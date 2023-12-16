insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewDevSpuCnt ,NewDevSkuCnt ,NewDevSpuCnt_ele ,SpuSkuRate )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `终审SPU数` 
	,count(distinct wp.sku ) `终审SkU数` 
	,count(distinct case when tag.spu is not null then tag.spu end) `终审SPU数-主题`
	,round(count(distinct wp.sku ) / count(distinct wp.spu ) ,2) `新品变体配比`
from wt_products wp 
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '夏季'
	group by spu ) tag on wp.spu = tag.spu 
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}' and ProjectTeam = '快百货'
group by ProjectTeam
union all 
select '${StartDay}' ,'${ReportType}' ,dep2 ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `终审SPU数` 
	,count(distinct wp.sku ) `终审SkU数` 
	,count(distinct case when tag.spu is not null then tag.spu end) `终审SPU数-主题`
	,round(count(distinct wp.sku ) / count(distinct wp.spu ) ,2) `新品变体配比`
from wt_products wp 
join ( select split(NodePathNameFull,'>')[2] as dep2 ,case when  NodePathName = '商品组' then '快节奏-商品组' else NodePathName end NodePathName	,name ,department
	from view_roles where ProductRole ='开发' ) vr on wp.DevelopUserName = vr.name
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '夏季'
	group by spu ) tag on wp.spu = tag.spu 
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}' and ProjectTeam = '快百货'
group by dep2;

-- 近90天新品
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewSpuCntIn90dDev ,StopSkuRateIn30dDev )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `近90天终审SPU数`
	,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `新品SKU停产占比`
from wt_products wp
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '快百货'
group by ProjectTeam
union all
select '${StartDay}' ,'${ReportType}' ,dep2 ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `近90天终审SPU数`
    ,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `新品SKU停产占比`
from wt_products wp
left join ( select substr(NodePathNameFull,5,5) as dep2 ,case when  NodePathName = '商品组' then '快节奏-商品组' else NodePathName end NodePathName	,name ,department
	from view_roles where ProductRole ='开发' ) vr on wp.DevelopUserName = vr.name
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '快百货'
    and dep2 regexp '快百货一部|快百货二部'
group by dep2;


-- 近3个月新品
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewSpuCntIn90dDev ,StopSkuRateIn30dDev )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `近90天终审SPU数`
	,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `新品SKU停产占比`
from wt_products wp
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '快百货'
    and date_add(wp.DevelopLastAuditTime , interval - 8 hour) >=  DATE_ADD( DATE_ADD('${NextStartDay}',interval -day('${NextStartDay}')+1 day) ,interval -2 month)
group by ProjectTeam
union all
select '${StartDay}' ,'${ReportType}' ,dep2 ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count(distinct wp.spu ) `近90天终审SPU数`
    ,round(count(distinct case when ProductStatus=2 then wp.sku end ) / count(distinct wp.sku ) ,4)  `新品SKU停产占比`
from wt_products wp
left join ( select substr(NodePathNameFull,5,5) as dep2 ,case when  NodePathName = '商品组' then '快节奏-商品组' else NodePathName end NodePathName	,name ,department
	from view_roles where ProductRole ='开发' ) vr on wp.DevelopUserName = vr.name
where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day) and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '快百货'
    and dep2 regexp '快百货一部|快百货二部'
group by dep2;


