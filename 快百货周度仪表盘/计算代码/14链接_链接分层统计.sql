
-- 快百货总
-- 标记期统计
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week` ,
ALstCnt,               --  comment 'A级链接数',
SLstCnt,              --  comment 'S级链接数',
BLstCnt,
CLstCnt,
ALstSaleSpuValue,      --  comment 'A级链接标记期单产',
SLstSaleSpuValue,      --  comment 'S级链接标记期单产',
BLstSaleSpuValue,
CLstSaleSpuValue,
SALstSaleSpuValue, -- SA链接单产
SALstOfflineSpuRate,   --  comment 'SA级链接未在线占比',
SALstProfitRate, -- SA链接利润率
otherLstProfitRate -- 非SA链接利润率
)
select
    '${StartDay}' ,'${ReportType}'
    ,'快百货'
    ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when list_level='A' then concat(asin,site) end) A链接数
    ,count(distinct case when list_level='S' then concat(asin,site) end) S链接数
    ,count(case when list_level='潜力' then concat(asin,site) end) B链接数
    ,count(case when list_level='其他' then concat(asin,site) end) C链接数
    ,round(sum(case when list_level='A' then sales_in30d end) /count(distinct case when list_level='A' then concat(asin,site) end),2) as A链接标记期单产
    ,round(sum(case when list_level='S' then sales_in30d end) /count(distinct case when list_level='S' then concat(asin,site) end),2) as S链接标记期单产
    ,round(sum(case when list_level='潜力' then sales_in30d end) /count(distinct case when list_level='潜力' then concat(asin,site) end),2) as B链接标记期单产
    ,round(sum(case when list_level='其他' then sales_in30d end) /count(distinct case when list_level='其他' then concat(asin,site) end),2) as C链接标记期单产
    ,round(sum(case when list_level regexp  'S|A' then sales_in30d end) /count(distinct case when list_level  regexp  'S|A' then  concat(asin,site) end),2) as SA链接单产
    ,round(sum(case when ListingStatus = '未在线' then 1 end) /count( 1 ),4) as SA级链接未在线占比
    ,round(sum(case when list_level regexp  'S|A' then profit_in30d end) / sum(case when list_level regexp  'S|A' then sales_in30d end) ,4) as SA链接利润率
    ,round(sum(case when list_level not regexp  'S|A' then profit_in30d end) / sum(case when list_level not regexp  'S|A' then sales_in30d end) ,4) as 非SA链接利润率
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}';

-- 本期统计
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
ALstSaleSpuAmount, --  'A级链接本期销售额',
SLstSaleSpuAmount, --  'S级链接本期销售额',
ALstSaleSpuRate, --  'A级链接本期销售额占比',
SLstSaleSpuRate, --  'S级链接本期销售额占比',
BLstSaleSpuRate,
CLstSaleSpuRate
)
select
	'${StartDay}' ,'${ReportType}'
    ,'快百货'
     ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round( sum(case when list_level='A' then sales_in7d end),2) `A级链接本期销售额`
	,round( sum(case when list_level='S' then sales_in7d end),2) `S级链接本期销售额`
	,round( sum(case when list_level='A' then sales_in7d end) / sum(sales_in7d) ,4) `A级链接本期销售额占比`
	,round( sum(case when list_level='S' then sales_in7d end) / sum(sales_in7d) ,4) `S级链接本期销售额占比`
	,round( sum(case when list_level='潜力' then sales_in7d end) / sum(sales_in7d) ,4) `B级链接本期销售额占比`
	,round( sum(case when list_level='其他' then sales_in7d end) / sum(sales_in7d) ,4) `C级链接本期销售额占比`
from import_data.dep_kbh_listing_level
where FirstDay = '${StartDay}';


-- 链接新增数
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
SLstCnt_NewAdd ,ALstCnt_NewAdd  )
select '${StartDay}' ,'${ReportType}'
    ,'快百货'
     ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when week_0.list_level='S' and week_bf1.list_level != 'S' then CONCAT( week_0.asin,week_0.site) end )   -- S新增数
    ,count(distinct case when week_0.list_level='A' and week_bf1.list_level not regexp  'A|S' then CONCAT( week_0.asin,week_0.site) end )   -- 旺新增数
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 week )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department;





-- 区分成都泉州
-- 标记期统计
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week` ,
ALstCnt,               --  comment 'A级链接数',
SLstCnt,              --  comment 'S级链接数',
BLstCnt,
CLstCnt,
ALstSaleSpuValue,      --  comment 'A级链接标记期单产',
SLstSaleSpuValue,      --  comment 'S级链接标记期单产',
BLstSaleSpuValue,
CLstSaleSpuValue,
SALstSaleSpuValue, -- SA链接单产
SALstOfflineSpuRate,   --  comment 'SA级链接未在线占比',
SALstProfitRate, -- SA链接利润率
otherLstProfitRate -- 非SA链接利润率
)
select
    '${StartDay}' ,'${ReportType}'
    , case when department regexp '成都' then '快百货一部' when department regexp '泉州' then '快百货二部' else department end as department
    ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when list_level='A' then concat(asin,site) end) A链接数
    ,count(distinct case when list_level='S' then concat(asin,site) end) S链接数
    ,count(case when list_level='潜力' then concat(asin,site) end) B链接数
    ,count(case when list_level='其他' then concat(asin,site) end) C链接数
    ,round(sum(case when list_level='A' then sales_in30d end) /count(distinct case when list_level='A' then concat(asin,site) end),2) as A链接标记期单产
    ,round(sum(case when list_level='S' then sales_in30d end) /count(distinct case when list_level='S' then concat(asin,site) end),2) as S链接标记期单产
    ,round(sum(case when list_level='潜力' then sales_in30d end) /count(distinct case when list_level='潜力' then concat(asin,site) end),2) as B链接标记期单产
    ,round(sum(case when list_level='其他' then sales_in30d end) /count(distinct case when list_level='其他' then concat(asin,site) end),2) as C链接标记期单产
    ,round(sum(case when list_level regexp  'S|A' then sales_in30d end) /count(distinct case when list_level  regexp  'S|A' then  concat(asin,site) end),2) as SA链接单产
    ,round(sum(case when ListingStatus = '未在线' then 1 end) /count( 1 ),4) as SA级链接未在线占比
    ,round(sum(case when list_level regexp  'S|A' then profit_in30d end) / sum(case when list_level regexp  'S|A' then sales_in30d end) ,4) as SA链接利润率
    ,round(sum(case when list_level not regexp  'S|A' then profit_in30d end) / sum(case when list_level not regexp  'S|A' then sales_in30d end) ,4) as 非SA链接利润率
