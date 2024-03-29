/*
 todo 按需求先建表，但指标先写新增的，优先出完周一周报

 风控指标的算法在： 20补充生成指标集数据
维度需求整理：
 新老品
 主题品
 高潜品
 一级类目


 新老刊登 统计期内刊登
 actionNdays 动作N天：刊登后7\14\30天  采购后1\5天 付款后2\5\7天 潜力款标记
 销售统计类型：挂单（付款单）、预估结算（订单表+广告表+退款表）、结算（按结算时间）

 交叉维度： 挂单x站点 利润率 、预估xz站点 利润率

 */

truncate table ads_kbh_report_metrics

create table if not exists ads_kbh_report_metrics (
`DimensionId` varchar(64) NOT NULL COMMENT "维度id",
`Year` int(11) NOT NULL COMMENT "统计年",
`Month` int(11) NOT NULL COMMENT "统计月",
`Week` int(11) NOT NULL COMMENT "统计周",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除" ,
`wttime` datetime REPLACE_IF_NOT_NULL  NULL COMMENT "写入时间",
`ReportType` varchar(16) REPLACE_IF_NOT_NULL NULL  COMMENT  "报表频次",
`FirstDay` date REPLACE_IF_NOT_NULL NULL  COMMENT  "统计期第一天" ,
`sale_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "销量",
`order_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "订单量",
`sales` double REPLACE_IF_NOT_NULL NULL  COMMENT "销售额S3",
`profit` double REPLACE_IF_NOT_NULL NULL  COMMENT "利润额M3",
`profit_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "利润率R3",
`refunds` double REPLACE_IF_NOT_NULL NULL  COMMENT "退款金额",
`feegross` double REPLACE_IF_NOT_NULL NULL  COMMENT "运费收入",
`refundrate` double REPLACE_IF_NOT_NULL NULL  COMMENT "退款率",
`FeeGrossRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "运费收入占比",
`BadDebtAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "坏账金额usd",
`BadDebtRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "坏账率",
`NumberOfTeam` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "团队人数",

`ProfitPerformance` double REPLACE_IF_NOT_NULL NULL  COMMENT "利润额人效",

`AdSpendRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告花费占比",
`AdSalesRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告业绩占比",
`AdOtherSkuSalesRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "非广告产品业绩占比",
`ROAS` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告所带来的总销售额与广告花费比值",
`CPC` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告花费与广告点击量比值",
`AdClickRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告点击率",
`AdSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "广告转化率",
`AdCoverRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "链接广告投放率",
`AdClicks` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "广告点击量",
`AdExposures` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "广告曝光量",
`AdClicks_per_lst` double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接广告点击量",
`AdExposures_per_lst` double REPLACE_IF_NOT_NULL NULL  COMMENT "单链接广告曝光量",

`add_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "添加SPU数",
`dev_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "终审SPU数",
`dev_sku_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "终审SKU数",
`spu_sku_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "终审变体比例",
`spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "产品库SPU数",
`sku_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "产品库SKU数",
`stop_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "停产SPU数",
`avg_days_dev2lst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "平均首登天数",
`sale_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "出单SPU数",
`sales_per_spu` double REPLACE_IF_NOT_NULL NULL  COMMENT "出单SPU单产",
`spu_sale_rate_over1` double REPLACE_IF_NOT_NULL NULL  COMMENT "SPU1单动销率",
`spu_sale_rate_over3` double REPLACE_IF_NOT_NULL NULL  COMMENT "SPU3单动销率",
`spu_sale_rate_over6` double REPLACE_IF_NOT_NULL NULL  COMMENT "SPU6单动销率",

`online_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "在线SPU数",
`online_spu_cnt_achieved` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "在线达标SPU数（按SPU在线4套且20条正常链接）",
`online_lst_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "在线链接数",
`lst_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "刊登链接数",
`lst_sale_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "链接动销率",
`sales_per_lst` double REPLACE_IF_NOT_NULL NULL  COMMENT "链接单产",
`sale_lst_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "出单链接数",

`sale_shop_Cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "出单店铺数",
`badshop_records_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "店铺违规记录总数",
`badshop_records_over5_shop_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "单店铺超过5条违规记录店铺数",
`gradein200_shop_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "0至200分正常店铺数",
`badshop_records_cnt_byprod` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "商品原因违规记录数",
`over6_onlinecomp_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "在线账号超6套SPU数",
`odr_unachieved_shop_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "odr超标店铺数",

`sku_purc_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "采购开单SKU数",
`purc_orders_cnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "采购单数",
`delayship_orders` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "付款N天未发货订单数",
`created_pack_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "付款N天生包率",
`ship_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "付款N天发货率",
`purc_recived_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "采购N天到库率",
`recived_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "到库N天销单率",
`instock_rate` double REPLACE_IF_NOT_NULL NULL  COMMENT "销单N天入库率",
`OnTimeDeliveryRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "准时交货率",

`inventory_occupied` double REPLACE_IF_NOT_NULL NULL  COMMENT "库存资金占用",
`inventory_turnover` double REPLACE_IF_NOT_NULL NULL  COMMENT "库存周转天数"

) ENGINE=OLAP
AGGREGATE KEY(DimensionId,Year,Month,Week)
COMMENT "快百货周月报宽表"
DISTRIBUTED BY HASH(DimensionId,Year,Month,Week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);