
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4  )
with od as (
select ms.Department ,wo.SettlementTime ,wo.TotalProfit ,wo.TotalGross ,wo.ExchangeUSD ,spu as product_spu ,sku as product_sku ,wo.PlatOrderNumber ,wo.SellerSku ,wo.ShopIrobotId as shopcode
     ,TransactionType ,wo.asin ,wo.OrderCountry as site ,wo.PurchaseCosts ,wo.TradeCommissions ,wo.AdvertisingCosts ,LocalFreight ,OverseasDeliveryFee , HeadFreight , FBAFee ,RefundAmount
from ods_orderdetails wo
join mysql_store ms on wo.ShopIrobotId  = ms.Code
    and ms.Department regexp '快百货|商厨汇|木工汇|特卖汇'
    and IsDeleted = 0  and SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}'
left join (select distinct  boxsku ,sku ,spu from  wt_products ) wp on wo.BoxSku = wp.BoxSku
)

-- 经营结果指标
select '${StartDay}' as 当期第一天 ,'营业额' as 指标  , ifnull(Department,'公司')  as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round( sum(  TotalGross/ExchangeUSD ) ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'毛利额' as 指标  ,  ifnull(Department,'公司')  as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round( sum(  TotalProfit/ExchangeUSD ) ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'毛利率' as 指标  ,  ifnull(Department,'公司')  as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round( sum( TotalProfit ) / sum( TotalGross ) ,4 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
-- 风控
union all
select '${StartDay}' as 当期第一天 ,'结算退款额' as 指标  ,  ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  RefundAmount /ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'结算退款额占营业额比' as 指标  ,  ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs(  round( sum( RefundAmount ) / sum( TotalGross ) ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))

-- 经营效率-SPU维度
union all
select '${StartDay}' as 当期第一天 ,'出单SPU数量' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,count( distinct product_spu )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'出单SPU单位销售额' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalGross/ExchangeUSD )  / count(distinct product_spu )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'出单SPU单位毛利额' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalProfit/ExchangeUSD )  / count(distinct product_spu )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'出单SPU单位订单量' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  count(distinct PlatOrderNumber ) / count(distinct product_spu )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
-- 经营效率-SKU维度
union all
select '${StartDay}' as 当期第一天 ,'出单SKU数量' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,count(distinct product_sku )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'出单SKU单位销售额' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalGross/ExchangeUSD )  / count(distinct product_sku )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'出单SKU单位毛利额' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalProfit/ExchangeUSD )  / count(distinct product_sku )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'出单SKU单位订单量' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  count(distinct PlatOrderNumber ) / count(distinct product_sku )  ,0 )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))


-- 经营效率-链接维度
union all
select '${StartDay}' as 当期第一天 ,'出单链接数量' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    , count(distinct case when TransactionType = '付款' then concat(shopcode,SellerSku) end )
from od where Department regexp '快百货|商厨汇|木工汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接单位销售额' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalGross/ExchangeUSD )  / count(distinct case when TransactionType = '付款' then concat(shopcode,SellerSku) end )  ,0 )
from od where Department regexp '快百货|商厨汇|木工汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接单位利润额' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalProfit/ExchangeUSD )  / count(distinct case when TransactionType = '付款' then concat(shopcode,SellerSku) end ) ,0 )
from od where Department regexp '快百货|商厨汇|木工汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接单位订单量' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  count(distinct PlatOrderNumber ) / count(distinct case when TransactionType = '付款' then concat(shopcode,SellerSku) end )  ,0 )
from od where Department regexp '快百货|商厨汇|木工汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接数量' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
   ,count(distinct case when TransactionType = '付款' then concat(asin,site) end )
from od where Department regexp '特卖汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接单位销售额' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalGross/ExchangeUSD )  /  count(distinct case when TransactionType = '付款' then concat(asin,site) end )  ,0 )
from od where Department regexp '特卖汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接单位利润额' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  sum(  TotalProfit/ExchangeUSD )  /  count(distinct case when TransactionType = '付款' then concat(asin,site) end )  ,0 )
from od where Department regexp '特卖汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)
union all
select '${StartDay}' as 当期第一天 ,'出单链接单位订单量' as 指标  , Department as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round(  count(distinct PlatOrderNumber ) /  count(distinct case when TransactionType = '付款' then concat(asin,site) end )  ,0 )
from od where Department regexp '特卖汇' group by Department ,year(SettlementTime)  ,month(SettlementTime)


-- 人效
union all
select '${StartDay}' as 当期第一天 ,'部门人效' as 指标  , a.Department as 部门 ,'经营分析月会' ,set_year 结算年份 ,set_month 结算月份
    ,round ( totalgross / EmpCount )
