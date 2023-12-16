-- ��Ʒ����-��˾ ��Ʒ����-�ɶ���Ʒ�� ������Ӫ����ָ��-��������

-- ����7��SPU����,�����ֿ����Ŷӣ����ֳ����Ŷ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn7dDev,  --  '����7��SPU������'
 SpuSaleRateIn7dDev_saleby_cd --  '����7��SPU�ɶ�������'
)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����7��SPU������`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `����7��SPU�ɶ�������`
from ( -- ����SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '��ٻ�һ��' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
            and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;


-- ����7��SPU����, �ɶ���Ʒ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn7dDev,  --  '����7��SPU������'
 SpuSaleRateIn7dDev_saleby_cd --  '����7��SPU�ɶ�������'
)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����7��SPU������`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `����7��SPU�ɶ�������`
from ( -- ����SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
    join ( select distinct name from view_roles where ProductRole ='����' and NodePathNameFull regexp '��ٻ�һ��') vr on wp.DevelopUserName = vr.name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '��ٻ�һ��' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
            and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;


-- ����14��SPU����,�����ֿ����Ŷӣ����ֳ����Ŷ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn14dDev,  --  '����14��SPU������'
 SpuSaleRateIn14dDev_ele, 
 SpuSaleRateIn14dDev_saleby_cd --  '����14��SPU�ɶ�������'
)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����14��SPU������`
	, round(count(distinct part.Product_SPU_ele)/count(distinct entire.Product_SPU_ele),4) `����14��SPU������_����`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `����14��SPU�ɶ�������`
from ( -- ����SPU
	select wp.Spu ,wp.SKU ,ProjectTeam 
		, case when tag.spu is not null then wp.SPU end as Product_SPU_ele
	from import_data.wt_products wp
	left join ( select eppaea.spu -- ����
		from import_data.erp_product_product_associated_element_attributes eppaea
		left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
		where eppea.name = '�ļ�'
		group by spu ) tag on wp.spu = tag.spu
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,tag.spu
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	from (
        select wo.*
        	, case when dep2 = '��ٻ�һ��' then Product_SKU end as Product_SPU_sale_by_cd
        	, case when tag.spu is not null then Product_SPU end as Product_SPU_ele
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        left join ( select eppaea.spu -- ����
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
			where eppea.name = '�ļ�'
			group by spu ) tag on wo.Product_SPU = tag.spu
        where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	) part on entire.Sku = part.Product_SKU;


-- ����14��SPU����, �ɶ���Ʒ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn14dDev,  --  '����14��SPU������'
 SpuSaleRateIn14dDev_saleby_cd --  '����14��SPU�ɶ�������'
)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����14��SPU������`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `����14��SPU�ɶ�������`
from ( -- ����SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
    join ( select distinct name from view_roles where ProductRole ='����' and NodePathNameFull regexp '��ٻ�һ��') vr on wp.DevelopUserName = vr.name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '��ٻ�һ��' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;

-- ����30��SPU����,�����ֿ����Ŷӣ����ֳ����Ŷ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn30dDev,  --  '����30��SPU������'
 SpuSaleRateIn30dDev_ele, 
 SpuSaleRateIn30dDev_saleby_cd --  '����30��SPU�ɶ�������'
)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����30��SPU������`
	, round(count(distinct part.Product_SPU_ele)/count(distinct entire.Product_SPU_ele),4) `����30��SPU������_����`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `����30��SPU�ɶ�������`
from ( -- ����SPU
	select wp.Spu ,wp.SKU ,ProjectTeam 
		, case when tag.spu is not null then wp.SPU end as Product_SPU_ele
	from import_data.wt_products wp
	left join ( select eppaea.spu -- ����
		from import_data.erp_product_product_associated_element_attributes eppaea
		left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
		where eppea.name = '�ļ�'
		group by spu ) tag on wp.spu = tag.spu
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,tag.spu
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	from (
        select wo.*
        	, case when dep2 = '��ٻ�һ��' then Product_SKU end as Product_SPU_sale_by_cd
        	, case when tag.spu is not null then Product_SPU end as Product_SPU_ele
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        left join ( select eppaea.spu -- ����
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
			where eppea.name = '�ļ�'
			group by spu ) tag on wo.Product_SPU = tag.spu
        where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
            and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd ,Product_SPU_ele
	) part on entire.Sku = part.Product_SKU;



-- ����30��SPU����, �ɶ���Ʒ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn30dDev,  --  '����30��SPU������'
 SpuSaleRateIn30dDev_saleby_cd --  '����30��SPU�ɶ�������'
)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�һ��' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����30��SPU������`
	, round(count(distinct part.Product_SPU_sale_by_cd)/count(distinct entire.Spu),4) `����30��SPU�ɶ�������`
