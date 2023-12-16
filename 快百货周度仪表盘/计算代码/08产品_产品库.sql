insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuCnt, SkuCnt ,OldSpuCntIn90dDev_ele)
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,count( distinct wp.spu ) `��Ʒ��SPU��`
	,count( distinct wp.sku ) `��Ʒ��SKU��`
	,count( distinct case when DevelopLastAuditTime < date_add('${NextStartDay}',interval - 90 day) and tag.spu is not null then wp.spu end ) `δͣ����ƷSPU��_����`
from import_data.wt_products wp
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '�ļ�'
	group by spu ) tag on wp.spu = tag.spu
where  ProjectTeam = '��ٻ�' and wp.ProductStatus != 2 and IsDeleted = 0 and DevelopLastAuditTime is not null
group by ProjectTeam;

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SpuCnt, SkuCnt ,OldSpuCntIn90dDev_ele)
select '${StartDay}' ,'${ReportType}' ,dep2 ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count( distinct wp.spu ) `��Ʒ��SPU��`
    ,count( distinct wp.sku ) `��Ʒ��SKU��`
    ,count( distinct case when DevelopLastAuditTime < date_add('${NextStartDay}',interval - 90 day) and tag.spu is not null then wp.spu end ) `δͣ����ƷSPU��_����`
from import_data.wt_products wp
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '�ļ�'
	group by spu ) tag on wp.spu = tag.spu
left join ( select substr(NodePathNameFull,5,5) as dep2 ,name ,department
    from view_roles where ProductRole ='����'  ) vr on wp.DevelopUserName = vr.name
where  ProjectTeam = '��ٻ�' and ProductStatus != 2 and IsDeleted = 0 and DevelopLastAuditTime is not null  and dep2 regexp '��ٻ�һ��|��ٻ�����'
group by dep2;

