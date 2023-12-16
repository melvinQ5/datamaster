select


`FirstDay` as "对应统计期的第一天",
`ReportType` as "报表类型",
case when Team = '快百货一部' then '快百货成都' when Team = '快百货二部' then '快百货泉州' else  Team end as "团队",
`Staff` as "人员",
`Year` as "统计年份",
`Month` as "统计月份",
`Week` as "统计周次",
`TotalGross` as "销售额",
`TotalProfit` as "利润额",
`ProfitRate` as "毛利率",
OriProfitRate as `挂单利润率`,
`AdSpendRate` as "广告花费占比",
`RefundRate` as "退款率",
`FeeGrossRate` as "运费收入占比",
`ProfitRate` - ifnull(`FeeGrossRate`,0) as `剔运费毛利率`,
`BadDebtAmount` as "坏账金额",
round(BadDebtAmount/TotalGross,4) as `坏账率`,
NumberOfTeam as `团队人数`,
ProfitPerformance as `利润额人效`,

-- 商品结果指标
`SpuSaleCntIn30d` as "近30天动销SPU数",
`SpuUnitSaleIn30d` as "产品库SPU单产",
ifnull(TopSaleSpuCnt,0) +  ifnull(HotSaleSpuCnt,0) as `爆旺款SPU数`,
`TopSaleSpuCnt` as "爆款SPU数",
`HotSaleSpuCnt` as "旺款SPU数",
`SpuSaleCntIn30d`  - ifnull(`TopSaleSpuCnt`,0) - ifnull(`HotSaleSpuCnt`,0)  `非爆旺款商品数`,
ifnull(TopSaleSpuCnt_NewAdd,0) + ifnull(HotSaleSpuCnt_NewAdd,0) as `爆旺款新增数`,
TopSaleSpuCnt_NewAdd as `爆款新增数`,
HotSaleSpuCnt_NewAdd as `旺款新增数`,

round ( (ifnull(ALstCnt,0) + ifnull(SLstCnt,0) ) / ( ifnull(TopSaleSpuCnt,0) +  ifnull(HotSaleSpuCnt,0) ) ,2) as `爆旺款平均SA链接数`,
round( ( TopSaleSpuCnt*TopSaleSpuValue + HotSaleSpuCnt*HotSaleSpuValue ) / ( TopSaleSpuCnt + HotSaleSpuCnt ) ,2)  AS `爆旺款单产`,
`TopSaleSpuValue` as "爆款单产",
`HotSaleSpuValue` as "旺款单产",
UnderHotSaleSpuValue as 非爆旺款单产,
`TopSaleSpuAmount` + `HotSaleSpuAmount` as "爆旺款本期销售额",
ifnull(`TopSaleSpuRate`,0) + IFNULL(`HotSaleSpuRate`,0) as "爆旺款本期销售额占比",
`TopSaleSpuRate` as "爆款SPU本期销售额占比",
`HotSaleSpuRate` as "旺款SPU本期销售额占比",
1-(`TopSaleSpuRate` + `HotSaleSpuRate`) as `非爆旺款本期销售额占比`,


-- 新品结果指标
`SaleAmountIn90dDev` as "新品销售额",  -- key代表销售团队
round(SaleAmountIn90dDev/TotalGross,4) as `新品销售额占比`, --
HotSaleSpuAmountIn3m + TopSaleSpuAmountIn3m as 新品爆旺款销售额,
round( (ifnull(HotSaleSpuAmountIn3m,0) + ifnull(TopSaleSpuAmountIn3m,0) ) /SaleAmountIn90dDev,4)  as 新品爆旺款销售额占比,
ifnull(TopSaleSpuCntIn90dDev,0) + ifnull(HotSaleSpuCntIn90dDev,0) as `新品爆旺款SPU数`,
TopSaleSpuCntIn90dDev_DevbySelf as 新品爆款SPU数_本部门开发,
HotSaleSpuCntIn90dDev_DevbySelf as 新品旺款SPU数_本部门开发,
ifnull(TopSaleSpuCntIn90dDev_DevbySelf,0) + ifnull(HotSaleSpuCntIn90dDev_DevbySelf,0) as `新品爆旺款SPU数_本部门开发`,
round( ( TopSaleSpuCntIn90dDev*TopSaleSpuValueIn30dDev + HotSaleSpuCntIn90dDev*HotSaleSpuValueIn30dDev ) / ( TopSaleSpuCntIn90dDev + HotSaleSpuCntIn90dDev ) ,2)  AS `新品爆旺款单产`,