from (
select ifnull(Department,'公司') department ,year(SettlementTime)  set_year ,month(SettlementTime) set_month ,round(  sum(  TotalGross/ExchangeUSD )  ,0 ) totalgross
from od  group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime))) ) a
left join ads_staff_stat b on a.department = b.department and a.set_month = month(b.FirstDay) and a.set_year = year(b.FirstDay)
union all
select '${StartDay}' as 当期第一天 ,'销售人效' as 指标  , a.Department as 部门 ,'经营分析月会' ,set_year 结算年份 ,set_month 结算月份
    ,round ( totalgross / SaleCount )
from (
select ifnull(Department,'公司') department ,year(SettlementTime)  set_year ,month(SettlementTime) set_month ,round(  sum(  TotalGross/ExchangeUSD )  ,0 ) totalgross
from od  group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime))) ) a
left join ads_staff_stat b on a.department = b.department and a.set_month = month(b.FirstDay) and a.set_year = year(b.FirstDay)

-- 销售成本
union all
select '${StartDay}' as 当期第一天 ,'采购成本' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  PurchaseCosts/ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'佣金成本' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  TradeCommissions/ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'广告成本' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  AdvertisingCosts/ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'物流成本' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD ) ,0 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))

-- 销售成本占比
union all
select '${StartDay}' as 当期第一天 ,'采购成本占比' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  PurchaseCosts/ExchangeUSD ) / sum(  TotalGross/ExchangeUSD ) ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'佣金成本占比' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  TradeCommissions/ExchangeUSD )  / sum(  TotalGross/ExchangeUSD )  ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'广告成本占比' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  AdvertisingCosts/ExchangeUSD )  / sum(  TotalGross/ExchangeUSD )  ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)))
union all
select '${StartDay}' as 当期第一天 ,'物流成本占比' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD )  / sum(  TotalGross/ExchangeUSD ) ,4 ) )
from od group by grouping sets ( ( Department ,year(SettlementTime)  ,month(SettlementTime)) ,(year(SettlementTime)  ,month(SettlementTime)));



-- ---------------------------------------------------------
-- 正式取数

-- SPU总数量
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'SPU总数量' as 指标  , ifnull(ProjectTeam,'公司') as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
    ,count( distinct SPU)
from erp_product_products where ProductStatus != 2 and IsDeleted = 0 and IsMatrix = 0 and DevelopLastAuditTime is not null and status = 10 
	and ProjectTeam  regexp '快百货|商厨汇|木工汇'
group by grouping sets (() ,(ProjectTeam)) ;

-- SPU总数量 回溯历史版: 获取链接数据（历史截至当月刊登过且目前未删除的） 且获取产品数据（目前未停产的）综合判断统计SPU、Sku数
-- insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
-- select '${StartDay}' as 当期第一天 ,'SPU总数量' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
--     ,count( distinct wl.SPU)
-- from wt_listing wl join mysql_store ms on wl.shopcode = ms.Code and wl.IsDeleted=0
-- join wt_products wp on wl.sku = wp.sku and wp.ProductStatus !=2 and wp.IsDeleted=0
-- where MinPublicationDate < '${NextStartDay}'
-- group by grouping sets (() ,(Department)) ;


-- SKU总数量
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'SKU总数量' as 指标  , ifnull(ProjectTeam,'公司') as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
    ,count( distinct SKU)
from erp_product_products where ProductStatus != 2 and IsDeleted = 0 and IsMatrix = 0 and DevelopLastAuditTime is not null and ProjectTeam  regexp '快百货|商厨汇|木工汇'
group by grouping sets (() ,(ProjectTeam)) ;

-- SKU总数量 回溯历史版: 获取链接数据（历史截至当月刊登过且目前未删除的） 且获取产品数据（目前未停产的）综合判断统计SPU、SKU数
-- insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
-- select '${StartDay}' as 当期第一天 ,'SKU总数量' as 指标  , ifnull(Department,'公司') as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
--     ,count( distinct wl.SKU)
-- from wt_listing wl join mysql_store ms on wl.shopcode = ms.Code and wl.IsDeleted=0
-- join wt_products wp on wl.sku = wp.sku and wp.ProductStatus !=2 and wp.IsDeleted=0
-- where MinPublicationDate < '${NextStartDay}'
-- group by grouping sets (() ,(Department)) ;


-- 链接总数量
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'链接总数量' as 指标  , Department as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}' ) 月份
    ,count( distinct concat(eaal.ShopCode,eaal.SellerSKU) ) online_lst
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '快百货|商厨汇|木工汇'  and eaal.ListingStatus =1 and ms.ShopStatus='正常'
group by Department
union all 
select '${StartDay}' as 当期第一天 ,'链接总数量' as 指标  , Department as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}' ) 月份
    ,count( distinct concat(asin,site) ) online_lst
