-- 清理无用表
-- 删除表
-- import_data.ads_ag_staff_kbh_report_weekly;
-- import_data.ads_staff_kbh_report_weekly;
-- import_data.ads_kbh_staff_stat_weekly;

select * from ads_ag_kbh_report_weekly where FirstDay= '2023-07-01' and ReportType='月报';

-- 清空表（慎重，状态数据）
truncate table ads_ag_kbh_report_weekly;
truncate table BadDebtRate;

-- 先创建临时表 (AGGREGATE)
CREATE TABLE IF NOT EXISTS 
ads_ag_kbh_report_weekly (
`FirstDay` date NOT NULL COMMENT "对应统计期的第一天",
`ReportType` varchar(128) NOT NULL COMMENT "报表类型",
`Team` varchar(64) NOT NULL COMMENT "团队",
`Staff` varchar(24) NOT NULL COMMENT "人员",
`Year` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "统计年份",
`Month` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "统计月份",
`Week` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "统计周次",

`TotalGross` double REPLACE_IF_NOT_NULL NULL  COMMENT "销售额",
`TotalProfit` double REPLACE_IF_NOT_NULL NULL  COMMENT "利润额",
`TotalCost` double REPLACE_IF_NOT_NULL NULL  COMMENT "成本",
`ProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "毛利率",
`OriProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "挂单毛利率",
`AdSpendRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告花费占比",
`RefundRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "退款率",
`FeeGrossRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "运费收入占比",
`BadDebtAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "坏账金额",
`BadDebtRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "坏账率",
`NumberOfTeam` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "团队人数",
`ProfitPerformance` double REPLACE_IF_NOT_NULL NULL  COMMENT "利润额人效" ,


`AdSalesRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告业绩占比",
`AdSalesRate_manual` double REPLACE_IF_NOT_NULL NULL  COMMENT "手动广告业绩占比",
`AdOtherSkuSalesRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "非广告产品业绩占比",
`ROAS` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告所带来的总销售额与广告花费比值",
`CPC` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告花费与广告点击量比值",
`AdClickRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告点击率",
`AdSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告转化率",
`AdCoverRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "链接广告投放率",
`AdClicks` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "广告点击量",
`AdExposures` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "广告曝光量",
`AvgAdClicks` double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接广告点击量",
`AvgAdExposures` double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接广告曝光量",
`AvgAdExposuresIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接刊登7天广告曝光量",
`RoasIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登7天广告ROI",
`RoasIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登14天广告ROI",
`RoasIn30dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登30天广告ROI",
`ExpoRateIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登7天广告曝光率（UK/DE/FR/US）",
`ExpoRateIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登14天广告曝光率（UK/DE/FR/US）",
`ClickRateIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登7天广告点击率（UK/DE/FR/US）",
`ClickRateIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登14天广告点击率（UK/DE/FR/US）",
`AdSaleRateIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登7天广告转化率（UK/DE/FR/US）",
`AdSaleRateIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登14天广告转化率（UK/DE/FR/US）",


`NewDevSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "终审SPU数",
`NewDevSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "终审SPU数-主题",
`NewDevSkuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "终审SKU数",
`SpuSkuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品变体配比",
`NewAddSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "添加SPU数",
`SpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "产品库SPU数（非停产）",
`SkuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "产品库SKU数（非停产）",
`SpuStopCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "停产SPU数（汰换SPU数）",
`NewSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "近90天终审且终审时间大于2023-03-01的SPU数，视为新品",
`OldSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "未被停产的老品SPU数-主题",
`SaleSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品出单SPU数，以近90天为新品",
`SaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品出单SPU数_本部门开发",
`SaleSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品出单SPU数-主题，以近90天为新品",
`FirstSaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "首次出单SPU数",
`SpuValueIn30dSinceFirstOrd`double REPLACE_IF_NOT_NULL NULL  COMMENT "首单30天SPU单产",
`SaleAmountIn90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "近90天终审产品销售额",
`SaleAmountIn90dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品销售额_本部门开发"
`SaleAmount_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "当月销售额-主题",

`SaleAmount_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "当年主题生命周期内累计销售额",
`SaleAmountIn90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "当年新品主题生命周期内累计销售额" 
`SaleAmountBf90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "当年老品主题生命周期内累计销售额" 

`SaleAmountIn90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "主题新品当月销售额",
`SaleAmountBf90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "主题老品当月销售额",
`StopSkuRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品SKU停产SPU占比",

`SaleAmountIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "近30天终审产品销售额",
`SpuSaleCntIn30d` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "近30天动销SPU数",
`SpuSaleRateIn30d` double REPLACE_IF_NOT_NULL NULL  COMMENT "近30天SPU动销率",
`SpuUnitSaleIn30d` double REPLACE_IF_NOT_NULL NULL  COMMENT "近30天动销SPU单产",

`TopSaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU数，近30天单SPU不含运费销售额>=1500USD",
`TopSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU新增数",
`TopSaleSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU数-主题",
`TopSaleSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款SPU数",
`TopSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款新增SPU数",
`TopSaleSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款SPU数",
`TopSaleSpuCntBf90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "老品爆款SPU数",
`HotSaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU数，近30天单SPU不含运费销售额>=500且小于1500USD",
`HotSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU新增数",
`HotSaleSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU数-主题",
`HotSaleSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款SPU数",
`HotSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款新增SPU数",
`HotSaleSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款SPU数-主题",
`HotSaleSpuCntBf90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "老品旺款SPU数-主题",
`PotentialLevelUpRateIn7d` double REPLACE_IF_NOT_NULL NULL  COMMENT "潜力款7天成功率,即潜力变为爆旺款",
`PotentialLevelUpRateIn14d` double REPLACE_IF_NOT_NULL NULL  COMMENT "潜力款14天成功率,即潜力变为爆旺款",
`PotentialLevelUpRateIn28d` double REPLACE_IF_NOT_NULL NULL  COMMENT "潜力款28天成功率,即潜力变为爆旺款",
`HotSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款SPU数_本部门开发",
`TopSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款SPU数_本部门开发",

`TopSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU标记期单产",
`TopSaleSpuValue_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU标记期单产-主题",
`TopSaleSpuValueIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款SPU标记期单产",
`HotSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU标记期单产",
`HotSaleSpuValue_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU标记期单产-主题",
`HotSaleSpuValueIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款SPU标记期单产",
`UnderHotSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "非爆旺款标记期单产",
`TopHotSaleRate_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆旺款业绩占比-主题",


`TopSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU本期销售额",
`TopSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆款新品SPU本期销售额",
`HotSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU本期销售额",
`HotSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款新品SPU本期销售额",
`TopSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU本期销售额占比",
`HotSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU本期销售额占比",
`TopHotStopSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆旺款停产SPU占比",

`ALstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "A级链接数",
`ALstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "A级链接新增数",
`SLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "S级链接数",
`SLstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "S级链接新增数",
`BLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "B级链接数",
`CLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "C级链接数",
`ALstSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "A级链接本期销售额",
`SLstSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "S级链接本期销售额",
`ALstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "A级链接本期销售额占比",
`SLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "S级链接本期销售额占比",
`BLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "B级链接本期销售额占比",
`CLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "C级链接本期销售额占比",
`ALstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "A级链接标记期单产",
`SLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "S级链接标记期单产",
`BLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "B级链接标记期单产",
`CLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "C级链接标记期单产",
`SALstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA级链接标记其单产",
`SALstOfflineSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA级链接未在线占比",
`SALstProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA链接利润率";

`SpuSaleRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审7天SPU动销率",
`SpuSaleRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审14天SPU动销率",
`SpuSaleRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审30天SPU动销率",
`SpuSaleRateIn7dDev_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审7天SPU动销率-主题",
`SpuSaleRateIn14dDev_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审14天SPU动销率-主题",
`SpuSaleRateIn30dDev_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审30天SPU动销率-主题",

`SkuExpoRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审7天SKU曝光率",
`SkuExpoRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审14天SKU曝光率",
`SkuExpoRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审30天SKU曝光率",
`SkuClickRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审7天SKU点击率",
`SkuClickRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审14天SKU点击率",
`SkuClickRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审30天SKU点击率",
`SkuAdSaleRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审7天SKU转化率",
`SkuAdSaleRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审14天SKU转化率",
`SkuAdSaleRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审30天SKU转化率",

`SaleShopCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "出单店铺数",
`SaleLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "出单链接数",
`SaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "动销SPU数",
`SaleSpuValue` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "动销SPU单产",
`OverShopSkuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "在线店铺超量SKU数，一个SKU最多上6个店铺",
`OnlineLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "在线链接数",
`LstSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "链接动销率",
`NewLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新刊登链接数（本期刊登）",
`LstCntIn30d` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "近30天刊登链接数",
`LstSaleRateIn7d` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登7天链接动销率",
`LstSaleRateIn14d` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登14天链接动销率",
`LstSaleRateIn30d` double REPLACE_IF_NOT_NULL NULL  COMMENT "刊登30天链接动销率",

`PurchaseOrders` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "采购单数",
`PurchaseIn1dRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "采购当天下单率",
`DelayShippedOver10dOrders` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "10天未发货订单数",
`CreatedPackageIn2dPayRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "2天生包率（付款起）",
`ShippedIn7dPayRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "7天发货率（付款起）",
`RecivedIn5dPurcRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "采购5天到货率（下单起）",
`OnTimeDeliveryRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "准时交货率",
`RecivedIn24hRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "仓库24小时收货率",
`InstockIn24hRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "仓库24小时入库率",
`ShippedIn24hRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "仓库24小时发货率",

`InventoryOccupied` double REPLACE_IF_NOT_NULL NULL  COMMENT "库存资金占用",
`InventoryTurnover` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "库存周转天数",
`InventorySkuSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "库存SKU动销率"

`SpuSaleRateIn7dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "终审7天SPU成都动销率",
`SpuSaleRateIn14dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "终审14天SPU成都动销率",
`SpuSaleRateIn30dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "终审30天SPU成都动销率"


) ENGINE=OLAP
AGGREGATE KEY(FirstDay,ReportType,Team,Staff)
COMMENT "快百货团队周报结果集"
DISTRIBUTED BY HASH(Team,Staff,FirstDay) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- 更新列

