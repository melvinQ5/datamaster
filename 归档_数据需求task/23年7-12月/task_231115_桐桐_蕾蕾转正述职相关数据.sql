-- 2023年1-9月，每月特卖汇和快百货平均客单价是多少啊？
with
od as (
select TransactionType ,PayTime
    ,dep2
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd_pay
    ,round( FeeGross/ExchangeUSD,2) FeeGross_usd_pay
    ,round( TotalProfit/ExchangeUSD ,2) TotalProfit_usd_pay
    ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,FeeGross ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode ,wo.SellerSku ,wo.asin ,salecount
    ,month(PayTime) pay_month
    ,month(settlementtime) set_month
    ,year(settlementtime) set_year
     ,ms.Department
,BoxSku
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
where wo.IsDeleted=0  and ms.Department regexp '快百货|特卖汇' and settlementtime  >='${StartDay}' and settlementtime < '${NextStartDay}'
)
,od_stat as (
select  wp.spu ,set_year,set_month
    ,ROUND(sum(TotalGross_usd_pay),4) 结算销售额S3
    ,ROUND(sum(TotalProfit_usd_pay),4) 结算利润额M3
    ,ROUND(sum(refundamount_usd),4) 退款额
    ,ROUND(sum(FeeGross_usd_pay),4) 运费收入
    ,ROUND(sum(SaleCount)) 销量
    ,count( distinct  PlatOrderNumber) 订单量
    ,count( distinct  date(PayTime)) 出单天数
    ,round( count( distinct  PlatOrderNumber) / count( distinct  date(PayTime)),2 ) 日均单数
    ,round( sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross_usd_pay end ) ,4) 挂单销售额
    ,round( sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit_usd_pay end ) /
        sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then  TotalGross_usd_pay end ) ,4) 挂单利润率
from od
join wt_products wp on od.BoxSku =wp.BoxSku and wp.IsDeleted=0 and wp.ProjectTeam = '快百货'
group by wp.spu ,set_year ,set_month
ORDER BY wp.spu ,set_year ,set_month )

,onlinelst as (select spu ,count(distinct concat(sellersku,shopcode)) 在线链接数 , min(MinPublicationDate) 首次刊登时间 from wt_listing wl join mysql_store ms on ms.Code=wl.ShopCode and ms.Department = '快百货' and ms.ShopStatus = '正常' and wl.ListingStatus= 1 group by spu )
,ware as ( select spu
,sum(TotalInventory) 当前库存数
,sum(TotalPrice) 当前库存金额
,sum(InventoryAge45) 0至45天库龄数
,sum(InventoryAge90) 46至90天库龄数
,sum(InventoryAge180) 91至180天库龄数
,sum(InventoryAge270) 181至270天库龄数
,sum(InventoryAge365) 271至365天库龄数
,sum(InventoryAgeOver) 大于365天库龄数
from daily_WarehouseInventory dw join wt_products wp on dw.BoxSku=wp.BoxSku and wp.ProjectTeam='快百货' and wp.IsDeleted = 0 where CreatedTime = '2023-11-24' group by spu )

select t1.*
,在线链接数
,首次刊登时间
,ProductName 产品名称
,CategoryPathByChineseName 全类目
,Logistics_Attr 物流属性
,TortType  侵权类型

,当前库存数
, 当前库存金额
, 0至45天库龄数
,46至90天库龄数
, 91至180天库龄数
,181至270天库龄数
, 271至365天库龄数
,大于365天库龄数
from od_stat t1
left join erp_product_products epp on t1.spu = epp.spu and epp.IsDeleted=0 and epp.IsMatrix=1 and epp.ProjectTeam='快百货'
left join (select distinct  spu ,CategoryPathByChineseName,Logistics_Attr,TortType from wt_products where ProjectTeam='快百货' and IsDeleted=0 ) wp on t1.spu=wp.spu
left join onlinelst o on t1.spu = o.SPU
left join ware  on t1.spu = ware.SPU