
with
prod as ( select distinct sku ,ele_name_priority ,isnew from dep_kbh_product_test where productstatus !=2 ) -- 新老品
-- prod as ( select sku ,ele_name_priority ,isnew from dep_kbh_product_test where isnew = '新品') -- 新老品

,t_list as ( -- 新品所有链接
select wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate ,wl.MarketType as site,wl.SellerSKU ,wl.ShopCode ,wl.asin
	,DevelopLastAuditTime ,ProductName
	,case when TortType is null then '未标记' else TortType end TortType ,DevelopUserName
	,Festival ,ta.ProductStatus
	,AccountCode
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
    ,case when wl.ListingStatus=1 then '在线' else '不在线' end as ListingStatus
    ,ShopStatus
    ,ele_name_priority ,isnew
    ,lst_pub_tag
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '快百货' and wl.IsDeleted=0
join prod on  wl.sku= prod.sku
join erp_amazon_amazon_listing  eaal on  wl.id =eaal.id  and wl.ListingStatus !=5 -- 未删除链接
left join ( -- 元素映射表，最小粒度是 SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on wl.sku =t_elem .sku
left join (
	select sku ,ProductName ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime ,DevelopUserName
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
		from import_data.wt_products wp where IsDeleted =0 and ProjectTeam='快百货'
	) ta on wl.sku =ta.sku
left join view_kbh_lst_pub_tag vklpt on wl.SellerSKU = vklpt.SellerSKU and wl.ShopCode = vklpt.shopcode
where wl.ListingStatus = 1 and ShopStatus='正常'
)

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU
	,wo.Product_Sku  as SKU
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 20 then 1 else 0 end as isOver20usd
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.sku = wo.Product_Sku
where
	PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -30 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
	and wo.IsDeleted=0
	and ms.Department = '快百货'  and TransactionType = '付款' -- 未含付款类型为其他
)

-- ----------链接打标签
,t_orde_stat as ( -- 新品链接标签的特征数据
select shopcode  ,sellersku
	,count(distinct case when timestampdiff(SECOND,paytime,  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  )/86400  <= 14 then PlatOrderNumber end) orders_in14d
	,count(distinct case when timestampdiff(SECOND,paytime,  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  )/86400  <= 30 then PlatOrderNumber end) orders_in30d
    ,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -14 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver20usd = 1 then PlatOrderNumber end ) orders_over_20usd -- 除运费超20美金订单数
from t_orde
group by shopcode  ,sellersku
)

,snap_list_mark as (
select FirstDay , asin ,site ,list_level as snapshot_list_level
from import_data.dep_kbh_listing_level  where list_level regexp 'S|A|潜力'
    and FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -5 week) and day(FirstDay) != 1
)

,lst_1 as ( -- 本周
select  distinct asin ,site ,list_level as list_mark_0 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1 week)
)

,lst_2 as (  -- w-1周
select  distinct asin ,site ,list_level as list_mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2 week)
)

,lst_3 as ( -- w-2周
select  distinct asin ,site ,list_level as list_mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3 week)
)

,snap_prod_mark as (
select FirstDay , spu  ,prod_level as snapshot_prod_level
from import_data.dep_kbh_product_level  where isdeleted = 0 and  FirstDay >=  date_ADD(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -5 week) and day(FirstDay) != 1
)

,prod_1 as ( -- 本周
select  distinct spu ,prod_level as mark_1 from dep_kbh_product_level
where isdeleted = 0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,prod_2 as (  -- w-1周
select  distinct spu ,prod_level as mark_2 from dep_kbh_product_level
where  isdeleted = 0 and year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,prod_3 as ( -- w-2周
select  distinct spu ,prod_level as mark_3 from dep_kbh_product_level
where  isdeleted = 0 and year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)

,lastest_prod_mark as (
select spu  ,group_concat(snapshot_prod_level,'-') old_prod_level
from (select spu ,snapshot_prod_level from snap_prod_mark
where FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -3 week) order by FirstDay desc
         ) t
group by spu
)

-- ----------计算订单表现
,od_pay as (
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_weekly
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) sales_undeduct_refunds
	,round( sum((TotalGross-FeeGross)/ExchangeUSD ),2 ) TotalGross_no_freight_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) profit_undeduct_refunds
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.sku = wo.Product_Sku
join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   -- 获取更久远的数据是为了包含到表主键的自然周
    and wo.IsDeleted=0
	and ms.Department = '快百货'
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

,od_refund as ( -- 销售额对应退款额，利润额对应退款额
select shopcode ,SellerSku ,dim_date.week_num_in_year as refund_week
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
join dim_date on dim_date.full_date = date(vr.max_refunddate)
where wo.IsDeleted = 0 and max_refunddate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and max_refunddate<  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) and TransactionType = '退款'
group by shopcode ,SellerSku ,refund_week
)

