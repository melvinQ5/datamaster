
-- ��� ����
truncate table dep_kbp_product_defect_category_maps;


CREATE TABLE IF NOT EXISTS
dep_kbp_product_defect_category_maps (
`SourceType` varchar(64)  NOT NULL COMMENT "������Դ",
`SourceCat1` varchar(64)  NULL COMMENT "�������Դ1��" ,
`SourceCat2`varchar(64) NULL COMMENT "�������Դ2��",
`IssueType1` varchar(64) NULL COMMENT "����1��",
`wttime` datetime  NOT NULL COMMENT "д��ʱ��"
) ENGINE=OLAP
DUPLICATE KEY(SourceType)
COMMENT "��ٻ���Ʒ��������ӳ���ϵ��"
DISTRIBUTED BY HASH(SourceType) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);
