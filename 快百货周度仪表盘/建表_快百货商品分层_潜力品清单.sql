-- 查询
select * from dep_kbh_product_level_potentail;
select distinct StartDay from dep_kbh_product_level_potentail;
select count(*) from dep_kbh_product_level_potentail;

-- 清空 慎重
# truncate table dep_kbh_product_level_potentail;



CREATE TABLE IF NOT EXISTS
dep_kbh_product_level_potentail (
`SPU` varchar(64)  NOT NULL COMMENT "SPU",
`Department`  varchar(24) NOT NULL COMMENT "承接运营团队" ,
`StartDay` date not NULL COMMENT "潜力款标签开始日期",
`EndDay` date not NULL COMMENT "潜力款标签结束日期",
`StarWeek` int(11)  NULL COMMENT "潜力款标签开始周次",
`prod_level` varchar(24)  NULL COMMENT "商品分层",
`wttime` datetime  NOT NULL COMMENT "写入时间"
) ENGINE=OLAP
DUPLICATE KEY(SPU,Department)
COMMENT "快百货商品分层潜力品清单"
DISTRIBUTED BY HASH(Department,SPU) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- 增加列
alter table dep_kbh_product_level_potentail add column `PushSite` varchar(24) null comment "主推站点" after  `prod_level`;
alter table dep_kbh_product_level_potentail add column `PushRule` varchar(512) null comment "推送规则" after  `PushSite`;
alter table dep_kbh_product_level_potentail add column `PushDate` date null comment "推送日期" after  `PushRule`;
alter table dep_kbh_product_level_potentail add column `StopPushDate` date null comment "停止推送日期" after  `PushDate`;
alter table dep_kbh_product_level_potentail add column `PushUser` varchar(24) null comment "推送人" after  `StopPushDate`;
alter table dep_kbh_product_level_potentail add column `PushReason` varchar(512) null comment "推送理由" after  `PushUser`;
alter table dep_kbh_product_level_potentail add column `isStopPush` varchar(24)  null comment "是否取消推送" after  `PushReason`;
-- 修改列