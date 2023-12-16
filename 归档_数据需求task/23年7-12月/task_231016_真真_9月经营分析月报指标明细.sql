-- 出单SKU 按SQL

with od as (
select ms.Department ,wo.SettlementTime ,wo.TotalProfit ,wo.TotalGross ,wo.ExchangeUSD ,spu as product_spu ,sku as product_sku ,wo.PlatOrderNumber ,wo.SellerSku ,wo.ShopIrobotId as shopcode
     ,wo.asin ,wo.OrderCountry as site ,wo.PurchaseCosts ,wo.TradeCommissions ,wo.AdvertisingCosts ,LocalFreight ,OverseasDeliveryFee , HeadFreight , FBAFee ,RefundAmount
from ods_orderdetails wo
join mysql_store ms on wo.ShopIrobotId  = ms.Code
    and ms.Department regexp '商厨汇'
    and IsDeleted = 0  and SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}'
left join (select distinct  boxsku ,sku ,spu from  wt_products ) wp on wo.BoxSku = wp.BoxSku
)

select distinct product_spu ,product_sku from od order by product_spu ,product_sku


-- SKU总数量 按共享盘