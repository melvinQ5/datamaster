
with topsku as (
select distinct dkpl.spu , dkpl.prod_level ,date('${NextStartDay}') as  mark_date
from dep_kbh_product_level dkpl
where isdeleted = 0 and FirstDay ='${FirstDay}' and prod_level regexp '爆|旺|潜力'
)

-- select * from topsku where spu =5260504

, pre_od_14 as ( -- 聚合到 spu+销售人员+站点+sku ,以算top站点\topSKU
select *
   , row_number() over (partition by spu, dep2, SellUserName,site  order by sales_14 desc ) sku_sales_sort
from (
    select wo.Product_SPU as spu, wo.Product_Sku as sku, BoxSku, dep2, SellUserName, wo.Site
        , round(sum((totalgross)/ExchangeUSD), 2) sales_14
        , round(sum((totalgross-feegross)/ExchangeUSD), 2) sales_no_feegross_14
        , round(sum((totalprofit)/ExchangeUSD), 2) profit_14
    from wt_orderdetails wo
    join ( select case when NodePathName regexp '成都' then '快百货成都' else '快百货泉州' end as dep2, *
    from import_data.mysql_store where department regexp '快') s on s.code=wo.shopcode and s.department='快百货'
    join topsku pp on pp.spu=wo.Product_SPU
    where wo.IsDeleted = 0 and TransactionType <> '其他' and PayTime >= date (date_add(' ${NextStartDay}', INTERVAL -14 day)) and PayTime < ' ${NextStartDay}'
    group by wo.Product_SPU, wo.Product_Sku, wo.BoxSku, dep2, SellUserName, wo.Site
    ) t
)
-- select * from pre_od_14 where spu =1054487 order by spu, dep2, SellUserName,site ,sku_sales_sort

, top_sku_sort as (
select spu,dep2,SellUserName
     , group_concat( sku )  销售额TopSKU
    , group_concat( BoxSku )  销售额TopBoxSku
 from (
select *,row_number() over (partition by spu,dep2,SellUserName order by sales_14 desc  ) sku_sales_sort
from (select spu,dep2,SellUserName,sku ,boxsku
    ,sum( sales_14 ) sales_14
    from pre_od_14 group by spu,dep2,SellUserName,sku ,boxsku ) t
) t
where sku_sales_sort  = 1
group by spu,dep2,SellUserName
)

, top_site_sort as (
select spu,dep2,SellUserName
    , group_concat( case when site_sales_sort <= 3 then site end )  销售额Top3站点
    , group_concat( case when sales_14 >= 80  then site end )  销售额大于80usd站点
 from (
select *,row_number() over (partition by spu,dep2,SellUserName order by sales_14 desc  ) site_sales_sort
from (select spu,dep2,SellUserName,site
    ,sum( sales_14 ) sales_14
    ,sum( sales_no_feegross_14 ) sales_no_feegross_14
    ,sum( profit_14 ) profit_14
    from pre_od_14 group by spu,dep2,SellUserName,site) t
) t
group by spu,dep2,SellUserName
)

-- select * from top_site
-- order by spu,dep2,SellUserName ,sales_sort

 ,od_14 as ( -- 聚合到spu+销售人员
select wo.spu ,dep2 ,SellUserName
     ,sum( sales_14 )  sales_14
     ,sum( sales_no_feegross_14 ) sales_no_feegross_14
     ,sum( profit_14 )  profit_14
from pre_od_14 wo group by wo.spu ,dep2 ,SellUserName
)

, refund_stat as (
select wo.Product_SPU as spu ,dep2 ,SellUserName
     ,round(sum((RefundAmount)/ExchangeUSD),2) refund_14
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  s on s.code=wo.shopcode and s.department='快百货'
join topsku pp on pp.spu=wo.Product_SPU
where wo.IsDeleted = 0 and TransactionType = '退款' and SettlementTime >= date(date_add('${NextStartDay}',INTERVAL -14 day)) and SettlementTime < '${NextStartDay}'
group by wo.Product_SPU ,dep2 ,SellUserName
)

,od_30 as (
select wo.Product_SPU as spu ,dep2 ,SellUserName
     ,round(sum((totalgross)/ExchangeUSD),2) sales_30
     ,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_feegross_30
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  s on s.code=wo.shopcode and s.department='快百货'
join topsku pp on pp.spu=wo.Product_SPU
where wo.IsDeleted = 0 and TransactionType <> '其他' and PayTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and PayTime < '${NextStartDay}'
group by wo.Product_SPU ,dep2 ,SellUserName
)

