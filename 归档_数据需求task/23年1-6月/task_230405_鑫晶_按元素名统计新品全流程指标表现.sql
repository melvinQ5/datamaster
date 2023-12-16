
with epp as ( -- sku 
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
-- where CreationTime  >= '${StartDay}'
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}' and DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货'
group by SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)
)
-- select * from epp 

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
	select eppaea.SPU , eppea.Name ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	join epp on eppaea.sku = epp.sku -- 新品
	group by eppaea.SPU , eppea.Name
)

,t_list as ( -- 刊登时间在2月1日至今
select wl.SPU ,wl.SKU ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin
	,DATE_ADD(epp.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
-- from import_data.wt_listing wl
from import_data.erp_amazon_amazon_listing  wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
join epp on wl.sku = epp.sku
where
	PublicationDate>= '${StartDay}'
-- 	and PublicationDate>= '2023-01-01'
	and PublicationDate <'${NextStartDay}'
	and wl.IsDeleted = 0
	and ms.Department = '快百货'
-- 	and wl.spu= 5202143
-- 	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
-- 	and NodePathName in ('快次方-成都销售组')
-- 	and NodePathName in ('快次元-成都销售组')
)

,t_orde as (
	select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
		,ExchangeUSD,TransactionType,SellerSku,RefundAmount
		,wo.Product_SPU as SPU ,PayTime
		,timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days 
		,min(PayTime) over (PARTITION by Product_SPU) min_pay_time
		,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
	from import_data.wt_orderdetails wo 
	join import_data.mysql_store ms on wo.shopcode=ms.Code
	join epp on wo.Product_Sku  = epp.sKU 
	where 
		PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
		and ms.Department = '快百货' 
	-- 	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
	-- 	and NodePathName in ('快次方-成都销售组')
	-- 	and NodePathName in ('快次元-成都销售组')
)
-- select * from t_orde 

,t_list_stat as ( -- 刊登统计
select t_list.SPU ,min_pub_date
	,count(distinct case when min_pub_date < DATE_ADD(DevelopLastAuditTime,interval 3 day) then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when min_pub_date < DATE_ADD(DevelopLastAuditTime,interval 7 day) then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when min_pub_date < DATE_ADD(DevelopLastAuditTime,interval 15 day) then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode,t_list.asin) ) list_cnt
from t_list 
left join (
	select SPU ,min(PublicationDate) as min_pub_date 
	from t_list group by SPU
	) tmp 
	on t_list.SPU = tmp.SPU 
group by t_list.SPU ,min_pub_date
)
-- select * from t_list_stat order by SPU

,t_ord_list_stat as (
select t_orde.SPU 
	,count(distinct concat(t_orde.SellerSKU,t_orde.ShopCode,t_orde.asin)) `首登30天内出单链接数`
from t_orde
left join (
	select spu ,min(PublicationDate) as min_pub_date from t_list group by spu
	) tmp 
	on tmp.spu = t_orde.spu
where PayTime <= DATE_ADD(min_pub_date,interval 30 day)
group by t_orde.SPU 
)

,t_ad as ( 
select t_list.SPU, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
	, DevelopLastAuditTime
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- 广告
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 7*86400 then '是' else '否' end `是否7天`
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 14*86400 then '是' else '否' end `是否14天`
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 30*86400 then '是' else '否' end `是否30天`
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
-- 	and t_list.spu= 5202143
where asa.CreatedTime >= '${StartDay}'
)

