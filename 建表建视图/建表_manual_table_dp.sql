
truncate table manual_table_duplicate

CREATE TABLE IF NOT EXISTS
manual_table_duplicate (
`wttime` datetime  NOT NULL COMMENT "写入时间",
`c1` varchar(128)  NULL COMMENT "",
`c2` varchar(128)  NULL COMMENT "",
`c3` varchar(128)  NULL COMMENT "",
`c4` varchar(128)  NULL COMMENT "",
`c5` varchar(128)  NULL COMMENT "",
`c6` varchar(128)  NULL COMMENT "",
`c7` varchar(128)  NULL COMMENT "",
`c8` varchar(128)  NULL COMMENT "",
`c9` varchar(128)  NULL COMMENT "",
`c10` varchar(128)  NULL COMMENT "",
`c11` varchar(128)  NULL COMMENT "",
`c12` varchar(128)  NULL COMMENT "",
`c13` varchar(128)  NULL COMMENT "",
`c14` varchar(128)  NULL COMMENT "",
`c15` varchar(128)  NULL COMMENT "",
`c16` varchar(128)  NULL COMMENT "",
`c17` varchar(128)  NULL COMMENT "",
`c18` varchar(128)  NULL COMMENT "",
`c19` varchar(128)  NULL COMMENT "",
`c20` varchar(128)  NULL COMMENT "",
`c21` varchar(128)  NULL COMMENT "",
`c22` varchar(128)  NULL COMMENT "",
`c23` varchar(128)  NULL COMMENT "",
`c24` varchar(128)  NULL COMMENT "",
`c25` varchar(128)  NULL COMMENT "",
`c26` varchar(128)  NULL COMMENT "",
`c27` varchar(128)  NULL COMMENT "",
`c28` varchar(128)  NULL COMMENT "",
`c29` varchar(128)  NULL COMMENT "",
`c30` varchar(128)  NULL COMMENT "",
`c31` varchar(128)  NULL COMMENT "",
`c32` varchar(128)  NULL COMMENT "",
`c33` varchar(128)  NULL COMMENT "",
`c34` varchar(128)  NULL COMMENT "",
`c35` varchar(128)  NULL COMMENT "",
`c36` varchar(128)  NULL COMMENT "",
`c37` varchar(128)  NULL COMMENT "",
`c38` varchar(128)  NULL COMMENT "",
`c39` varchar(128)  NULL COMMENT "",
`c40` varchar(128)  NULL COMMENT "",
`c41` varchar(128)  NULL COMMENT "",
`c42` varchar(128)  NULL COMMENT "",
`c43` varchar(128)  NULL COMMENT "",
`c44` varchar(128)  NULL COMMENT "",
`c45` varchar(128)  NULL COMMENT ""
) ENGINE=OLAP
DUPLICATE KEY(wttime)
COMMENT "快百货商品分层潜力品清单"
DISTRIBUTED BY HASH(wttime) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);