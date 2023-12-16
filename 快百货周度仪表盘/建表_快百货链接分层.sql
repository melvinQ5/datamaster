
CREATE TABLE IF NOT EXISTS
dep_kbh_listing_level (
`FirstDay` date NOT NULL COMMENT "统计期的第一天",
`Department`  varchar(24) NOT NULL COMMENT "适用部门" ,
`asin` varchar(64)  NOT NULL COMMENT "ASIN",
`site` varchar(32)  NOT NULL COMMENT "站点",
`spu` double REPLACE_IF_NOT_NULL NULL  COMMENT  "spu",
`Week` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "统计周次",
`list_level` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "链接分层",
`old_list_level` varchar(128) REPLACE_IF_NOT_NULL NULL  COMMENT  "历史链接标签" ,
`ListingStatus` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "统计时链接在线状态",
`sales_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "不含运费销售额",
`sales_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天销售额",
`profit_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天利润额",
`sales_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天销售额",
`profit_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天利润额",
`list_orders` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT  "累计订单数",
`prod_level` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "产品分层",
`isnew` varchar(24) REPLACE_IF_NOT_NULL NULL  COMMENT "新老品，当月及前两个月终审视为新品",
`ProductStatus` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "产品状态",
`ele_name` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "元素名称",
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "写入时间"
) ENGINE=OLAP
AGGREGATE KEY(FirstDay,Department,asin,site)
COMMENT "快百货链接分层"
DISTRIBUTED BY HASH(FirstDay,Department,asin,site) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);


-- 查询
select count(1) from  dep_kbh_listing_level
select FirstDay,Department,count(1) from  dep_kbh_listing_level group by FirstDay,Department order by FirstDay;
SELECT * from dep_kbh_listing_level WHERE FirstDay = '2023-07-24' ORDER BY ASIN ,SITE;


-- 增加字段
ALTER TABLE dep_kbh_listing_level ADD COLUMN `sales_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天销售额" after sales_no_freight;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `sales_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天销售额" after sales_in30d;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `profit_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近30天利润额" after sales_in30d;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `profit_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "近7天利润额" after sales_in7d;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `spu` double REPLACE_IF_NOT_NULL NULL  COMMENT  "spu" after site;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `prod_level` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "产品分层" after list_orders;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `isnew` varchar(24) REPLACE_IF_NOT_NULL NULL  COMMENT "新老品，当月及前两个月终审视为新品" after prod_level;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `ProductStatus` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "产品状态" after isnew;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `ele_name` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "元素名称" after ProductStatus;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "扣运费扣广告扣退款利润额" after sales_no_freight;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `old_list_level` varchar(128) REPLACE_IF_NOT_NULL NULL  COMMENT  "历史链接标签" after list_level;
ALTER TABLE dep_kbh_listing_level ADD COLUMN `isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除" after ele_name;

-- 更新
-- 标记删除数据
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted ,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_listing_level where FirstDay = '2023-10-31';

insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted ,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_listing_level where date(wttime) = '2023-10-16';
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted ,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_listing_level where FirstDay ='2023-09-25';
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted ,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_listing_level where FirstDay ='2023-09-01';
insert into dep_kbh_listing_level (FirstDay,Department,asin ,site ,isdeleted)
    select FirstDay,Department,asin ,site,1
        from dep_kbh_listing_level where FirstDay <= '2023-06-01';
insert into dep_kbh_listing_level (FirstDay,Department,asin ,site ,isdeleted)
    select FirstDay,Department,asin ,site,0
        from dep_kbh_listing_level where FirstDay > '2023-06-01';
-- 更新新老品
insert into dep_kbh_listing_level (FirstDay,Department,asin,site,isnew)
    select FirstDay,Department,asin,site, case when vknp.spu is not null  then '新品' else '老品' end  isnew
    from dep_kbh_listing_level dkpl
    left join (select distinct spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    where FirstDay >= '2023-10-01';

-- 其他修改
insert into dep_kbh_listing_level (FirstDay,Department,asin ,site ,list_level)
    select FirstDay,Department,asin ,site, case when list_level = '潜力' then '其他' else list_level end  list_level
        from dep_kbh_listing_level

insert into dep_kbh_listing_level (FirstDay,Department,asin ,site ,list_level)
    select FirstDay,Department,asin ,site ,'潜力' as list_level
        from dep_kbh_listing_level
        where firstday = '2023-07-31' and concat(site,' ',asin) in (
            'US B0C38PVF56',
'UK B0C27WN8F3',
'UK B0C46FG5GD',
'US B0C5LZC527',
'DE B0C5DP83VZ',
'UK B0BW3LXLWW',
'US B0C1ZC4MNF',
'US B0C23L5F76',
'MX B08L91PRXQ',
'US B0C6T7WRVW',
'UK B0C7VZPGS8',
'FR B0BMGQK96J',
'UK B0BMGQK96J',
'DE B0BBG313HK',
'DE B0BSLBKRNH',
'ES B0C5MSBXTQ',
'SE B0BWN8JQLC',
'US B0BW443GYP',
'UK B0CCJC7F31',
'UK B0CCSBNN6B',
'US B0CCDMK4W1',
'US B0CCYLPNWR',
'US B0CCYN1QQ6',
'US B0CD2FMGJ8',
'US B0CDBFFK69',
'US B0CD3B7Q2L',
'US B0CD7T6DW9',
'US B0CD7W3N6W',
'US B0CC4M6QL9',
'US B0CCVH94LD',
'UK B0CCY68YXH',
'UK B0C85RW86J',
'US B0CCYPHGCQ',
'US B0CCYMD2P6',
'UK B0CCCSRH38',
'US B0CCYPG2G2',
'US B0CCYQ3DL4'
            )




-- 清空
truncate table dep_kbh_listing_level;



