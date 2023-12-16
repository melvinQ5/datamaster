
-- 分月x出单店铺x出单sku
-- StartDay =2023-07-01 EndDay=2023-10-01


select a.month 月份 ,a.shopcode ,a.sku ,a.BoxSku ,a.Product_Name
    ,salecount 销售SKU件数
    ,round(TotalGross,2) 结算销售额
    ,TotalProfit 结算利润额
    ,round(TotalProfit - ifnull(adspend,0),2) 结算利润额_扣广告
    ,RefundAmount 结算退款额
    ,round(adspend,2) 广告花费
    ,round(AdSales,2) 广告销售额
    ,ReturnQuantity 退货数量

from (
    select month(SettlementTime) month
        ,shopcode ,wo.BoxSku ,wo.Product_Sku as sku ,wo.Product_Name
        ,round( sum((TotalGross )/ExchangeUSD),2) as TotalGross
        ,round( sum((TotalProfit )/ExchangeUSD),2) as TotalProfit
        ,abs( round( sum((RefundAmount )/ExchangeUSD),2) ) as RefundAmount
        ,sum(SaleCount) salecount
    from import_data.wt_orderdetails wo
    join mysql_store ms on wo.shopcode=ms.Code and ms.Department REGEXP '木工汇'
    where SettlementTime >='${StartDay}' and SettlementTime<'${EndDay}' and wo.IsDeleted=0 and wo.TransactionType !='其他'
    group by month(SettlementTime) ,shopcode ,wo.BoxSku ,wo.Product_Sku ,wo.Product_Name
) a
left join (
    select month(GenerateDate) month ,ad.shopcode ,ad.SKU
         ,sum(AdSpend) adspend
         ,sum(AdSales) AdSales
    from import_data.wt_adserving_amazon_daily ad
    join mysql_store ms on ad.ShopCode=ms.Code and ms.Department REGEXP '木工汇'
    where ad.GenerateDate >='${StartDay}' and ad.GenerateDate<'${EndDay}'
    group by  month(GenerateDate)  ,ad.shopcode ,ad.SKU
) b on a.month = b.month and a.sku =b.sku and a.shopcode = b.ShopCode
left join (
select  month(ReturnDate)  month ,rg.shopcode ,wo.product_sku as SKU
    ,sum(ReturnQuantity) ReturnQuantity
from erp_amazon_amazon_return_goods rg
join mysql_store ws on rg.ShopCode = ws.Code and ws.Department='木工汇' and rg.IsDeleted=0
    and ReturnDate >='${StartDay}' and ReturnDate<'${EndDay}'
left join wt_orderdetails wo on rg.OrderId = wo.PlatOrderNumber and wo.IsDeleted = 0 and  rg.ShopCode =wo.shopcode and rg.MerchantSku =wo.SellerSku and rg.Asin =wo.Asin
group by  month(ReturnDate)  ,rg.shopcode ,wo.product_sku
) c on a.month = c.month and a.sku =c.sku and a.shopcode = c.ShopCode
order by a.month ,a.shopcode ,a.SKU
