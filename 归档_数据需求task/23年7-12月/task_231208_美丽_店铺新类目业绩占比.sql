with
mysql_store_team as ( -- 剔除定制运营组,增加dep2区域维度
select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,* from import_data.mysql_store where Department = '快百货' and NodePathName != '定制运营组'
)

,online_lst as (
select ifnull(c3,'无新类目') 一级类目,ifnull(c4,'无新类目') 二级类目 ,ifnull(c5,'无新类目') 三级类目 ,ShopCode ,11 as month
,count(distinct concat(eaal.ShopCode,eaal.SellerSKU)) 在线链接数
from erp_amazon_amazon_listing eaal join mysql_store_team ms on eaal.ShopCode=ms.Code and ms.Department='快百货'
left join manual_table j on  handlename='美丽_快百货新旧类目对照_231208' and j.memo=eaal.sku
group by ifnull(c3,'无新类目') ,ifnull(c4,'无新类目')  ,ifnull(c5,'无新类目')  ,ShopCode )

,od as (
select month(SettlementTime) set_month ,CompanyCode ,shopcode ,ms.site ,dep2 ,NodePathName ,SellUserName ,ifnull(c3,'无新类目') 一级类目,ifnull(c4,'无新类目') 二级类目 ,ifnull(c5,'无新类目') 三级类目
,round(sum( TotalGross/ExchangeUSD) ,2) 销售额S3
,round(sum( TotalProfit/ExchangeUSD) ,2) 利润额M3
,round(sum( TotalProfit ) /sum( TotalGross) ,2) 利润率R3
from wt_orderdetails  wo
join mysql_store_team ms on wo.shopcode = ms.code
left join manual_table j on  handlename='美丽_快百货新旧类目对照_231208' and j.c2=wo.boxsku
where settlementtime >= '2023-01-01' and settlementtime < '2023-12-01' and IsDeleted=0
group by month(SettlementTime) ,CompanyCode ,shopcode ,ms.site ,dep2 ,NodePathName ,SellUserName ,ifnull(c3,'无新类目') ,ifnull(c4,'无新类目') ,ifnull(c5,'无新类目') )

,res as (
select od.* ,在线链接数 from od left join  online_lst lst on od.shopcode =lst.shopcode and  od.一级类目 =lst.一级类目 and  od.二级类目 =lst.二级类目 and  od.三级类目 =lst.三级类目 and od.set_month =lst.month
)

select  *
,round( 销售额S3 / sum(销售额S3) over (partition by set_month ,shopcode ) ,4 ) 月销售额占比
,round( 利润额M3 / sum(利润额M3) over (partition by set_month ,shopcode ) ,4 ) 月利润额占比
,round( 在线链接数 / sum(在线链接数) over (partition by set_month ,shopcode ) ,4 ) 在线链接占比
from res

