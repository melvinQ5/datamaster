
-- ��ٻ���
-- �����ͳ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week` ,
ALstCnt,               --  comment 'A��������',
SLstCnt,              --  comment 'S��������',
BLstCnt,
CLstCnt,
ALstSaleSpuValue,      --  comment 'A�����ӱ���ڵ���',
SLstSaleSpuValue,      --  comment 'S�����ӱ���ڵ���',
BLstSaleSpuValue,
CLstSaleSpuValue,
SALstSaleSpuValue, -- SA���ӵ���
SALstOfflineSpuRate,   --  comment 'SA������δ����ռ��',
SALstProfitRate, -- SA����������
otherLstProfitRate -- ��SA����������
)
select
    '${StartDay}' ,'${ReportType}'
    ,'��ٻ�'
    ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when list_level='A' then concat(asin,site) end) A������
    ,count(distinct case when list_level='S' then concat(asin,site) end) S������
    ,count(case when list_level='Ǳ��' then concat(asin,site) end) B������
    ,count(case when list_level='����' then concat(asin,site) end) C������
    ,round(sum(case when list_level='A' then sales_in30d end) /count(distinct case when list_level='A' then concat(asin,site) end),2) as A���ӱ���ڵ���
    ,round(sum(case when list_level='S' then sales_in30d end) /count(distinct case when list_level='S' then concat(asin,site) end),2) as S���ӱ���ڵ���
    ,round(sum(case when list_level='Ǳ��' then sales_in30d end) /count(distinct case when list_level='Ǳ��' then concat(asin,site) end),2) as B���ӱ���ڵ���
    ,round(sum(case when list_level='����' then sales_in30d end) /count(distinct case when list_level='����' then concat(asin,site) end),2) as C���ӱ���ڵ���
    ,round(sum(case when list_level regexp  'S|A' then sales_in30d end) /count(distinct case when list_level  regexp  'S|A' then  concat(asin,site) end),2) as SA���ӵ���
    ,round(sum(case when ListingStatus = 'δ����' then 1 end) /count( 1 ),4) as SA������δ����ռ��
    ,round(sum(case when list_level regexp  'S|A' then profit_in30d end) / sum(case when list_level regexp  'S|A' then sales_in30d end) ,4) as SA����������
    ,round(sum(case when list_level not regexp  'S|A' then profit_in30d end) / sum(case when list_level not regexp  'S|A' then sales_in30d end) ,4) as ��SA����������
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}';

-- ����ͳ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
ALstSaleSpuAmount, --  'A�����ӱ������۶�',
SLstSaleSpuAmount, --  'S�����ӱ������۶�',
ALstSaleSpuRate, --  'A�����ӱ������۶�ռ��',
SLstSaleSpuRate, --  'S�����ӱ������۶�ռ��',
BLstSaleSpuRate,
CLstSaleSpuRate
)
select
	'${StartDay}' ,'${ReportType}'
    ,'��ٻ�'
     ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round( sum(case when list_level='A' then sales_in7d end),2) `A�����ӱ������۶�`
	,round( sum(case when list_level='S' then sales_in7d end),2) `S�����ӱ������۶�`
	,round( sum(case when list_level='A' then sales_in7d end) / sum(sales_in7d) ,4) `A�����ӱ������۶�ռ��`
	,round( sum(case when list_level='S' then sales_in7d end) / sum(sales_in7d) ,4) `S�����ӱ������۶�ռ��`
	,round( sum(case when list_level='Ǳ��' then sales_in7d end) / sum(sales_in7d) ,4) `B�����ӱ������۶�ռ��`
	,round( sum(case when list_level='����' then sales_in7d end) / sum(sales_in7d) ,4) `C�����ӱ������۶�ռ��`
from import_data.dep_kbh_listing_level
where FirstDay = '${StartDay}';


-- ����������
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
SLstCnt_NewAdd ,ALstCnt_NewAdd  )
select '${StartDay}' ,'${ReportType}'
    ,'��ٻ�'
     ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when week_0.list_level='S' and week_bf1.list_level != 'S' then CONCAT( week_0.asin,week_0.site) end )   -- S������
    ,count(distinct case when week_0.list_level='A' and week_bf1.list_level not regexp  'A|S' then CONCAT( week_0.asin,week_0.site) end )   -- ��������
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department;





-- ���ֳɶ�Ȫ��
-- �����ͳ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week` ,
ALstCnt,               --  comment 'A��������',
SLstCnt,              --  comment 'S��������',
BLstCnt,
CLstCnt,
ALstSaleSpuValue,      --  comment 'A�����ӱ���ڵ���',
SLstSaleSpuValue,      --  comment 'S�����ӱ���ڵ���',
BLstSaleSpuValue,
CLstSaleSpuValue,
SALstSaleSpuValue, -- SA���ӵ���
SALstOfflineSpuRate,   --  comment 'SA������δ����ռ��',
SALstProfitRate, -- SA����������
otherLstProfitRate -- ��SA����������
)
select
    '${StartDay}' ,'${ReportType}'
    , case when department regexp '�ɶ�' then '��ٻ�һ��' when department regexp 'Ȫ��' then '��ٻ�����' else department end as department
    ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when list_level='A' then concat(asin,site) end) A������
    ,count(distinct case when list_level='S' then concat(asin,site) end) S������
    ,count(case when list_level='Ǳ��' then concat(asin,site) end) B������
    ,count(case when list_level='����' then concat(asin,site) end) C������
    ,round(sum(case when list_level='A' then sales_in30d end) /count(distinct case when list_level='A' then concat(asin,site) end),2) as A���ӱ���ڵ���
    ,round(sum(case when list_level='S' then sales_in30d end) /count(distinct case when list_level='S' then concat(asin,site) end),2) as S���ӱ���ڵ���
    ,round(sum(case when list_level='Ǳ��' then sales_in30d end) /count(distinct case when list_level='Ǳ��' then concat(asin,site) end),2) as B���ӱ���ڵ���
    ,round(sum(case when list_level='����' then sales_in30d end) /count(distinct case when list_level='����' then concat(asin,site) end),2) as C���ӱ���ڵ���
    ,round(sum(case when list_level regexp  'S|A' then sales_in30d end) /count(distinct case when list_level  regexp  'S|A' then  concat(asin,site) end),2) as SA���ӵ���
    ,round(sum(case when ListingStatus = 'δ����' then 1 end) /count( 1 ),4) as SA������δ����ռ��
    ,round(sum(case when list_level regexp  'S|A' then profit_in30d end) / sum(case when list_level regexp  'S|A' then sales_in30d end) ,4) as SA����������
    ,round(sum(case when list_level not regexp  'S|A' then profit_in30d end) / sum(case when list_level not regexp  'S|A' then sales_in30d end) ,4) as ��SA����������
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}'
group by department;

