
CREATE TABLE IF NOT EXISTS
ads_staff_stat (
ReportType      varchar(20) not null comment '��������',
FirstDay        date        not null comment 'ͳ���ڵ�һ��',
Department      varchar(64) not null comment '����',
EmpCount        int    REPLACE_IF_NOT_NULL NULL comment '��������',
SaleCount        int   REPLACE_IF_NOT_NULL NULL comment '���۸�����',
wttime  datetime  REPLACE_IF_NOT_NULL NULL COMMENT "д��ʱ��"
) ENGINE=OLAP
AGGREGATE KEY(ReportType,FirstDay,Department)
COMMENT "��������ͳ�Ʊ�"
DISTRIBUTED BY HASH(ReportType,FirstDay,Department) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

