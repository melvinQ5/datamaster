
/*
-- 每周二 （周二才能拿到完整一周广告数据）
链接经营标签类型：
新品1 '近14天3单+'
新品2 '除运费客单20usd且近14天2单+'
全品 '近30天日均0.5单'
老品1 上周有4天出单都在出单（按统计日期，即近1-7天 与 近8-14天两周对比）
老品2 上周出单5单以上，同时环比再上周增长1.5倍以上（按统计日期，即近1-7天 与 近8-14天两周对比）
*/

-- 首先生成爆旺款数据，再生成此标签表数据
-- 'team' 替换成 '泉州'

with
t_prod as ( -- 新品:3月后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' 
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货' and Status = 10
)
-- select * from epp  '`DevelopLastAuditTime`' 

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU
	,wo.Product_Sku  as SKU
    ,case when date_add(Product_DevelopLastAuditTime , interval - 8 hour) >= '2023-07-01'
        then '新品' else '老品' end as isnewpp
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 20 then 1 else 0 end as isOver20usd
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
where
	PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -30 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) 
	and wo.IsDeleted=0
	and ms.Department = '快百货'  and TransactionType = '付款' -- 未含付款类型为其他
	and NodePathName regexp '${team}'
)
-- select * from t_orde 
-- ----------链接打标签
,t_orde_stat as ( -- 链接标签的特征数据
select shopcode  ,sellersku ,isnewpp
	,count(distinct case when timestampdiff(SECOND,paytime, subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) )/86400  <= 14 then PlatOrderNumber end) orders_in14d
	,count(distinct case when timestampdiff(SECOND,paytime, subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) )/86400  <= 30 then PlatOrderNumber end) orders_in30d
    ,count(distinct case when  PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -7 day) and PayTime < date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count(distinct case when  PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -7 day) and PayTime < date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count(distinct case when  PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -14 day) and PayTime < date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver20usd = 1 then PlatOrderNumber end ) orders_over_20usd -- 除运费超20美金订单数
from t_orde
group by shopcode  ,sellersku ,isnewpp
)
-- select * from t_orde_stat

,list_mark as (
	select shopcode  ,sellersku ,GROUP_CONCAT(list_type) list_type
	from (

        select shopcode  ,sellersku
        ,case when orders_in30d/30 >5 then '全_近30天日均超5单' 
        	when orders_in30d/30 >= 3 then '全_近30天日均3-5单'
        	when orders_in30d/30 >= 1 then '全_近30天日均1-3单'
        	else '全_近30天日均0.5-1单'
        end as list_type
		from t_orde_stat where orders_in30d/30 >= 0.5
        union
		select shopcode  ,sellersku  ,'新_近14天3单+' list_type
		from t_orde_stat where orders_in14d >= 3 and isnewpp = '新品' -- 14天内出3单
		union
		select shopcode  ,sellersku  ,'新_除运费客单20usd且近14天2单+' list_type
		from t_orde_stat where orders_over_20usd > 0 and  orders_in14d >= 2 and isnewpp = '新品'
		union
		select shopcode  ,sellersku  ,'老_近7天达4天出单' list_type
		from t_orde_stat where isnewpp = '老品' and order_days_in1_7 >= 4
		union
		select shopcode  ,sellersku  ,'老_近7天累计5单且环比前7天单量达1.5倍' list_type
		from t_orde_stat where isnewpp = '老品' and orders_in1_7 >= 5 and orders_in1_7 / orders_in8_14 >=1.5



		) tb
	group by shopcode  ,sellersku
)

-- ----------计算订单表现
,t_orde_week_stat as ( -- 用于累计订单
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_weekly
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -7*10 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  -- 获取更久远的数据是为了包含到表主键的自然周
	and wo.IsDeleted=0
	and ms.Department = '快百货'  and TransactionType = '付款' -- 未含付款类型为其他
	and NodePathName regexp '${team}'
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

-- ----------计算广告表现

,t_list as (
select wl.SPU ,wl.SKU ,BoxSku ,MinPublicationDate ,MarketType ,wl.SellerSKU ,wl.ShopCode ,asin
	,DevelopLastAuditTime ,ProductName ,DevelopUserName
	,case when TortType is null then '未标记' else TortType end TortType 
	,Festival ,ProductStatus
	,AccountCode  ,ms.Site
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '快百货'
left join ( -- 元素映射表，最小粒度是 SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on wl.sku =t_elem .sku
left join (
	select sku ,ProductName ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
		from import_data.wt_products wp where IsDeleted =0 
	) ta on wl.sku =ta.sku 
join (select shopcode,sellersku from erp_amazon_amazon_listing  group by shopcode,sellersku ) undeleted on wl.ShopCode =undeleted.ShopCode and wl.sellersku = undeleted.sellersku
where NodePathName regexp '${team}'

)

,t_ad as ( -- 优化链接对应广告数据
select asa.AdActivityName ,campaignBudget ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure ,asa.Spend
	,ROAS ,Acost as ACOS 
	, ta.ShopCode ,ta.SellerSKU 
	, asa.CreatedTime ,asa.Asin  
	, dim_date.week_num_in_year ad_stat_week
	, dim_date.week_begin_date  ad_week_begin_date
	, list_type
from list_mark ta -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
left join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU 
	and asa.CreatedTime >=date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -7*10 DAY) and  asa.CreatedTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) 
left join dim_date on dim_date.full_date = asa.CreatedTime
)

