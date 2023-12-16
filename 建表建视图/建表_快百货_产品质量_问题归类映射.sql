
-- 清空 慎重
truncate table dep_kbp_product_defect_category_maps;


CREATE TABLE IF NOT EXISTS
dep_kbp_product_defect_category_maps (
`SourceType` varchar(64)  NOT NULL COMMENT "报告来源",
`SourceCat1` varchar(64)  NULL COMMENT "问题分类源1级" ,
`SourceCat2`varchar(64) NULL COMMENT "问题分类源2级",
`IssueType1` varchar(64) NULL COMMENT "归类1级",
`wttime` datetime  NOT NULL COMMENT "写入时间"
) ENGINE=OLAP
DUPLICATE KEY(SourceType)
COMMENT "快百货产品质量归类映射关系表"
DISTRIBUTED BY HASH(SourceType) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);
