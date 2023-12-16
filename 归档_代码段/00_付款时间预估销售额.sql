-- 预估销售额
-- 订单表中 TotalGross 已经减去了退款和广告花费，因此计算预估时，需要先把“订单表”中的“总收入”中被减去的退款和广告花费给加回来，再分别从“退款表”和“广告表”中计算得到金额对其扣除


select a.date ,a.department
    ,round(gross_include_refunds - ifnull(refunds,0),2) TotalGross
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
from (
    select  date(paytime) date , ms.department
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- 订单表收入加回订单表退款金额
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
    from import_data.wt_orderdetails wo
    join mysql_store ms on wo.shopcode=ms.Code
    where PayTime >='${StartDay}' and PayTime<'${EndDay}' and wo.IsDeleted=0
    group by date(paytime) , ms.department
) a
left join (
    select date(RefundDate) date , department,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join mysql_store ms on rf.OrderSource=ms.Code
    where RefundStatus ='已退款' and RefundDate>='${StartDay}' and RefundDate<'${EndDay}'
    group by date(RefundDate), department
) b on a.date = b.date and a.department = b.department
left join (
    select  date(CreatedTime) date , department,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join mysql_store ms on ad.ShopCode=ms.Code
    where ad.CreatedTime >='${StartDay}' and ad.CreatedTime<'${EndDay}'
    group by date(CreatedTime), department
) c on a.date = c.date and a.department = c.department

