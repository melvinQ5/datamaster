-- 评估删除链接的影响
-- 将出单链接分为 当前已删除 和 当前未删除两部分，
-- 按部门 x 分月维度统计结算销售额


select ms.Department ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) 亚马逊结算销售额
    ,round( sum( case when onli.shopcode is not null then TotalGross/ExchangeUSD end ) ,0 ) 当前未删除链接部分
    ,round( sum( case when onli.shopcode is null then TotalGross/ExchangeUSD end ) ,0 ) 当前已删除链接部分
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code
    and ms.Department regexp '快百货|商厨汇|木工汇'
    and IsDeleted = 0  and SettlementTime >= '2023-03-01' and SettlementTime < '2023-09-01'
left join ( select distinct sellersku ,shopcode from erp_amazon_amazon_listing eaal
    join mysql_store ms on eaal.shopcode = ms.Code
        and ms.Department regexp '快百货|商厨汇|木工汇'
        and ListingStatus!=5 ) onli
    on wo.shopcode = onli.ShopCode and wo.SellerSku = onli.SellerSKU  -- 未删除链接
group by ms.Department ,year(SettlementTime)  ,month(SettlementTime)
order by Department,结算月份


select ms.Department ,year(SettlementTime) 结算年份 ,month(SettlementTime) 结算月份
    ,round( sum(  TotalGross/ExchangeUSD ) ,0 ) 亚马逊结算销售额
    ,round( sum( case when onli.shopcode is not null then TotalGross/ExchangeUSD end ) ,0 ) 当前未删除链接部分
    ,round( sum( case when onli.shopcode is null then TotalGross/ExchangeUSD end ) ,0 ) 当前已删除链接部分
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code
    and ms.Department regexp '特卖汇'
    and IsDeleted = 0  and SettlementTime >= '2023-03-01' and SettlementTime < '2023-09-01'
left join ( select distinct sellersku ,shopcode ,asin from ads_tmh_online_listing where listing_status != '待删除' ) onli
    on wo.shopcode = onli.ShopCode and wo.SellerSku = onli.SellerSKU and wo.asin = onli.ASIN -- 未删除链接
group by ms.Department ,year(SettlementTime)  ,month(SettlementTime)
order by Department,结算月份

