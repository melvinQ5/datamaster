
-- 新品定义
-- 上半年的新品的定义，每个月按照当月及前两个月终审的为新品，比如SKU0001终审时间是2月1日， 5月2日有一笔出单，则该笔订单不算新品销售额（统计5月时，新品为3、4、5三个月）
-- 下半年的新品定义，按7月1日之后终审都算新品
-- 时间统计 230101-231001

-- 使用结算时间
-- 新品14天动销率 、 新品刊登14天动销率两个指标数据源 直接获取每日生成的《新品N天开发动销率表》



with
wp as (select sku ,spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01'
    and ProjectTeam = '快百货' )

,od as (
select wo.*
    ,case
        when settlementtime < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( settlementtime,interval -day(settlementtime)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) >= 0  then '新品'
        when settlementtime < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( settlementtime,interval -day(settlementtime)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) < 0  then '老品'
        when DevelopLastAuditTime >= '2023-07-01' then '新品' end 新老品
    , timestampdiff(SECOND,DevelopLastAuditTime,settlementtime)/86400 as ord_days
    , timestampdiff(SECOND,PublicationDate,settlementtime)/86400 as ord_days_since_lst
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	from import_data.mysql_store where department regexp '快' )  ms
	on wo.shopcode=ms.Code
left join (select boxsku ,min(DevelopLastAuditTime) DevelopLastAuditTime from  wt_products where ProjectTeam='快百货' group by boxsku ) wp on wo.BoxSku = wp.BoxSku
where settlementtime >= '${StartDay}' and settlementtime <'${NextStartDay}' and wo.IsDeleted=0
)

,r1 as (  -- 新品统计
select  DATE_FORMAT(settlementtime,'%Y%m') 统计月份
    ,round(sum(TotalGross/ExchangeUSD),2) 新品销售额
    ,round(sum(TotalProfit/ExchangeUSD),2) 新品利润额
    ,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),4) 新品利润率_未扣广告
    ,count(distinct Product_SPU) 新品出单SPU数
    ,round(sum(TotalGross/ExchangeUSD)/count(distinct Product_SPU),4) 新品出单SPU单产
from od where 新老品 = '新品'
group by DATE_FORMAT(settlementtime,'%Y%m')
)

,tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
 	, epp.DevelopUserName
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime)as dev_week
from import_data.erp_product_products epp
where epp.IsDeleted = 0 and epp.IsMatrix = 0 AND epp.ProjectTeam ='快百货'
)

,tmp_lst as (
select DATE_FORMAT(MinPublicationDate,'%Y%m') pub_month ,MinPublicationDate
    ,ShopCode ,SellerSKU ,asin ,spu
    ,case
        when MinPublicationDate < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( MinPublicationDate,interval -day(MinPublicationDate)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) >= 0  then '新品'
        when MinPublicationDate < '2023-07-01' and timestampdiff( day, date_add( DATE_ADD( MinPublicationDate,interval -day(MinPublicationDate)+1 day) ,interval -2 month ) ,DevelopLastAuditTime) < 0  then '老品'
        when DevelopLastAuditTime >= '2023-07-01' then '新品' end 新老品
from wt_listing wl join mysql_store ms on wl.ShopCode = ms.Code and ms.Department='快百货'
left join (select sku ,min(DevelopLastAuditTime) DevelopLastAuditTime from  wt_products where ProjectTeam='快百货' group by sku ) wp on wl.sku = wp.sku
where MinPublicationDate  >= '${StartDay}'
)

-- 新品刊登14天动销率 = 首次刊登后14天内出单的SPU ÷ 首次刊登SPU
-- 当月新刊登平均链接数