-- select * from t_ad WHERE ASIN = 'B01FRWGI0G' LIMIT 10 ;

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week ,list_type
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
		from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week ,list_type
	) tmp
)
-- select * from t_ad_stat

, t_ad_name as ( -- 广告活动名称
select shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
	, GROUP_CONCAT(AdActivityName) AdActivityName
from ( select shopcode  ,sellersku  ,ad_week_begin_date ,ad_stat_week,AdActivityName from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week ,AdActivityName ) tb
group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
)
-- select * from t_ad_name 



,t_merage as (
select
	date( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ) `订单广告统计截至日期`
    ,lst_key.list_type `运营优化标签`
    ,lst_key.shopcode `店铺简码`
	,lst_key.sellersku `渠道sku`
     ,case when t_list.SellerSKU is null then '链接已删除' else '' end as 链接是否删除
    ,t_list.site `站点`
    ,t_list.asin
	,t_list.AccountCode `账号`
	,t_list.NodePathName `销售团队`
	,t_list.SellUserName `首选业务员`
    ,orders_in30d `近30天订单量`
	,orders_in14d `近14天订单量`
	,orders_in1_7 `近7天订单量`
	
	,week_num_in_year `自然周次`
 	,pay_week `订单统计周`
	,TotalGross_weekly `当周总销售额`
	,TotalProfit_weekly - ifnull(ad_Spend,0) `当周总利润额`
	,orders_weekly `当周总订单量`
	,salecount_weekly `当周总sku销量`
	
	,t_ad_stat.ad_stat_week `广告统计周`
-- 	,t_ad_stat.ad_week_begin_date `广告当周周一`
	,AdActivityName `当周广告活动`
	,ad_sku_Exposure `当周广告曝光量`
	,ad_Spend `当周广告花费`
	,ad_TotalSale7Day `当周广告销售额`
	,ad_sku_TotalSale7DayUnit `当周广告销量`
	,ad_sku_Clicks `当周广告点击量` 
	,click_rate `当周广告点击率`
	,adsale_rate `当周广告转化率`
	,ROAS `当周ROAS`
	,ACOS `当周ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `当周CPC`
	
	,t_list.spu
	,dkpl.prod_level `爆旺款`
    ,date(date_add(dkpl.FirstDay,interval 1 week)) `爆旺款标记日`
	,t_list.sku 
	,t_list.boxsku 
	,ProductName 
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,Festival `季节节日`
	,ele_name `元素` 
	,t_list.DevelopLastAuditTime `产品终审时间`
	,left(t_list.DevelopLastAuditTime,7) `产品终审月份`
	,DevelopUserName `开发人员`
from 
	( select lm.* , week_num_in_year
	from list_mark lm 
	join ( select distinct week_num_in_year from dim_date 
		where full_date >= date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -30 DAY) and full_date <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  ) dd 
	order by shopcode  ,sellersku ,week_num_in_year
	) lst_key 
left join t_ad_stat on  t_ad_stat.ShopCode = lst_key.ShopCode and t_ad_stat.SellerSKU = lst_key.SellerSKU and lst_key.week_num_in_year = t_ad_stat.ad_stat_week 
left join t_ad_name on  lst_key.ShopCode = t_ad_name.ShopCode and lst_key.SellerSKU = t_ad_name.SellerSKU and lst_key.week_num_in_year = t_ad_name.ad_stat_week
left join t_list on  t_list.ShopCode = lst_key.ShopCode and t_list.SellerSKU = lst_key.SellerSKU 
left join t_prod on t_list.sku = t_prod.sku 
left join t_orde_stat on  lst_key.ShopCode = t_orde_stat.ShopCode and lst_key.SellerSKU = t_orde_stat.SellerSKU 
left join t_orde_week_stat on  lst_key.ShopCode = t_orde_week_stat.ShopCode and lst_key.SellerSKU = t_orde_week_stat.SellerSKU 
	and lst_key.week_num_in_year = t_orde_week_stat.pay_week
left join ( select spu ,prod_level,FirstDay from dep_kbh_product_level where department = '快百货' and FirstDay = (select max(firstday) from dep_kbh_product_level) ) dkpl
	on t_list.spu = dkpl.spu
)

-- select list_type ,count(DISTINCT shopcode  ,sellersku ) from t_ad_stat group by list_type   '`lst_key`.`ad_stat_week`' 
select * from t_merage 
order by `渠道sku` ,`广告统计周`