round( ifnull(HotSaleSpuAmountIn3m,0)  /SaleAmountIn90dDev,4)  as 新品爆款销售额占比,
round( ifnull(TopSaleSpuAmountIn3m,0)  /SaleAmountIn90dDev,4)  as 新品旺款销售额占比,
round( (`SaleAmountIn90dDev`  - ifnull(HotSaleSpuAmountIn3m,0) - ifnull(TopSaleSpuAmountIn3m,0) )/SaleAmountIn90dDev,4)  as 新品非爆旺款销售额占比,

`TopSaleSpuCntIn90dDev` as "新品爆款SPU数", -- key代表销售团队
`HotSaleSpuCntIn90dDev` as "新品旺款SPU数", -- key代表销售团队
SaleSpuCntIn90dDev -  ifnull(TopSaleSpuCntIn90dDev,0) - ifnull(HotSaleSpuCntIn90dDev,0)  as 新品非爆旺款SPU数,
`TopSaleSpuValueIn30dDev` as "新品爆款单产", -- key代表销售团队
`HotSaleSpuValueIn30dDev` as "新品旺款单产", -- key代表销售团队

round( (`SaleAmountIn90dDev`  - ifnull(HotSaleSpuAmountIn3m,0) - ifnull(TopSaleSpuAmountIn3m,0) )/(SaleSpuCntIn90dDev -  ifnull(TopSaleSpuCntIn90dDev,0) - ifnull(HotSaleSpuCntIn90dDev,0) ) ,2)  as 新品非爆旺款单产,
TopSaleSpuCntIn90dDev_NewAdd as `新品爆款新增数`,
HotSaleSpuCntIn90dDev_NewAdd as `新品旺款新增数`,

-- 销售结果指标
ifnull(ALstCnt,0) + ifnull(SLstCnt,0)  as `SA链接数` ,
ifnull(BLstCnt,0) + ifnull(CLstCnt,0)  as `非SA链接数` ,
SALstSaleSpuValue as `SA链接单产`,
ifnull(ALstCnt_NewAdd,0) + ifnull(SLstCnt_NewAdd,0)  as SA链接新增数,
`SLstCnt` as "S链接数",
`ALstCnt` as "A链接数",
BLstCnt as B链接数,
CLstCnt as C链接数,
`SLstSaleSpuValue` as "S链接单产",
`ALstSaleSpuValue` as "A链接单产",

BLstSaleSpuValue as B链接单产,
CLstSaleSpuValue as C链接单产,

SLstCnt_NewAdd as S链接新增数,
ALstCnt_NewAdd as A链接新增数,
ifnull(`ALstSaleSpuAmount`,0) + ifnull(`SLstSaleSpuAmount`,0) as "SA链接本期销售额",
ifnull(`SLstSaleSpuRate`,0) + ifnull(`ALstSaleSpuRate`,0) as "SA链接本期销售额占比",
1 - ifnull(`SLstSaleSpuRate`,0) - ifnull(`ALstSaleSpuRate`,0) as "非SA链接本期销售额占比",
`SLstSaleSpuRate` as "S链接本期销售额占比",
`ALstSaleSpuRate` as "A链接本期销售额占比",
BLstSaleSpuRate  as "B链接本期销售额占比",
CLstSaleSpuRate as "C链接本期销售额占比",

-- 供应链指标
`DelayShippedOver10dOrders` as "10天未发货订单数",
`CreatedPackageIn2dPayRate` as "2天生包率",
`ShippedIn7dPayRate` as "订单7天发货率",

