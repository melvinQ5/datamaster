insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,SaleSpuCntIn90dDev ,SaleAmountIn90dDev ,SaleSpuCntIn90dDev_ele )
select '${StartDay}' ,'${ReportType}',ifnull(ms.dep2,'��ٻ�'),'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.Product_SPU) ��Ʒ����SPU��
    ,round(sum(TotalGross/ExchangeUSD),2) ��Ʒ���۶�
    ,count(distinct tag.spu ) ��Ʒ����SPU��_����
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.shopcode=ms.Code
join ( select distinct spu from view_kbp_new_products ) wp on wo.product_spu = wp.spu
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '${ele_name}'
	group by spu ) tag on wp.spu = tag.spu
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.department regexp '��'
group by grouping sets ((),(ms.dep2));



--  �ɶ���Ʒ�鿪����Ʒ����Ʒ���۶� ������
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	SaleSpuCntIn90dDev_DevbySelf ,SaleAmountIn90dDev_DevbySelf )
select '${StartDay}' ,'${ReportType}','��ٻ�һ��','�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.Product_SPU) ��Ʒ����SPU��_�����ſ���
    ,round(sum(TotalGross/ExchangeUSD),2) ��Ʒ���۶�_�����ſ���
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.shopcode=ms.Code
join(select distinct spu from wt_products wp
    join ( select staff_name, level2_name ,level3_name,rolenames from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����' and level2_name ='��ٻ�һ��'
        ) ds on wp.DevelopUserName = ds.staff_name
--     where date_add(DevelopLastAuditTime , interval - 8 hour) >=  DATE_ADD( DATE_ADD('${NextStartDay}',interval -day('${NextStartDay}')+1 day) ,interval -2 month)
    where date_add(DevelopLastAuditTime , interval - 8 hour)  >= '2023-07-01'
        and ProjectTeam = '��ٻ�'
    ) wp on wo.product_spu = wp.spu
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '${ele_name}'
	group by spu ) tag on wp.spu = tag.spu
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.department regexp '��';


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,SaleSpuCntIn90dDev ,SaleAmountIn90dDev ,SaleSpuCntIn90dDev_ele )
select '${StartDay}' ,'${ReportType}',nodepathname ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct wo.Product_SPU) ��Ʒ����SPU��
    ,round(sum(TotalGross/ExchangeUSD),2) ��Ʒ���۶�
    ,count(distinct tag.spu ) ��Ʒ����SPU��_����
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.shopcode=ms.Code
join(select distinct spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >= '2023-07-01'
    and ProjectTeam = '��ٻ�'
    ) wp on wo.product_spu = wp.spu
left join ( select eppaea.spu
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name = '${ele_name}'
	group by spu ) tag on wp.spu = tag.spu
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '����'  and asin <>'' -- ÿ�»��м�ʮ���ϰ�����������û��ASIN
	and ms.department regexp '��'
group by nodepathname;
