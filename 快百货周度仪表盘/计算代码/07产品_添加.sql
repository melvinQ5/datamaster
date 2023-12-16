insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	NewAddSpuCnt )
select '${StartDay}' ,'${ReportType}' ,ProjectTeam ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 as weeks
	,count(distinct wp.spu ) `添加SPU数`
from import_data.erp_product_products wp
join erp_product_product_statuses epps -- 每个产品创建后会一次性生成每个状态的行记录，有IsCurrentStage来表示进度
    on wp.Id = epps.ProductId
    and IsCurrentStage = 1 and DevelopStage >10 -- 剔除待开发提交的数据，即草稿箱
where Creationtime < '${NextStartDay}' and Creationtime >= '${StartDay}' and ProjectTeam = '快百货' and IsMatrix=0
  and status != 20  -- 不等于作废，即包含开发中和开发完成
group by ProjectTeam;