-- 新品 key = 快百货
`SpuSaleRateIn7dDev` as "终审7天SPU动销率",
`SpuSaleRateIn14dDev` as "终审14天SPU动销率",
`SpuSaleRateIn30dDev` as "终审30天SPU动销率",
`SpuValueIn30dSinceFirstOrd`as "首单30天SPU单产",
`NewSpuCntIn90dDev` as "近90天终审SPU数", -- key 表示商品团队
`SaleSpuCntIn90dDev` as "新品出单SPU数", -- key 表示商品团队

`NewAddSpuCnt` as "新品开发数",-- 添加SPU数  key 表示商品团队
`NewAddSpuCnt` as "添加SPU数",-- 添加SPU数  key 表示商品团队
round(`NewAddSpuCnt`/4) as "人均新品开发数",-- 添加SPU数  key 表示商品团队
`SpuSkuRate` as "新品变体配比",-- key 表示商品团队
`StopSkuRateIn30dDev` as "新品SKU停产SPU占比", -- key 表示商品团队

-- 考虑新写一段SQL查询
-- 新品 key = 快百货一部 成都开发 快百货出单
SaleAmountIn90dDev_DevbySelf as 新品销售额_本部门开发,
 SaleSpuCntIn90dDev_DevbySelf as 新品出单SPU数_本部门开发,


-- 主题
`SaleAmount_ele_Yearly`as "主题累计销售额",
`SaleAmountIn90dDev_ele_Yearly` as "主题新品累计销售额",
`SaleAmountBf90dDev_ele_Yearly` as "主题老品累计销售额",

`SaleAmount_ele_monthly` as "主题当月累计销售额",
`SaleAmountIn90dDev_ele_monthly` as "主题新品当月累计销售额",
`SaleAmountBf90dDev_ele_monthly` as "主题老品当月累计销售额",
 TopHotSaleRate_ele as "主题爆旺款销售额占比",
`TopSaleSpuCnt_ele` as "爆款SPU数-主题",
`HotSaleSpuCnt_ele` as "旺款SPU数-主题",
`TopSaleSpuValue_ele` as "爆款单产-主题",
`HotSaleSpuValue_ele` as "旺款单产-主题",
`HotSaleSpuCntIn90dDev_ele` as "新品旺款SPU数-主题",
`HotSaleSpuCntBf90dDev_ele` as "老品旺款SPU数-主题",
`TopSaleSpuCntIn90dDev_ele` as "新品爆款SPU数-主题",
`TopSaleSpuCntBf90dDev_ele` as "老品爆款SPU数-主题",
`OldSpuCntIn90dDev_ele` as "未被停产的老品SPU数-主题",
`NewDevSpuCnt_ele` as "终审SPU数-主题",
`SaleSpuCntIn90dDev_ele` as "新品出单SPU数-主题",
`SpuSaleRateIn7dDev_ele` as "终审7天SPU动销率-主题",
`SpuSaleRateIn14dDev_ele` as "终审14天SPU动销率-主题",
`SpuSaleRateIn30dDev_ele` as "终审30天SPU动销率-主题",


-- 商品运营-公司
`SpuSaleCntIn30d` as `近30天动销SPU数`,
`SpuUnitSaleIn30d` as `近30天动销SPU单产`,
 PotentialLevelUpRateIn7d as `高潜商品7天成功率`,
 PotentialLevelUpRateIn14d as `高潜商品14天成功率`,
 PotentialLevelUpRateIn28d as `高潜商品28天成功率`,
`SkuExpoRateIn7dDev` as "终审7天SKU曝光率",
`SkuExpoRateIn14dDev` as "终审14天SKU曝光率",
`SkuExpoRateIn30dDev` as "终审30天SKU曝光率",
`SkuClickRateIn7dDev` as "终审7天SKU点击率",
`SkuClickRateIn14dDev` as "终审14天SKU点击率",
`SkuClickRateIn30dDev` as "终审30天SKU点击率",
`SkuAdSaleRateIn7dDev` as "终审7天SKU转化率",
`SkuAdSaleRateIn14dDev` as "终审14天SKU转化率",
`SkuAdSaleRateIn30dDev` as "终审30天SKU转化率",


