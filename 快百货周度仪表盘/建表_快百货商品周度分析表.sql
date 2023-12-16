

CREATE TABLE IF NOT EXISTS
ads_kbh_product_analysis_weekly (
`spu` varchar(32)  not NULL COMMENT "SPU",
`year` int(11) not NULL COMMENT "自然年",
`week` int(11) not NULL COMMENT "自然周",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除",
`wttime` datetime REPLACE_IF_NOT_NULL NULL COMMENT "写入时间",
`sales_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "不含运费销售额",
`profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "不含运费利润额",
`salecount` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT  "销量",
`price_range`  varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "价格带" ,
`refund_rate_in30d` double REPLACE_IF_NOT_NULL NULL COMMENT "近30天退款率",
`ProductStatus` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "产品状态",
`StopReason` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "停产原因",
`updown_mark` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "升降标记",
`updown_reason` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "升降原因归类",
`updown_reason_details` varchar(256) REPLACE_IF_NOT_NULL NULL COMMENT "升降原因明细",
`action` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "策略动作",
`action_tracks` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "结果跟进"
) ENGINE=OLAP
AGGREGATE KEY(spu,year,week)
COMMENT "快百货产品涨跌归因分析表"
DISTRIBUTED BY HASH(spu,year,week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- 增加字段
ALTER TABLE ads_kbh_product_analysis_weekly ADD COLUMN `purchase_days_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天平均采购时长" after refund_rate_in30d;