-- ����ͳ��
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
ALstSaleSpuAmount, --  'A�����ӱ������۶�',
SLstSaleSpuAmount, --  'S�����ӱ������۶�',
ALstSaleSpuRate, --  'A�����ӱ������۶�ռ��',
SLstSaleSpuRate, --  'S�����ӱ������۶�ռ��',
BLstSaleSpuRate,
CLstSaleSpuRate
)
select
	'${StartDay}' ,'${ReportType}'
     , case when department regexp '�ɶ�' then '��ٻ�һ��' when department regexp 'Ȫ��' then '��ٻ�����' else department end as department
     ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round( sum(case when list_level='A' then sales_in7d end),2) `A�����ӱ������۶�`
	,round( sum(case when list_level='S' then sales_in7d end),2) `S�����ӱ������۶�`
	,round( sum(case when list_level='A' then sales_in7d end) / sum(sales_in7d) ,4) `A�����ӱ������۶�ռ��`
	,round( sum(case when list_level='S' then sales_in7d end) / sum(sales_in7d) ,4) `S�����ӱ������۶�ռ��`
	,round( sum(case when list_level='Ǳ��' then sales_in7d end) / sum(sales_in7d) ,4) `B�����ӱ������۶�ռ��`
	,round( sum(case when list_level='����' then sales_in7d end) / sum(sales_in7d) ,4) `C�����ӱ������۶�ռ��`
from import_data.dep_kbh_listing_level
where FirstDay = '${StartDay}'
group by Department;


