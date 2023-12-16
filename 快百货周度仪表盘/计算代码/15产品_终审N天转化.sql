-- 新品开发-公司 新品开发-成都商品组 销售运营过程指标-链接质量

-- 终审7天SPU动销,不区分开发团队，区分出单团队
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn7dDev,  --  '终审7天SPU动销率'
 SpuSaleRateIn7dDev_saleby_cd --  '终审7天SPU成都动销率'
)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审7天SPU动销率`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `终审7天SPU成都动销率`
from ( -- 开发SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '快百货一部' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
            and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;


-- 终审7天SPU动销, 成都商品组
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn7dDev,  --  '终审7天SPU动销率'
 SpuSaleRateIn7dDev_saleby_cd --  '终审7天SPU成都动销率'
)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审7天SPU动销率`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `终审7天SPU成都动销率`
from ( -- 开发SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
    join ( select distinct name from view_roles where ProductRole ='开发' and NodePathNameFull regexp '快百货一部') vr on wp.DevelopUserName = vr.name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '快百货一部' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
            and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;


-- 终审14天SPU动销,不区分开发团队，区分出单团队
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn14dDev,  --  '终审14天SPU动销率'
 SpuSaleRateIn14dDev_ele, 
 SpuSaleRateIn14dDev_saleby_cd --  '终审14天SPU成都动销率'
)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审14天SPU动销率`
	, round(count(distinct part.Product_SPU_ele)/count(distinct entire.Product_SPU_ele),4) `终审14天SPU动销率_主题`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `终审14天SPU成都动销率`
from ( -- 开发SPU
	select wp.Spu ,wp.SKU ,ProjectTeam 
		, case when tag.spu is not null then wp.SPU end as Product_SPU_ele
	from import_data.wt_products wp
	left join ( select eppaea.spu -- 主题
		from import_data.erp_product_product_associated_element_attributes eppaea
		left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
		where eppea.name = '夏季'
		group by spu ) tag on wp.spu = tag.spu
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,tag.spu
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	from (
        select wo.*
        	, case when dep2 = '快百货一部' then Product_SKU end as Product_SPU_sale_by_cd
        	, case when tag.spu is not null then Product_SPU end as Product_SPU_ele
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        left join ( select eppaea.spu -- 主题
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
			where eppea.name = '夏季'
			group by spu ) tag on wo.Product_SPU = tag.spu
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	) part on entire.Sku = part.Product_SKU;


-- 终审14天SPU动销, 成都商品组
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn14dDev,  --  '终审14天SPU动销率'
 SpuSaleRateIn14dDev_saleby_cd --  '终审14天SPU成都动销率'
)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审14天SPU动销率`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `终审14天SPU成都动销率`
from ( -- 开发SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
    join ( select distinct name from view_roles where ProductRole ='开发' and NodePathNameFull regexp '快百货一部') vr on wp.DevelopUserName = vr.name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '快百货一部' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;

-- 终审30天SPU动销,不区分开发团队，区分出单团队
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn30dDev,  --  '终审30天SPU动销率'
 SpuSaleRateIn30dDev_ele, 
 SpuSaleRateIn30dDev_saleby_cd --  '终审30天SPU成都动销率'
)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审30天SPU动销率`
	, round(count(distinct part.Product_SPU_ele)/count(distinct entire.Product_SPU_ele),4) `终审30天SPU动销率_主题`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `终审30天SPU成都动销率`
from ( -- 开发SPU
	select wp.Spu ,wp.SKU ,ProjectTeam 
		, case when tag.spu is not null then wp.SPU end as Product_SPU_ele
	from import_data.wt_products wp
	left join ( select eppaea.spu -- 主题
		from import_data.erp_product_product_associated_element_attributes eppaea
		left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
		where eppea.name = '夏季'
		group by spu ) tag on wp.spu = tag.spu
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,tag.spu
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	from (
        select wo.*
        	, case when dep2 = '快百货一部' then Product_SKU end as Product_SPU_sale_by_cd
        	, case when tag.spu is not null then Product_SPU end as Product_SPU_ele
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        left join ( select eppaea.spu -- 主题
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
			where eppea.name = '夏季'
			group by spu ) tag on wo.Product_SPU = tag.spu
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
            and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	) part on entire.Sku = part.Product_SKU;



-- 终审30天SPU动销, 成都商品组
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn30dDev,  --  '终审30天SPU动销率'
 SpuSaleRateIn30dDev_saleby_cd --  '终审30天SPU成都动销率'
)
select '${StartDay}' ,'${ReportType}' ,'快百货一部' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审30天SPU动销率`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `终审30天SPU成都动销率`
from ( -- 开发SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
    join ( select distinct name from view_roles where ProductRole ='开发' and NodePathNameFull regexp '快百货一部') vr on wp.DevelopUserName = vr.name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '快百货一部' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
            and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;

-- ----------------------

-- 终审7天SPU动销,限本部门开发，不区分出单团队
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn7dDev_DevbySelf --  '成都终审7天SPU动销率'
)
select '${StartDay}' ,'${ReportType}' ,entire.level2_name ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审7天SPU动销率_本部门开发`
from ( -- 开发SPU
	select SPU ,SKU ,level2_name
	from (
	select wp.SPU ,wp.SKU ,ProjectTeam ,level2_name  from import_data.wt_products wp
	join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  level2_name regexp '快百货一部|快百货二部' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,level2_name ) t
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp '泉州' then '快百货二部'
            when NodePathName regexp '成都' then '快百货一部' end as dep2, *
         from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
    join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
    where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
        and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
        and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by Product_SPU , Product_SKU
	) part on entire.Sku = part.Product_SKU
group by entire.level2_name;

-- 终审14天SPU动销,限本部门开发，不区分出单团队
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn14dDev_DevbySelf --  '成都终审14天SPU动销率'
)
select '${StartDay}' ,'${ReportType}' ,entire.level2_name ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审14天SPU动销率_本部门开发`
from ( -- 开发SPU
	select SPU ,SKU ,level2_name
	from (
	select wp.SPU ,wp.SKU ,ProjectTeam ,level2_name  from import_data.wt_products wp
	join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  level2_name regexp '快百货一部|快百货二部' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,level2_name ) t
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp '泉州' then '快百货二部'
            when NodePathName regexp '成都' then '快百货一部' end as dep2, *
         from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
    join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
    where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
        and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
        and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by Product_SPU , Product_SKU
	) part on entire.Sku = part.Product_SKU
