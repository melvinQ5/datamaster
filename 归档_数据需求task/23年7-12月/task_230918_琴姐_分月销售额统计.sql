-- 从2022年9月到2023年8月，我们公司快百货业务的总销售额和利润额数据？（按月给

select left(SettlementTime,7) as 结算月份
    ,round( sum( TotalGross/ExchangeUSD ) ,2) 销售额usd
    ,round( sum( TotalProfit/ExchangeUSD ) ,2) 利润额usd
    ,round( sum( TotalProfit/ExchangeUSD ) / sum( TotalGross/ExchangeUSD ) ,4) 利润率
from wt_orderdetails wo
join mysql_store ms on ms.Code = wo.shopcode and ms.Department = '快百货'
where IsDeleted=0 and SettlementTime >= '2022-09-01' and SettlementTime < '2023-09-01'
group by left(SettlementTime,7)
order by left(SettlementTime,7)