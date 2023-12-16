/*
激励时间：2023.2.13至2023.3.12
取值条件：在激励时间范围内，由美工编辑处理完成，进入开发终审的新品，即编辑提交时间2023.2.13--2023.3.12所有新品；美工提交时间2023.2.13--2023.3.12所有新品
分析维度：日期、美工、编辑、SKU数、曝光量、曝光SKU占比、点击量、点击率
美工数据：日均产出达到15款以上，取个人的整体图片点击率（个人总点击/个人总曝光）
编辑数据：日均产出达到15款以上，取个人的曝光量占比（个人有曝光SKU数量/个人总SKU数量）
数据说明：编辑、美工数据表格拉取数据后，设置公式计算（计算逻辑公式如上）

我增加了实际处理SPU数，日均处理美丽让取真实值。曝光量占比门槛确定设为：日均曝光≥1（日均款数现在这里算的包含了周末，只计算实际工作日的日均款数）

*/

-- 0212-0302 共休息4天 RestDays = 4 
-- 0212-0306 共休息4天 RestDays = 6 
-- 0212-0312 共休息4天 RestDays = 7

with art_sku as (
select HandleUserName , SKU ,SPU ,ProductId
from import_data.erp_product_products epp 
join (
	select ProductId  ,HandleUserName 
	from import_data.erp_product_product_statuses
	where AuditTime  < '${NextStartDay}' and AuditTime >= '${StartDay}' 
		and DevelopStage = 40
	group by ProductId  ,HandleUserName 
	) art on epp.Id = art.ProductId
where HandleUserName in ('沈庆雯','张娟','涂宇佳','黄雪莉') and DevelopLastAuditTime is not null 
group by HandleUserName , SKU ,SPU ,ProductId
)

, art_adserving as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin 
		,Clicks as AdClicks ,Exposure as AdExposure
		,eaal.SKU 
from (		
	select eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	from import_data.erp_amazon_amazon_listing eaal 
	join art_sku t on eaal.sku = t.SKU and eaal.ListingStatus = 1 
	group by eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	) eaal
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day)/*时间维度*/
		and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 	
-- join import_data.mysql_store s on ad.ShopCode=s.Code  and department = '快百货'
)

, art_stat as (
 select
 	HandleUserName 
 	, round(sum(AdClicks)/sum(AdExposure),10) `广告点击率`
 	, count(DISTINCT t.sku) `美工审过且终审通过SKU数`
 	, count(DISTINCT t.sPU) `对应SPU数`
 from art_sku t 
 left join (
	select SKU ,sum(AdClicks) AdClicks,sum(AdExposure) AdExposure
 	from art_adserving 
 	group by SKU ) ads
 	on ads.SKU =t.SKU  
 group by HandleUserName
)

-- 美工
select HandleUserName ,`广告点击率` 
	,`美工审过且终审通过SKU数` 
-- 	,`对应SPU数`
-- 	,round(`对应SPU数`/(datediff('${NextStartDay}','2023-02-13')-'${RestDays}') ,1) `日均处理SPU数` 
from art_stat
where HandleUserName in ('沈庆雯','张娟','涂宇佳','黄雪莉')
order by HandleUserName


WITH editor_sku as ( -- 编辑处理的sku
select HandleUserName , epp.SKU ,epp.SPU 
from import_data.erp_product_products epp 
join ( 
	select ProductId  ,HandleUserName 
	from import_data.erp_product_product_statuses
	where AuditTime  < '${NextStartDay}' and AuditTime >= '${StartDay}' 
		and DevelopStage = 50
	group by ProductId  ,HandleUserName 
	) editor 
on epp.Id = editor.ProductId
where HandleUserName in ('朱玉洁','刘冬','符雪花','赵晋') and DevelopLastAuditTime is not null 
group by HandleUserName , epp.SKU ,epp.SPU 
)


, editor_adserving as ( -- 编辑处理SKU的 广告数据
select ad.ShopCode ,ad.SellerSKU ,ad.Asin 
		,Clicks as AdClicks ,Exposure as AdExposure
		,eaal.SKU 
from (		
	select eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	from import_data.erp_amazon_amazon_listing eaal 
	join editor_sku t on eaal.sku = t.SKU 
-- 	and eaal.ListingStatus = 1 
	and LENGTH(eaal.SKU) > 0 
	group by eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	) eaal
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day)/*时间维度*/
		and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 	
-- join import_data.mysql_store s on ad.ShopCode=s.Code  and department = '快百货'
)


, editor_stat_expo as ( -- 日均曝光量
select SKU , AdExposure_stat/(datediff('${NextStartDay}','2023-02-13')-'${RestDays}') as daily_ADexpo
from (
	select SKU,sum(AdExposure) AdExposure_stat 
	from editor_adserving group by SKU
	) tmp 
)


, editor_stat as ( -- 取个人的曝光量占比（个人有曝光SKU数量/个人总SKU数量）
select HandleUserName
	, count(distinct case when daily_ADexpo >= 1
		then editor_stat_expo.sku end)/count(distinct editor_stat_expo.sku) `日均曝光大于等于1的SKU占比`
	, count(DISTINCT editor_sku.sku) `编辑审过且终审通过SKU数`
	, count(DISTINCT editor_sku.spu) `对应SPU数`
from editor_sku
left join editor_stat_expo on editor_sku.SKU =editor_stat_expo.SKU  
group by HandleUserName
)


-- 编辑
select HandleUserName 
	,`日均曝光大于等于1的SKU占比` 
	,`编辑审过且终审通过SKU数` 
from editor_stat
where HandleUserName in ('朱玉洁','刘冬','符雪花','赵晋')
order by HandleUserName

