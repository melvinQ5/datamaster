
-- 标记期统计
insert into ads_ag_kbh_report_weekly ( `FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    TopSaleSpuCnt, --  '爆款SPU数，近30天单SPU不含运费销售额>=1500USD',
    TopSaleSpuCnt_ele, --  '爆款SPU数-主题',
    TopSaleSpuCntIn90dDev, --  '新品爆款SPU数',
    TopSaleSpuCntIn90dDev_ele, --  '新品爆款SPU数_主题',
    TopSaleSpuCntBf90dDev_ele, --  '老品爆款SPU数_主题',
    HotSaleSpuCnt, --  '旺款SPU数，近30天单SPU不含运费销售额>=500且小于1500USD',
    HotSaleSpuCnt_ele, --  '旺款SPU数-主题',
    HotSaleSpuCntIn90dDev, --  '新品旺款SPU数',
    HotSaleSpuCntIn90dDev_ele, --  '新品旺款SPU数-主题',
    HotSaleSpuCntBf90dDev_ele, --  '老品旺款SPU数-主题'
    TopSaleSpuValue,            --  '爆款SPU标记期单产',
    TopSaleSpuValue_ele,        --  '爆款SPU标记期单产_主题',
    TopSaleSpuValueIn30dDev,    --  '新品爆款SPU标记期单产',
    HotSaleSpuValue,            --  '旺款SPU标记期单产',
    HotSaleSpuValue_ele,        --  '旺款SPU标记期单产_主题',
    HotSaleSpuValueIn30dDev,    --  '新品旺款SPU标记期单产'
    TopHotStopSpuRate,           -- 爆旺款停产SPU占比
    UnderHotSaleSpuValue,  -- 非爆旺款单产
    UnderHotSaleSpuValue_In90dDev -- 新品非爆旺款单产
)
select
    '${StartDay}' ,'${ReportType}'
     , case when department = '快百货成都' then '快百货一部' when department = '快百货泉州' then '快百货二部' else department end as department
     ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(distinct case when prod_level='爆款' then akpl.spu end) 爆款spu数
    ,count(distinct case when prod_level='爆款' and tag.spu is not null then akpl.spu end) 爆款spu数_主题
    ,count(distinct case when prod_level='爆款' and isnew='新品' then akpl.spu end) 新品爆款spu数
    ,count(distinct case when prod_level='爆款' and isnew='新品' and tag.spu is not null then akpl.spu end) 新品爆款spu数_主题
    ,count(distinct case when prod_level='爆款' and isnew='老品' and tag.spu is not null then akpl.spu end) 老品爆款spu数_主题
    ,count(distinct case when prod_level='旺款' then akpl.spu end) 旺款spu数
    ,count(distinct case when prod_level='旺款' and tag.spu is not null then akpl.spu end) 旺款spu数_主题
    ,count(distinct case when prod_level='旺款' and isnew='新品' then akpl.spu end) 新品旺款spu数
    ,count(distinct case when prod_level='旺款' and isnew='新品' and tag.spu is not null then akpl.spu end) 新品旺款spu数_主题
    ,count(distinct case when prod_level='旺款' and isnew='老品' and tag.spu is not null then akpl.spu end) 老品旺款spu数_主题
    ,round(sum(case when prod_level='爆款' then sales_in30d end) /count(case when prod_level='爆款' then akpl.spu end),2) as 爆款SPU标记期单产
    ,ifnull(round(sum(case when prod_level='爆款' and tag.spu is not null then sales_in30d end) /count(case when prod_level='爆款' and tag.spu is not null then akpl.spu  end),2),0) as 爆款SPU标记期单产_主题
    ,round(sum(case when prod_level='爆款' and isnew='新品' then sales_in30d end) /count(case when prod_level='爆款' and isnew='新品' then akpl.spu end),2) as 新品爆款SPU标记期单产
    ,round(sum(case when prod_level='旺款' then sales_in30d end) /count(case when prod_level='旺款' then akpl.spu end),2) as 旺款SPU标记期单产
    ,round(sum(case when prod_level='旺款' and tag.spu is not null then sales_in30d end) /count(case when prod_level='旺款' and tag.spu is not null then akpl.spu end),2) as 旺款SPU标记期单产_主题
    ,round(sum(case when prod_level='旺款' and isnew='新品' then sales_in30d end) /count(case when prod_level='旺款' and isnew='新品' then akpl.spu end),2) as 新品旺款SPU标记期单产
    ,round(count(case when ProductStatus = '停产' then akpl.spu end) /count( akpl.spu  ),2) as 爆旺款停产SPU占比
    ,round(sum(case when prod_level not regexp '爆款|旺款' then sales_in30d end) /count(case when prod_level not regexp '爆款|旺款' then akpl.spu end),2) as 非爆款SPU标记期单产
    ,round(sum(case when prod_level not regexp '爆款|旺款' and isnew='新品' then sales_in30d end) /count(case when prod_level not regexp '爆款|旺款' and isnew='新品' then akpl.spu end),2) as 新品非爆款SPU标记期单产
from import_data.dep_kbh_product_level akpl
left join ( select eppaea.spu -- 主题
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name regexp '圣诞节|万圣节'
	group by spu ) tag on akpl.spu = tag.spu
left join ( select distinct spu ,level2_name  from wt_products wp -- 为了计算 新品爆旺款数_本部门开发
    join ( select staff_name ,case when staff_name regexp '郑燕飞|杨敏霞|林家贤' then '快百货泉州' else '快百货成都' end as level2_name
        from import_data.dim_staff
        where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
        ) ds on wp.DevelopUserName = ds.staff_name  and ProjectTeam = '快百货'
    ) self on akpl.spu = self.spu
--     and akpl.Department = self.level2_name
where akpl.FirstDay >= '${StartDay}' and akpl.FirstDay < '${NextStartDay}'
group by department ;





-- 近7天统计 本期 ,适用快百货
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    TopSaleSpuAmount, --  '爆款SPU本期销售额',
    TopSaleSpuAmountIn3m, -- 爆款新品SPU本期销售额
    HotSaleSpuAmount, --  '旺款SPU本期销售额',
    HotSaleSpuAmountIn3m, -- 爆款新品SPU本期销售额
    TopSaleSpuRate, --  '爆款SPU本期销售额占比',
    HotSaleSpuRate, --  '旺款SPU本期销售额占比',
    TopHotProfitRate,
    otherProdProfitRate,
    ProfitRate_In90dDev,
    ProfitRate_Bf90dDev
)
select '${StartDay}'
    , '${ReportType}'
    , '快百货'
    , '合计'
    , year('${StartDay}')
    , month('${StartDay}')
    , WEEKOFYEAR('${StartDay}') + 1
    , round(sum(case when prod_level = '爆款' then sales_in7d end), 2)                   `爆款SPU本期销售额`
    , round(sum(case when prod_level = '爆款' and isnew = '新品' then sales_in7d end), 2) `爆款新品SPU本期销售额`
    , round(sum(case when prod_level = '旺款' then sales_in7d end), 2)                   `旺款SPU本期销售额`
    , round(sum(case when prod_level = '旺款' and isnew = '新品' then sales_in7d end),2)   `旺款新品SPU本期销售额`
    , round(sum(case when prod_level = '爆款' then sales_in7d end) / sum(sales_in7d), 2) `爆款SPU本期销售额占比`
    , round(sum(case when prod_level = '旺款' then sales_in7d end) / sum(sales_in7d), 2) `旺款SPU本期销售额占比`
    ,round( sum(case when prod_level regexp '爆款|旺款' then profit_in30d end) / sum( case when prod_level regexp '爆款|旺款' then sales_in30d end ),4) `爆旺款利润率`
    ,round( sum(case when prod_level not regexp '爆款|旺款' then profit_in30d end) / sum( case when prod_level not regexp '爆款|旺款' then sales_in30d end ),4) `非爆旺款利润率`
    ,round( sum(case when isnew ='新品' then profit_in7d end) / sum( case when isnew ='新品' then sales_in7d end ),4) `新品利润率`
    ,round( sum(case when isnew ='老品' then profit_in7d end) / sum( case when isnew ='老品' then sales_in7d end ),4) `老品利润率`
from import_data.dep_kbh_product_level
where FirstDay = '${StartDay}';



-- 主题爆旺款业绩占比 TopHotSaleRate_ele
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    TopHotSaleRate_ele )
select
	'${StartDay}' ,'${ReportType}'
    , case when Department = '快百货成都' then '快百货一部'  when  Department = '快百货泉州' then '快百货二部' else  Department  end Department
     ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round( sum( case when prod_level regexp '爆款|旺款' and tag.spu is not null then sales_in30d end) / sum(case when tag.spu is not null then sales_in30d end ),4) `主题爆旺款业绩占比`
from dep_kbh_product_level akpl
left join ( select eppaea.spu -- 主题
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name regexp '圣诞节|万圣节'
	group by spu ) tag on akpl.spu = tag.spu
where FirstDay= '${StartDay}'
group by Department;





-- 成都团队新品开发，成都+泉州出单
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
    HotSaleSpuCntIn90dDev_DevbySelf, -- 新品旺款SPU数_本部门开发
    TopSaleSpuCntIn90dDev_DevbySelf -- 新品爆款SPU数_本部门开发
)
select 
	'${StartDay}' ,'${ReportType}'
     , '快百货一部'
     ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,count(case when prod_level='旺款' and isnew='新品' and spu_team.spu is not null then akpl.spu end) 新品旺款spu数_本部门开发
    ,count(case when prod_level='爆款' and isnew='新品' and spu_team.spu is not null then akpl.spu end) 新品爆款spu数_本部门开发
from import_data.dep_kbh_product_level akpl
left join ( select distinct spu ,level2_name  from wt_products wp -- 为了计算 新品爆旺款数_本部门开发
	join ( select staff_name ,case when staff_name regexp '郑燕飞|杨敏霞|林家贤' then '快百货泉州' else '快百货成都' end as level2_name
	    from import_data.dim_staff
	    where  department='快百货' and rolenames regexp '产品开发专员|产品开发经理|PM选品专员|PM选品主管'
	    ) ds on wp.DevelopUserName = ds.staff_name  and ProjectTeam = '快百货'
	) spu_team on akpl.spu = spu_team.spu
where akpl.FirstDay= '${StartDay}' and akpl.Department = '快百货' and spu_team.level2_name = '快百货成都';



-- 快百货成功率
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
PotentialLevelUpRateIn7d)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  7天成功率
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -1 week )) and prod_level regexp '潜力款' group by spu ) w0 -- 上周潜力款
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay =  '${StartDay}'  and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
PotentialLevelUpRateIn14d)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14天成功率
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -2 week )) and prod_level regexp '潜力款' group by spu ) w0 -- 上周潜力款
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${StartDay}',interval -2 week )) and FirstDay <= '${StartDay}' and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
PotentialLevelUpRateIn28d)
select '${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  28天成功率
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -4 week )) and prod_level regexp '潜力款' group by spu ) w0 -- 上周潜力款
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay >= date(date_add('${StartDay}',interval -4 week )) and FirstDay <= '${StartDay}' and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;
