-- 查询
select * from  dep_kbh_product_level_potentail where asin = 'B0C36JVPXG' AND ShopCode = 'QR-CA'


select date_add('2023-07-23',interval -14 day)

CREATE TABLE IF NOT EXISTS
dep_kbh_listing_level_details (
`MarkDate` date NOT NULL COMMENT "标签计算日期",
`Asin` varchar(64)  NOT NULL COMMENT "ASIN",
`ShopCode` varchar(64)  NOT NULL COMMENT "店铺简码",
`SellerSku` varchar(64)  NOT NULL COMMENT "渠道SKU",

`ListLevel` varchar(64)  REPLACE_IF_NOT_NULL NULL COMMENT "链接分层",
`OldListLevel` varchar(512)  REPLACE_IF_NOT_NULL NULL COMMENT "历史链接分层",
`MinPublicationDate` datetime REPLACE_IF_NOT_NULL NULL COMMENT "首次刊登时间" ,
`site` varchar(32)  REPLACE_IF_NOT_NULL NULL COMMENT "站点",
`AccountCode` varchar(64) REPLACE_IF_NOT_NULL  NULL COMMENT "账号",
`NodePathName` varchar(64) REPLACE_IF_NOT_NULL  NULL COMMENT "销售团队",
`SellUserName` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "首选业务员",

`salescountInt1` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "昨天销量T1",
`SalesCountInt2` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "前天销量T2",
`SalesCountInt3` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3销量",
`SalesCountIn1w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近1周销量",
`SalesCountIn2w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近2周销量",
`SalesCountIn30d` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近30天销量",
`SalesCountIn90d` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近90天销量",

`ExposureInt2` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "前天曝光T2",
`ExposureInt3` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3曝光",
`ExposureInt4` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T4曝光",
`ExposureIn1w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近1周曝光",
`ExposureIn2w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近2周曝光",
    
`ClicksInt2` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "前天点击T2",
`ClicksInt3` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3点击",
`ClicksInt4` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T4点击",
`ClicksIn1w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近1周点击",
`ClicksIn2w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近2周点击",

`AdSpendInt2` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "前天广告花费T-",
`AdSpendInt3` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3广告花费",
`AdSpendInt4` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T4广告花费",
`AdSpendIn1w` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近1周广告花费",
`AdSpendIn2w` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "近2周广告花费",

`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "写入时间"
) ENGINE=OLAP
AGGREGATE KEY(MarkDate,asin,shopcode,sellersku)
COMMENT "快百货链接分层明细表"
DISTRIBUTED BY HASH(asin,shopcode,sellersku) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- 增加列
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `ListingId` varchar(256) REPLACE_IF_NOT_NULL NULL COMMENT  "链接表Id" after SellerSku;
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `BoxSku` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT  "BoxSku" after AdSpendIn2w;
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `SPU` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT  "spu" after BoxSku;
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `SKU` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT  "SKU" after SPU;

-- 修改列
ALTER TABLE dep_kbh_listing_level_details MODIFY COLUMN MinPublicationDate date REPLACE_IF_NOT_NULL NULL  COMMENT "首次刊登时间" ;