from ( -- ����SPU
	select wp.Spu ,wp.SKU ,ProjectTeam from import_data.wt_products wp
    join ( select distinct name from view_roles where ProductRole ='����' and NodePathNameFull regexp '��ٻ�һ��') vr on wp.DevelopUserName = vr.name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
	  and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	from (
        select wo.*
        	, case when dep2 = '��ٻ�һ��' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
                when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
        where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
            and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU ,Product_SPU_sale_by_cd
	) part on entire.Sku = part.Product_SKU;

-- ----------------------

-- ����7��SPU����,�ޱ����ſ����������ֳ����Ŷ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn7dDev_DevbySelf --  '�ɶ�����7��SPU������'
)
select '${StartDay}' ,'${ReportType}' ,entire.level2_name ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����7��SPU������_�����ſ���`
from ( -- ����SPU
	select SPU ,SKU ,level2_name
	from (
	select wp.SPU ,wp.SKU ,ProjectTeam ,level2_name  from import_data.wt_products wp
	join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  level2_name regexp '��ٻ�һ��|��ٻ�����' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,level2_name ) t
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
            when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
         from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
    join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
    where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day)
        and paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
        and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by Product_SPU , Product_SKU
	) part on entire.Sku = part.Product_SKU
group by entire.level2_name;

-- ����14��SPU����,�ޱ����ſ����������ֳ����Ŷ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn14dDev_DevbySelf --  '�ɶ�����14��SPU������'
)
select '${StartDay}' ,'${ReportType}' ,entire.level2_name ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����14��SPU������_�����ſ���`
from ( -- ����SPU
	select SPU ,SKU ,level2_name
	from (
	select wp.SPU ,wp.SKU ,ProjectTeam ,level2_name  from import_data.wt_products wp
	join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  level2_name regexp '��ٻ�һ��|��ٻ�����' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,level2_name ) t
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
            when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
         from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
    join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
    where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day)
        and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
        and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by Product_SPU , Product_SKU
	) part on entire.Sku = part.Product_SKU
group by entire.level2_name;

-- ����30��SPU����,�ޱ����ſ����������ֳ����Ŷ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 SpuSaleRateIn30dDev_DevbySelf --  '�ɶ�����30��SPU������'
)
select '${StartDay}' ,'${ReportType}' ,entire.level2_name ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `����30��SPU������_�����ſ���`
from ( -- ����SPU
	select SPU ,SKU ,level2_name
	from (
	select wp.SPU ,wp.SKU ,ProjectTeam ,level2_name  from import_data.wt_products wp
	join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  level2_name regexp '��ٻ�һ��|��ٻ�����' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SPU ,wp.SKU ,ProjectTeam ,level2_name ) t
	) entire
left join ( -- ����SKU
	select Product_SPU , Product_SKU
    from import_data.wt_orderdetails wo
    join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����'
            when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2, *
         from import_data.mysql_store ms where ms.department regexp '��') ms on wo.shopcode = ms.Code
    join import_data.wt_products wp on wp.BoxSku = wo.BoxSku
    where wo.Department = '��ٻ�' and DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day)
        and paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '��ٻ�' and wo.IsDeleted =0 and orderstatus != '����'
        and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by Product_SPU , Product_SKU
	) part on entire.Sku = part.Product_SKU
group by entire.level2_name;


--  SpuSaleRateIn7dDev_ele,  --  '����7��SPU������-����', SpuSaleRateIn14dDev_ele, --  '����14��SPU������-����', SpuSaleRateIn30dDev_ele, --  '����30��SPU������-����'


