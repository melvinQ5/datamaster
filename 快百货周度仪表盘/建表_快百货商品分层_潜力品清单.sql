-- ��ѯ
select * from dep_kbh_product_level_potentail;
select distinct StartDay from dep_kbh_product_level_potentail;
select count(*) from dep_kbh_product_level_potentail;

-- ��� ����
# truncate table dep_kbh_product_level_potentail;



CREATE TABLE IF NOT EXISTS
dep_kbh_product_level_potentail (
`SPU` varchar(64)  NOT NULL COMMENT "SPU",
`Department`  varchar(24) NOT NULL COMMENT "�н���Ӫ�Ŷ�" ,
`StartDay` date not NULL COMMENT "Ǳ�����ǩ��ʼ����",
`EndDay` date not NULL COMMENT "Ǳ�����ǩ��������",
`StarWeek` int(11)  NULL COMMENT "Ǳ�����ǩ��ʼ�ܴ�",
`prod_level` varchar(24)  NULL COMMENT "��Ʒ�ֲ�",
`wttime` datetime  NOT NULL COMMENT "д��ʱ��"
) ENGINE=OLAP
DUPLICATE KEY(SPU,Department)
COMMENT "��ٻ���Ʒ�ֲ�Ǳ��Ʒ�嵥"
DISTRIBUTED BY HASH(Department,SPU) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- ������
alter table dep_kbh_product_level_potentail add column `PushSite` varchar(24) null comment "����վ��" after  `prod_level`;
alter table dep_kbh_product_level_potentail add column `PushRule` varchar(512) null comment "���͹���" after  `PushSite`;
alter table dep_kbh_product_level_potentail add column `PushDate` date null comment "��������" after  `PushRule`;
alter table dep_kbh_product_level_potentail add column `StopPushDate` date null comment "ֹͣ��������" after  `PushDate`;
alter table dep_kbh_product_level_potentail add column `PushUser` varchar(24) null comment "������" after  `StopPushDate`;
alter table dep_kbh_product_level_potentail add column `PushReason` varchar(512) null comment "��������" after  `PushUser`;
alter table dep_kbh_product_level_potentail add column `isStopPush` varchar(24)  null comment "�Ƿ�ȡ������" after  `PushReason`;
-- �޸���