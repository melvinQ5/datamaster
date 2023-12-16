CREATE TABLE IF NOT EXISTS
dep_purchase_sales_inventory_log (
`id` varchar(64)  NOT NULL COMMENT "库存变动流水id",
`boxsku` varchar(64)  NOT NULL COMMENT "塞盒SKU",
`isdeleted` varchar(64)  NOT NULL COMMENT "记录是否删除",
`department` varchar(64) REPLACE_IF_NOT_NULL  NULL COMMENT "SKU归属部门",
`event_type` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "单据分类",
`event_id_type` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "单据号类型",
`event_id` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "单据号",
`line` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "运输路线",

`start_time_type` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "起始时间类型",
`start_time` datetime   REPLACE_IF_NOT_NULL NULL COMMENT "起始时间",
`from_place` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "发出地",
`from_place_detail` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "发出地详情",
`start_quantity` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "发出数量",

`end_time_type` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "结束时间类型",
`end_time` datetime   REPLACE_IF_NOT_NULL NULL COMMENT "结束时间",
`reach_place` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "到达地",
`reach_place_detail` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "到达地详情",
`end_quantity` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "到达数量",
`memo` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "备注",
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "写入时间"

) ENGINE=OLAP
AGGREGATE KEY(id,boxsku,isdeleted)
COMMENT "全流程库存变动明细账"  
DISTRIBUTED BY HASH( id,boxsku,isdeleted ) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


ALTER TABLE dep_purchase_sales_inventory_log ADD COLUMN `purchase_source` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "进货来源" after isdeleted;

