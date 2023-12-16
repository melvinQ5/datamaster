
CREATE TABLE IF NOT EXISTS
`dim_AbroadRegion` (
  `region_key` varchar(64) NOT NULL COMMENT "������",
  `region_level` varchar(64) NOT NULL COMMENT "�����㼶",
  `CountryCode` varchar(64) NOT NULL COMMENT "���Ҽ��",
  `CountryCNname` varchar(64) NOT NULL DEFAULT "������������",
  `StateCNname` varchar(64) NOT NULL COMMENT "��ʡ��������",
  `StateENname` varchar(64) NOT NULL COMMENT "��ʡӢ������",
  `StateCode` varchar(64) NOT NULL COMMENT "��ʡ",
  `CityCNname` varchar(64) NOT NULL COMMENT "������������",
  `CityENname` varchar(64) NOT NULL COMMENT "����Ӣ������",
  `AreaTag` varchar(64) NOT NULL COMMENT "�����ǩ",
  `update_time` datetime NOT NULL COMMENT "����ʱ��"
) ENGINE=OLAP
DUPLICATE KEY(`region_key`)
COMMENT "�������ά�ȱ�"
DISTRIBUTED BY HASH(`region_key`) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- ���
truncate table dim_AbroadRegion;
