-- 产品范围：所有
-- 每个自然周 x 每个元素（包含未打元素标签） x 每个店铺 x 每个终审年月的各项指标
-- 时间参数 230703 -231002



with
prod as (
select wp.sku ,isnew
  ,case when ele_name_priority is null then '无元素标签' else ele_name_priority end 优先级元素
  ,left(DevelopLastAuditTime,7) 终审年月
from wt_products wp
left join dep_kbh_product_test vke on wp.SKU = vke.sku
where wp.ProjectTeam='快百货' and wp.IsDeleted=0 and ProductStatus !=2
)

-- ----------计算订单表现
,pre_t_orde_week_stat as (   -- 付款数据
select shopcode ,SellerSku ,sku  ,dim_date.week_num_in_year as pay_week
    ,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
    ,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
    ,round( sum(salecount ),2) SaleCount_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.sku = wo.Product_Sku
join dim_date on dim_date.full_date = date(wo.PayTime)
where
    PayTime >=  '${StartDay}'  and PayTime <  '${NextStartDay}'  -- 获取更久远的数据是为了包含到表主键的自然周
    and wo.IsDeleted=0
    and ms.Department = '快百货'
    and TransactionType = '付款' -- 未含付款类型为其他
    and OrderStatus <> '作废'
group by shopcode ,SellerSku ,sku  ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- 使用退款表
select  shopcode  ,sellersku  ,sku ,refund_week
    ,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from
( select distinct PlatOrderNumber , RefundUSDPrice ,dim_date.week_num_in_year as refund_week
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='已退款'  and ms.Department = '快百货'
join dim_date on dim_date.full_date = date(rf.RefundDate)
where  RefundDate >=  '${StartDay}'  and RefundDate <  '${NextStartDay}'
) t1
join (
select distinct PlatOrderNumber ,shopcode ,sellersku ,Product_Sku as sku
from wt_orderdetails wo
join prod on prod.sku = wo.Product_Sku -- 新品
where IsDeleted=0 and TransactionType='付款' and department = '快百货'
) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
group by  shopcode  ,sellersku  ,sku  ,refund_week
)
-- select * from pre_refund_t_orde_week_stat