-- 销售运营过程指标-链接质量
`SaleShopCnt` as "出单店铺数",
`OnlineLstCnt` as "在线链接数",
`LstSaleRate` as "链接动销率",
`NewLstCnt` as "新刊登链接数",
`LstCntIn30d` as "近30天刊登链接数",
`SpuSaleRateIn7dDev_saleby_cd` as "终审7天SPU成都动销率",
`SpuSaleRateIn14dDev_saleby_cd` as "终审14天SPU成都动销率",
`SpuSaleRateIn30dDev_saleby_cd` as "终审30天SPU成都动销率",
`LstSaleRateIn7d` as "刊登7天链接动销率",
`LstSaleRateIn14d` as "刊登14天链接动销率",
`LstSaleRateIn30d` as "刊登30天链接动销率",
`RoasIn7dLst` as "刊登7天广告ROI",
`RoasIn14dLst` as "刊登14天广告ROI",
`RoasIn30dLst` as "刊登30天广告ROI",
`ExpoRateIn7dLst` as "刊登7天广告曝光率",
`ExpoRateIn14dLst` as "刊登14天广告曝光率",
`ClickRateIn7dLst` as "刊登7天广告点击率",
`ClickRateIn14dLst` as "刊登14天广告点击率",
`AdSaleRateIn7dLst` as "刊登7天广告转化率",
`AdSaleRateIn14dLst` as "刊登14天广告转化率",


-- 销售运营过程指标 -营销推广
`AdSalesRate` as "广告销售额占比",
`AdOtherSkuSalesRate` as "非广告产品销售额占比",
`ROAS` as "广告ROI",
`AdClickRate` as "广告点击率",
`AdSaleRate` as "广告转化率",
`AdCoverRate` as "链接广告投放率",
`AdExposures` as "广告曝光量",
`AdClicks` as "广告点击量",
`AvgAdExposures` as "单链接广告曝光量",
`AvgAdClicks` as "单链接广告点击量",
`CPC` as "广告CPC",


-- 销售运营过程指标-成本控制
SALstProfitRate as SA链接利润率,
otherLstProfitRate as 非SA链接利润率,
TopHotProfitRate as `爆旺款利润率`,
otherProdProfitRate as `非爆旺款利润率`,
ProfitRate_In90dDev as `新品利润率`,
ProfitRate_Bf90dDev as `老品利润率`,


-- 销售运营过程指标-风险控制
`SaleAmountIn30dDev` as "近30天终审产品销售额",
`PurchaseOrders` as "采购单数",
`PurchaseIn1dRate` as "采购当天下单率",
`RecivedIn5dPurcRate` as "采购5天到货率",
`OnTimeDeliveryRate` as "准时交货率",
`RecivedIn24hRate` as "仓库24小时收货率",
`InstockIn24hRate` as "仓库24小时入库率",
`ShippedIn24hRate` as "仓库24小时发货率",
`InventoryOccupied` as "库存资金占用",
`InventoryTurnover` as "库存周转天数",
`InventorySkuSaleRate` as "库存SKU动销率",
`AdSalesRate_manual` as "手动广告销售额占比",
`AvgAdExposuresIn7dLst` as "单链接刊登7天广告曝光量",
`NewDevSpuCnt` as "终审SPU数",
`NewDevSkuCnt` as "终审SKU数",
`SpuCnt` as "产品库SPU数",
`SkuCnt` as "产品库SKU数",
`SpuStopCnt` as "停产SPU数",
`FirstSaleSpuCnt` as "首单SPU数",
`SALstOfflineSpuRate` as "SA链接未在线占比",
`TopSaleSpuAmount` as "爆款SPU本期销售额",
`TopSaleSpuAmountIn3m` as "新品爆款SPU本期销售额",
`HotSaleSpuAmount` as "旺款SPU本期销售额",
`HotSaleSpuAmountIn3m` as "新品旺款SPU本期销售额",
`TopHotStopSpuRate` as "爆旺款停产SPU占比",
`SaleLstCnt` as "出单链接数",
`OverShopSkuCnt` as "在线店铺超量SKU数"

from ads_ag_kbh_report_weekly
where FirstDay = '${StartDay}' and ReportType ='${ReportType}'
order by  "团队";