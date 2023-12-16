-- 挂单利润率
select shopcode ,SellerSku
        ,round( (gross_include_refunds - ifnull(expend_include_ads,0)  ) /  (gross_include_refunds) ,4) Ori_Profit
from ( select wo.shopcode ,wo.SellerSku
     ,round( sum((TotalGross )/ExchangeUSD),2) as gross_include_refunds -- 订单表不含退款金额
    ,round( sum(
        -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
        ,2) as expend_include_ads  -- 订单表成本加回订单表广告成本 （将负数转为正数，方便理解公式）
    from import_data.wt_orderdetails wo
    join import_data.mysql_store  ms on wo.shopcode=ms.Code and ms.department regexp '快'
    where PayTime >='${StartDay}' and PayTime<' ${NextStartDay}' and wo.IsDeleted=0 and FeeGross = 0 and OrderStatus <> '作废'
             and TransactionType = '付款'
             group by wo.shopcode ,wo.SellerSku
     ) t
