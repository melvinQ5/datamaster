CREATE TABLE IF NOT EXISTS
dep_purchase_sales_inventory_log (
`id` varchar(64)  NOT NULL COMMENT "���䶯��ˮid",
`boxsku` varchar(64)  NOT NULL COMMENT "����SKU",
`isdeleted` varchar(64)  NOT NULL COMMENT "��¼�Ƿ�ɾ��",
`department` varchar(64) REPLACE_IF_NOT_NULL  NULL COMMENT "SKU��������",
`event_type` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "���ݷ���",
`event_id_type` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "���ݺ�����",
`event_id` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "���ݺ�",
`line` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "����·��",

`start_time_type` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "��ʼʱ������",
`start_time` datetime   REPLACE_IF_NOT_NULL NULL COMMENT "��ʼʱ��",
`from_place` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "������",
`from_place_detail` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "����������",
`start_quantity` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "��������",

`end_time_type` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "����ʱ������",
`end_time` datetime   REPLACE_IF_NOT_NULL NULL COMMENT "����ʱ��",
`reach_place` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "�����",
`reach_place_detail` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "���������",
`end_quantity` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "��������",
`memo` varchar(512) REPLACE_IF_NOT_NULL NULL COMMENT "��ע",
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "д��ʱ��"

) ENGINE=OLAP
AGGREGATE KEY(id,boxsku,isdeleted)
COMMENT "ȫ���̿��䶯��ϸ��"  
DISTRIBUTED BY HASH( id,boxsku,isdeleted ) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


ALTER TABLE dep_purchase_sales_inventory_log ADD COLUMN `purchase_source` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "������Դ" after isdeleted;

