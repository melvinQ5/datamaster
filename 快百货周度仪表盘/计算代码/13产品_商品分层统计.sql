
-- �����ͳ��
insert into ads_ag_kbh_report_weekly ( `FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    TopSaleSpuCnt, --  '����SPU������30�쵥SPU�����˷����۶�>=1500USD',
    TopSaleSpuCnt_ele, --  '����SPU��-����',
    TopSaleSpuCntIn90dDev, --  '��Ʒ����SPU��',
    TopSaleSpuCntIn90dDev_ele, --  '��Ʒ����SPU��_����',
    TopSaleSpuCntBf90dDev_ele, --  '��Ʒ����SPU��_����',
    HotSaleSpuCnt, --  '����SPU������30�쵥SPU�����˷����۶�>=500��С��1500USD',
    HotSaleSpuCnt_ele, --  '����SPU��-����',
    HotSaleSpuCntIn90dDev, --  '��Ʒ����SPU��',
    HotSaleSpuCntIn90dDev_ele, --  '��Ʒ����SPU��-����',
    HotSaleSpuCntBf90dDev_ele, --  '��Ʒ����SPU��-����'
    TopSaleSpuValue,            --  '����SPU����ڵ���',
    TopSaleSpuValue_ele,        --  '����SPU����ڵ���_����',
    TopSaleSpuValueIn30dDev,    --  '��Ʒ����SPU����ڵ���',
    HotSaleSpuValue,            --  '����SPU����ڵ���',
    HotSaleSpuValue_ele,        --  '����SPU����ڵ���_����',
    HotSaleSpuValueIn30dDev,    --  '��Ʒ����SPU����ڵ���'
    TopHotStopSpuRate,           -- ������ͣ��SPUռ��
    UnderHotSaleSpuValue,  -- �Ǳ������
    UnderHotSaleSpuValue_In90dDev -- ��Ʒ�Ǳ������
)
select
    '${StartDay}' ,'${ReportType}'
     , case when department = '��ٻ��ɶ�' then '��ٻ�һ��' when department = '��ٻ�Ȫ��' then '��ٻ�����' else department end as department
     ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when prod_level='����' then akpl.spu end) ����spu��
    ,count(distinct case when prod_level='����' and tag.spu is not null then akpl.spu end) ����spu��_����
    ,count(distinct case when prod_level='����' and isnew='��Ʒ' then akpl.spu end) ��Ʒ����spu��
    ,count(distinct case when prod_level='����' and isnew='��Ʒ' and tag.spu is not null then akpl.spu end) ��Ʒ����spu��_����
    ,count(distinct case when prod_level='����' and isnew='��Ʒ' and tag.spu is not null then akpl.spu end) ��Ʒ����spu��_����
    ,count(distinct case when prod_level='����' then akpl.spu end) ����spu��
    ,count(distinct case when prod_level='����' and tag.spu is not null then akpl.spu end) ����spu��_����
    ,count(distinct case when prod_level='����' and isnew='��Ʒ' then akpl.spu end) ��Ʒ����spu��
    ,count(distinct case when prod_level='����' and isnew='��Ʒ' and tag.spu is not null then akpl.spu end) ��Ʒ����spu��_����
    ,count(distinct case when prod_level='����' and isnew='��Ʒ' and tag.spu is not null then akpl.spu end) ��Ʒ����spu��_����
    ,round(sum(case when prod_level='����' then sales_in30d end) /count(case when prod_level='����' then akpl.spu end),2) as ����SPU����ڵ���
    ,ifnull(round(sum(case when prod_level='����' and tag.spu is not null then sales_in30d end) /count(case when prod_level='����' and tag.spu is not null then akpl.spu  end),2),0) as ����SPU����ڵ���_����
    ,round(sum(case when prod_level='����' and isnew='��Ʒ' then sales_in30d end) /count(case when prod_level='����' and isnew='��Ʒ' then akpl.spu end),2) as ��Ʒ����SPU����ڵ���
    ,round(sum(case when prod_level='����' then sales_in30d end) /count(case when prod_level='����' then akpl.spu end),2) as ����SPU����ڵ���
    ,round(sum(case when prod_level='����' and tag.spu is not null then sales_in30d end) /count(case when prod_level='����' and tag.spu is not null then akpl.spu end),2) as ����SPU����ڵ���_����
    ,round(sum(case when prod_level='����' and isnew='��Ʒ' then sales_in30d end) /count(case when prod_level='����' and isnew='��Ʒ' then akpl.spu end),2) as ��Ʒ����SPU����ڵ���
    ,round(count(case when ProductStatus = 'ͣ��' then akpl.spu end) /count( akpl.spu  ),2) as ������ͣ��SPUռ��
    ,round(sum(case when prod_level not regexp '����|����' then sales_in30d end) /count(case when prod_level not regexp '����|����' then akpl.spu end),2) as �Ǳ���SPU����ڵ���
    ,round(sum(case when prod_level not regexp '����|����' and isnew='��Ʒ' then sales_in30d end) /count(case when prod_level not regexp '����|����' and isnew='��Ʒ' then akpl.spu end),2) as ��Ʒ�Ǳ���SPU����ڵ���
from import_data.dep_kbh_product_level akpl
left join ( select eppaea.spu -- ����
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name regexp 'ʥ����|��ʥ��'
	group by spu ) tag on akpl.spu = tag.spu
left join ( select distinct spu ,level2_name  from wt_products wp -- Ϊ�˼��� ��Ʒ��������_�����ſ���
    join ( select staff_name ,case when staff_name regexp '֣���|����ϼ|�ּ���' then '��ٻ�Ȫ��' else '��ٻ��ɶ�' end as level2_name
        from import_data.dim_staff
        where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
        ) ds on wp.DevelopUserName = ds.staff_name  and ProjectTeam = '��ٻ�'
    ) self on akpl.spu = self.spu
--     and akpl.Department = self.level2_name
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}'
group by department ;





-- ��7��ͳ�� ���� ,���ÿ�ٻ�
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    TopSaleSpuAmount, --  '����SPU�������۶�',
    TopSaleSpuAmountIn3m, -- ������ƷSPU�������۶�
    HotSaleSpuAmount, --  '����SPU�������۶�',
    HotSaleSpuAmountIn3m, -- ������ƷSPU�������۶�
    TopSaleSpuRate, --  '����SPU�������۶�ռ��',
    HotSaleSpuRate, --  '����SPU�������۶�ռ��',
    TopHotProfitRate,
    otherProdProfitRate,
    ProfitRate_In90dDev,
    ProfitRate_Bf90dDev
)
select '${StartDay}'
    , '${ReportType}'
    , '��ٻ�'
    , '�ϼ�'
    , year('${StartDay}')
    , month('${StartDay}')
    , WEEKOFYEAR('${StartDay}') + 1
    , round(sum(case when prod_level = '����' then sales_in7d end), 2)                   `����SPU�������۶�`
    , round(sum(case when prod_level = '����' and isnew = '��Ʒ' then sales_in7d end), 2) `������ƷSPU�������۶�`
    , round(sum(case when prod_level = '����' then sales_in7d end), 2)                   `����SPU�������۶�`
    , round(sum(case when prod_level = '����' and isnew = '��Ʒ' then sales_in7d end),2)   `������ƷSPU�������۶�`
    , round(sum(case when prod_level = '����' then sales_in7d end) / sum(sales_in7d), 2) `����SPU�������۶�ռ��`
    , round(sum(case when prod_level = '����' then sales_in7d end) / sum(sales_in7d), 2) `����SPU�������۶�ռ��`
    ,round( sum(case when prod_level regexp '����|����' then profit_in30d end) / sum( case when prod_level regexp '����|����' then sales_in30d end ),4) `������������`
    ,round( sum(case when prod_level not regexp '����|����' then profit_in30d end) / sum( case when prod_level not regexp '����|����' then sales_in30d end ),4) `�Ǳ�����������`
    ,round( sum(case when isnew ='��Ʒ' then profit_in7d end) / sum( case when isnew ='��Ʒ' then sales_in7d end ),4) `��Ʒ������`
    ,round( sum(case when isnew ='��Ʒ' then profit_in7d end) / sum( case when isnew ='��Ʒ' then sales_in7d end ),4) `��Ʒ������`
from import_data.dep_kbh_product_level
where FirstDay = '${StartDay}';



-- ���ⱬ����ҵ��ռ�� TopHotSaleRate_ele
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    TopHotSaleRate_ele )
select
	'${StartDay}' ,'${ReportType}'
    , case when Department = '��ٻ��ɶ�' then '��ٻ�һ��'  when  Department = '��ٻ�Ȫ��' then '��ٻ�����' else  Department  end Department
     ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round( sum( case when prod_level regexp '����|����' and tag.spu is not null then sales_in30d end) / sum(case when tag.spu is not null then sales_in30d end ),4) `���ⱬ����ҵ��ռ��`
from dep_kbh_product_level akpl
left join ( select eppaea.spu -- ����
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name regexp 'ʥ����|��ʥ��'
	group by spu ) tag on akpl.spu = tag.spu
where FirstDay= '${StartDay}'
group by Department;





-- �ɶ��Ŷ���Ʒ�������ɶ�+Ȫ�ݳ���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    HotSaleSpuCntIn90dDev_DevbySelf, -- ��Ʒ����SPU��_�����ſ���
    TopSaleSpuCntIn90dDev_DevbySelf -- ��Ʒ����SPU��_�����ſ���
)
select 
	'${StartDay}' ,'${ReportType}'
     , '��ٻ�һ��'
     ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(case when prod_level='����' and isnew='��Ʒ' and spu_team.spu is not null then akpl.spu end) ��Ʒ����spu��_�����ſ���
    ,count(case when prod_level='����' and isnew='��Ʒ' and spu_team.spu is not null then akpl.spu end) ��Ʒ����spu��_�����ſ���
from import_data.dep_kbh_product_level akpl
left join ( select distinct spu ,level2_name  from wt_products wp -- Ϊ�˼��� ��Ʒ��������_�����ſ���
	join ( select staff_name ,case when staff_name regexp '֣���|����ϼ|�ּ���' then '��ٻ�Ȫ��' else '��ٻ��ɶ�' end as level2_name
	    from import_data.dim_staff
	    where  department='��ٻ�' and rolenames regexp '��Ʒ����רԱ|��Ʒ��������|PMѡƷרԱ|PMѡƷ����'
	    ) ds on wp.DevelopUserName = ds.staff_name  and ProjectTeam = '��ٻ�'
	) spu_team on akpl.spu = spu_team.spu
where akpl.FirstDay= '${StartDay}' and akpl.Department = '��ٻ�' and spu_team.level2_name = '��ٻ��ɶ�';



-- ��ٻ��ɹ���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
PotentialLevelUpRateIn7d)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  7��ɹ���
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -1 week )) and prod_level regexp 'Ǳ����' group by spu ) w0 -- ����Ǳ����
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay =  '${StartDay}'  and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
PotentialLevelUpRateIn14d)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14��ɹ���
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -2 week )) and prod_level regexp 'Ǳ����' group by spu ) w0 -- ����Ǳ����
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${StartDay}',interval -2 week )) and FirstDay <= '${StartDay}' and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
PotentialLevelUpRateIn28d)
select '${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  28��ɹ���
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -4 week )) and prod_level regexp 'Ǳ����' group by spu ) w0 -- ����Ǳ����
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${StartDay}',interval -4 week )) and FirstDay <= '${StartDay}' and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;