,od_stat_pre as ( -- 拼接有出单 和 仅退款的记录
select  shopcode  ,sellersku ,pay_week
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,pay_week , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,refund_week , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,pay_week
)
-- select * from pre_refund_t_orde_week_stat ;

,od_stat as (
select  a.shopcode ,a.sellersku ,a.pay_week
    ,orders_weekly ,salecount_weekly
    ,sales  as TotalGross_weekly
    ,TotalGross_no_freight_weekly
    ,profit  as TotalProfit_weekly
    ,sales_refund as TotalGross_weekly_refund
from od_stat_pre a
left join  od_pay b on a.shopcode  = b.shopcode and  a.sellersku = b.SellerSku and a.pay_week = b.pay_week
)
-- ----------计算广告表现
-- select * from t_list
-- select count(1) from t_list

,t_ad as ( -- 优化链接对应广告数据
select ShopCode ,SellerSKU  ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
	, dim_date.week_num_in_year ad_stat_week
	, dim_date.week_begin_date  ad_week_begin_date
    , case when GenerateDate =  date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -2 day)
        then MaxEnabledBidUSD end MaxEnabledBidUSD -- 周一给出上周六作为最新竞价
    , MaxBidUSD  -- 用于算近7日均
    , GenerateDate
from wt_adserving_amazon_daily  asa -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join prod on asa.sku =prod.sku -- 新品
	and asa.GenerateDate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and  asa.GenerateDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
join dim_date on dim_date.full_date = asa.GenerateDate
)

-- select * from t_ad ;

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
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
	    , round(max(MaxEnabledBidUSD),2) as MaxEnabledBidUSD
	    ,round( avg( case when GenerateDate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and  GenerateDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) then MaxBidUSD end ) ,2 ) MaxBidUSD_in7d
		from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
	) tmp
)

,t_ad_bid as (
select waad.ShopCode ,waad.SellerSku
    ,max( case when GenerateDate = date_add(  '${NextStartDay}',interval -2 day ) then MaxEnabledBidUSD end  ) `日最大bid`
    ,max( case when GenerateDate = date_add(  '${NextStartDay}',interval -2-7 day ) then MaxEnabledBidUSD end  ) `日最大bid_7天前`
    ,round( avg( case when GenerateDate >= date_add(  '${NextStartDay}',interval -2-7 day ) and  GenerateDate <  date_add(  '${NextStartDay}',interval -2 day ) then MaxBidUSD end ) ,2 ) 7日平均bid
    ,round( avg( case when GenerateDate >= date_add(  '${NextStartDay}',interval -2-7-7 day ) and  GenerateDate <  date_add(  '${NextStartDay}',interval -2-7 day ) then MaxBidUSD end ) ,2 ) 7日平均bid_上期
from wt_adserving_amazon_daily  waad
join prod on waad.sku =prod.sku -- 新品
	and waad.GenerateDate >= date_add(  '${NextStartDay}',interval -2-7-7 day) and waad.GenerateDate <  '${NextStartDay}'
join dim_date on dim_date.full_date = waad.GenerateDate
group by waad.ShopCode ,waad.SellerSku
)


