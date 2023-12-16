
CREATE TABLE IF NOT EXISTS
dep_kbh_product_level (
`FirstDay` date NOT NULL COMMENT "计算商品分层日期",
`Department`  varchar(24) NOT NULL COMMENT "适用部门" ,
`SPU` varchar(64)  NOT NULL COMMENT "SPU",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除" ,
`Week` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "统计周次",
`prod_level` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "商品分层",
`ProductStatus` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "产品状态",
`sales_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "不含运费销售额",
`profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "扣运费扣广告扣退款利润",
`AdSpend_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天产品广告花费",
`sales_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天销售额",
`profit_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天利润额",
`AdSpend_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天产品广告花费",
`sales_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天销售额",
`profit_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天利润额",
`isnew`  varchar(24) REPLACE_IF_NOT_NULL NULL  COMMENT "新老品，当月及前两个月终审视为新品",
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "写入时间"
) ENGINE=OLAP
AGGREGATE KEY(FirstDay,Department,SPU)
COMMENT "快百货商品分层"
DISTRIBUTED BY HASH(FirstDay,Department,SPU) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- 增加字段
ALTER TABLE dep_kbh_product_level ADD COLUMN `sales_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天销售额" after sales_no_freight;
ALTER TABLE dep_kbh_product_level ADD COLUMN `sales_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天销售额" after sales_in30d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `profit_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天利润额" after sales_in30d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `profit_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天利润额" after sales_in7d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "扣运费扣广告扣退款利润" after sales_no_freight;
ALTER TABLE dep_kbh_product_level ADD COLUMN `isPushByCD` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "成都跟进潜力款" after prod_level;
ALTER TABLE dep_kbh_product_level ADD COLUMN `isPushByQZ` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "泉州跟进潜力款" after isPushByCD;
ALTER TABLE dep_kbh_product_level ADD COLUMN `AdSpend_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天产品广告花费" after profit_no_freight;
ALTER TABLE dep_kbh_product_level ADD COLUMN `AdSpend_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天产品广告花费" after profit_in30d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除" after SPU;



-- 更新
-- 补充MarkDate
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,MarkDate)
    select FirstDay,Department,SPU, date(date_add(FirstDay,interval 1 week)) as MarkDate
        from dep_kbh_product_level where day(firstday) != 1;
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,MarkDate)
    select FirstDay,Department,SPU, date(date_add(FirstDay,interval 1 month)) as MarkDate
        from dep_kbh_product_level where day(firstday) = 1;

-- 标记删除数据
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where FirstDay ='2023-10-31'
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where MarkDate ='2023-10-16'
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where FirstDay ='2023-09-25'
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where FirstDay ='2023-09-01'

-- 更新新老品
insert into dep_kbh_product_level (FirstDay,Department,SPU,isnew)
    select FirstDay,Department,dkpl.SPU, case when vknp.spu is not null  then '新品' else '老品' end  isnew
    from dep_kbh_product_level dkpl
    left join (select distinct spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    where FirstDay >= '2023-10-01';

select cast(firstday as varchar) as firstday ,spu ,week ,prod_level,isnew  from dep_kbh_product_level  where firstday > '2023-07-01' and isdeleted = 0



-- 查询
select FirstDay,Department ,count(1) from  dep_kbh_product_level where isdeleted = 0 group by FirstDay,Department;
select count(1) from  dep_kbh_product_level;
select * from  dep_kbh_product_level WHERE Department = '快百货' and FirstDay='2023-06-05' and prod_level regexp '爆|旺';

select FirstDay ,count(1) spu数 from  dep_kbh_product_level WHERE Department = '快百货' and right(FirstDay,2) = '01' group by FirstDay

-- 清空
truncate ---- table dep_kbh_product_level;

