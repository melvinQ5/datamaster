
CREATE TABLE IF NOT EXISTS
ads_staff_stat (
ReportType      varchar(20) not null comment '日期类型',
FirstDay        date        not null comment '统计期第一天',
Department      varchar(64) not null comment '部门',
EmpCount        int    REPLACE_IF_NOT_NULL NULL comment '部门人数',
SaleCount        int   REPLACE_IF_NOT_NULL NULL comment '销售岗人数',
wttime  datetime  REPLACE_IF_NOT_NULL NULL COMMENT "写入时间"
) ENGINE=OLAP
AGGREGATE KEY(ReportType,FirstDay,Department)
COMMENT "部门人数统计表"
DISTRIBUTED BY HASH(ReportType,FirstDay,Department) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