from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '特卖汇'  and eaal.ListingStatus =1 and ms.ShopStatus='正常'
group by Department;


-- 链接总数量 回溯历史版:历史月份8月的在线链接数 = 当前最新在线链接数据 - 8月至今刊登链接数 + 8月至今删除链接数据
-- 快百货 商厨汇 木工汇
-- insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
-- select '${StartDay}' as 当期第一天 ,'链接总数量' as 指标  , a.Department as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}' ) 月份
--     ,online_lst - add_lst + dele_lst
-- from (
-- select Department
--     ,count( distinct concat(eaal.ShopCode,eaal.SellerSKU) ) online_lst
--     ,count(distinct case when PublicationDate >= '${NextStartDay}' then concat(eaal.ShopCode,eaal.SellerSKU) end ) add_lst
-- from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '快百货|商厨汇|木工汇' and eaal.IsDeleted =0 and eaal.ListingStatus =1 and ms.ShopStatus='正常'
-- group by Department
-- ) a
-- left join (
-- select Department ,count( distinct concat(eaal.ShopCode,eaal.SellerSKU) ) dele_lst
-- from erp_amazon_amazon_listing_delete eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '快百货|商厨汇|木工汇' and  eaal.LastModificationTime >= '${NextStartDay}'  -- 和毛俊沟通用LastModificationTime,这个才是移入删除表的时间
-- group by Department
-- ) b
-- on a.Department=b.Department
-- union all 
-- select '${StartDay}' as 当期第一天 ,'链接总数量' as 指标  , a.Department as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}' ) 月份
--     ,online_lst - add_lst + dele_lst
-- from (
-- select Department
--     ,count( distinct concat(asin,site) ) online_lst
--     ,count(distinct case when PublicationDate >= '${NextStartDay}' then concat(eaal.ShopCode,eaal.SellerSKU) end ) add_lst
-- from erp_amazon_amazon_listing eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '特卖汇' and eaal.IsDeleted =0 and eaal.ListingStatus =1 and ms.ShopStatus='正常'
-- group by Department
-- ) a
-- left join (
-- select Department ,count( distinct concat(asin,site) ) dele_lst
-- from erp_amazon_amazon_listing_delete eaal join mysql_store ms on eaal.shopcode = ms.Code and ms.Department regexp '特卖汇' and  eaal.LastModificationTime >= '${NextStartDay}'  -- 和毛俊沟通用LastModificationTime,这个才是移入删除表的时间
-- group by Department
-- ) b
-- on a.Department=b.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'链接总数量' as 指标  , '公司' as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
    ,sum(c4 + 0) 链接总数量求和
from  manual_table where memo = '链接总数量' and c3 = month('${StartDay}');



-- 出单SPU占比
insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'出单SPU占比' as 指标  , a.handlename as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
    ,round( a.指标值 /  b.指标值 ,4 )
from ( select handlename ,memo , c3 as 月份 ,c4 as 指标值 from manual_table where memo = '出单SPU数量' and c3 = month('${StartDay}') ) a
join ( select handlename ,memo , c3 as 月份 ,c4 as 指标值 from manual_table where memo = 'SPU总数量' and c3 = month('${StartDay}')  ) b
    on a.handlename =b.handlename and a.月份 = b.月份 ;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'出单SKU占比' as 指标  , a.handlename as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
    ,round( a.指标值 /  b.指标值 ,4 )
from ( select handlename ,memo , c3 as 月份 ,c4 as 指标值 from manual_table where memo = '出单SKU数量' and c3 = month('${StartDay}') ) a
join ( select handlename ,memo , c3 as 月份 ,c4 as 指标值 from manual_table where memo = 'SKU总数量' and c3 = month('${StartDay}')  ) b
    on a.handlename =b.handlename and a.月份 = b.月份 ;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 )
select '${StartDay}' as 当期第一天 ,'出单链接占比' as 指标  , a.handlename as 部门 ,'经营分析月会' ,year( '${StartDay}') 年份 ,month( '${StartDay}') 月份
    ,round( a.指标值 /  b.指标值 ,4 )
from ( select handlename ,memo , c3 as 月份 ,c4 as 指标值 from manual_table where memo = '出单链接数量' and c3 = month('${StartDay}') ) a
join ( select handlename ,memo , c3 as 月份 ,c4 as 指标值 from manual_table where memo = '链接总数量' and c3 = month('${StartDay}')  ) b
    on a.handlename =b.handlename and a.月份 = b.月份 ;