,t_merage as (
select
    lst_key.week_begin_date
    ,concat(lst_key.sellersku,lst_key.shopcode,week_num_in_year,ifnull(pay_week,'_'),ifnull(t_ad_stat.ad_stat_week,'_')) 表id
	,now() `数据刷新时间`
    ,snap_list_mark.snapshot_list_level `链接分层快照`
    , case when orders_in30d is null then null else concat(ifnull(list_mark_0,'无'),'-',ifnull(list_mark_1,'无'),'-',ifnull(list_mark_2,'无'))  end  `前三周链接分层`
    ,lst_key.shopcode `店铺简码`
	,lst_key.sellersku `渠道sku`
    ,left(lst_key.`MinPublicationDate`,7) `刊登年月`
    ,lst_key.lst_pub_tag `链接刊登划分`
    ,lst_key.site `站点`
    ,lst_key.asin
	,lst_key.AccountCode `账号`
	,lst_key.NodePathName `销售团队`
	,lst_key.SellUserName `首选业务员`
    ,orders_in30d `近30天订单量`
	,orders_in14d `近14天订单量`
	,orders_in1_7 `近7天订单量`

	,week_num_in_year `自然周次`
 	,pay_week `订单统计周`
	,ifnull(TotalGross_weekly,0) `当周销售额`
    ,ifnull(TotalGross_no_freight_weekly,0) `当周扣运费销售额`
	,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `当周扣广告利润额`
	,orders_weekly `当周订单量`
	,salecount_weekly `当周sku销量`

	,t_ad_stat.ad_stat_week `广告统计周`
	,'-' `当周广告活动`
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
    ,`日最大bid`
    ,`日最大bid_7天前`
    ,`日最大bid` - `日最大bid_7天前` as 日bid之差
    ,7日平均bid
    ,7日平均bid_上期
    ,`7日平均bid` - `7日平均bid_上期` as 7日均bid之差

	,lst_key.spu
	,spm.snapshot_prod_level `商品分层快照`
    ,concat(ifnull(mark_1,'无'),'-',ifnull(mark_2,'无'),'-',ifnull(mark_3,'无'))  前三周商品分层
	,lst_key.sku
	,lst_key.boxsku
	,ProductName
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,Festival `季节节日`
	,ele_name `元素`
	,lst_key.DevelopLastAuditTime `产品终审时间`
	,left(lst_key.DevelopLastAuditTime,7) `产品终审月份`
	,DevelopUserName `开发人员`
    ,case when lst_key.SellerSKU is null then '链接已删除' else '' end as 链接是否删除
    ,lst_key.ListingStatus 链接状态
    ,lst_key.ShopStatus 店铺状态
    ,case when dp.spu is null then '否' else '是' end as `是否标记过爆旺款`
    ,ifnull(TotalGross_weekly_refund,0) as `当周退款金额`
    ,case when lst_key.NodePathName regexp '成都' then '成都' when lst_key.NodePathName regexp '泉州' then '泉州' end as 区域
    ,ele_name_priority 优先级元素 ,isnew 新老品

from
	( select lm.* , week_num_in_year ,week_begin_date
	from t_list lm
	join ( select distinct week_num_in_year,week_begin_date from dim_date
		where full_date >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and full_date < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
		) dd
	) lst_key -- 新品所有链接
left join snap_list_mark on  snap_list_mark.asin = lst_key.asin and snap_list_mark.site = lst_key.site and snap_list_mark.FirstDay = lst_key.week_begin_date
left join lst_1 on lst_key.site = lst_1.site  and lst_key.Asin =lst_1.Asin
left join lst_2 on lst_key.site = lst_2.site  and lst_key.Asin =lst_2.Asin
left join lst_3 on lst_key.site = lst_3.site  and lst_key.Asin =lst_3.Asin
left join t_ad_stat on  t_ad_stat.ShopCode = lst_key.ShopCode and t_ad_stat.SellerSKU = lst_key.SellerSKU and lst_key.week_num_in_year = t_ad_stat.ad_stat_week
left join t_ad_bid on  t_ad_bid.ShopCode = lst_key.ShopCode and t_ad_bid.SellerSKU = lst_key.SellerSKU
left join t_orde_stat on  lst_key.ShopCode = t_orde_stat.ShopCode and lst_key.SellerSKU = t_orde_stat.SellerSKU
left join od_stat on  lst_key.ShopCode = od_stat.ShopCode and lst_key.SellerSKU = od_stat.SellerSKU
	and lst_key.week_num_in_year = od_stat.pay_week
left join snap_prod_mark  spm on lst_key.spu = spm.spu  and spm.FirstDay = lst_key.week_begin_date
left join prod_1 on lst_key.spu = prod_1.spu
left join prod_2 on lst_key.spu = prod_2.spu
left join prod_3 on lst_key.spu = prod_3.spu
left join (select spu from dep_kbh_product_level where  isdeleted = 0 and prod_level regexp '爆款|旺款' group by spu ) dp on lst_key.spu = dp.spu
)


,t_res as (
select distinct
表id,
`数据刷新时间` ,
`链接分层快照` ,
`前三周链接分层` ,
`店铺简码` ,
`渠道sku` ,
`刊登年月`,
链接刊登划分,
`站点` ,
t_merage.asin ,
`账号` ,
`销售团队` ,
`首选业务员` ,
`近30天订单量` ,
`近14天订单量` ,
`近7天订单量` ,
`自然周次` ,
`订单统计周` ,
round(`当周销售额`,2) 当周销售额 ,
round(`当周扣运费销售额`,2) 当周扣运费销售额,
round(`当周扣广告利润额`,2) 当周扣广告利润额,
`当周订单量` ,
`当周sku销量` ,
`广告统计周` ,
`当周广告活动`,
`当周广告曝光量` ,
`当周广告花费` ,
`当周广告销售额` ,
`当周广告销量` ,
`当周广告点击量` ,
`当周广告点击率` ,
`当周广告转化率` ,
`当周ROAS` ,
`当周ACOS` ,
`当周CPC`
,`日最大bid`
,`日最大bid_7天前`
, 日bid之差
,7日平均bid
,7日平均bid_上期
,7日均bid之差
,spu
`商品分层快照` ,
`前三周商品分层`,
sku ,
boxsku ,
ProductName ,
`产品状态` ,
`侵权状态` ,
`季节节日` ,
`元素` ,
`产品终审时间` ,
`产品终审月份` ,
`开发人员` ,
链接是否删除 ,
链接状态 ,
店铺状态 ,
`是否标记过爆旺款`,
当周退款金额 ,
区域,
优先级元素,
新老品
from t_merage
)

select * from t_res
-- where 店铺简码 ='PQ-MX'  and 渠道sku = '5P4XKD1I1M5KMUFMU1EBS-01'