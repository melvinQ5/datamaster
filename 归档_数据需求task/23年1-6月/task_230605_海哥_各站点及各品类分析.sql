
-- 大盘情况
总销售，
各站点占的比重，每年top有无变化

-- 各站点
select ifnull(site,'所有站点') 站点 ,year(SettlementTime) year
     ,round(sum(totalgross/exchangeusd)/10000) 销售额_wUSD
     ,round(sum(TotalProfit/exchangeusd)/10000) 利润额_wUSD
     ,round(sum(TotalProfit/exchangeusd)/sum(totalgross/exchangeusd),4) 利润率
     ,count(distinct PlatOrderNumber) 订单量
     ,round(sum(TotalProfit/exchangeusd)/count(distinct PlatOrderNumber),2) 客单_USD
from wt_orderdetails where SettlementTime>='2020-01-01' and OrderStatus!= '作废'
group by grouping sets ((year(SettlementTime)),(site ,year(SettlementTime)))


-- 各品类
select wp.cat1 ,year(SettlementTime) year
      ,round(sum(totalgross/exchangeusd)/10000,2) 销售额_wUSD
     ,round(sum(TotalProfit/exchangeusd)/10000,2) 利润额_wUSD
     ,round(sum(TotalProfit/exchangeusd)/sum(totalgross/exchangeusd),4) 利润率
     ,count(distinct PlatOrderNumber) 订单量
     ,round(sum(TotalProfit/exchangeusd)/count(distinct PlatOrderNumber),2) 客单_USD
from wt_orderdetails wo
left join wt_products wp on wo.BoxSku = wp.BoxSku
where SettlementTime>='2020-01-01'
group by wp.cat1 ,year(SettlementTime)-

-- 各品类
select  row_number() over (partition by year order by 销售额_wUSD desc ) 当年销售额排名,*
from (select wp.cat1
           , wp.cat2
           , year(SettlementTime)                                                        year
           , round(sum(totalgross / exchangeusd) / 10000, 2)                            销售额_wUSD
           , round(sum(TotalProfit / exchangeusd) / 10000, 2)                           利润额_wUSD
           , round(sum(TotalProfit / exchangeusd) / sum(totalgross / exchangeusd), 4)   利润率
           , count(distinct PlatOrderNumber)                                            订单量
           , round(sum(TotalProfit / exchangeusd) / count(distinct PlatOrderNumber), 2) 客单_USD
      from wt_orderdetails wo
               left join wt_products wp on wo.BoxSku = wp.BoxSku
      where SettlementTime >= '2020-01-01'
        and Cat1 regexp 'A3'
      group by wp.cat1, wp.cat2, year(SettlementTime)) ta


-- 类目x站点
select wp.cat1 一级类目,site 站点,year(SettlementTime) year
      ,round(sum(totalgross/exchangeusd)) 销售额_USD
     ,round(sum(TotalProfit/exchangeusd)) 利润额_USD
     ,round(sum(TotalProfit/exchangeusd)/sum(totalgross/exchangeusd),4) 利润率
     ,count(distinct PlatOrderNumber) 订单量
     ,round(sum(TotalProfit/exchangeusd)/count(distinct PlatOrderNumber),2) 客单_USD
from wt_orderdetails wo
left join wt_products wp on wo.BoxSku = wp.BoxSku
where SettlementTime>='2023-01-01'
group by wp.cat1,site ,year(SettlementTime)
