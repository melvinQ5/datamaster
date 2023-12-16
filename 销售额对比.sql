-- 退款数据源用 daily_refundorders
select sum(TotalGross) from (
    select a.year, a.month ,a.department,
           round(gross_include_refunds - ifnull(refunds,0),2) TotalGross,
           round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
    from (
             select  YEAR(paytime) year, MONTH(paytime) month , ms.department,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds
                  ,round( sum(-1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) ),2) as expend_include_ads
             from import_data.wt_orderdetails wo
                      join mysql_store ms on wo.shopcode=ms.Code where PayTime >='${StartDay}' and PayTime<'${EndDay}' and wo.IsDeleted=0 group by year, month, ms.department
         ) a left join (
        select YEAR(RefundDate) year, MONTH(RefundDate) month , ms.department, ifnull(sum(RefundUSDPrice),0) refunds
        from import_data.daily_RefundOrders rf join mysql_store ms on rf.OrderSource=ms.Code where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${EndDay}'
        group by year, month, department
    ) b on a.year = b.year and a.month = b.month and a.department = b.department
             left join (
        select  YEAR(CreatedTime) year, MONTH(CreatedTime) month , department,sum(Spend) adspend
        from import_data.AdServing_Amazon ad join mysql_store ms on ad.ShopCode=ms.Code where ad.CreatedTime >='${StartDay}' and ad.CreatedTime<'${EndDay}'
        group by year, month, department
    ) c on a.year = c.year and a.month = c.month and a.department = c.department
) t;


-- 退款数据源换 wt
select sum(TotalGross) from (
    select a.year, a.month ,a.department,
           round(gross_include_refunds - ifnull(refunds,0),2) TotalGross,
           round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
    from (
             select  YEAR(paytime) year, MONTH(paytime) month , ms.department,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds
                  ,round( sum(-1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) ),2) as expend_include_ads
             from import_data.wt_orderdetails wo
                      join mysql_store ms on wo.shopcode=ms.Code where PayTime >='${StartDay}' and PayTime<'${EndDay}' and wo.IsDeleted=0 group by year, month, ms.department
         ) a left join (
        select YEAR(SettlementTime) year, MONTH(SettlementTime) month , ms.department
             ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
        from import_data.wt_orderdetails rf join mysql_store ms on rf.shopcode=ms.Code
        where TransactionType ='退款' and SettlementTime>='${StartDay}' and SettlementTime<'${EndDay}' and IsDeleted = 0
        group by year, month, ms.department
    ) b on a.year = b.year and a.month = b.month and a.department = b.department
             left join (
        select  YEAR(CreatedTime) year, MONTH(CreatedTime) month , department,sum(Spend) adspend
        from import_data.AdServing_Amazon ad join mysql_store ms on ad.ShopCode=ms.Code where ad.CreatedTime >='${StartDay}' and ad.CreatedTime<'${EndDay}'
        group by year, month, department
    ) c on a.year = c.year and a.month = c.month and a.department = c.department
) t;



--
select
    round(sum(TotalGross/ExchangeUSD),2) 销售额
    ,round(sum(TotalProfit/ExchangeUSD),2) 利润额
    ,round(sum(TotalProfit)/sum(TotalGross),6) 利润率
from wt_orderdetails wo
join wt_store ms on wo.shopcode=ms.Code
where IsDeleted=0 and  SettlementTime >='${StartDay}' and SettlementTime<'${EndDay}' and ms.Department !='深圳领科';