insert into ads_ag_kbh_report_weekly (FirstDay,ReportType,Team,Staff)
    select FirstDay,ReportType, case when Team = '快百货一部' then '快百货成都' when Team = '快百货二部' then '快百货泉州' else  Team end Team ,Staff
        from ads_ag_kbh_report_weekly;


insert into ads_ag_kbh_report_weekly (FirstDay,ReportType,Team,Staff)
select FirstDay,ReportType, case when Team = '快百货一部' then '快百货成都' when Team = '快百货二部' then '快百货泉州' else  Team end Team ,Staff
        from ads_ag_kbh_report_weekly ;

-- 修改列 
-- ALTER TABLE ads_ag_staff_kbh_report_weekly MODIFY COLUMN Team varchar(64) NOT NULL  ;
 ALTER TABLE ads_ag_kbh_report_weekly MODIFY COLUMN AvgAdClicks double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接广告点击量" ;
 ALTER TABLE ads_ag_kbh_report_weekly MODIFY COLUMN AvgAdExposures double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接广告点击量" ;
 ALTER TABLE ads_ag_kbh_report_weekly MODIFY COLUMN AvgAdExposuresIn7dLst double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接刊登7天广告曝光量" ;

-- 增加列
-- ALTER TABLE ads_kbh_staff_stat_weekly ADD COLUMN PurcOrders int(11) DEFAULT '0' COMMENT "采购单数" after SkuAdSaleRateIn30dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "爆款SPU数-主题" after TopSaleSpuCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmount_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "当月销售额-主题" after SaleAmountIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountIn90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "主题新品当月销售额" after SaleAmount_ele_monthly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountBf90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "主题老品当月销售额" after SaleAmountIn90dDev_ele_monthly;

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆款新品SPU本期销售额" after TopSaleSpuAmount;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款新品SPU本期销售额" after HotSaleSpuAmount;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuValue_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU标记期单产-主题" after HotSaleSpuValue;

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn7dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "终审7天SPU成都动销率";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn14dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "终审14天SPU成都动销率";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn30dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "终审30天SPU成都动销率";

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuValueIn30dSinceFirstOrd_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "首单30天SPU单产_限本部门开发产品";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn7dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "终审7天SPU动销率_限本部门开发产品";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn14dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "终审14天SPU动销率_限本部门开发产品";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn30dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "终审30天SPU动销率_限本部门开发产品";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SALstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA级链接标记其单产" after SLstSaleSpuValue ;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `NumberOfTeam` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "团队人数" after BadDebtRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `OriProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "挂单毛利率" after ProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ProfitPerformance` double REPLACE_IF_NOT_NULL NULL  COMMENT "利润额人效" after NumberOfTeam;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "爆款SPU新增数" after TopSaleSpuCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "旺款SPU新增数" after HotSaleSpuCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `UnderHotSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "非爆旺款标记期单产" after HotSaleSpuValueIn30dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款新增SPU数" after TopSaleSpuCntIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款新增SPU数" after HotSaleSpuCntIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ALstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "A级链接新增数" after ALstCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SLstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "S级链接新增数" after SLstCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `BLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "B级链接数" after SLstCnt_NewAdd;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `CLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "C级链接数" after BLstCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `BLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "B级链接标记期单产" after SLstSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `CLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "C级链接标记期单产" after BLstSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopHotSaleRate_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆旺款业绩占比-主题" after UnderHotSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `PotentialLevelUpRateIn7d` double REPLACE_IF_NOT_NULL NULL  COMMENT "潜力款7天成功率,即潜力变为爆旺款" after HotSaleSpuCntBf90dDev_ele;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `PotentialLevelUpRateIn14d` double REPLACE_IF_NOT_NULL NULL  COMMENT "潜力款14天成功率,即潜力变为爆旺款" after PotentialLevelUpRateIn7d;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `PotentialLevelUpRateIn28d` double REPLACE_IF_NOT_NULL NULL  COMMENT "潜力款28天成功率,即潜力变为爆旺款" after PotentialLevelUpRateIn14d;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountIn90dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品销售额_本部门开发" after SaleAmountIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品出单SPU数_本部门开发" after SaleSpuCntIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `BLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "B级链接本期销售额占比" after SLstSaleSpuRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `CLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "C级链接本期销售额占比" after BLstSaleSpuRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品旺款SPU数_本部门开发" after PotentialLevelUpRateIn28d;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "新品爆款SPU数_本部门开发" after HotSaleSpuCntIn90dDev_DevbySelf;

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmount_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "当年主题生命周期内累计销售额" after SaleAmount_ele_monthly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountIn90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "当年新品主题生命周期内累计销售额" after SaleAmount_ele_Yearly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountBf90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "当年老品主题生命周期内累计销售额" after SaleAmountIn90dDev_ele_Yearly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `UnderHotSaleSpuValue_In90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品非爆旺款单产" after UnderHotSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SALstProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA链接利润率" after SALstOfflineSpuRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `otherLstProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "非SA链接利润率" after SALstProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopHotProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "爆旺款利润率" after otherLstProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `otherProdProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "非爆旺款利润率" after TopHotProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ProfitRate_In90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "新品利润率" after otherProdProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ProfitRate_Bf90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "老品利润率" after ProfitRate_In90dDev;



-- 以下是废弃列，待删除或注释为废弃
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn7dDev_devby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "成都终审7天SPU动销率，成都团队开发，不限出单团队";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn14dDev_devby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "成都终审14天SPU动销率，成都团队开发，不限出单团队";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn30dDev_devby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "成都终审30天SPU动销率，成都团队开发，不限出单团队";



-- 修改列
-- ALTER TABLE ads_kbh_staff_stat_weekly DROP COLUMN PurcOrders ;
`TotalGross` double REPLACE_IF_NOT_NULL NULL  COMMENT "销售额",