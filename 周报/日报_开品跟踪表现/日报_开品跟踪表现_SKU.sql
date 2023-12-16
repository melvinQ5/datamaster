

with epp as ( -- sku
select SKU ,SPU ,DevelopLastAuditTime
from import_data.erp_product_products
where CreationTime  >= '${StartDay}' and CreationTime < '${NextStartDay}'
-- where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}'
and IsMatrix = 0 and IsDeleted = 0
and ProjectTeam ='快百货' and Status != 20
group by SKU ,SPU ,DevelopLastAuditTime
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select sku ,GROUP_CONCAT( Name ) ele_name
from (
select eppaea.sku ,eppea.Name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join epp on eppaea.sku = epp.sku
group by eppaea.sku ,eppea.Name
) t
group by sku
)

,t_list as ( -- 刊登时间在2月1日至今
select wl.SPU ,wl.SKU ,MinPublicationDate ,wl.MarketType ,wl.SellerSKU ,wl.ShopCode ,wl.asin ,CompanyCode
	,DevelopLastAuditTime
from import_data.erp_amazon_amazon_listing eaal
join import_data.mysql_store ms on eaal.ShopCode = ms.Code and ms.Department = '快百货' and NodePathName regexp '${team1}|${team2}'
join epp on eaal.sku = epp.sku
left join import_data.wt_listing wl
    on eaal.id = wl.id and MinPublicationDate>= '${StartDay}'  and MinPublicationDate <'${NextStartDay}'
)
-- select * from t_list

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	, timestampdiff(SECOND,epp.DevelopLastAuditTime,PayTime)/86400 as ord_days 
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_SKU = epp.sKU
where 
	PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
	and ms.Department = '快百货' and NodePathName regexp '${team1}|${team2}'
-- 	and boxsku = 4554327
-- 	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
-- 	and NodePathName in ('快次方-成都销售组')
-- 	and NodePathName in ('快次元-成都销售组')
)
-- select * from t_orde 

,t_list_stat as ( -- 刊登统计
select t_list.sku
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=15 then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode,t_list.asin) ) list_cnt
	,count(distinct CompanyCode ) list_CompanyCode_cnt
	,min(MinPublicationDate) as min_pub_date
from t_list 
group by t_list.sku
)
-- select * from t_list_stat

,t_ord_list_stat as (
select t_orde.sku 
	,count(distinct concat(t_orde.SellerSKU,t_orde.ShopCode,t_orde.asin)) `首登30天内出单链接数`
from t_orde
join (
	select sku ,min(MinPublicationDate) as min_pub_date from t_list group by sku
	) tmp 
	on tmp.sku = t_orde.sku
where PayTime <= DATE_ADD(min_pub_date,interval 30 day)
group by t_orde.sku 
)

,t_ad as ( 
select t_list.sku, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
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
	( select sku
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
		from t_ad  group by sku
	) tmp
)
-- select * from t_ad_stat where spu = 5203342 

,t_orde_stat as (
select sku 
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
-- 	,sum(TotalGross) TotalGross
	,round( count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}'),4) orders_daily
	,count( distinct PlatOrderNumber) orders_total
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30天出单链接数`
	,to_date(min(paytime)) `首次出单时间`
from t_orde 
group by sku 
)
-- 5207230

,online_companycode as (
select
    wl.sku
    ,count(distinct concat(wl.SellerSKU,wl.ShopCode,wl.asin) ) online_list_cnt
	,count(distinct CompanyCode ) online_list_CompanyCode_cnt
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and wl.IsDeleted = 0 and ms.ShopStatus='正常' and wl.ListingStatus=1
join epp on wl.sku = epp.sku and NodePathName regexp '${team1}|${team2}'
group by wl.sku
)

,online_seller as (
select wl.spu ,ms.SellUserName
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and wl.IsDeleted = 0 and ms.ShopStatus='正常' and wl.ListingStatus=1
join epp on wl.sku = epp.sku and NodePathName regexp '${team1}|${team2}' and Department='快百货'
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



,t_merage as (
select epp.sku 
	,ProductName 
	,DevelopUserName `开发人员`
	,Artist  `美工`
	,Editor  `编辑`
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,Festival `季节节日`
	,ele_name `元素` 
	,date(DATE_ADD(CreationTime,interval - 8 hour)) `添加时间`
	,left(DATE_ADD(DevelopLastAuditTime,interval - 8 hour),7) `终审月份`
	,date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) `终审时间`
	,`首次出单时间`
	,case when `首次出单时间` is null then '否' else '是' end as '是否出单'
	,date(min_pub_date) `首次刊登时间`
	,list_cnt_in3d `终审3天内刊登条数`
	,list_cnt_in7d `终审7天内刊登条数`
	,list_cnt_in15d `终审15天内刊登条数`
	,list_cnt_UK `UK刊登总条数`
	,list_cnt_DE `DE刊登总条数`
	,list_cnt_FR `FR刊登总条数`
	,list_cnt_US `US刊登总条数`

	,list_cnt `刊登条数`
    ,list_CompanyCode_cnt `刊登账号套数`
    ,online_list_cnt `在线条数`
    ,online_list_CompanyCode_cnt `在线账号套数`

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
-- 	,orders_daily `日均订单量`
	,orders_total `累计订单量`
	,TotalGross `累计销售额`
	,TotalProfit `累计利润额`
	,Profit_rate `毛利率`
	,`首登30天内出单链接数`
-- 	,round( `首登30天内出单链接数` / list_cnt ,40) `30天链接出单率`
    ,prod_seller_list SPU分配销售人
    ,online_seller_list SPU在线账号销售人
    ,unonline_seller_list SPU未刊登人员
from (select sku ,spu from epp group by sku,spu ) epp
left join 
	(select sku ,CreationTime ,DevelopLastAuditTime,ProductName ,DevelopUserName
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
	from erp_product_products wp where IsMatrix = 0
	) epp_spu on epp.sku =epp_spu.sku
left join (
	select sku ,case when TortType is null then '未标记' else TortType end TortType ,Festival ,Artist ,Editor 
		from import_data.wt_products 
		where IsDeleted =0 and CreationTime  >= '${StartDay}' and ProjectTeam='快百货' 
	) epp_spu_Tort on epp.sku =epp_spu_Tort.sku 
left join t_elem on epp.sku =t_elem.sku 
left join t_list_stat on epp.sku =t_list_stat.sku
left join t_ad_stat on epp.sku =t_ad_stat.sku
left join t_orde_stat on epp.sku =t_orde_stat.sku 
left join t_ord_list_stat on epp.sku =t_ord_list_stat.sku
left join online_companycode oc on oc.sku = epp.sku
left join prod_seller_stat pss on pss.spu = epp.spu
left join online_seller_stat oss on oss.spu = epp.spu
left join unonline_seller_stat uss on uss.spu = epp.spu
)

-- select count(1)
select * 
from t_merage
where `添加时间`>='2023-01-01'
order by sku