,t_orde_week_stat as (
select   a.shopcode ,a.SellerSku ,a.sku  ,a.pay_week
    ,round( TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalGross_weekly
    ,round( TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalProfit_weekly
    ,TotalGross_weekly_refund
    ,SaleCount_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and a.SellerSku  = b.SellerSku
)
-- ----------计算广告表现

,t_ad as ( --
select  shopcode ,SellerSku ,asa.sku  ,dim_date.week_num_in_year as ad_stat_week
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily asa -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join ( select distinct wl.id ,wl.sku  from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '快百货'
    join prod on wl.sku =prod.sku
    ) wl on asa.ListingId = wl.id
    and  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}'-- 7月3日是按dim_date的28周，对应广告周表的27周
join dim_date on dim_date.full_date = date(asa.GenerateDate)
)

-- select * from t_ad ,

, t_ad_stat as (
select tmp.*
    , round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
    , round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
    , round(ad_TotalSale7Day/ad_Spend,2) as ROAS
    , round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
    ( select  shopcode  ,SellerSku ,sku ,ad_stat_week
        -- 曝光量
        , round(sum(Exposure)) as ad_sku_Exposure
        -- 广告花费
        , round(sum(Spend),2) as ad_Spend
        -- 广告销售额
        , round(sum(TotalSale7Day),2) as ad_TotalSale7Day
        -- 广告销量
        , round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
        -- 点击量
        , round(sum(Clicks)) as ad_sku_Clicks
        from t_ad  group by  shopcode ,SellerSku ,sku ,ad_stat_week
    ) tmp
)

,t0 as (
select t.* ,week_num_in_year ,week_begin_date  ,区域 ,销售小组 ,销售人员 ,终审年月 ,优先级元素 ,CompanyCode ,AccountCode ,isnew ,ShopStatus
from ( select shopcode ,SellerSku , sku from t_orde_week_stat
    union select shopcode ,SellerSku , sku from t_ad_stat   -- 去除没有出单或没有广告的行记录
    ) t
join ( select distinct week_num_in_year,week_begin_date  from dim_date
    where full_date >= '${StartDay}'  and full_date < '${NextStartDay}'
    ) dd
left join (select * , case when NodePathName regexp  '成都' then '成都' else '泉州' end as 区域 , NodePathName as 销售小组 ,SellUserName 销售人员
      from mysql_store where Department = '快百货') ms on t.shopcode = ms.code
left join prod on t.sku =prod.sku
)

,res as (
select
    t0.ShopStatus ,t0.shopcode ,t0.SellerSKU
    ,lst_pub_tag 链接刊登划分
    ,t0.sku ,终审年月 ,isnew 新老品 ,t0.优先级元素
     ,week_num_in_year as 自然周 ,week_begin_date as 当周一 ,t0.CompanyCode ,t0.AccountCode ,区域 ,销售小组 ,销售人员
    ,ifnull(SaleCount_weekly,0) `当周销量`
    ,ifnull(TotalGross_weekly,0) `当周销售额`
    ,ifnull(TotalProfit_weekly,0) 当周利润额_未扣ad
    ,round( ifnull(TotalProfit_weekly,0) / ifnull(TotalGross_weekly,0) ,4 ) 利润率_未扣ad
    ,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `当周利润额_扣ad`
    ,round( ( ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0) ) / ifnull(TotalGross_weekly,0) ,4 ) 利润率_扣ad
    ,ifnull(TotalGross_weekly_refund,0) `当周退款额`
    ,ad_sku_Exposure `当周广告曝光量`
    ,ifnull(ad_Spend,0) `当周广告花费`
    ,ad_TotalSale7Day `当周广告销售额`
    ,ad_sku_TotalSale7DayUnit `当周广告销量`
    ,ad_sku_Clicks `当周广告点击量`
    ,click_rate `当周广告点击率`
    ,adsale_rate `当周广告转化率`
    ,ROAS `当周ROAS`
    ,ACOS `当周ACOS`
    ,round(ad_Spend/ad_sku_Clicks,4) `当周CPC`
from t0
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.SellerSku = t_orde_week_stat.SellerSku
    and t0.week_num_in_year = t_orde_week_stat.pay_week
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.SellerSku = t_ad_stat.SellerSku
    and t0.week_num_in_year = t_ad_stat.ad_stat_week
left join view_kbh_lst_pub_tag vl on t0.SellerSku=vl.SellerSKU and t0.shopcode = vl.shopcode
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_weekly,0) >0  -- 去除没有出单或没有广告的行记录
order by t0.shopcode ,t0.SellerSKU ,t0.sku ,自然周
)

,res2 as (
select ShopStatus ,shopcode ,链接刊登划分,终审年月,新老品,优先级元素,自然周,当周一,CompanyCode,AccountCode,区域,销售小组,销售人员
    ,sum(当周销量) +0 当周销量
    ,sum(当周销售额) +0  当周销售额
    ,sum(当周利润额_未扣ad) +0 当周利润额_未扣ad
    ,sum(当周利润额_扣ad) +0  当周利润额_扣ad
    ,sum(当周退款额) +0 当周退款额
    ,sum(当周广告曝光量) +0 当周广告曝光量
    ,sum(当周广告花费) +0 当周广告花费
    ,sum(当周广告销售额) +0 当周广告销售额
    ,sum(当周广告销量) +0 当周广告销量
    ,sum(当周广告点击量) +0 当周广告点击量
from res
group by ShopStatus ,shopcode ,链接刊登划分,终审年月,新老品,优先级元素,自然周,当周一,CompanyCode,AccountCode,区域,销售小组,销售人员
)
select * from res2