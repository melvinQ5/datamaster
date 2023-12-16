/*
5月推款专项
统计时间范围 Q1+Q2分月
维度：SKU X 统计时间快照 x 销售团队 x 类型 
指标：在线链接、出单统计、广告指标
*/


with 
prod1 as ( -- 4月高潜商品
select c4 as sku ,c5 as push_type
from manual_table mt where c1 = '推款专项（主题+专项）_0511'
)

,prod2 as ( -- 夏季
select eppaea.sku ,group_concat(eppea.Name) push_type  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.Name = '夏季'
group by eppaea.sku 
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele_name  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku 
)

,t_prod as ( 
select wp.SKU ,SPU ,BoxSKU ,ProductName 
	,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
	,TortType
	,Festival
	,ele_name
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,DevelopUserName
	,push_type
from import_data.wt_products wp 
-- join prod1 on wp.sku =prod1.sku
join prod2 on wp.sku =prod2.sku
left join t_elem on wp.sku =t_elem.sku 
)

,t_list as ( -- 新品链接
select  SellerSKU ,ShopCode ,asin 
	, site
	, NodePathName 
	, ms.CompanyCode 
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,push_type
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
where wl.IsDeleted = 0 and ms.Department = '快百货' and ms.ShopStatus = '正常' and ListingStatus = 1
)

,t_ad as ( -- 广告明细
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	,t_list.site
	, NodePathName 
	, SellUserName 
	, t_list.push_type
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  < '${NextStartDay}'
)
-- select * from t_ad 

,t_orde as (  
select 
	PlatOrderNumber ,TotalGross,TotalProfit ,FeeGross
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	, t_prod.push_type
	, NodePathName 
	, SellUserName
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on t_prod.sku = wo.Product_Sku  
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
	and OrderStatus != '作废' and ms.Department = '快百货'
)
-- select * from t_orde 

,t_list_stat as (
select SKU , NodePathName ,push_type
	,count(distinct CompanyCode ) `在线链接账号数` 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `在线链接数` 
	,count(distinct case when MarketType in ('UK','DE','FR')  then concat(SellerSKU,ShopCode) end ) `UK_DE_FR在线链接数`
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) `UK在线链接数`
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) `DE在线链接数`
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) `FR在线链接数`
from t_list
group by SKU , NodePathName ,push_type
)

,t_list_uproll_stat as (
select SKU ,push_type
	,count(distinct CompanyCode ) `在线链接账号数_SKU` 
	,count(distinct case when NodePathName in ('快次元-成都销售组','快次方-成都销售组') then CompanyCode end ) `在线链接账号数_成都` 
	,count(distinct case when NodePathName in ('运营组-泉州1组','运营组-泉州2组','运营组-泉州3组') then CompanyCode end ) `在线链接账号数_泉州`
from t_list
group by SKU ,push_type
)

,t_sale_stat as (
select sku , NodePathName ,push_type
	,round(sum(TotalGross/ExchangeUSD)) `销售额` 
	,round(sum(TotalProfit/ExchangeUSD)) `利润额` 
	,count(distinct PlatOrderNumber) `订单数` 
	,round( sum( FeeGross/ExchangeUSD )) `运费收入`
from t_orde
group by sku , NodePathName ,push_type
)

, t_site_sort as (  -- 每个SKU 近3月销量top2的站点 
select sku ,GROUP_CONCAT(site) 销量主站点_SKU
from (
	select * , ROW_NUMBER () over (partition by sku order by sales desc ) sort 
	from (
		select Product_Sku as sku ,  ms.Site , sum(SaleCount) sales
		from import_data.wt_orderdetails wo 
		join mysql_store ms on ms.Code = wo.shopcode 
		join t_prod on t_prod.sku = wo.Product_Sku  
		where PayTime >= date_add(current_date(),interval - 3 month) 
			and PayTime < current_date()
			and OrderStatus != '作废' and ms.Department = '快百货'
		group by Product_Sku ,  ms.Site
		) tb 
	where sales > 0
	) tc 
where sort <= 2 
group by sku
)

, t_ad_stat as (
select tmp.* 
	, round(Clicks/Exposure,4) as CTR
	, round(TotalSale7DayUnit/Clicks,6) as CVR
	, round(TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/Clicks,4) as `CPC`
from 
	( select sku , NodePathName ,push_type
		-- 曝光量
		, round(sum( Exposure )) as Exposure
		-- 广告花费
		, round(sum( cost*ExchangeUSD),2) as ad_Spend
		-- 广告销售额
		, round(sum( TotalSale7Day ),2) as TotalSale7Day
		-- 广告销量	
		, round(sum( TotalSale7DayUnit ),2) as TotalSale7DayUnit
		-- 点击量
		, round(sum( Clicks )) as Clicks
		from t_ad  group by sku , NodePathName ,push_type
	) tmp  
)


,t_merge as (
select 
	ta.push_type 类型
	,replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') 统计时间范围
	,ta.NodePathName 销售团队
	,spu
	,ta.sku 
	,ta.boxsku
	,ProductName
	,TortType 侵权状态
	,Festival 季节节日
	,ele_name 元素名称
	,date(DevelopLastAuditTime) 终审日期
	,DevelopUserName 开发人员
	,销量主站点_SKU
	,在线链接账号数_SKU
	,在线链接账号数_成都
	,在线链接账号数_泉州
	,在线链接账号数
	,在线链接数
	,UK_DE_FR在线链接数
	,UK在线链接数
	,DE在线链接数
	,FR在线链接数
	,销售额
	,利润额  -- 订单表按产品维度聚合，未扣广告费
	,利润额 - ad_Spend  as 利润额_扣广告
	,订单数
	,运费收入
	,Exposure
	,Clicks 
	,ad_Spend 
	,TotalSale7Day AS ad_sale_amount
	,TotalSale7DayUnit AS ad_sale_unit
	,CTR
	,CVR 
	,CPC
	,ACOS
	,ROAS
from (
	select t_prod.* ,t.NodePathName
	from t_prod 
	cross join ( select distinct NodePathName from import_data.mysql_store where department = '快百货' ) t 
	) ta
left join t_list_uproll_stat tb on ta.sku = tb.sku and ta.push_type = tb.push_type 
left join t_sale_stat tc on ta.sku = tc.sku and ta.push_type = tc.push_type and ta.NodePathName = tc.NodePathName
left join t_ad_stat td on ta.sku = td.sku and ta.push_type = td.push_type and ta.NodePathName = td.NodePathName
left join t_list_stat te on ta.sku = te.sku and ta.push_type = te.push_type and ta.NodePathName = te.NodePathName
left join t_site_sort tf on ta.sku = tf.sku
)

select * from t_merge
