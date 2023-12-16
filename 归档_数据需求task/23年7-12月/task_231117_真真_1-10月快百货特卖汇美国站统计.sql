
with
od as (
select TransactionType ,PayTime
    ,dep2
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd_pay
    ,round( TotalProfit/ExchangeUSD ,2) TotalProfit_usd_pay
    ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,FeeGross ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode ,wo.SellerSku ,wo.asin ,salecount
    ,month(PayTime) pay_month
    ,month(settlementtime) set_month
     ,ms.Department ,ms.code ,ms.accountcode
,BoxSku
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
where wo.IsDeleted=0  and ms.Department regexp '快百货|特卖汇' and settlementtime  >='${StartDay}' and settlementtime < '${NextStartDay}' and ms.site ='US'
)

select  Department 部门 ,code 店铺简码
    ,ROUND(sum(TotalGross_usd_pay)) 结算销售额usd
    ,ROUND(sum(TotalProfit_usd_pay)) 结算利润额usd
    ,round( sum(TotalProfit_usd_pay) / sum(TotalGross_usd_pay) ,4 ) 结算利润率
    ,count( distinct  PlatOrderNumber) 订单量
from od
group by Department ,code
ORDER BY Department ,结算销售额usd desc