,t_ad_stat as (
select tmp.* 
	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `终审7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `终审14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `终审30天点击率`
	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `终审7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `终审14天广告转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `终审30天广告转化率`
from 
	( select SPU
		-- 曝光量
		, round(sum(case when 0 <= ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 <= ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 <= ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
		-- 点击量
		, round(sum(case when 0 <= ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 <= ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 <= ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
		-- 销量	
		, round(sum(case when 0 <= ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 <= ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 <= ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
		from t_ad  group by SPU
	) tmp
)

,t_orde_stat as (
select SPU ,min_pay_time `首次出单时间`
	,round(sum( case when 0 <= ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d -- ord_days 出单-终审
	,round(sum( case when 0 <= ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 <= ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
	,count( distinct PlatOrderNumber) orders_total
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30天出单链接数`
from t_orde 
group by SPU ,min_pay_time
)

,t_merage as ( 
select epp.spu 
	,ProductName 
	,DevelopUserName `开发人员`
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,Festival `季节节日`
	,ele_name `元素` 
	,DATE_ADD(CreationTime,interval - 8 hour) `添加时间`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) `终审时间`
	,`首次出单时间`
	,case when `首次出单时间` is null then '否' else '是' end as '是否出单'
	,min_pub_date `首次刊登时间`
	,list_cnt_in3d `终审3天内刊登条数`
	,list_cnt_in7d `终审7天内刊登条数`
	,list_cnt_in15d `终审15天内刊登条数`
	,list_cnt_UK `UK刊登总条数`
	,list_cnt_DE `DE刊登总条数`
	,list_cnt_FR `FR刊登总条数`
	,list_cnt_US `US刊登总条数`
	,list_cnt `刊登条数`
	,ad7_sku_Exposure `终审7天曝光`
	,ad14_sku_Exposure `终审14天曝光`
	,ad30_sku_Exposure `终审30天曝光`
	,ad7_sku_Clicks `终审7天点击` 
	,ad14_sku_Clicks `终审14天点击`
	,ad30_sku_Clicks `终审30天点击`
	,`终审7天点击率`
	,`终审14天点击率`
	,`终审30天点击率`
	,ad7_sku_TotalSale7DayUnit `终审7天广告销量`
	,ad14_sku_TotalSale7DayUnit `终审14天广告销量`
	,ad30_sku_TotalSale7DayUnit `终审30天广告销量`
	,`终审7天广告转化率`
	,`终审14天广告转化率`
	,`终审30天广告转化率`
	,TotalGross_in7d `终审7天销售额usd`
	,TotalGross_in14d `终审14天销售额usd`
	,TotalGross_in30d `终审30天销售额usd`
	,orders_total `累计订单量`
	,TotalGross `累计销售额`
	,TotalProfit `累计利润额`
	,Profit_rate `毛利率`
	,`首登30天内出单链接数`
-- 	,round( `首登30天内出单链接数` / list_cnt ,40) `30天链接出单率`
from (select spu from import_data.erp_product_products 
-- where CreationTime  >= '${StartDay}'
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}' and DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}'
and IsMatrix = 1 and IsDeleted = 0 
and ProjectTeam ='快百货'
group by spu ) epp 
left join 
	(select Spu ,CreationTime ,DevelopLastAuditTime,ProductName ,DevelopUserName
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
	from erp_product_products wp where IsMatrix = 1 
	) epp_spu on epp.SPU =epp_spu.spu
left join (
	select SPU ,case when TortType is null then '未标记' else TortType end TortType ,Festival
	from import_data.wt_products 
	where IsDeleted =0 and CreationTime  >= '${StartDay}' and ProjectTeam='快百货' 
	group by SPU , TortType ,Festival
	) epp_spu_Tort on epp.SPU =epp_spu_Tort.spu 
left join t_list_stat on epp.spu =t_list_stat.spu
join t_elem on epp.spu =t_elem.spu
left join t_ad_stat on epp.spu =t_ad_stat.spu
left join t_orde_stat on epp.spu =t_orde_stat.spu 
left join t_ord_list_stat on epp.spu =t_ord_list_stat.spu
where DATE_ADD(CreationTime,interval - 8 hour) >= '2023-01-01'
)

-- SELECT * FROM t_merage  
SELECT 
	`元素`
	,count(distinct spu) `1-3月终审SPU数`
	,round(sum(终审7天点击)/sum(终审7天曝光),4) `终审7天点击率`
	,round(sum(终审14天点击)/sum(终审14天曝光),4) `终审14天点击率`
	,round(sum(终审30天点击)/sum(终审30天曝光),4) `终审30天点击率`
	,round(sum(终审7天广告销量)/sum(终审7天点击),4) `终审7天转化率`
	,round(sum(终审14天广告销量)/sum(终审14天点击),4) `终审14天转化率`
	,round(sum(终审30天广告销量)/sum(终审30天点击),4) `终审30天转化率`
FROM t_merage  
group by grouping sets ((),(`元素`))
order by `元素`



