 -- todo �޸�wt���� ����sku���ݣ������ܴ˱�
CREATE TABLE IF NOT EXISTS
dep_kbh_lst_sku_maps_test (
`shopcode` varchar(32)  NOT NULL COMMENT "",
`sellersku` varchar(128)  NOT NULL COMMENT "",
`sku` varchar(32)  NOT NULL COMMENT "",
`pub_sort` int(11) null comment "����ʱ������"
) ENGINE=OLAP
DUPLICATE KEY(shopcode,sellersku,sku)
COMMENT "��ٻ���ʱ���ӹ���SKU��"
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
    select shopcode ,sellersku ,sku ,PublicationDate from erp_amazon_amazon_listing el join  mysql_store ms on ms.code = el.ShopCode and ms.Department = '��ٻ�' and  length(sku) > 0 -- Ϊ����sku�������޳�û��sku�ļ�¼
    union select shopcode ,sellersku ,sku ,PublicationDate from erp_amazon_amazon_listing_delete el join  mysql_store ms on ms.code = el.ShopCode and ms.Department = '��ٻ�' and  length(sku) > 0
    ) t
)

select *
from (
select shopcode ,sellersku ,sku ,row_number() over (partition by  shopcode ,sellersku ,sku  order by PublicationDate)  as pub_sort
from lst ) t
where pub_sort = 1 )