,r2 as (
select a.* , round(ord14_sku_cnt_since_lst/dev_pub_cnt,4) as `新品刊登14天动销率`
from (
    select t.dev_month
            , count(distinct t.SPU) as dev_cnt
            , count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.Product_Sku end) as ord14_sku_cnt
            , round( count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.Product_Sku end) /  count(distinct t.SPU) ,4 ) 新品14天动销率
            , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then od.Product_Sku end) as ord14_sku_cnt_since_lst
    from tmp_epp t
    left join od on od.BoxSku =t.BoxSKU and od.新老品 = '新品' -- 对出单结算当月来说是新品
    group by t.dev_month ) a
left join ( select  pub_month ,count( distinct spu ) dev_pub_cnt from tmp_lst where 新老品='新品' group by pub_month ) b -- 新品刊登SPU数
    on a.dev_month = b.pub_month
)


,r3 as (  -- 新刊登统计
select a.pub_month
    ,新刊登销售额
    ,新刊登链接数
    ,round( 新刊登出单链接数/新刊登链接数 ,4) 新刊登链接动销率
    ,当月新刊登平均链接数
from (
    select  DATE_FORMAT(PublicationDate,'%Y%m') pub_month , DATE_FORMAT(settlementtime,'%Y%m') set_month
        ,round(sum( TotalGross/ExchangeUSD),2) 新刊登销售额
        ,count(distinct concat(SellerSku,shopcode)) 新刊登出单链接数
    from od
    group by DATE_FORMAT(PublicationDate,'%Y%m') , DATE_FORMAT(settlementtime,'%Y%m')
    ) a
left join (
    select pub_month
         ,count(distinct concat(SellerSku,shopcode)) 新刊登链接数
        ,round( count(distinct concat(SellerSku,shopcode)) /count(distinct spu ) ,4) 当月新刊登平均链接数
    from tmp_lst group by pub_month
    ) b on a.pub_month = b.pub_month
where a.pub_month=set_month -- 当月刊登且当月出单
)


,t_ad as (
select *,case when pre_ad_days < 0 then 0.1 else pre_ad_days end ad_days -- 存在广告时间早于首次刊登时间，故做此清洗
    ,DATE_FORMAT(GenerateDate,'%Y%m') ad_month
from (
select asa.ShopCode ,asa.Asin  ,asa.SellerSKU ,GenerateDate
    , AdExposure ,AdClicks ,AdSaleUnits
	, timestampdiff(SECOND,MinPublicationDate,asa.GenerateDate)/86400 as pre_ad_days -- 刊登后14天内
from tmp_lst t_list
join import_data.wt_adserving_amazon_daily asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU
where asa.GenerateDate >= '2023-07-01' and  asa.GenerateDate < '${NextStartDay}'
) t1
)



, r4 as (
select ad_month
    ,ad7_lst
    , round(ad7_sku_Exposure/ad7_lst,2) as `刊登7天平均曝光量`
    , round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `刊登14天广告点击率`
    , round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `刊登14天广告转化率`
from
	( select ad_month
	    -- 曝光链接数
	    , count( distinct case when 0 <= ad_days and ad_days <= 7 then concat(SellerSku,shopcode) end ) ad7_lst
		-- 曝光量
		, round(sum(case when 0 <= ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 <= ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_Exposure
		-- 广告销量
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end),2) as ad14_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_Clicks
		from t_ad  group by ad_month
	) tmp
)



-- 新品14天动销率 、 新品刊登14天动销率数据源 直接获取每日生成的《新品N天开发动销率表》
select
    r1.*
     -- ,新品14天动销率
     ,新刊登销售额 ,新刊登链接动销率
     -- ,新品刊登14天动销率
     ,当月新刊登平均链接数
    ,刊登7天平均曝光量
    ,round(r4.ad7_lst/新刊登链接数,4) 刊登7天曝光率
    ,刊登14天广告点击率 ,刊登14天广告转化率
from r1
left join r2 on r1.统计月份=r2.dev_month
left join r3 on r1.统计月份=r3.pub_month
left join r4 on r1.统计月份=r4.ad_month
order by r1.统计月份