, lst_ad_spend as ( -- 单独按SKU聚合计算广告费，不止计算出单链接的广告花费，需要计算所有链接的广告花费
select SPU,dep2 ,SellUserName
     ,sum(Spend) AdSpend_in30d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then Spend end ) AdSpend_in14d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then Exposure end ) Exposure_in14d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then Clicks end ) Clicks_in14d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -14-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY) then TotalSale7DayUnit end ) ad_sales_in14d
from (select sellersku ,shopcode ,topsku.SPU
    from topsku join wt_listing on topsku.spu =wt_listing.spu
    group by  sellersku ,shopcode ,topsku.SPU ) wl
join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code
where CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
group by SPU ,dep2 ,SellUserName
)

, online_stat as ( -- 在线账号 在线链接
select spu ,dep2 ,SellUserName ,count(distinct CompanyCode) 在线账号套数
    , count(distinct concat(SellerSKU,ShopCode)) 在线链接数
from erp_amazon_amazon_listing eaal
join  ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on eaal.shopcode=ms.Code and eaal.ListingStatus = 1 and ms.ShopStatus = '正常'
group by spu ,dep2 ,SellUserName
)

, sa_lst_stat as (
select spu ,SellUserName , case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2
     ,count(DISTINCT CONCAT(ASIN,SITE )) AS sa链接数
from dep_kbh_listing_level_details
where  ListLevel regexp 'S|A'
group by spu ,SellUserName ,NodePathName
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

, res as (
select
    concat(mark_date,a.spu,a.SellUserName) as 表id
    , mark_date 标签更新日期
    , a.spu
    , prod_level as 商品分层
    , a.dep2 as 销售团队
    , a.SellUserName as 首选业务员
    , case when locate(a.SellUserName,j.seller_list) >0  then '是' end as 首选是否是销售负责人
    , sales_30 as 销售额_30天
    , sales_no_feegross_30 as 扣运费销售额_30天
    , round(sales_14,2)  as  销售额_14天
    , round(sales_no_feegross_14,2) as 扣运费销售额_14天
    , ifnull(在线链接数,0) 在线链接数
    , ifnull(在线账号套数,0) 在线账号套数
    , ifnull(SA链接数,0) SA链接数  -- 该SPU有10条SA链接，其中王万清有3条
    , ifnull( AdSpend_in14d,0 ) as 广告花费_14天
    , round( ifnull(AdSpend_in14d,0) / sales_14 ,2 ) as 广告花费占比_14天
    , round( ifnull(refund_14,0) / sales_14 ,2 ) as 退款率_14天
    , round( (profit_14 - ifnull(AdSpend_in14d,0))  / sales_14 ,2) 扣广告利润率_14天
    , Exposure_in14d as SPU曝光量_14天
    , Clicks_in14d as  SPU点击量_14天
    , round( Clicks_in14d / Exposure_in14d ,4 ) as SPU点击率_14天
    , round( ad_sales_in14d / Clicks_in14d ,4 ) as SPU转化率_14天
    , 销售额Top3站点
    , 销售额大于80usd站点
    , 销售额TopSKU
    , 销售额TopBoxSku
from topsku t1
left join od_30 a on t1.SPU = a.spu
left join od_14 b on a.spu =b.spu and a.SellUserName = b.SellUserName and a.dep2 = b.dep2
left join top_site_sort f on a.spu =f.spu and a.SellUserName = f.SellUserName and a.dep2 = f.dep2
left join lst_ad_spend c on a.spu =c.spu and a.SellUserName = c.SellUserName and a.dep2 = c.dep2
left join online_stat d on a.spu = d.spu and a.SellUserName = d.SellUserName and a.dep2 = d.dep2
left join refund_stat e on a.spu = e.spu and a.SellUserName = e.SellUserName and a.dep2 = e.dep2
left join sa_lst_stat h on a.spu = h.spu and a.SellUserName = h.SellUserName and a.dep2 = h.dep2
left join top_sku_sort i on a.spu =i.spu and a.SellUserName = i.SellUserName and a.dep2 = i.dep2
left join prod_seller j on a.spu =j.spu

)

 select * from res
-- select count(*) from res