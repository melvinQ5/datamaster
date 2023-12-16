CREATE TABLE IF NOT EXISTS
dep_kbh_product_test (
`SPU` varchar(32)  NOT NULL COMMENT "SPU",
`SKU` varchar(32)  NOT NULL COMMENT "SKU",
`boxsku` varchar(32)  NOT NULL COMMENT "BOXSKU",
`isnew`  varchar(32)  NULL COMMENT "新老品" ,
`istheme`  varchar(32)  NULL COMMENT "主题品" ,
`ispotenial`  varchar(32)  NULL COMMENT "潜力品" ,
`min_pushdate` date null comment "首次推荐时间（从10月1日起算首次）" ,
`cat1`  varchar(32)  NULL COMMENT "一级类目" ,
`ele_name_priority`  varchar(32)  NULL COMMENT "优先级元素" ,
`ele_name_group`  varchar(128)  NULL COMMENT "所有元素标签",
`productstatus` int(11) null comment "产品状态",
`unique_brand_shop` varchar(32) null comment "一标一店产品"
) ENGINE=OLAP
DUPLICATE KEY(SPU,SKU,boxsku)
COMMENT "快百货临时产品维度表"
DISTRIBUTED BY HASH(SPU,SKU,boxsku) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- 清空
truncate table dep_kbh_product_test;


-- 增加字段
alter table dep_kbh_product_test add column `min_pushdate` date null comment "首次推荐时间（从10月1日起算首次）" after  `ispotenial`;
alter table dep_kbh_product_test add column `productstatus` int(11) null comment "产品状态" after  `ele_name_group`;
alter table dep_kbh_product_test add column `unique_brand_shop` varchar(32) null comment "一标一店产品" after  `productstatus`;
