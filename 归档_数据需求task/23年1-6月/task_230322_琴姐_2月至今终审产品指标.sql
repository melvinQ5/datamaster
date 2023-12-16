

with epp as ( -- sku 
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
-- where CreationTime  >= '${StartDay}'
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货'
group by SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)
)
-- select * from epp 


,t_list as ( -- 刊登时间在2月1日至今
select wl.SPU ,wl.SKU ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
	,DATE_ADD(epp.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
from wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join epp on wl.sku = epp.sku 
where 
	PublicationDate>= '${StartDay}' and PublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
		and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
)

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU ,PayTime
	, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days 
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_SPU = epp.spu 
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
	and ms.Department = '快百货' 
	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
)

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
-- select * from t_list_stat

,t_ord_list_stat as (
select t_orde.SPU 
	,count(distinct concat(t_orde.SellerSKU,t_orde.ShopCode,t_orde.asin)) `首登30天内出单链接数`
from t_orde
join (
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
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 14 then '是' else '否' end `是否14天`
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 30 then '是' else '否' end `是否30天`
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU and t_list.SellerSKU <> ''
where asa.CreatedTime >= '${StartDay}'
)

,t_ad_stat as (
select tmp.* 
	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30天点击率`
	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `7天转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `14天转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `30天转化率`
from 
	( select SPU
	-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
			-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
			-- 销量	
		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
		from t_ad  group by SPU
	) tmp
)
-- select * from t_ad_stat 

,t_orde_stat as (
select SPU 
	,sum( case when 0 < ord_days and ord_days <= 7 then TotalGross end ) TotalGross_in7d
	,sum( case when 0 < ord_days and ord_days <= 14 then TotalGross end ) TotalGross_in14d
	,sum( case when 0 < ord_days and ord_days <= 30 then TotalGross end ) TotalGross_in30d
-- 	,sum(TotalGross) TotalGross
	,round( count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}'),4) orders_daily
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30天出单链接数`
from t_orde 
group by SPU 
)
-- 5207230
,t_merage as (
select epp.spu 
	,ProductName 
	,DevelopUserName `开发人员`
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,DATE_ADD(CreationTime,interval - 8 hour) `添加时间`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) `终审时间`
	,min_pub_date `首次刊登时间`
	,list_cnt_in3d `3天内刊登条数`
	,list_cnt_in7d `7天内刊登条数`
	,list_cnt_in15d `15天内刊登条数`
	,list_cnt_UK `UK刊登总条数`
	,list_cnt_DE `DE刊登总条数`
	,list_cnt_FR `FR刊登总条数`
	,list_cnt_US `US刊登总条数`
	,list_cnt `刊登条数`
	,ad7_sku_Exposure `7天曝光`
	,ad14_sku_Exposure `14天曝光`
	,ad30_sku_Exposure `30天曝光`
	,ad7_sku_Clicks `7天点击` 
	,ad14_sku_Clicks `14天点击`
	,ad30_sku_Clicks `30天点击`
	,`7天点击率`
	,`14天点击率`
	,`30天点击率`
	,ad7_sku_TotalSale7DayUnit `7天广告销量`
	,ad14_sku_TotalSale7DayUnit `14天广告销量`
	,ad30_sku_TotalSale7DayUnit `30天广告销量`
	,`7天转化率`
	,`14天转化率`
	,`30天转化率`
	,TotalGross_in7d `7天销售额`
	,TotalGross_in14d `14天销售额`
	,TotalGross_in30d `30天销售额`
	,orders_daily `日均订单量`
	,Profit_rate `毛利率`
	,`首登30天内出单链接数`
-- 	,round( `首登30天内出单链接数` / list_cnt ,40) `30天链接出单率`
from (select spu from epp group by spu ) epp 
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
	select SPU ,GROUP_CONCAT( case when TortType is null then '未标记' else TortType end ) TortType 
	from ( select SPU ,TortType
		from import_data.wt_products 
		where IsDeleted =0 and CreationTime  >= '${StartDay}' and ProjectTeam='快百货' 
		group by SPU ,TortType ) ta
	group by SPU
	) epp_spu_Tort on epp.SPU =epp_spu_Tort.spu 
left join t_list_stat on epp.spu =t_list_stat.spu
left join t_ad_stat on epp.spu =t_ad_stat.spu
left join t_orde_stat on epp.spu =t_orde_stat.spu 
left join t_ord_list_stat on epp.spu =t_ord_list_stat.spu
)

-- select count(1)
select * 
from t_merage
order by SPU
