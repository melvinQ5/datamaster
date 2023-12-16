
with
t0 as (  -- 主键 spu x 推送日期 -- 产品不分区域，订单广告分区域
select distinct spu ,PushDate ,StopPushDate ,PushSite 主推站点,PushRule 推送标准,PushUser 推送人 ,PushReason 推送理由
    ,case when '${NextStartDay}' > StopPushDate then '是' else '否' end 是否过季
from dep_kbh_product_level_potentail where PushDate >= '2023-10-01'  and isStopPush ='否'
)

,t_list as (  -- 主键 spu x 推送日期
select distinct wl.SPU ,wl.SKU ,MinPublicationDate ,wl.MarketType ,wl.SellerSKU ,wl.ShopCode ,wl.asin ,CompanyCode
    ,PushDate
    ,timestampdiff(second,PushDate,MinPublicationDate)/86400 as lst_days ,ListingStatus ,ShopStatus
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
    and ms.Department = '快百货' and NodePathName regexp '${team1}|${team2}'
     AND MinPublicationDate >= '${StartDay}' and MinPublicationDate < '${NextStartDay}' and IsDeleted=0
join t0 on wl.spu = t0.spu -- 一变多
)

,t_list_stat as ( -- 刊登统计
select SPU,PushDate
	,count(distinct case when lst_days > 0 and lst_days <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when lst_days > 0 and lst_days <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when lst_days > 0 and lst_days <=15 then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
	,count(distinct case when lst_days > 0 and lst_days <=30 then concat(SellerSKU,ShopCode) end ) list_cnt_in30d
	,count(distinct case when lst_days > 0 and lst_days <=60 then concat(SellerSKU,ShopCode) end ) list_cnt_in60d
	,count(distinct case when lst_days > 0 and lst_days <=90 then concat(SellerSKU,ShopCode) end ) list_cnt_in90d
	,count(distinct case when lst_days > 0 and lst_days <=30 then concat(CompanyCode) end ) list_comp_cnt_in30d
	,count(distinct case when lst_days > 0 and lst_days <=60 then concat(CompanyCode) end ) list_comp_cnt_in60d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct case when MarketType = 'CA' then concat(SellerSKU,ShopCode) end ) list_cnt_CA
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode) ) list_cnt
    ,count(distinct CompanyCode ) list_CompanyCode_cnt
	,min(MinPublicationDate) as min_pub_date
from t_list
where lst_days > 0
group by SPU,PushDate
)
-- select * from t_list_stat

,t_orde as (  -- 主键 spu x 推送日期
select
    Product_SPU as spu ,PushDate
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode , wo.asin ,FeeGross
	,ExchangeUSD,TransactionType, wo.SellerSku,RefundAmount
	,wo.Product_SPU as SKU ,PayTime
	,timestampdiff(SECOND,PushDate,PayTime)/86400 as ord_days
	,timestampdiff(SECOND,PushDate,PublicationDate)/86400 as lst_days  -- 计算推荐后新刊登链接销售额
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,ms.CompanyCode
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t0 on wo.Product_Spu  = t0.spu -- 一变多
where
	PayTime >= date_add('2023-10-01', interval -30 day)  -- 0703是首批推送日期，有一个指标需要计算推荐前30天，故使用0703往前推30天作为固定起始时间 ,不影响推荐后60、90天
    and PayTime < '${NextStartDay}' and wo.IsDeleted=0 and TransactionType='付款'
	and ms.Department = '快百货' and NodePathName regexp '${team1}|${team2}'
)


