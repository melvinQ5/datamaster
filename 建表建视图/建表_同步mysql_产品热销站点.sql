-- ����
CREATE TABLE `ads_amazon_product_hot_sites` (
  `Id` varchar(64) NOT NULL COMMENT "ID",
  `ProductId` varchar(64) NOT NULL COMMENT "��Ʒid",
  `SiteCode` varchar(64) NOT NULL COMMENT "վ��",
  `CreationTime` datetime NOT NULL COMMENT "����ʱ��"
) ENGINE=OLAP
UNIQUE KEY(`Id`)
COMMENT "��Ʒ����վ��_ͬ��ERP"
DISTRIBUTED BY HASH(`Id`) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

select Id , ProductId ,SiteCode ,CreationTime from ads_amazon_product_hot_sites;

truncate table ads_amazon_product_hot_sites;

-- �������� ��ÿ����truncate ��ͬ��
insert into ads_amazon_product_hot_sites (
with ord as (
select epp.id as productid_sku ,sku ,spu ,OrderCountry as site ,sum(TotalGross) sales
from ods_orderdetails ord
join erp_product_products epp on ord.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix = 0
    and  ord.IsDeleted=0 and TransactionType='����' and paytime >= date_add(curdate(),interval -5 year )
group by epp.id ,sku ,spu ,OrderCountry
)

,sku_sort as (
select productid_sku ,site ,dense_rank() over (partition by productid_sku  order by sales desc ) sort
from ord )

select uuid() ,productid_sku ,site as SiteCode , now() from sku_sort where sort=1 ) ;


insert into ads_amazon_product_hot_sites (
with ord as (
select epp.id as productid_sku ,sku ,spu ,OrderCountry as site ,sum(TotalGross) sales
from ods_orderdetails ord
join erp_product_products epp on ord.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix = 0
    and  ord.IsDeleted=0 and TransactionType='����' and paytime >= date_add(curdate(),interval -5 year )
group by epp.id ,sku ,spu ,OrderCountry
)

,spu_sort as (
select epp.id as productid_spu ,site ,dense_rank() over (partition by epp.id  order by sales desc ) sort
from ( select spu , site  ,sum(sales) sales from ord group by  spu , site  ) t
left join  erp_product_products epp on t.spu = epp.spu and epp.IsDeleted=0 and epp.IsMatrix = 1
)

select uuid() ,productid_spu as productid ,site as SiteCode , now() from spu_sort where sort=1
);


with ord as (
select epp.id as productid_sku ,sku ,spu ,OrderCountry as site ,sum(TotalGross) sales
from ods_orderdetails ord
join erp_product_products epp on ord.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix = 0
    and  ord.IsDeleted=0 and TransactionType='����' and paytime >= date_add(curdate(),interval -5 year )
group by epp.id ,sku ,spu ,OrderCountry
)

,sku_sort as (
select productid_sku ,site ,dense_rank() over (partition by productid_sku  order by sales desc ) sort
from ord )

select uuid() ,productid_sku ,site as SiteCode , now() from sku_sort where sort=1 ) ;


with ord as (
select Product_Sku as sku ,Product_Spu as spu ,ms.site ,sum(TotalGross/ExchangeUSD) sales
from wt_orderdetails ord
join mysql_store ms on ord.shopcode = ms.code and ms.Department='��ٻ�'
    and  ord.IsDeleted=0 and TransactionType='����' and paytime >= '2023-01-01'
group by sku ,spu ,ms.site
)

,spu_sort as (
select spu ,site ,dense_rank() over (partition by spu  order by sales desc ) sort -- ��ÿ����SPU�����ո���վ�㡱�ġ����۶ָ�꽵��
from ( select spu , site  ,sum(sales) sales from ord group by  spu , site  ) t
)

select spu ,site from spu_sort where sort=1 -- ȡ����ĵ�һ���������Ҫ��top5 �͸ĳ� <=5
