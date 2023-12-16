CREATE TABLE IF NOT EXISTS
dep_kbh_product_test (
`SPU` varchar(32)  NOT NULL COMMENT "SPU",
`SKU` varchar(32)  NOT NULL COMMENT "SKU",
`boxsku` varchar(32)  NOT NULL COMMENT "BOXSKU",
`isnew`  varchar(32)  NULL COMMENT "����Ʒ" ,
`istheme`  varchar(32)  NULL COMMENT "����Ʒ" ,
`ispotenial`  varchar(32)  NULL COMMENT "Ǳ��Ʒ" ,
`min_pushdate` date null comment "�״��Ƽ�ʱ�䣨��10��1�������״Σ�" ,
`cat1`  varchar(32)  NULL COMMENT "һ����Ŀ" ,
`ele_name_priority`  varchar(32)  NULL COMMENT "���ȼ�Ԫ��" ,
`ele_name_group`  varchar(128)  NULL COMMENT "����Ԫ�ر�ǩ",
`productstatus` int(11) null comment "��Ʒ״̬",
`unique_brand_shop` varchar(32) null comment "һ��һ���Ʒ"
) ENGINE=OLAP
DUPLICATE KEY(SPU,SKU,boxsku)
COMMENT "��ٻ���ʱ��Ʒά�ȱ�"
DISTRIBUTED BY HASH(SPU,SKU,boxsku) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- ���
truncate table dep_kbh_product_test;


-- �����ֶ�
alter table dep_kbh_product_test add column `min_pushdate` date null comment "�״��Ƽ�ʱ�䣨��10��1�������״Σ�" after  `ispotenial`;
alter table dep_kbh_product_test add column `productstatus` int(11) null comment "��Ʒ״̬" after  `ele_name_group`;
alter table dep_kbh_product_test add column `unique_brand_shop` varchar(32) null comment "һ��һ���Ʒ" after  `productstatus`;
