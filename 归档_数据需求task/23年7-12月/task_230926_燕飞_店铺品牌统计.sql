-- 清单1 IT获取店铺x商标
with map as ( -- IT获取品牌关系
select c4 as shopcode ,c1 as site ,c2 as brand ,c3 as ismark ,ws.AccountCode ,ws.Market ,ws.ShopStatus ,SellUserName ,NodePathName
from manual_table  mb
left join wt_store ws on mb.c4 = ws.Code
where handlename = '快百货店铺品牌关系' and handletime = '2023-09-26'
)

, od_stat as (
select  map.AccountCode ,map.shopcode, map.brand
    ,map.SellUserName
    ,map.NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*1 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近30天结算销售额
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*3 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近90天结算销售额
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*6 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近180天结算销售额
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*12 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近360天结算销售额
from wt_orderdetails wo
join map on wo.shopcode = map.shopcode
left join wt_products wp on wp.sku = wo.Product_Sku
where  wo.IsDeleted =0 and SettlementTime >= '2022-09-01'
group by map.AccountCode ,map.shopcode , map.brand ,SellUserName ,NodePathName ,category
)

,lst_stat as (
select  eaal.BrandName as brand ,AccountCode,shopcode ,SellUserName ,NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,count( distinct concat(ShopCode,SellerSKU) ) 在线链接数
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='快百货' and ListingStatus=1 and ShopStatus='正常'
left join wt_products wp on wp.sku = eaal.sku
group by eaal.BrandName ,AccountCode,shopcode ,SellUserName ,NodePathName ,category
)
-- select * from lst_stat

,t0 as ( -- 结果表主键
select distinct  AccountCode ,shopcode ,brand , category , Market ,ShopStatus ,SellUserName as 销售人员 ,NodePathName as 团队
from map
join (select distinct concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category from wt_products wp ) wp
)

select t0.*
    ,在线链接数
    ,近30天结算销售额
    ,近90天结算销售额
    ,近180天结算销售额
    ,近360天结算销售额
from t0
left join  od_stat t1 on t0.shopcode = t1.shopcode and t0.brand = t1.brand and t0.category = t1.category
left join  lst_stat t2 on t0.shopcode = t2.shopcode and t0.brand = t2.brand and t0.category = t2.category
where concat(t1.shopcode,t2.ShopCode) is not null ;-- 主键是店铺x商标x类目，剔除掉既没有在线链接，又没有出单的记录


-- 清单2 快百货在线链接的店铺x商标
with map as ( -- 当期在线链接的品牌关系
select  distinct shopcode , site ,BrandName as brand  ,ms.AccountCode ,ms.Market ,ms.ShopStatus ,SellUserName ,NodePathName
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='快百货' and ListingStatus=1 and ShopStatus='正常'
)

, od_stat as (
select  map.AccountCode ,map.shopcode, map.brand
    ,map.SellUserName
    ,map.NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*1 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近30天结算销售额
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*3 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近90天结算销售额
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*6 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近180天结算销售额
    ,round( sum( case when  SettlementTime >= date_add('2023-09-26' ,interval -30*12 day) and SettlementTime < '2023-09-26' then   TotalGross/ExchangeUSD end ) , 2 ) 近360天结算销售额
from wt_orderdetails wo
join map on wo.shopcode = map.shopcode
left join wt_products wp on wp.sku = wo.Product_Sku
where  wo.IsDeleted =0 and SettlementTime >= '2022-09-01'
group by map.AccountCode ,map.shopcode , map.brand ,SellUserName ,NodePathName ,category
)

,lst_stat as (
select  eaal.BrandName as brand ,AccountCode,shopcode ,SellUserName ,NodePathName
    ,concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category
    ,count( distinct concat(ShopCode,SellerSKU) ) 在线链接数
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='快百货' and ListingStatus=1 and ShopStatus='正常'
left join wt_products wp on wp.sku = eaal.sku
group by eaal.BrandName ,AccountCode,shopcode ,SellUserName ,NodePathName ,category
)
-- select * from lst_stat

,t0 as ( -- 结果表主键
select distinct  AccountCode ,shopcode ,brand , category , Market ,ShopStatus ,SellUserName as 销售人员 ,NodePathName as 团队
from map
join (select distinct concat(wp.cat1,'>',cat2,'>',cat3,'>',cat4) category from wt_products wp ) wp
)

select t0.*
    ,在线链接数
    ,近30天结算销售额
    ,近90天结算销售额
    ,近180天结算销售额
    ,近360天结算销售额
from t0
left join  od_stat t1 on t0.shopcode = t1.shopcode and t0.brand = t1.brand and t0.category = t1.category
left join  lst_stat t2 on t0.shopcode = t2.shopcode and t0.brand = t2.brand and t0.category = t2.category
where concat(t1.shopcode,t2.ShopCode) is not null -- 主键是店铺x商标x类目，剔除掉既没有在线链接，又没有出单的记录

-- 清单3
select  shopcode ,SellUserName as 销售人员 ,NodePathName as 团队
    ,count( distinct concat(ShopCode,SellerSKU) ) 在线链接数
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode =ms.Code and ms.Department='快百货' and ListingStatus=1 and ShopStatus='正常'
group by shopcode ,SellUserName  ,NodePathName