group by entire.level2_name;

-- 终审30天SPU动销,限本部门开发，不区分出单团队
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn30dDev_DevbySelf --  '成都终审30天SPU动销率'
)
select '${StartDay}' ,'${ReportType}' ,entire.level2_name ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审30天SPU动销率_本部门开发`
from ( -- 开发SPU
	select SPU ,SKU ,level2_name
	from (
	select wp.SPU ,wp.SKU ,ProjectTeam ,level2_name  from import_data.wt_products wp
	join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  level2_name regexp '快百货一部|快百货二部' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,level2_name ) t
	) entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp '泉州' then '快百货二部'
            when NodePathName regexp '成都' then '快百货一部' end as dep2, *
         from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
    join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
    where wo.Department = '快百货' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
        and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
        and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by Product_SPU , Product_SKU
	) part on entire.Sku = part.Product_SKU
group by entire.level2_name;


--  SpuSaleRateIn7dDev_ele,  --  '终审7天SPU动销率-主题', SpuSaleRateIn14dDev_ele, --  '终审14天SPU动销率-主题', SpuSaleRateIn30dDev_ele, --  '终审30天SPU动销率-主题'


-- 终审7天SKU曝光率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuExpoRateIn7dDev)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(part.SKU)/count(entire.SKU),4) `终审7天SKU曝光率`
from ( -- 开发SKU
	select wp.SKU ,ProjectTeam,dep2 from import_data.wt_products wp
	left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SKU ,ProjectTeam,dep2 ) entire
left join ( -- 有曝光SKU
    select wl.SKU
    from wt_listing wl
    join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
         ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day)
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
    where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
    group by wl.SKU having  sum(Exposure) > 100
    ) part on entire.Sku = part.SKU
group by grouping sets ((),(entire.dep2));

-- 终审14天SKU曝光率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuExpoRateIn14dDev)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(part.SKU)/count(entire.SKU),4) `终审14天SKU曝光率`
from ( -- 开发SKU
	select wp.SKU ,ProjectTeam,dep2 from import_data.wt_products wp
	left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SKU ,ProjectTeam,dep2 ) entire
left join ( -- 有曝光SKU
    select wl.SKU
    from wt_listing wl
    join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
         ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day)
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
    where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
    group by wl.SKU having  sum(Exposure) > 100
    ) part on entire.Sku = part.SKU
group by grouping sets ((),(entire.dep2));


-- 终审30天SKU曝光率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuExpoRateIn30dDev)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(part.SKU)/count(entire.SKU),4) `终审30天SKU曝光率`
from ( -- 开发SKU
	select wp.SKU ,ProjectTeam,dep2 from import_data.wt_products wp
	left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
	group by wp.SKU ,ProjectTeam,dep2 ) entire
left join ( -- 有曝光SKU
    select wl.SKU
    from wt_listing wl
    join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
         ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -30 day)
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -30 day) and ad.CreatedTime< '${NextStartDay}'
    where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
    group by wl.SKU having  sum(Exposure) > 100
    ) part on entire.Sku = part.SKU
group by grouping sets ((),(entire.dep2));


-- 终审7天SKU点击率、转化率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuClickRateIn7dDev ,SkuAdSaleRateIn7dDev )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(Clicks)/sum(Exposure),4) SkuClickRateIn7dDev
	,round(sum(TotalSale7DayUnit )/sum(Clicks),4) SkuAdSaleRateIn7dDev
from wt_listing wl
join (select wp.SKU ,dep2,DevelopLastAuditTime from import_data.wt_products wp
    left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
        ) ds on wp.DevelopUserName = ds.staff_name
    where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
     ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
	and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
group by grouping sets ((),(dep2));

-- 终审14天SKU点击率、转化率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuClickRateIn14dDev ,SkuAdSaleRateIn14dDev )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(Clicks)/sum(Exposure),4) SkuClickRateIn14dDev
	,round(sum(TotalSale7DayUnit )/sum(Clicks),4) SkuAdSaleRateIn14dDev
from wt_listing wl
join (select wp.SKU ,dep2,DevelopLastAuditTime from import_data.wt_products wp
    left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
        ) ds on wp.DevelopUserName = ds.staff_name
    where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
     ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
	and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
group by grouping sets ((),(dep2));

-- 终审30天SKU点击率、转化率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuClickRateIn30dDev ,SkuAdSaleRateIn30dDev )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'快百货') ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(Clicks)/sum(Exposure),4) SkuClickRateIn30dDev
	,round(sum(TotalSale7DayUnit )/sum(Clicks),4) SkuAdSaleRateIn30dDev
from wt_listing wl
join (select wp.SKU ,dep2,DevelopLastAuditTime from import_data.wt_products wp
    left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
        ) ds on wp.DevelopUserName = ds.staff_name
    where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '快百货'
     ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -30 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
	and ad.CreatedTime >= date_add('${StartDay}',interval -30 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
group by grouping sets ((),(dep2));