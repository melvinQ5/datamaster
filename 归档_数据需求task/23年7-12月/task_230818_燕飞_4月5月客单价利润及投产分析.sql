

with
od_pay as ( -- 付款数据
select Product_SPU as spu ,left(PayTime,7) pay_month
    ,count(distinct PlatOrderNumber) orders -- 订单数
    ,count(distinct case when FeeGross = 0 then PlatOrderNumber end ) orders_minusFreight -- 剔除运费单的订单数
    ,round(sum(totalgross/wo.ExchangeUSD),2) pay_sales
    ,round(sum(totalprofit/wo.ExchangeUSD),2) pay_profit
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) pay_sales_minusFreight
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2)  pay_profit_minusFreight
    ,round(sum(feegross/wo.ExchangeUSD),2) feegross
from import_data.wt_orderdetails wo join mysql_store ms on wo.shopcode=ms.Code
and PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and ms.department regexp '快'
and wo.IsDeleted = 0 and TransactionType = '付款'  and wo.asin <>'' and wo.boxsku<>''
group by wo.Product_SPU ,left(PayTime,7)
)

,od_refund as ( -- 退款数据
select  Product_SPU as spu ,left(SettlementTime,7) refund_month
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refund
from wt_orderdetails wo join mysql_store  ms on ms.code=wo.shopcode
and SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}' and ms.department regexp '快'
and wo.IsDeleted = 0 and TransactionType = '退款'  and wo.asin <>''  and wo.boxsku<>''
group by  wo.Product_SPU ,left(SettlementTime,7)
)

, lst_ad_spend as ( -- 单独按SKU聚合计算广告费，不止计算出单链接的广告花费，需要计算所有链接的广告花费
select SPU , left(GenerateDate,7) ad_month
    , round(sum(AdExposure)) as ad_Exposure
    , round(sum(AdClicks)) as ad_Clicks
    , round(sum(AdSpend),2) as ad_Spend
    , round(sum(AdSales),2) as ad_TotalSale7Day
    , round(sum(AdSaleUnits),2) as ad_TotalSale7DayUnit
	, round(sum(AdClicks)/sum(AdExposure),4) as ctr
	, round(sum(AdSaleUnits)/sum(AdClicks),4) as cvr
	, round(sum(AdSpend)/sum(AdClicks),4) as cpc
	, round(sum(AdSales)/sum(AdSpend),4) as roas
	, round(sum(AdSpend)/sum(AdSales),4) as acost
from (select sellersku ,shopcode ,od.SPU -- 出单产品的所有链接
    from ( -- 出单产品
    select product_spu as spu
    from import_data.wt_orderdetails wo join mysql_store ms on wo.shopcode=ms.Code
        and PayTime >= '${StartDay}' and PayTime <'${NextStartDay}' and ms.department regexp '快'
        and wo.IsDeleted = 0 and TransactionType = '付款'  and wo.asin <>'' and wo.boxsku<>'' group by product_spu
    ) od
    join wt_listing wl on od.spu = wl.spu
    join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
        from import_data.mysql_store where department regexp '快') ms on wl.shopcode=ms.Code
    group by  sellersku ,shopcode ,od.spu
    ) wl
-- join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
join import_data.wt_adserving_amazon_daily ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
where GenerateDate >= '${StartDay}' and GenerateDate<  '${NextStartDay}'
group by SPU , left(GenerateDate,7)
)

, prod as (
select distinct  spu ,DevelopLastAuditTime
from erp_product_products where IsMatrix = 1 and IsDeleted=0 and ProjectTeam = '快百货'
)

-- , res as (
select
    pay_month as 月份
    ,t1.SPU
    ,date(DevelopLastAuditTime) as 开发终审时间
    ,orders as 订单数
    ,orders_minusFreight as 订单数_剔运费单
    ,pay_sales as 付款销售额
    ,pay_sales_minusFreight as 付款销售额_扣运费
    ,round( pay_sales_minusFreight / orders ,2) 客单价
    ,pay_profit as 利润额_未扣广告
    ,round(pay_profit/pay_sales,2) as 利润率_未扣广告
    ,pay_profit_minusFreight  as 利润额_未扣广告扣运费
    ,round(pay_profit_minusFreight/pay_sales_minusFreight,2) as 利润率_未扣广告扣运费
    ,refund as 退款额
    ,feegross as 运费收入
    ,pay_profit - ifnull(ad_Spend,0) as 利润额_扣广告
    ,round( (pay_profit - ifnull(ad_Spend,0)) / pay_sales ,2) 利润率_扣广告
    ,ad_Exposure as 曝光量
    ,ad_Clicks as 点击量
    ,ad_Spend as 广告花费
    ,ad_TotalSale7DayUnit as 广告销量
    ,ad_TotalSale7Day as 广告业绩
    ,ctr
    ,cvr
    ,cpc
    ,acost
    ,roas
    ,round(ad_TotalSale7Day / ( pay_sales - ifnull(refund,0) ),2) as 广告业绩占比
from od_pay t1
left join od_refund t2 on t1.spu = t2.spu and t1.pay_month = t2.refund_month
left join lst_ad_spend t3 on t1.spu = t3.spu and t1.pay_month = t3.ad_month
left join prod t4 on t1.spu =t4.spu
where t1.spu is not null
order by pay_month ,spu


-- select 月份, sum(利润额_未扣广告)  , sum(利润额_扣广告) ,sum(利润额_未扣广告-利润额_扣广告),sum(广告花费) from res group by 月份
-- select * from res;