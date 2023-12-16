-- 滚动N周写法
-- date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*14 DAY)
-- 本表从10月开始计算 分周数据

with
lst as ( -- 10月起链接
select ShopCode ,spu ,SellerSKU ,asin ,MinPublicationDate ,dim_date.week_num_in_year as lst_week
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '快百货' and IsDeleted=0
join dim_date on dim_date.full_date= date(MinPublicationDate)
where MinPublicationDate >= '2023-10-01' and MinPublicationDate < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
group by ShopCode ,spu ,SellerSKU ,asin  ,MinPublicationDate ,dim_date.week_num_in_year
)

,lst_week_stat as (
select ShopCode ,lst_week ,count(distinct concat(ShopCode,SellerSKU) ) 当周刊登链接数 from lst group by ShopCode ,lst_week )

,lst_stat as (
select ShopCode  ,count(distinct concat(ShopCode,SellerSKU) ) 10月起刊登链接数  ,count(distinct spu ) 10月起刊登SPU数
from lst where MinPublicationDate >= '2023-10-01' group by ShopCode ) -- 10月起累计，所以从1号开始

-- ----------计算订单表现
,pre_t_orde_week_stat as (   -- 付款数据
select wo.shopcode ,dim_date.week_num_in_year as pay_week
    ,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
    ,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
    ,sum(salecount ) SaleCount_weekly
    ,count(distinct Product_SPU ) od_spu_weekly
    ,count(distinct concat(wo.shopcode,wo.SellerSku) ) od_lst_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join lst on wo.shopcode =lst.shopcode and wo.sellersku = lst.sellersku -- 10月后刊登链接
join dim_date on dim_date.full_date  = date(wo.PayTime)
    and PayTime >= '2023-10-02' and PayTime < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
    and wo.IsDeleted=0
    and ms.Department = '快百货'
    and TransactionType = '付款'
    and OrderStatus <> '作废'
group by wo.shopcode ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- 使用退款表
select ms.Code as shopcode  ,dim_date.week_num_in_year as refund_week
    ,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='已退款'  and ms.Department = '快百货'
join (select OrderNumber from import_data.wt_orderdetails wo  join lst on wo.shopcode =lst.shopcode and wo.sellersku = lst.sellersku and wo.IsDeleted =0
    group by OrderNumber
    ) lst_od on rf.OrderNumber = lst_od.OrderNumber  -- 10月后刊登链接
join dim_date on dim_date.full_date  = date(rf.RefundDate)
where  RefundDate >= '2023-10-02' and RefundDate < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
group by  ms.Code    ,refund_week
)
-- select * from pre_refund_t_orde_week_stat

,t_orde_week_stat as (
select   a.shopcode ,a.pay_week
    ,round( TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalGross_weekly
    ,round( TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalProfit_weekly
    ,TotalGross_weekly_refund
    ,SaleCount_weekly
    ,od_spu_weekly
    ,od_lst_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and a.pay_week  = b.refund_week
)

-- ----------计算广告表现
,t_ad as (
select  waad.shopcode ,waad.SellerSku ,waad.sku  ,dim_date.week_num_in_year as ad_stat_week
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , waad.AdClicks as Clicks  , waad.AdExposure as Exposure ,waad.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily waad -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join import_data.mysql_store ms on waad.shopcode=ms.Code and Department = '快百货'
    and GenerateDate >= '2023-10-02' and GenerateDate < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
join dim_date on dim_date.full_date= date(GenerateDate)
join lst on waad.shopcode =lst.shopcode and waad.sellersku = lst.sellersku -- 10月后刊登链接
)
-- select * from t_ad

, t_ad_stat as (
select tmp.*
    , round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
    , round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
    , round(ad_TotalSale7Day/ad_Spend,2) as ROAS
    , round(ad_Spend/ad_TotalSale7Day,2) as ACOS
    ,round(ad_Spend/ad_sku_Clicks,4) `CPC`
from
    ( select  shopcode  ,ad_stat_week
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
        from t_ad  group by  shopcode ,ad_stat_week
    ) tmp
)


,vist as (  -- todo lm表取最小访客数那条记录 lst取最后刊登
select lm.ShopCode , round(TotalCount*FeaturedOfferPercent/100,0) `访客数` ,OrderedCount `访客销量` ,week_num_in_year
from import_data.ListingManage lm
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,* from import_data.mysql_store )  ms
    on lm.shopcode=ms.Code  and ms.Department='快百货' and ReportType= '周报'
join dim_date dd  on dd.full_date=lm.Monday
join lst on lm.shopcode =lst.shopcode and lm.ChildAsin = lst.asin -- 10月后刊登链接
)

-- 1个asin 只能对应1个SKU  , select asin ,site from  view_kbh_lst_pub_tag group by asin ,site  having count(distinct sku ) >1

,vist_stat as (
select ShopCode ,week_num_in_year as lm_week
    ,sum( 访客数 ) 访客数
    ,round ( sum( 访客销量 ) / sum( 访客数 ) ,4 ) 访客转化率
from vist
group by ShopCode,week_num_in_year
)

,t0 as (
select  week_num_in_year  自然周 ,week_begin_date 当期第一天 ,code as shopcode ,ShopStatus 店铺状态 ,CompanyCode ,AccountCode ,site
    , case when NodePathName regexp  '成都' then '成都' else '泉州' end as 区域 , NodePathName as 销售小组 ,SellUserName 销售人员
from mysql_store
join ( select distinct week_num_in_year,week_begin_date from dim_date
    where full_date >= '2023-10-02' and full_date < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
    ) dd
where Department = '快百货' and CompanyCode regexp 'B26|B205|B204|MM|MH'
-- 一标一店范围 B26,B205,B204,MM,MH
)

select t0.*
,10月起刊登SPU数
,10月起刊登链接数
,od_spu_weekly 当周动销SPU数
,od_lst_weekly 当周动销链接数
,当周刊登链接数

,salecount_weekly `当周销量`
,round( ifnull(TotalGross_weekly,0) ,2 )`当周销售额`
,round( ifnull(TotalProfit_weekly,0) ,2) `当周利润额_未扣ad`
,round(  (ifnull(TotalProfit_weekly,0) ) / ifnull(TotalGross_weekly,0)  ,4) `当周利润率_未扣ad`
,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `当周利润额_扣ad`
,round(  (ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0)) / ifnull(TotalGross_weekly,0)  ,4) `当周利润率_扣ad`
,ifnull(TotalGross_weekly_refund,0) `当周退款额`

,访客数
,访客转化率
,round(ifnull(访客数,0) - ifnull(ad_sku_Clicks,0)) `自然访客数（减法）`

,ifnull(ad_Spend,0) `当周广告花费`
,ad_sku_Exposure `当周广告曝光量`
,ad_TotalSale7Day `当周广告销售额`
,ad_sku_TotalSale7DayUnit `当周广告销量`
,ad_sku_Clicks `当周广告点击量`
,click_rate `当周广告点击率`
,adsale_rate `当周广告转化率`
,ROAS `当周ROAS`
,ACOS `当周ACOS`
,CPC `当周CPC`


from t0
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.自然周 = t_orde_week_stat.pay_week
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.自然周 = t_ad_stat.ad_stat_week
left join lst_week_stat  on t0.ShopCode = lst_week_stat.ShopCode and t0.自然周 = lst_week_stat.lst_week
left join vist_stat  on t0.ShopCode = vist_stat.ShopCode and t0.自然周 = vist_stat.lm_week
left join lst_stat  on t0.ShopCode = lst_stat.ShopCode
order by t0.shopcode  ,自然周 desc

