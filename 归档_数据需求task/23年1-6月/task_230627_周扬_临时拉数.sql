-- 销售毛利，广告，分店铺、站点、sku维度就好

-- 
-- select a.site ,a.code
--     ,round(gross_include_refunds - ifnull(refunds,0),2) TotalGross
-- 	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
-- 	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) / (gross_include_refunds - ifnull(refunds,0)) ,4) ProfitRate
-- 	, ifnull(adspend,0) adspend
-- 	, ifnull(refunds,0) refunds
-- from (
--     select ms.site ,ms.code
--         ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
--         ,round( sum(
--             -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
--             ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
--     from import_data.wt_orderdetails wo
--     join mysql_store ms on wo.shopcode=ms.Code and CompanyCode REGEXP 'WY|NJ|XH'
--     where PayTime >='${StartDay}' and PayTime<'${EndDay}' and wo.IsDeleted=0
--     group by ms.site ,ms.code
-- ) a
-- left join (
--     select ms.site ,ms.code ,ifnull(sum(RefundUSDPrice),0) refunds
--     from import_data.daily_RefundOrders rf
--     join mysql_store ms on rf.OrderSource=ms.Code and CompanyCode REGEXP 'WY|NJ|XH'
--     where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${EndDay}'
--     group by ms.site ,ms.code
-- ) b on a.code = b.code
-- left join (
--     select ms.site ,ms.code ,sum(Spend) adspend
--     from import_data.AdServing_Amazon ad
--     join mysql_store ms on ad.ShopCode=ms.Code and CompanyCode REGEXP 'WY|NJ|XH'
--     where ad.CreatedTime >='${StartDay}' and ad.CreatedTime<'${EndDay}'
--     group by ms.site ,ms.code 
-- ) c on a.code = c.code 


--  

select a.site ,a.code
    ,round(gross_include_refunds - ifnull(refunds,0),2) TotalGross
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) / (gross_include_refunds - ifnull(refunds,0)) ,4) ProfitRate
	, ifnull(adspend,0) adspend
	, ifnull(refunds,0) refunds
from (
    select ms.CompanyCode ,wo.BoxSku 
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
    from import_data.wt_orderdetails wo
    join mysql_store ms on wo.shopcode=ms.Code and CompanyCode REGEXP 'WY|NJ|XH'
    where PayTime >='${StartDay}' and PayTime<'${EndDay}' and wo.IsDeleted=0
    group by ms.CompanyCode ,wo.BoxSku 
) a
left join (
    select ms.site ,ms.code ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join mysql_store ms on rf.OrderSource=ms.Code and CompanyCode REGEXP 'WY|NJ|XH'
    where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${EndDay}'
    group by ms.site ,ms.code
) b on a.code = b.code
left join (
    select ms.site ,ms.code ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join mysql_store ms on ad.ShopCode=ms.Code and CompanyCode REGEXP 'WY|NJ|XH'
    where ad.CreatedTime >='${StartDay}' and ad.CreatedTime<'${EndDay}'
    group by ms.site ,ms.code 
) c on a.code = c.code 
