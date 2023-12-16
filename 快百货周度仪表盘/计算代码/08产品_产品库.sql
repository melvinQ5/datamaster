insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuCnt, SkuCnt ,OldSpuCntIn90dDev_ele)
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count( distinct wp.spu ) `产品库SPU数`
	,count( distinct wp.sku ) `产品库SKU数`
	,count( distinct case when DevelopLastAuditTime < date_add('${NextStartDay}',interval - 90 day) and tag.spu is not null then wp.spu end ) `未停产老品SPU数_主题`
from import_data.wt_products wp
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '夏季'
	group by spu ) tag on wp.spu = tag.spu
where  ProjectTeam = '快百货' and wp.ProductStatus != 2 and IsDeleted = 0 and DevelopLastAuditTime is not null
group by ProjectTeam;

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuCnt, SkuCnt ,OldSpuCntIn90dDev_ele)
select '${StartDay}' ,'${ReportType}' ,dep2 ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count( distinct wp.spu ) `产品库SPU数`
    ,count( distinct wp.sku ) `产品库SKU数`
    ,count( distinct case when DevelopLastAuditTime < date_add('${NextStartDay}',interval - 90 day) and tag.spu is not null then wp.spu end ) `未停产老品SPU数_主题`
from import_data.wt_products wp
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '夏季'
	group by spu ) tag on wp.spu = tag.spu
left join ( select substr(NodePathNameFull,5,5) as dep2 ,name ,department
    from view_roles where ProductRole ='开发'  ) vr on wp.DevelopUserName = vr.name
where  ProjectTeam = '快百货' and ProductStatus != 2 and IsDeleted = 0 and DevelopLastAuditTime is not null  and dep2 regexp '快百货一部|快百货二部'
group by dep2;

