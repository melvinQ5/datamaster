 -- todo 修复wt广告表 关联sku数据，减少跑此表
CREATE TABLE IF NOT EXISTS
dep_kbh_lst_sku_maps_test (
`shopcode` varchar(32)  NOT NULL COMMENT "",
`sellersku` varchar(128)  NOT NULL COMMENT "",
`sku` varchar(32)  NOT NULL COMMENT "",
`pub_sort` int(11) null comment "刊登时间排序"
) ENGINE=OLAP
DUPLICATE KEY(shopcode,sellersku,sku)
COMMENT "快百货临时链接关联SKU表"
DISTRIBUTED BY HASH(shopcode,sellersku,sku) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

truncate table dep_kbh_lst_sku_maps_test;


insert into dep_kbh_lst_sku_maps_test (
with lst as ( --
select shopcode ,sellersku ,sku ,PublicationDate
from (
    select shopcode ,sellersku ,sku ,PublicationDate from erp_amazon_amazon_listing el join  mysql_store ms on ms.code = el.ShopCode and ms.Department = '快百货' and  length(sku) > 0 -- 为了找sku关联，剔除没有sku的记录
    union select shopcode ,sellersku ,sku ,PublicationDate from erp_amazon_amazon_listing_delete el join  mysql_store ms on ms.code = el.ShopCode and ms.Department = '快百货' and  length(sku) > 0
    ) t
)

select *
from (
select shopcode ,sellersku ,sku ,row_number() over (partition by  shopcode ,sellersku ,sku  order by PublicationDate)  as pub_sort
from lst ) t
where pub_sort = 1 )