from import_data.dep_kbh_listing_level akll
where akll.FirstDay= '${StartDay}'
group by department;

-- 本期统计
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
ALstSaleSpuAmount, --  'A级链接本期销售额',
SLstSaleSpuAmount, --  'S级链接本期销售额',
ALstSaleSpuRate, --  'A级链接本期销售额占比',
SLstSaleSpuRate, --  'S级链接本期销售额占比',
BLstSaleSpuRate,
CLstSaleSpuRate
)
select
	'${StartDay}' ,'${ReportType}'
     , case when department regexp '成都' then '快百货一部' when department regexp '泉州' then '快百货二部' else department end as department
     ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round( sum(case when list_level='A' then sales_in7d end),2) `A级链接本期销售额`
	,round( sum(case when list_level='S' then sales_in7d end),2) `S级链接本期销售额`
	,round( sum(case when list_level='A' then sales_in7d end) / sum(sales_in7d) ,4) `A级链接本期销售额占比`
	,round( sum(case when list_level='S' then sales_in7d end) / sum(sales_in7d) ,4) `S级链接本期销售额占比`
	,round( sum(case when list_level='潜力' then sales_in7d end) / sum(sales_in7d) ,4) `B级链接本期销售额占比`
	,round( sum(case when list_level='其他' then sales_in7d end) / sum(sales_in7d) ,4) `C级链接本期销售额占比`
from import_data.dep_kbh_listing_level
where FirstDay = '${StartDay}'
group by Department;


