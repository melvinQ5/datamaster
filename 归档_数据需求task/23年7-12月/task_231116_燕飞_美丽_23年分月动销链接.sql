-- 重复值情况：1 多个产品上了同链接导致的,  链接唯一值得改为店铺简码+渠道SKU+产品SKU ，2 join 多表时链接条件有null值
-- 动销链接

with
-- 美丽 店铺范围 ：历史+目前
-- full_store as ( select memo as Code  , case when c1 regexp  '成都' then '成都' else '泉州' end as dep2 from manual_table where handlename='美丽_快百货总账号_231116' )
-- 燕飞 店铺范围 ：目前
full_store as ( select  Code  , case when nodepathname regexp  '成都' then '成都' else '泉州' end as dep2 from mysql_store where department='快百货' )

,od as (
select TransactionType ,PayTime ,max_refunddate
    ,dep2 区域
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd
    ,round( TotalProfit/ExchangeUSD,2) TotalProfit_usd
    ,round( FeeGross/ExchangeUSD,2) FeeGross
    ,round( case when TransactionType = '其他' then TotalExpend/ExchangeUSD end ,2) shopfee
    ,round( abs(TotalExpend/ExchangeUSD) + abs(ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' then ifnull(AdvertisingCosts/ExchangeUSD,0) end),0))   ,2) Expend_usd_except_ad
    ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode
    ,case when TransactionType = '其他' then '店铺费用项' else  wo.SellerSku  end SellerSku
    ,wo.asin ,salecount
    ,year(SettlementTime) set_year
    ,month(SettlementTime) set_month
    ,BoxSku ,month(max_refunddate) re_month ,SettlementTime
from import_data.wt_orderdetails wo
join full_store fs on wo.shopcode=fs.Code
-- join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted=0  and SettlementTime  >='${StartDay}' and SettlementTime < '${NextStartDay}'
)


-- ----------计算订单表现
,od_stat as (
select shopcode ,SellerSku ,asin, ifnull(sku,0) sku ,set_year ,set_month
    ,round( sum( TotalGross_usd ),2 ) TotalGross_usd
    ,round( sum( TotalProfit_usd ),2 ) TotalProfit_usd
    ,round( sum( refundamount_usd ),2 ) refund
    ,round( sum(FeeGross ),2) feegross
    ,round( sum(shopfee ),2) shopfee
    ,sum( case when  TransactionType = '付款' then SaleCount end  ) SaleCount
    ,count(distinct case when  TransactionType = '付款' then PlatOrderNumber end ) orders
from od
group by shopcode ,SellerSku ,asin,sku ,set_year ,set_month
)


,od_ori_stat as ( -- 挂单利润率
select shopcode ,SellerSku ,asin,sku ,set_year ,set_month
    ,round( sum( TotalGross_usd ),2 ) 销售额_未扣退款
    ,round( sum( TotalProfit_usd ),2 ) 利润额_未扣退款
    ,round(sum(TotalGross_usd-FeeGross),2) 不含运费销售额
from od where TransactionType = '付款'
group by shopcode ,SellerSku ,asin,sku ,set_year ,set_month
)

-- ----------计算广告表现
,ad as (
select  waad.shopcode ,waad.SellerSku ,asin ,waad.sku ,left(waad.sku,7) spu
     ,year(GenerateDate) ad_year
     ,month(GenerateDate) ad_month
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , waad.AdClicks as Clicks  , waad.AdExposure as Exposure ,waad.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily waad -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join full_store fs on waad.shopcode=fs.code and  GenerateDate >=  '2023-07-01'  and GenerateDate <  '${NextStartDay}'
)

, ad_stat as (
select tmp.*
    , round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
    , round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
    , round(ad_TotalSale7Day/ad_Spend,2) as ROAS
    , round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
    ( select  shopcode  ,SellerSku  ,asin,sku ,ad_year ,ad_month
        -- 曝光量
        , round(sum(Exposure)) as ad_sku_Exposure
        -- 广告花费
        , round(sum(Spend),2) as ad_Spend
        -- 广告销售额
        , round(sum(TotalSale7Day),2) as ad_TotalSale7Day
        -- 广告销量
        , round(sum(TotalSale7DayUnit)) as ad_sku_TotalSale7DayUnit
        -- 点击量
        , round(sum(Clicks)) as ad_sku_Clicks
        from ad  group by  shopcode ,SellerSku ,asin ,sku ,ad_year ,ad_month
    ) tmp
)

,lst as ( -- 有出单 或有广告花费的链接
select distinct shopcode ,SellerSku  ,asin ,set_year ,set_month ,a.sku
     ,spu ,BoxSku ,DevelopLastAuditTime
from (
select    shopcode ,SellerSku ,asin  ,set_year ,set_month,sku  from od_stat
union select  shopcode ,SellerSku ,asin  ,ad_year ,ad_month,sku from ad_stat where ad_Spend > 0
) a
left join wt_products wp on a.sku = wp.sku and wp.ProjectTeam='快百货' and wp.IsDeleted=0
)


-- 结算利润率 14% ，预付是9%， 差在所有广告花费？，结算时间内的订单表的广告花费不是所有的吗？

,undel_lst as ( -- 未删除链接
select lst.shopcode ,lst.SellerSku ,lst.sku ,ListingStatus
from lst join erp_amazon_amazon_listing eaal on lst.shopcode=eaal.shopcode and lst.SellerSku=eaal.SellerSku and ListingStatus != 5 -- 亚马逊后台API单选状态1、3、4，IT处理延迟删除状态5
group by  lst.shopcode ,lst.SellerSku ,lst.sku ,ListingStatus
)


,merge as (
select
    lst.set_year 结算年份
    ,lst.set_month 结算月份
    ,case when NodePathName regexp '成都' then '成都' when NodePathName regexp '泉州' then '泉州' else '历史账号' end 区域
    ,ms.NodePathName `销售团队`
	,ms.SellUserName `首选业务员`
    ,right(lst.shopcode,2) `站点`
	,ms.AccountCode `账号`
     ,lst.shopcode 店铺简码
    ,ms.ShopStatus 店铺状态
    ,lst.SellerSku 渠道SKU
    ,lst.asin
    ,wl.`刊登年月`
    ,case when un.ListingStatus = 1 then '在线' else '不在线' end 链接状态
    ,case when un.shopcode is null then '已删除' else '未删除' end 链接是否删除
    ,ifnull(feegross,0) `运费收入`
    ,round(ifnull(TotalGross_usd,0),2) `结算销售额`
	,round(ifnull(TotalProfit_usd,0),2) `结算利润额_未扣ad`
	,case when lst.set_month >=7 then round(ifnull(TotalProfit_usd,0) - ifnull(ad_Spend,0),2)  else 0 end `结算利润额_7月起扣ad` -- 7月起有完整广告月表
    ,refund 退款金额
    ,case when lst.SellerSku = '店铺费用项' then '是' else '否'  end 是否结算店铺费用项
    ,shopfee 店铺费用
    ,销售额_未扣退款
    ,利润额_未扣退款
    ,round(利润额_未扣退款 /销售额_未扣退款 ,4)  挂单利润率
    ,ad_Spend `广告花费`
    ,ad_sku_Exposure `广告曝光量`
    ,ad_sku_Clicks `广告点击量`
    ,ad_TotalSale7Day   `广告销售额`
    ,ad_sku_TotalSale7DayUnit    `广告销量`
    ,lst.spu ,lst.sku ,lst.boxsku
    ,date(wp.DevelopLastAuditTime) 终审年月
    ,dkpt.ele_name_priority 优先级元素
    ,dkpt.cat1 一级类目
    ,case when dp.spu is not null then '是' else '否' end 是否标记过爆旺款
    ,SaleCount 销量
    ,orders 订单量
    ,不含运费销售额
    ,case when orders >= 30 then '达30+' end 月销达30单
    ,case when 不含运费销售额 >= 250 then '达SA' end 月不含运费业绩达250
    ,concat(lst.SellerSku,'_',lst.shopcode) 渠道sku_店铺
    ,concat(lst.asin,'_',right(lst.shopcode,2)) asin_站点
    ,wp.ProductStatusName 产品状态
    ,wp.ProductStopTime 产品停产时间
from lst
left join mysql_store ms on lst.shopcode=ms.code
left join od_stat t1 on lst.shopcode=t1.shopcode and lst.SellerSku=t1.SellerSku and lst.sku=t1.sku and lst.set_month=t1.set_month and lst.set_year=t1.set_year
left join od_ori_stat t3 on lst.shopcode=t3.shopcode and lst.SellerSku=t3.SellerSku and lst.sku=t3.sku and lst.set_month=t3.set_month and lst.set_year=t3.set_year
left join ad_stat t2 on lst.shopcode=t2.shopcode and lst.SellerSku=t2.SellerSku and lst.sku=t2.sku and lst.set_month=t2.ad_month and lst.set_year=t2.ad_year
left join ( select ShopCode ,sellersku , left(min(MinPublicationDate),7) 刊登年月  from wt_listing wl join mysql_store ms on ms.code = wl.ShopCode
   where  ms.Department='快百货' group by shopcode,SellerSku ) wl
    on lst.shopcode=wl.shopcode and lst.SellerSku=wl.SellerSku
left join undel_lst un on lst.shopcode=un.shopcode and lst.SellerSku=un.SellerSku and lst.sku=un.sku
left join (select spu from dep_kbh_product_level where  isdeleted = 0 and prod_level regexp '爆款|旺款' and FirstDay  >='${StartDay}' group by spu ) dp on lst.spu = dp.spu
left join dep_kbh_product_test dkpt on dkpt.sku =lst.sku
left join wt_products wp on lst.sku = wp.sku and wp.IsDeleted=0 and wp.ProjectTeam='快百货'
)





,res as (
select
    结算年份 ,结算月份 ,区域 ,销售团队 ,首选业务员 ,站点 ,账号 ,店铺简码 ,店铺状态 ,渠道SKU ,asin ,刊登年月 ,链接状态 ,链接是否删除
    ,运费收入 ,结算销售额 ,结算利润额_未扣ad ,结算利润额_7月起扣ad ,退款金额 ,是否结算店铺费用项 ,店铺费用 ,销售额_未扣退款 ,利润额_未扣退款
    ,挂单利润率 ,广告花费 ,广告曝光量 ,广告点击量 ,广告销售额 ,广告销量 ,spu ,sku ,boxsku ,终审年月 ,优先级元素 ,一级类目 ,是否标记过爆旺款
    ,销量 ,订单量
     ,不含运费销售额 ,月销达30单 ,月不含运费业绩达250
     -- ,渠道sku_店铺 ,asin_站点
     ,产品状态 ,产品停产时间
from merge
group by 结算年份 ,结算月份 ,区域 ,销售团队 ,首选业务员 ,站点 ,账号 ,店铺简码 ,店铺状态 ,渠道SKU ,asin ,刊登年月 ,链接状态 ,链接是否删除
    ,运费收入 ,结算销售额 ,结算利润额_未扣ad ,结算利润额_7月起扣ad ,退款金额 ,是否结算店铺费用项 ,店铺费用 ,销售额_未扣退款 ,利润额_未扣退款
    ,挂单利润率 ,广告花费 ,广告曝光量 ,广告点击量 ,广告销售额 ,广告销量 ,spu ,sku ,boxsku ,终审年月 ,优先级元素 ,一级类目 ,是否标记过爆旺款
    ,销量 ,订单量
       ,不含运费销售额 ,月销达30单 ,月不含运费业绩达250
       -- ,渠道sku_店铺 ,asin_站点
       ,产品状态 ,产品停产时间
)


-- 燕飞
select * from res where 店铺简码 = 'TR-US' and 渠道SKU ='04PY566526F8UWYS4';
-- select 结算年份 ,结算月份,渠道SKU ,asin ,店铺简码,sku  from res group by 结算年份 ,结算月份,渠道SKU ,asin ,店铺简码,sku having  count(*) >1
-- 美丽
-- select * from res where 订单量 >= 5;


-- 美丽 不限制订单量5单的统计
select 结算年份,结算月份
    ,round( sum(结算销售额 ),2)  结算销售额
    ,round( sum(结算利润额_未扣ad ) ,2) 结算利润额_未扣ad
    ,round( sum(结算利润额_未扣ad ) / sum(结算销售额 )  ,4) 利润率
    ,sum(订单量 ) 订单量
    ,sum(销量 ) 销量
    ,count(distinct 渠道sku_店铺) 出单链接数

    ,round( sum(case when 月销达30单 ='达30+' then 结算销售额 end ),2) 达30_结算销售额
    ,round( sum(case when 月销达30单 ='达30+' then 结算利润额_未扣ad end ),2) 达30_结算利润额_未扣ad
    ,sum(case when 月销达30单 ='达30+' then 订单量 end ) 达30_订单量
    ,count(distinct case when 月销达30单 ='达30+' then 渠道sku_店铺 end ) 达30_出单链接数

    ,round( sum(case when 月不含运费业绩达250 ='达SA' then 结算销售额 end ),2) 达SA_结算销售额
    ,round( sum(case when 月不含运费业绩达250 ='达SA' then 结算利润额_未扣ad end ),2) 达SA_结算利润额_未扣ad
    , sum(case when 月不含运费业绩达250 ='达SA' then 订单量 end ) 达SA_订单量
    ,count(distinct case when 月不含运费业绩达250 ='达SA' then 渠道sku_店铺 end ) 达SA_出单链接数
from res
group by 结算年份,结算月份
order by 结算年份,结算月份