,t_orde_stat as (
select SPU,PushDate
	,round(sum( case when 0 < ord_days and ord_days <= 7 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_in30d
	,round(sum( case when 0 < ord_days and ord_days <= 30 and 0 < lst_days and lst_days <= 30  then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_new_list_in30d -- 推荐后新刊登出单
	,round(sum( case when 0 < ord_days and ord_days <= 60 and 0 < lst_days and lst_days <= 60  then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_new_list_in60d -- 推荐后新刊登出单
	,round(sum( case when 0 < ord_days and ord_days <= 90 and 0 < lst_days and lst_days <= 90  then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_new_list_in90d -- 推荐后新刊登出单

    ,round(sum( case when 0 < ord_days and  0 < lst_days and month(PayTime)=10 then (TotalGross)/ExchangeUSD end ),2) TotalGross_new_list_2310 -- 推荐后新刊登出单
    ,round(sum( case when 0 < ord_days and  0 < lst_days and month(PayTime)=11 then (TotalGross)/ExchangeUSD end ),2) TotalGross_new_list_2311 -- 推荐后新刊登出单
    ,round(sum( case when 0 < ord_days and  0 < lst_days and month(PayTime)=12 then (TotalGross)/ExchangeUSD end ),2) TotalGross_new_list_2312 -- 推荐后新刊登出单

     ,round(sum( case when -30 <= ord_days and ord_days < 0 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_bf30d

 	,count( distinct case when 0 < ord_days then CONCAT(SellerSku,shopcode) end ) od_list_total
 	,count( distinct case when 0 < ord_days and 0 < lst_days and lst_days <= 30 then CONCAT(SellerSku,shopcode) end ) od_new_list_in30d -- 推荐后新刊登出单
 	,count( distinct case when 0 < ord_days and 0 < lst_days and lst_days <= 60 then CONCAT(SellerSku,shopcode) end ) od_new_list_in60d -- 推荐后新刊登出单
 	,count( distinct case when 0 < ord_days and 0 < lst_days and lst_days <= 90 then CONCAT(SellerSku,shopcode) end ) od_new_list_in90d -- 推荐后新刊登出单
 	,count( distinct case when 0 < ord_days then companycode end ) od_companycode_total
 	,count( distinct case when 0 < ord_days then PlatOrderNumber end ) orders_total
	,round( sum( case when 0 < ord_days then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross
	,round( sum( case when 0 < ord_days then (TotalProfit-feegross)/ExchangeUSD end ),2) TotalProfit
	,round( sum( case when 0 < ord_days then (TotalProfit-feegross) end ) / sum( case when 0 < ord_days then (TotalGross-feegross) end ) ,4 ) Profit_rate
	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30天出单链接数`
from t_orde
group by SPU,PushDate
)

,t_ad as (
select t0.SPU, waad.GenerateDate, waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits
	, PushDate
	, timestampdiff(SECOND,PushDate,waad.GenerateDate)/86400 as ad_days -- 广告
from wt_adserving_amazon_daily waad
join t0 on left(waad.sku,7) = t0.spu
where waad.GenerateDate >= '${StartDay}' AND waad.GenerateDate < '${NextStartDay}'
)

,t_ad_stat as (
select tmp.*
	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `推荐7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `推荐14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `推荐30天点击率`
	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `推荐7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `推荐14天广告转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `推荐30天广告转化率`
from
	( select  SPU,PushDate
		-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_Exposure
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_Clicks
		-- 销量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_TotalSale7DayUnit
		from t_ad  group by  SPU,PushDate
	) tmp
)


,online_companycode as (
select
    spu ,PushDate
    ,count(distinct concat(SellerSKU,ShopCode,asin) ) online_list_cnt
	,count(distinct CompanyCode ) online_list_CompanyCode_cnt
from t_list
where ShopStatus='正常' and ListingStatus=1 and lst_days >=0
group by spu ,PushDate
)

,online_seller as (
select wl.spu ,ms.SellUserName
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and wl.IsDeleted = 0 and ms.ShopStatus='正常' and wl.ListingStatus=1
 and NodePathName regexp '${team1}|${team2}' and ms.Department='快百货'
group by wl.spu ,ms.SellUserName
)

, prod_seller as (
select spu, eaapis.SellUserName
from erp_amazon_amazon_product_in_sells eaapis
join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
group by spu, eaapis.SellUserName
)

,prod_seller_stat  as ( select spu ,group_concat(SellUserName) prod_seller_list from  prod_seller group by spu )
,online_seller_stat  as ( select spu ,group_concat(SellUserName) online_seller_list from  online_seller group by spu )
,unonline_seller_stat  as (
select p.spu ,group_concat(p.SellUserName) unonline_seller_list
from  prod_seller p left join  online_seller o on p.spu = o.spu and o.SellUserName = p.SellUserName
where o.SellUserName is null group by p.spu )

,sa_list_stat as (
select d.spu
     ,count(distinct case when  list_level='S' then concat(asin,site) END ) as 'S链接数'
     ,count(distinct case when  list_level='A' then concat(asin,site) END ) as 'A链接数'
from dep_kbh_listing_level d
WHERE list_level REGEXP 'S|A' group by d.spu )

,t_merage as (
select t0.spu ,t0.PushDate 推送日期
	,epp.ProductName
    ,case when TotalGross_in30d >= 500 then '是' else '否' end as 推荐30天业绩达500usd
    ,ele_name_group 元素
    ,ele_name_priority 优先级元素
    ,epp.productstatus `产品状态`

    ,dd.week_num_in_year as 推荐周次 -- 生效日期对应周次
    ,t0.主推站点
    ,t0.推送标准
    ,t0.推送人
    ,t0.推送理由

	,list_cnt_in3d `推荐3天内新刊登条数`
	,list_cnt_in7d `推荐7天内新刊登条数`
	,list_cnt_in15d `推荐15天内新刊登条数`
	,list_cnt_in30d `推荐30天内新刊登条数`
	,list_comp_cnt_in30d `推荐30天内新刊登套数`
	,list_cnt_UK `推荐后UK刊登条数`
	,list_cnt_DE `推荐后DE刊登条数`
	,list_cnt_FR `推荐后FR刊登条数`
	,list_cnt_US `推荐后US刊登条数`
	,list_cnt_CA `推荐后CA刊登条数`

	,list_cnt `推荐后刊登条数`
    ,list_CompanyCode_cnt `推荐后刊登账号套数`
    ,online_list_cnt `推荐后刊登在线条数`
    ,online_list_CompanyCode_cnt `推荐后刊登在线账号套数`
    ,od_list_total 推荐后出单条数
    ,od_companycode_total 推荐后出单账号数
    ,S链接数
    ,A链接数

	,ad7_sku_Exposure `推荐7天曝光`
	,ad14_sku_Exposure `推荐14天曝光`
	,ad30_sku_Exposure `推荐30天曝光`
	,ad7_sku_Clicks `推荐7天点击`
	,ad14_sku_Clicks `推荐14天点击`
	,ad30_sku_Clicks `推荐30天点击`
	,`推荐7天点击率`
	,`推荐14天点击率`
	,`推荐30天点击率`
	,ad7_sku_TotalSale7DayUnit `推荐7天广告销量`
	,ad14_sku_TotalSale7DayUnit `推荐14天广告销量`
	,ad30_sku_TotalSale7DayUnit `推荐30天广告销量`
	,`推荐7天广告转化率`
	,`推荐14天广告转化率`
	,`推荐30天广告转化率`
	,TotalGross_in7d `推荐后7天销售额`
	,TotalGross_in14d `推荐后14天销售额`
	,TotalGross_in30d `推荐后30天销售额`
    ,TotalGross_bf30d `推荐前30天销售额`
	,TotalGross_new_list_in30d `推荐后30天新刊登销售额`
    ,od_new_list_in30d 推荐后30天新刊登出单链接数
    ,round( od_new_list_in30d / list_cnt_in30d ,4) 推荐后30天新链接动销率
	,TotalGross_new_list_in60d `推荐后60天新刊登销售额`
    ,od_new_list_in60d 推荐后60天新刊登出单链接数
    ,round( od_new_list_in60d / list_cnt_in60d ,4) 推荐后60天新链接动销率
	,TotalGross_new_list_in90d `推荐后90天新刊登销售额`
    ,od_new_list_in90d 推荐后90天新刊登出单链接数
    ,round( od_new_list_in90d / list_cnt_in90d ,4) 推荐后90天新链接动销率

	,orders_total `推荐后订单量`
	,TotalGross `推荐后销售额`
	,TotalProfit `推荐后利润额`
	,Profit_rate `推荐后毛利率`
    ,prod_seller_list SPU分配销售人
    ,online_seller_list SPU在线账号销售人
    ,unonline_seller_list SPU未刊登人员

    ,list_comp_cnt_in60d `推荐60天内新刊登套数`
	,list_cnt_in60d `推荐60天内新刊登条数`
    ,是否过季
    ,TotalGross_new_list_2310 推荐后新刊登月销售额S2_2310
    ,TotalGross_new_list_2311 推荐后新刊登月销售额S2_2311
    ,TotalGross_new_list_2312 推荐后新刊登月销售额S2_2312
from t0
join dim_date dd on t0.PushDate =dd.full_date
left join (select distinct spu ,ele_name_group ,ele_name_priority  from dep_kbh_product_test ) dt on t0.spu=dt.spu
left join (select  spu
                ,case when ProductStatus = 0 then '正常'
                    when ProductStatus = 2 then '停产'
                    when ProductStatus = 3 then '停售'
                    when ProductStatus = 4 then '暂时缺货'
                    when ProductStatus = 5 then '清仓'
                    end as ProductStatus
                ,ProductName
           from erp_product_products where IsDeleted=0 and IsMatrix=1 and ProjectTeam='快百货' ) epp on t0.spu=epp.spu
left join t_list_stat on t0.spu =t_list_stat.spu and t0.pushdate =t_list_stat.pushdate
left join t_ad_stat on t0.spu =t_ad_stat.spu and t0.pushdate =t_ad_stat.pushdate
left join t_orde_stat on t0.spu =t_orde_stat.spu and t0.pushdate =t_orde_stat.pushdate
left join online_companycode oc on oc.SPU = t0.SPU and t0.pushdate =oc.pushdate
left join prod_seller_stat pss on pss.spu = t0.spu
left join online_seller_stat oss on oss.spu = t0.spu
left join unonline_seller_stat uss on uss.spu = t0.spu
left join sa_list_stat sls on sls.spu = t0.spu
)

select * from t_merage order by SPU