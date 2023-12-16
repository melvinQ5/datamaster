-- 3月至今终审产品，单量及平均客单价


with epp as ( -- sku 
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '2023-05-01'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货' and Status != 20
group by SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)
)
-- select * from epp where sku =  5211271.01

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join epp on eppaea.sku = epp.sku 
group by eppaea.sku 
)

-- ,t_list as ( -- 刊登时间在2月1日至今
-- select wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
-- 	,DATE_ADD(epp.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
-- from import_data.wt_listing wl 
-- join import_data.mysql_store ms on wl.ShopCode = ms.Code 
-- join epp on wl.sku = epp.sku 
-- where 
-- 	MinPublicationDate>= '${StartDay}' 
-- 	and MinPublicationDate <'${NextStartDay}' 
-- 	and wl.IsDeleted = 0 
-- 	and ms.Department = '快百货' 
-- )

,t_orde as ( 
select OrderNumber ,wo.PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode ,asin 
	,ExchangeUSD,TransactionType,wo.SellerSku,RefundAmount,wo.SaleCount 
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
-- 	,timestampdiff(second,MinPublicationDate,PayTime)/86400 as ord_days -- 订单表中为最早刊登时间
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
-- left join (
-- 	select shopcode,SellerSku,MinPublicationDate from t_list group by shopcode,SellerSku,MinPublicationDate 
-- 	) t_list
-- 	on wo.shopcode = t_list.shopcode and wo.SellerSku = t_list.SellerSku 
join epp on wo.Product_SKU = epp.sKU
left join (select PlatOrderNumber from wt_orderdetails 
	where FeeGross > 0 
		and PayTime >= '2023-03-01' and PayTime < '2023-05-01'
		and IsDeleted=0 
	group by PlatOrderNumber 
	) tb on wo.PlatOrderNumber =tb.PlatOrderNumber
where 
	PayTime >= '2023-03-01' and PayTime < '2023-05-01'
	and wo.IsDeleted=0 
	and ms.Department = '快百货' 
	and tb.PlatOrderNumber is null  -- 剔除运费单
)
-- select * from t_orde 


-- ,t_list_stat as ( -- 刊登统计
-- select t_list.sku
-- 	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
-- 	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
-- 	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=15 then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
-- 	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
-- 	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
-- 	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
-- 	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
-- 	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode,t_list.asin) ) list_cnt
-- 	,min(MinPublicationDate) as min_pub_date 
-- from t_list 
-- group by t_list.sku
-- )
-- select * from t_list_stat

-- ,t_ord_list_stat as (
-- select t_orde.sku 
-- 	,count(distinct concat(t_orde.SellerSKU,t_orde.ShopCode,t_orde.asin)) `首登30天内出单链接数`
-- from t_orde
-- join (
-- 	select sku ,min(MinPublicationDate) as min_pub_date from t_list group by sku
-- 	) tmp 
-- 	on tmp.sku = t_orde.sku
-- where PayTime <= DATE_ADD(min_pub_date,interval 30 day)
-- group by t_orde.sku 
-- )

-- ,t_ad as ( 
-- select t_list.sku, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
-- 	, DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- 广告
-- 	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 7*86400 then '是' else '否' end `是否7天`
-- 	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 14*86400 then '是' else '否' end `是否14天`
-- 	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 30*86400 then '是' else '否' end `是否30天`
-- from t_list
-- join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
-- -- 	and t_list.spu= 5202143
-- where asa.CreatedTime >= '${StartDay}'
-- )
-- 
-- ,t_ad_stat as (
-- select tmp.* 
-- 	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `终审7天点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `终审14天点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `终审30天点击率`
-- 	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `终审7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `终审14天广告转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `终审30天广告转化率`
-- from 
-- 	( select sku
-- 		-- 曝光量
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
-- 		, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
-- 		-- 点击量
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
-- 		, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
-- 		-- 销量	
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
-- 		, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
-- 		from t_ad  group by sku
-- 	) tmp
-- )
-- select * from t_ad_stat where spu = 5203342 

