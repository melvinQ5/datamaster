
CREATE TABLE IF NOT EXISTS
`dim_AbroadRegion` (
  `region_key` varchar(64) NOT NULL COMMENT "地区键",
  `region_level` varchar(64) NOT NULL COMMENT "地区层级",
  `CountryCode` varchar(64) NOT NULL COMMENT "国家简称",
  `CountryCNname` varchar(64) NOT NULL DEFAULT "国家中文名称",
  `StateCNname` varchar(64) NOT NULL COMMENT "州省中文名称",
  `StateENname` varchar(64) NOT NULL COMMENT "州省英文名称",
  `StateCode` varchar(64) NOT NULL COMMENT "州省",
  `CityCNname` varchar(64) NOT NULL COMMENT "城市中文名称",
  `CityENname` varchar(64) NOT NULL COMMENT "城市英文名称",
  `AreaTag` varchar(64) NOT NULL COMMENT "区域标签",
  `update_time` datetime NOT NULL COMMENT "更新时间"
) ENGINE=OLAP
DUPLICATE KEY(`region_key`)
COMMENT "海外地区维度表"
DISTRIBUTED BY HASH(`region_key`) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- 清空
truncate table dim_AbroadRegion;
