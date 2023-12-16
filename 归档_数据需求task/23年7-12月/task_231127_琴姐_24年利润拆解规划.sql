with
prod as (
select wp.spu ,wp.sku ,wp.boxsku,case when DevelopLastAuditTime >= '2023-01-01' then '年度新品' else '年度老品' end 年度新老品
from wt_products wp
left join dep_kbh_product_test dk on wp.sku =dk.sku
left join JinqinSku js on wp.spu = js.spu and monday='2023-11-27'
where  wp.projectteam = '快百货' and wp.isdeleted = 0
    and js.spu is null  -- 排除汰换清单（不计入统计的汰换SPU)
    and ele_name_group not regexp '冬季|夏季|复活|开斋|圣帕特里克节|圣诞|万圣|感恩' -- 排除指定主题品，其余视为非主题品
)

,od_pay as (   -- 销售额不含退款数据，利润额不含退款不含广告
select wo.shopcode ,wo.SellerSku  ,ifnull(wo.Product_Sku,0) as sku   ,年度新老品
    ,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
    , sum(salecount ) salecount
from import_data.wt_orderdetails wo
join mysql_store  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join prod on wo.Product_Sku = prod.sku
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by wo.shopcode ,wo.SellerSku ,wo.Product_Sku ,年度新老品
)

,od_refund as ( -- 销售额对应退款额，利润额对应退款额
select shopcode ,SellerSku ,ifnull(wo.Product_Sku,0) as sku
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join mysql_store  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join prod on wo.Product_Sku = prod.sku
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款'
group by shopcode ,SellerSku  ,wo.Product_Sku
)

,od_deduct_refund as ( -- 扣退款
select  shopcode  ,sellersku  ,sku
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku   ,sku  , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku  ,sku , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku  ,sku
)

,od_lst_stat as( -- 链接销售统计
select prod.年度新老品 ,a.shopcode ,a.SellerSku ,prod.spu ,a.sku ,round(sales,2) sales ,round(profit,2) profit ,sales_refund,salecount
from od_deduct_refund a left join od_pay b on a.SellerSku =b.SellerSku and a.shopcode =b.shopcode and a.sku =b.sku
left join prod on a.sku =prod.sku
)

,ad_sku_map as ( -- 广告周表匹配链接SKU
select wl.shopcode,wl.sellersku ,wl.asin ,wl.sku,wl.spu
from wt_listing wl
join prod on wl.sku = prod.sku
join wt_adserving_amazon_weekly aa on wl.ShopCode = aa.ShopCode and wl.SellerSKU = aa.SellerSKU and wl.Asin = aa.Asin
group by wl.shopcode,wl.sellersku  ,wl.asin  ,wl.sku,wl.spu
)
--    select * from ad_sku_map


,ad as (
select  waad.shopcode ,waad.SellerSku ,t.sku
     ,AdSales  , AdSaleUnits
    , waad.AdClicks   , waad.AdExposure  ,waad.AdSpend
from wt_adserving_amazon_weekly waad -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '快百货' and Year=2023  and week <= 45 -- 45周是 1030-1105 会多5天广告数据
left join ad_sku_map t on waad.ShopCode=t.ShopCode and waad.SellerSku =t.SellerSKU and waad.Asin = t.asin
)

, ad_stat as (
select  shopcode  ,SellerSku,sku
        -- 曝光量
        , round(sum(AdExposure)) as AdExposure
        -- 广告花费
        , round(sum(AdSpend),2) as AdSpend
        -- 广告销售额
        , round(sum(AdSales),2) as AdSales
        -- 广告销量
        , round(sum(AdSaleUnits),2) as AdSaleUnits
        -- 点击量
        , round(sum(AdClicks)) as AdClicks
        from ad  group by  shopcode ,SellerSku,sku
)

,od_stat as (
select 年度新老品
,round( sum(profit - AdSpend) ,2) 利润额M3
, count(distinct spu) 出单SPU数
,round( sum(salecount) /  count(distinct spu) ,0) 单品销量
,round( sum(sales) /  sum(salecount) ,2) 件单价
,round( sum(profit - AdSpend) /  sum(sales) ,4) 利润率R3
,round( sum(AdSpend) ,2) 广告花费
,round( sum(sales) ,2) 销售额S3
,round( sum(AdExposure) /  count(distinct spu) ,0) 单品曝光量
,round( sum(AdSaleUnits) /  count(distinct spu) ,0) 广告单品销量
,round( sum(AdClicks) /   sum(AdExposure) ,6) CTR
,round( sum(AdSaleUnits) /   sum(AdClicks) ,6) CVR
,round( sum(AdSpend) /   sum(AdClicks) ,4) CPC
from od_lst_stat t1 left join ad_stat t2 on t1.shopcode=t2.ShopCode and t1.SellerSku=t2.SellerSku and t1.sku=t2.sku
group by 年度新老品)

,prod_stat as ( select 年度新老品 , count(distinct spu) SPU数  from prod group by 年度新老品 )

select
t1.年度新老品
,利润额M3
,spu数
,round( 出单SPU数 /  SPU数 ,0) SPU动销率
,单品销量
,件单价
,利润率R3
,出单SPU数
,销售额S3
,单品曝光量
,CTR
,CVR
,CPC
,广告单品销量
,单品销量 - 广告单品销量 as 自然单品销量
from od_stat t1 join prod_stat t2 on t1.年度新老品=t2.年度新老品