-- ����7��SKU�ع���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuExpoRateIn7dDev)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(part.SKU)/count(entire.SKU),4) `����7��SKU�ع���`
from ( -- ����SKU
	select wp.SKU ,ProjectTeam,dep2 from import_data.wt_products wp
	left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SKU ,ProjectTeam,dep2 ) entire
left join ( -- ���ع�SKU
    select wl.SKU
    from wt_listing wl
    join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
         ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day)
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
    where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
    group by wl.SKU having  sum(Exposure) > 100
    ) part on entire.Sku = part.SKU
group by grouping sets ((),(entire.dep2));

-- ����14��SKU�ع���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuExpoRateIn14dDev)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(part.SKU)/count(entire.SKU),4) `����14��SKU�ع���`
from ( -- ����SKU
	select wp.SKU ,ProjectTeam,dep2 from import_data.wt_products wp
	left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SKU ,ProjectTeam,dep2 ) entire
left join ( -- ���ع�SKU
    select wl.SKU
    from wt_listing wl
    join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
         ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day)
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
    where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
    group by wl.SKU having  sum(Exposure) > 100
    ) part on entire.Sku = part.SKU
group by grouping sets ((),(entire.dep2));


-- ����30��SKU�ع���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuExpoRateIn30dDev)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round(count(part.SKU)/count(entire.SKU),4) `����30��SKU�ع���`
from ( -- ����SKU
	select wp.SKU ,ProjectTeam,dep2 from import_data.wt_products wp
	left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' ) ds on wp.DevelopUserName = ds.staff_name
	where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
	group by wp.SKU ,ProjectTeam,dep2 ) entire
left join ( -- ���ع�SKU
    select wl.SKU
    from wt_listing wl
    join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
         ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -30 day)
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -30 day) and ad.CreatedTime< '${NextStartDay}'
    where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
    group by wl.SKU having  sum(Exposure) > 100
    ) part on entire.Sku = part.SKU
group by grouping sets ((),(entire.dep2));


-- ����7��SKU����ʡ�ת����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuClickRateIn7dDev ,SkuAdSaleRateIn7dDev )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(Clicks)/sum(Exposure),4) SkuClickRateIn7dDev
	,round(sum(TotalSale7DayUnit )/sum(Clicks),4) SkuAdSaleRateIn7dDev
from wt_listing wl
join (select wp.SKU ,dep2,DevelopLastAuditTime from import_data.wt_products wp
    left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
        ) ds on wp.DevelopUserName = ds.staff_name
    where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
     ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
	and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 7 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
group by grouping sets ((),(dep2));

-- ����14��SKU����ʡ�ת����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuClickRateIn14dDev ,SkuAdSaleRateIn14dDev )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(Clicks)/sum(Exposure),4) SkuClickRateIn14dDev
	,round(sum(TotalSale7DayUnit )/sum(Clicks),4) SkuAdSaleRateIn14dDev
from wt_listing wl
join (select wp.SKU ,dep2,DevelopLastAuditTime from import_data.wt_products wp
    left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
        ) ds on wp.DevelopUserName = ds.staff_name
    where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
     ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
	and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
group by grouping sets ((),(dep2));

-- ����30��SKU����ʡ�ת����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SkuClickRateIn30dDev ,SkuAdSaleRateIn30dDev )
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(Clicks)/sum(Exposure),4) SkuClickRateIn30dDev
	,round(sum(TotalSale7DayUnit )/sum(Clicks),4) SkuAdSaleRateIn30dDev
from wt_listing wl
join (select wp.SKU ,dep2,DevelopLastAuditTime from import_data.wt_products wp
    left join ( select staff_name, level2_name as dep2,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
        ) ds on wp.DevelopUserName = ds.staff_name
    where DevelopLastAuditTime >= date_add('${StartDay}',interval -30 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -30 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
     ) wp on wl.sku = wp.sku and wl.MinPublicationDate >= date_add('${StartDay}',interval -30 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
	and ad.CreatedTime >= date_add('${StartDay}',interval -30 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 <= 30 and timestampdiff(second,DevelopLastAuditTime,CreatedTime)/86400 >= 0
group by grouping sets ((),(dep2));