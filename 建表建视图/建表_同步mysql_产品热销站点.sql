-- 建表
CREATE TABLE `ads_amazon_product_hot_sites` (
  `Id` varchar(64) NOT NULL COMMENT "ID",
  `ProductId` varchar(64) NOT NULL COMMENT "产品id",
  `SiteCode` varchar(64) NOT NULL COMMENT "站点",
  `CreationTime` datetime NOT NULL COMMENT "创建时间"
) ENGINE=OLAP
UNIQUE KEY(`Id`)
COMMENT "产品热销站点_同步ERP"
DISTRIBUTED BY HASH(`Id`) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

select Id , ProductId ,SiteCode ,CreationTime from ads_amazon_product_hot_sites;

truncate table ads_amazon_product_hot_sites;

-- 数据生成 ，每天先truncate 再同步
insert into ads_amazon_product_hot_sites (
with ord as (
select epp.id as productid_sku ,sku ,spu ,OrderCountry as site ,sum(TotalGross) sales
from ods_orderdetails ord
join erp_product_products epp on ord.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix = 0
    and  ord.IsDeleted=0 and TransactionType='付款' and paytime >= date_add(curdate(),interval -5 year )
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
    and  ord.IsDeleted=0 and TransactionType='付款' and paytime >= date_add(curdate(),interval -5 year )
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
    and  ord.IsDeleted=0 and TransactionType='付款' and paytime >= date_add(curdate(),interval -5 year )
group by epp.id ,sku ,spu ,OrderCountry
)

,sku_sort as (
select productid_sku ,site ,dense_rank() over (partition by productid_sku  order by sales desc ) sort
from ord )

select uuid() ,productid_sku ,site as SiteCode , now() from sku_sort where sort=1 ) ;


with ord as (
select Product_Sku as sku ,Product_Spu as spu ,ms.site ,sum(TotalGross/ExchangeUSD) sales
from wt_orderdetails ord
join mysql_store ms on ord.shopcode = ms.code and ms.Department='快百货'
    and  ord.IsDeleted=0 and TransactionType='付款' and paytime >= '2023-01-01'
group by sku ,spu ,ms.site
)

,spu_sort as (
select spu ,site ,dense_rank() over (partition by spu  order by sales desc ) sort -- 对每个“SPU”按照各“站点”的“销售额”指标降序
from ( select spu , site  ,sum(sales) sales from ord group by  spu , site  ) t
)

select spu ,site from spu_sort where sort=1 -- 取排序的第一名，如果你要看top5 就改成 <=5
