

/*
我需要bysku  售价、毛利率、刊登时间   bysku维度 的数据
    20、21、22、15周
在线链接售价（UK DE FR US  CA)
SKU 泉州最早刊登时间
SKU 成都最早刊登时间
挂单利润率（排除运费收入）
  */

with
-- step1 数据源处理
t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku
)


,t_prod as (
select ta.* ,tb.TortType
from (
	select wp.Spu ,wp.SKU ,BoxSku ,DevelopUserName
		,date_add(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
		,weekofyear( date_add(DevelopLastAuditTime,interval - 8 hour) )+1 dev_week
		,Cat1 ,Cat2 ,ProductName ,CreationTime
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
		,t_elem.ele
	from import_data.wt_products wp
	left join t_elem on wp.sku =t_elem.sku
	where IsDeleted =0
	  and weekofyear( date_add(DevelopLastAuditTime,interval - 8 hour) )+1 in (20,21,22,15) -- 四周开发
	  and year(date_add(DevelopLastAuditTime,interval - 8 hour)) = 2023
	  and ProjectTeam='快百货'
	) ta
left join (
	select SKU ,group_concat(case when TortType is null then '未标记' else TortType end ) TortType from import_data.wt_products
	where IsDeleted =0 and weekofyear( date_add(DevelopLastAuditTime,interval - 8 hour) )+1 in (20,21,22,15)  and ProjectTeam='快百货'
	group by SKU
	) tb
	on ta.SKU = tb.SKU
)


,t_copy_new_pp as ( -- 2月复制产品非新品
select eppcr.NewProdId, null spu ,epp.sku
from import_data.erp_product_product_copy_relations eppcr
join import_data.erp_product_products epp on eppcr .NewProdId = epp.Id
where  epp.IsMatrix =0 and eppcr.IsDeleted = 0
group by eppcr.NewProdId, epp.sku
union
select eppcr.NewProdId, epp.spu ,null sku
from import_data.erp_product_product_copy_relations eppcr
join import_data.erp_product_products epp on eppcr.NewProdId = epp.Id
where  epp.IsMatrix =1 and eppcr.IsDeleted = 0
group by eppcr.NewProdId, epp.spu
)


,t_orde as (  -- 每周出单明细
select
	OrderNumber ,PlatOrderNumber ,wo.Market
	,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,PurchaseCosts ,FeeGross
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
-- 	and paytime >= '2023-02-01'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
)

,t_list as ( -- 在线链接
select wl.BoxSku ,wl.SKU ,MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN ,wl.price ,wl.MarketType AS site
	,WEEKOFYEAR( MinPublicationDate) pub_week
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
	,DATE_ADD(t_prod.DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from wt_listing wl -- 因为最终输出落到具体sku,所以不需要使用erp表
join import_data.mysql_store ms on wl.ShopCode = ms.Code
join t_prod on t_prod.sku = wl.SKU
where
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
)
-- select * from t_list

,t_onway_sku  as (
select boxsku
-- 	, sum(Price - DiscountedPrice) `在途产品采购金额CNY`
-- 	, ROUND(ifnull(sum(SkuFreight),0),2) `在途产品分摊运费CNY`
	,ifnull(sum(Quantity),0) `在途SKU件数`
from (
	select Price ,DiscountedPrice , SkuFreight ,boxsku,Quantity
	from wt_purchaseorder wp
	where ordertime < '${NextStartDay}' and ordertime >= '2023-01-01'
		and isOnWay = "是" and WarehouseName = '东莞仓'
	) tmp
group by boxsku
)

,t_instock_sku as (
SELECT boxsku
-- 	,sum(ifnull(TotalPrice,0)) `在仓产品金额CNY`
	,sum(ifnull(TotalInventory,0)) `在仓sku件数`
-- 	,count(*) `在仓sku数`
FROM ( -- local_warehouse 本地仓表
	select TotalPrice, TotalInventory ,boxsku
	FROM import_data.daily_WarehouseInventory wi
	where WarehouseName = '东莞仓' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
	)  tmp
group by boxsku
)

,t_list_stat as ( -- 表1 刊登计算
select BoxSKU
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `在线链接数`
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1`
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2`
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1`
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2`
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉3`
	,min( case when NodePathName regexp '运营组-泉州' then MinPublicationDate end) `泉州首次刊登时间`
	,min( case when NodePathName regexp '-成都销售组' then MinPublicationDate end) `成都首次刊登时间`
	,avg( case when site = 'UK' then Price end) `UK平均售价`
	,avg( case when site = 'DE' then Price end) `DE平均售价`
	,avg( case when site = 'FR' then Price end) `FR平均售价`
	,avg( case when site = 'US' then Price end) `US平均售价`
	,avg( case when site = 'CA' then Price end) `CA平均售价`
from t_list
group by BoxSKU
)
-- select * from t_list_stat where boxsku = 4478758

,t_ad as (
select t_list.boxsku, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
    , NodePathName
	, DevelopLastAuditTime
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- 广告
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU
where asa.CreatedTime >= '2023-03-01'
)

,t_ad_stat as (
select tmp.*
	, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `终审14天广告点击率`
	, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `终审14天广告转化率`

	, round(ad14_sku_Clicks_cd/ad14_sku_Exposure_cd,4) as `终审14天广告点击率_成都`
	, round(ad14_sku_TotalSale7DayUnit_cd/ad14_sku_Clicks_cd,6) as `终审14天广告转化率_成都`

	, round(ad14_sku_Clicks_qz/ad14_sku_Exposure_qz,4) as `终审14天广告点击率_泉州`
	, round(ad14_sku_TotalSale7DayUnit_qz/ad14_sku_Clicks_qz,6) as `终审14天广告转化率_泉州`

from
	( select boxsku
		-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		-- 销量
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit

		-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 14 and NodePathName regexp '成都' then Exposure end)) as ad14_sku_Exposure_cd
		, round(sum(case when 0 < ad_days and ad_days <= 14 and NodePathName regexp '泉州' then Exposure end)) as ad14_sku_Exposure_qz
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 14 and NodePathName regexp '成都' then Clicks end)) as ad14_sku_Clicks_cd
		, round(sum(case when 0 < ad_days and ad_days <= 14 and NodePathName regexp '泉州' then Clicks end)) as ad14_sku_Clicks_qz
		-- 销量
		, round(sum(case when 0 < ad_days and ad_days <= 14 and NodePathName regexp '成都' then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit_cd
		, round(sum(case when 0 < ad_days and ad_days <= 14 and NodePathName regexp '泉州' then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit_qz
		from t_ad  group by boxsku
	) tmp
)


,t_sale_stat as (
select BoxSKU
    ,round(sum((TotalGross-FeeGross)/ExchangeUSD)) `扣运费收入销售额`
    ,round(sum((TotalProfit-FeeGross)/ExchangeUSD)) `扣运费收入利润额`

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

	,count(distinct concat(shopcode,sellersku) ) `出单链接数`
	,count(distinct case when NodePathName ='快次元-成都销售组' then  concat(shopcode,sellersku) end ) `出单链接数_成1`
	,count(distinct case when NodePathName ='快次方-成都销售组' then  concat(shopcode,sellersku) end ) `出单链接数_成2`
	,count(distinct case when NodePathName ='运营组-泉州1组' then  concat(shopcode,sellersku) end ) `出单链接数_泉1`
	,count(distinct case when NodePathName ='运营组-泉州2组' then  concat(shopcode,sellersku) end ) `出单链接数_泉2`
	,count(distinct case when NodePathName ='运营组-泉州3组' then  concat(shopcode,sellersku) end ) `出单链接数_泉3`

	,count(distinct Market ) `出单市场数`
	,count(distinct case when NodePathName ='快次元-成都销售组' then  Market end ) `出单市场数_成1`
	,count(distinct case when NodePathName ='快次方-成都销售组' then  Market end ) `出单市场数_成2`
	,count(distinct case when NodePathName ='快次元-泉州1组' then  Market end ) `出单市场数_泉1`
	,count(distinct case when NodePathName ='快次元-泉州2组' then  Market end ) `出单市场数_泉2`
	,count(distinct case when NodePathName ='快次元-泉州3组' then  Market end ) `出单市场数_泉3`

from t_orde
group by BoxSKU
)

-- select NodePathName from mysql_store ms  group by NodePathName

-- select * from t_sale_stat
--
-- -- 表1 sku明细输出
-- select count(1) from (

select
	dev_week `终审周次`
	,t_prod.spu
	,t_prod.sku
	,t_prod.boxsku
	,t_prod.ele `元素`
	,t_prod.cat1 `一级类目`
	,t_prod.ProductStatus `产品状态`
	,t_prod.TortType `侵权状态`
	,t_prod.ProductName
	,t_prod.DevelopUserName `开发人员`
	,to_date(t_prod.DevelopLastAuditTime) `终审时间`
	
	,date(t_prod.CreationTime) `产品添加时间`
    ,`扣运费收入销售额`
    ,`扣运费收入利润额`
    ,round( `扣运费收入利润额` /`扣运费收入销售额` ,4 ) `扣运费收入利润率`
    ,`泉州首次刊登时间`
    ,`成都首次刊登时间`
    ,`UK平均售价`
    ,`DE平均售价`
     ,`FR平均售价`
     ,`US平均售价`
     ,`CA平均售价`
     ,ad14_sku_Exposure `终审14天广告曝光`
     ,ad14_sku_Exposure_cd  `终审14天广告曝光_成都`
     ,ad14_sku_Exposure_qz  `终审14天广告曝光_泉州`
	,ad14_sku_Clicks `终审14天广告点击`
	,ad14_sku_Clicks_cd `终审14天广告点击_成都`
	,ad14_sku_Clicks_qz `终审14天广告点击_泉州`
	,`终审14天广告点击率`
	,`终审14天广告点击率_成都`
	,`终审14天广告点击率_泉州`
	,`终审14天广告转化率`
	,`终审14天广告转化率_成都`
	,`终审14天广告转化率_泉州`

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

	,`订单数`
	,`订单数_成1`
	,`订单数_成2`
	,`订单数_泉1`
	,`订单数_泉2`
	,`订单数_泉3`

	,`出单SKU件数`
	,`出单SKU件数_成1`
	,`出单SKU件数_成2`
	,`出单SKU件数_泉1`
	,`出单SKU件数_泉2`
	,`出单SKU件数_泉3`

	,`出单链接数`
	,`出单链接数_成1`
	,`出单链接数_成2`
	,`出单链接数_泉1`
	,`出单链接数_泉2`
	,`出单链接数_泉3`

	,`在线链接数`
	,`在线链接数_成1`
	,`在线链接数_成2`
	,`在线链接数_泉1`
	,`在线链接数_泉2`
	,`在线链接数_泉3`

	,`出单市场数`
	,`出单市场数_成1`
	,`出单市场数_成2`
	,`出单市场数_泉1`
	,`出单市场数_泉2`
	,`出单市场数_泉3`

-- 	,`首次出单时间`
-- 	,`在途SKU件数`
-- 	,`在仓SKU件数`
-- 	,`在途产品采购金额CNY`
-- 	,`在途产品分摊运费CNY`
-- 	, `在仓产品金额CNY`

from t_prod
left join t_sale_stat on t_prod.boxsku =t_sale_stat.boxsku
left join t_list_stat on t_prod.boxsku =t_list_stat.boxsku
left join t_ad_stat on t_prod.boxsku =t_ad_stat.boxsku
left join t_onway_sku on t_prod.boxsku =t_onway_sku.boxsku
left join t_instock_sku on t_prod.boxsku =t_instock_sku.boxsku
-- where t_prod.CreationTime >= '2023-01-01'
-- where t_prod.boxsku =4747105

-- ) tmp