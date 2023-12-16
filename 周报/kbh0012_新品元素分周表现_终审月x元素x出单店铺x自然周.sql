-- 产品范围：所有新品
-- 每个自然周 x 每个元素（包含未打元素标签） x 每个店铺 x 每个终审年月的各项指标
-- 时间参数 230703 -231002

with
prod as (
select vknp.sku
  ,case when ele_name_priority is null then '无元素标签' else ele_name_priority end ele_name
  ,left(DevelopLastAuditTime,7) dev_month
from view_kbp_new_products  vknp
left join view_kbh_element vke on vknp.SKU = vke.sku
left join wt_products p on vknp.sku = p.sku and p.ProjectTeam='快百货'
)

-- ----------计算订单表现
,pre_t_orde_week_stat as (   -- 付款数据
select ele_name , shopcode ,dev_month  ,dim_date.week_num_in_year as pay_week
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
group by ele_name , shopcode ,dev_month    ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- 使用退款表
select ele_name , shopcode  ,dev_month ,refund_week
	,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from
( select distinct PlatOrderNumber,OrderSource as shopcode , RefundUSDPrice ,dim_date.week_num_in_year as refund_week
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='已退款'  and ms.Department = '快百货'
join dim_date on dim_date.full_date = date(rf.RefundDate)
where  RefundDate >=  '${StartDay}'  and RefundDate <  '${NextStartDay}'
) t1
join (
select PlatOrderNumber , ele_name ,dev_month
from wt_orderdetails wo
join prod on prod.sku = wo.Product_Sku -- 新品
where IsDeleted=0 and TransactionType='付款' and department = '快百货' group by PlatOrderNumber , ele_name ,dev_month
) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
group by ele_name , shopcode  ,dev_month ,refund_week
)
-- select * from pre_refund_t_orde_week_stat ,

,t_orde_week_stat as (
select  a.ele_name , a.shopcode  ,a.dev_month  ,a.pay_week
    ,TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) as TotalGross_weekly
    ,TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) as TotalProfit_weekly
    ,TotalGross_weekly_refund 
    ,SaleCount_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and  a.ele_name = b.ele_name and a.pay_week = b.refund_week and a.dev_month = b.dev_month
)
-- ----------计算广告表现

,t_ad as ( --
select ele_name , shopcode  ,dev_month  ,dim_date.week_num_in_year as ad_stat_week
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily asa -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join ( select distinct wl.id ,wl.sku ,ele_name ,dev_month from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '快百货'
    join prod on wl.sku =prod.sku  -- 新品
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
	( select  ele_name , shopcode  ,dev_month ,ad_stat_week
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
		from t_ad  group by ele_name , shopcode  ,dev_month ,ad_stat_week
	) tmp
)

,t0 as (
select prod.* ,week_num_in_year ,week_begin_date  ,ms.*
from (select distinct  ele_name ,dev_month 终审年月 from prod ) prod
join ( select distinct week_num_in_year,week_begin_date  from dim_date
    where full_date >= '${StartDay}'  and full_date < '${NextStartDay}'
    ) dd
join (select distinct code as shopcode ,CompanyCode , AccountCode
    , case when NodePathName regexp  '成都' then '成都' else '泉州' end as 区域
    , NodePathName as 销售小组 ,SellUserName 销售人员
      from mysql_store where Department = '快百货') ms
)


select
    t0.ele_name 优先级元素
    ,终审年月 ,week_num_in_year as 自然周 ,week_begin_date as 当周一 ,t0.shopcode ,t0.CompanyCode ,t0.AccountCode ,区域 ,销售小组 ,销售人员
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
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.ele_name = t_orde_week_stat.ele_name
	and t0.week_num_in_year = t_orde_week_stat.pay_week and t0.终审年月 = t_orde_week_stat.dev_month
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.ele_name = t_ad_stat.ele_name
	and t0.week_num_in_year = t_ad_stat.ad_stat_week and t0.终审年月 = t_ad_stat.dev_month
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_weekly,0) >0  -- 去除没有出单或没有广告的行记录