-- ,t_orde_stat as (
-- select sku 
-- 	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
-- 	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
-- 	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
-- -- 	,sum(TotalGross) TotalGross
-- 	,round( count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}'),4) orders_daily
-- 	,count( distinct PlatOrderNumber) orders_total
-- 	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
-- 	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
-- 	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
-- 	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30天出单链接数`
-- 	,to_date(min(paytime)) `首次出单时间`
-- from t_orde 
-- group by sku 
-- )

-- 将上面代码改为下面 拆团队销售数据
,t_orde_stat as (
select sku 
	,round(sum(TotalGross/ExchangeUSD)) `销售额` 
	,round(sum(case when NodePathName ='快次元-成都销售组' then TotalGross/ExchangeUSD end )) `销售额_成1` 
	,round(sum(case when NodePathName ='快次方-成都销售组' then TotalGross/ExchangeUSD end )) `销售额_成2` 
	,round(sum(case when NodePathName ='运营组-泉州1组' then TotalGross/ExchangeUSD end )) `销售额_泉1` 
	,round(sum(case when NodePathName ='运营组-泉州2组' then TotalGross/ExchangeUSD end )) `销售额_泉2` 
	,round(sum(case when NodePathName ='运营组-泉州3组' then TotalGross/ExchangeUSD end )) `销售额_泉3` 
	
	,round(sum(TotalProfit/ExchangeUSD)) `利润额` 
	,round(sum(case when NodePathName ='快次元-成都销售组' then TotalProfit/ExchangeUSD end )) `利润额_成1` 
	,round(sum(case when NodePathName ='快次方-成都销售组' then TotalProfit/ExchangeUSD end )) `利润额_成2` 
	,round(sum(case when NodePathName ='运营组-泉州1组' then TotalProfit/ExchangeUSD end )) `利润额_泉1` 
	,round(sum(case when NodePathName ='运营组-泉州2组' then TotalProfit/ExchangeUSD end )) `利润额_泉2` 
	,round(sum(case when NodePathName ='运营组-泉州3组' then TotalProfit/ExchangeUSD end )) `利润额_泉3` 
	
	,sum(salecount) `出单SKU件数` 
	,sum( case when NodePathName ='快次元-成都销售组' then salecount end ) `出单SKU件数_成1` 
	,sum( case when NodePathName ='快次方-成都销售组' then salecount end ) `出单SKU件数_成2` 
	,sum( case when NodePathName ='运营组-泉州1组' then salecount end ) `出单SKU件数_泉1` 
	,sum( case when NodePathName ='运营组-泉州2组' then salecount end ) `出单SKU件数_泉2` 
	,sum( case when NodePathName ='运营组-泉州3组' then salecount end ) `出单SKU件数_泉3` 

	,count(distinct PlatOrderNumber) `订单数` 
	,count(distinct case when NodePathName ='快次元-成都销售组' then  PlatOrderNumber end ) `订单数_成1`
	,count(distinct case when NodePathName ='快次方-成都销售组' then  PlatOrderNumber end ) `订单数_成2`
	,count(distinct case when NodePathName ='运营组-泉州1组' then  PlatOrderNumber end ) `订单数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then  PlatOrderNumber end ) `订单数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then  PlatOrderNumber end ) `订单数_泉3` 
-- 
-- 	,count(distinct concat(shopcode,sellersku) ) `出单链接数` 
-- 	,count(distinct case when NodePathName ='快次元-成都销售组' then  concat(shopcode,sellersku) end ) `出单链接数_成1`
-- 	,count(distinct case when NodePathName ='快次方-成都销售组' then  concat(shopcode,sellersku) end ) `出单链接数_成2`
-- 	,count(distinct case when NodePathName ='运营组-泉州1组' then  concat(shopcode,sellersku) end ) `出单链接数_泉1` 
-- 	,count(distinct case when NodePathName ='运营组-泉州2组' then  concat(shopcode,sellersku) end ) `出单链接数_泉2` 
-- 	,count(distinct case when NodePathName ='运营组-泉州3组' then  concat(shopcode,sellersku) end ) `出单链接数_泉3` 

-- 	,count(distinct Market ) `出单市场数` 
-- 	,count(distinct case when NodePathName ='快次元-成都销售组' then  Market end ) `出单市场数_成1` 
-- 	,count(distinct case when NodePathName ='快次方-成都销售组' then  Market end ) `出单市场数_成2` 
-- 	,count(distinct case when NodePathName ='快次元-泉州1组' then  Market end ) `出单市场数_泉1` 
-- 	,count(distinct case when NodePathName ='快次元-泉州2组' then  Market end ) `出单市场数_泉2` 
-- 	,count(distinct case when NodePathName ='快次元-泉州3组' then  Market end ) `出单市场数_泉3` 

from t_orde
group by sku
)
-- 5207230

,t_merage as (
select 
	left(DATE_ADD(DevelopLastAuditTime,interval - 8 hour),7) `终审月份`
	,epp.sku 
	,ProductName 
	,DevelopUserName `开发人员`
	,ProductStatus `产品状态`
	,TortType `侵权状态`
	,Festival `季节节日`
	,ele_name `元素` 
	
	,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) `终审时间`
	,replace(concat(right('2023-03-01',5),'至',right(to_date(date_add('2023-05-01',-1)),5)),'-','') `订单统计时间范围`
	
	,round(销售额/订单数,2)  `平均客单`
	,round(销售额_成1/订单数_成1,2)  `平均客单_成1`
	,round(销售额_成2/订单数_成2,2)  `平均客单_成2`
	,round(销售额_泉1/订单数_泉1,2)  `平均客单_泉1`
	,round(销售额_泉2/订单数_泉2,2)  `平均客单_泉2`
	,round(销售额_泉3/订单数_泉3,2)  `平均客单_泉3`
	
	, `销售额`
	, `销售额_成1` 
	, `销售额_成2` 
	, `销售额_泉1` 
	, `销售额_泉2` 
	, `销售额_泉3` 
	
	,`利润额`
	,`利润额_成1` 
	,`利润额_成2` 
	,`利润额_泉1` 
	,`利润额_泉2` 
	,`利润额_泉3` 
	
	,round(利润额 / 销售额,2)  `毛利率`
	,round(利润额_成1 / 销售额_成1,2)  `毛利率_成1`
	,round(利润额_成2 / 销售额_成2,2)  `毛利率_成2`
	,round(利润额_泉1 / 销售额_泉1,2)  `毛利率_泉1`
	,round(利润额_泉2 / 销售额_泉2,2)  `毛利率_泉2`
	,round(利润额_泉3 / 销售额_泉3,2)  `毛利率_泉3`
	
	,`订单数`
	,`订单数_成1` 
	,`订单数_成2` 
	,`订单数_泉1` 
	,`订单数_泉2` 
	,`订单数_泉3` 
	
-- 	,`出单SKU件数`
-- 	,`出单SKU件数_成1` 
-- 	,`出单SKU件数_成2` 
-- 	,`出单SKU件数_泉1` 
-- 	,`出单SKU件数_泉2` 
-- 	,`出单SKU件数_泉3` 

	
-- 	,Artist  `美工`
-- 	,Editor  `编辑`
-- 	,to_date(DATE_ADD(CreationTime,interval - 8 hour)) `添加时间`
from (select sku from epp group by sku ) epp 
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
		where IsDeleted =0  and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' and ProjectTeam='快百货' 
	) epp_spu_Tort on epp.sku =epp_spu_Tort.sku 
left join t_elem on epp.sku =t_elem.sku 
-- left join t_list_stat on epp.sku =t_list_stat.sku
-- left join t_ad_stat on epp.sku =t_ad_stat.sku
left join t_orde_stat on epp.sku =t_orde_stat.sku 
-- left join t_ord_list_stat on epp.sku =t_ord_list_stat.sku
)

-- select count(1)
select * 
from t_merage
order by 终审月份 