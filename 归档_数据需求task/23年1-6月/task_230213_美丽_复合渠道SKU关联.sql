-- SELECT COUNT(1) FROM (

select js.spu ,js.sku ,js.boxsku , js.ProjectTeam , rela.PlatformSku as `渠道sku` ,rela.ShopCode 
	,`boxsku对应订单数` ,`统计期内最后出单时间`,`产品状态`
	,wp.Festival
from (select spu, sku ,boxsku ,ProjectTeam 
		, case when ProductStatus = 0 then '正常'
			when ProductStatus = 2 then '停产'
			when ProductStatus = 3 then '停售'
			when ProductStatus = 4 then '暂时缺货'
			when ProductStatus = 5 then '清仓'
		end as `产品状态`
	from import_data.erp_product_products epp 
	where ProjectTeam  <> '快百货' and IsMatrix = 0 and IsDeleted =0
	group by spu, sku ,boxsku ,ProjectTeam  ,`产品状态`
	) js 
left join ( -- ERP渠道关联表，数据来源结合了 塞盒渠道关联页面+亚马逊API
	select BoxSku , PlatformSku ,ShopCode
	from import_data.erp_amazon_amazon_channelskus eaac 
	group by BoxSku , PlatformSku ,ShopCode
	) rela
	on js.BoxSku=rela.BoxSku
left join (
	select boxsku ,count(distinct platordernumber) `boxsku对应订单数`  --不包含未发货、作废
		, max(paytime) `统计期内最后出单时间`
	from wt_orderdetails wo where IsDeleted =0 and paytime  < '${NextStartDay}' and paytime >= '${StartDay}'
	group by boxsku
	) od 
	on js.BoxSku=od.BoxSku
left join (
	select sku,Festival
	from import_data.wt_products wp 
	where isdeleted = 0 
	) wp on js.sku = wp.sku -- 待元素标签功能稳定后直接使用wt表

-- ) TMP 
	
-- with
-- kbh_sellersku as (
-- select js.BoxSku ,rela.cnt `快百货渠道SKU关联条数`
-- from 
-- (select BoxSku from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js
-- left join (
-- 	select BoxSku , count(1) cnt
-- 	from ( 
-- 		select BoxSku , PlatformSku 
-- 		from import_data.erp_amazon_amazon_channelskus eaac 
-- 		group by BoxSku , PlatformSku 
-- 		) tmp
-- 	group by BoxSku 
-- ) rela
-- on js.BoxSku=rela.BoxSku
-- )
-- 
-- , kbh_listing_cnt as (
-- select SKU , count(1) `快百货链接在线条数`
-- from (
-- select js.SKU , eaal.Id 
-- from import_data.erp_amazon_amazon_listing eaal 
-- join (select SKU  from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js on eaal.SKU = js.SKU and ListingStatus = 1
-- join import_data.mysql_store ms on ms.Code =eaal.ShopCode and ms.ShopStatus = '正常'
-- group by js.SKU , eaal.Id 
-- ) tmo 
-- group by SKU
-- )
-- 
-- 
-- SELECT  SKU , BoxSku ,department
-- 	,`快百货渠道SKU关联条数`, `快百货链接在线条数`
-- 	, case when `快百货首次刊登时间_删除表` is not null then `快百货首次刊登时间_删除表` else `快百货首次刊登时间_未删除表` end as `快百货首次刊登时间`
-- 	, case when `特卖汇首次刊登时间_删除表` is not null then `特卖汇首次刊登时间_删除表` else `特卖汇首次刊登时间_未删除表` end as `特卖汇首次刊登时间`
-- FROM ( 
-- 
-- select js.SKu ,js.boxsku ,js.department 
-- 	,kbh_sellersku.`快百货渠道SKU关联条数`
-- 	,kbh_listing_cnt.`快百货链接在线条数`
-- 	,kbh_listing_fristtime_delete.`快百货首次刊登时间_删除表`
-- 	,kbh_listing_fristtime_nodelete.`快百货首次刊登时间_未删除表`
-- 	,tmh_listing_fristtime_delete.`特卖汇首次刊登时间_删除表`
-- 	,tmh_listing_fristtime_nodelete.`特卖汇首次刊登时间_未删除表`
-- from 
-- 	(select SKu,boxsku,SPU as department from import_data.JinqinSku where Monday ='2099-01-01' and SPU in ('GM','PM')) js
-- left join kbh_sellersku on js.BoxSku = kbh_sellersku.BoxSku
-- left join kbh_listing_cnt on js.SKU = kbh_listing_cnt.SKU
-- left join 
-- 	(  -- 快百货链接首次刊登时间
-- 	select js.SKU , min(eaald.PublicationDate) `快百货首次刊登时间_删除表`
-- 	from import_data.erp_amazon_amazon_listing_delete eaald
-- 	join (select SKU from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js on eaald.SKU = js.SKU 
-- 	group by js.SKU
-- 	) kbh_listing_fristtime_delete
-- 	on js.SKU = kbh_listing_fristtime_delete.SKU
-- left join 
-- 	(
-- 	select js.SKU , min(eaal.PublicationDate) `快百货首次刊登时间_未删除表`
-- 	from import_data.erp_amazon_amazon_listing eaal
-- 	join (select SKU from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='PM') js on eaal.SKU = js.SKU 
-- 	group by js.SKU
-- 	) kbh_listing_fristtime_nodelete
-- 	on js.SKU = kbh_listing_fristtime_nodelete.SKU
-- 	
-- left join 
-- 	(  -- 特卖汇链接首次刊登时间
-- 	select js.SKU , min(eaald.PublicationDate) `特卖汇首次刊登时间_删除表`
-- 	from import_data.erp_amazon_amazon_listing_delete eaald
-- 	join (select SKU  from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='GM') js 
-- 		on eaald.SKU = js.SKU 
-- 	group by js.SKU
-- 	) tmh_listing_fristtime_delete
-- 	on js.SKU = tmh_listing_fristtime_delete.SKU
-- left join 
-- 	(
-- 	select js.SKU , min(eaal.PublicationDate) `特卖汇首次刊登时间_未删除表`
-- 	from import_data.erp_amazon_amazon_listing eaal
-- 	join (select SKU  from import_data.JinqinSku where Monday ='2099-01-01' and SPU ='GM') js on eaal.SKU = js.SKU 
-- 	group by js.SKU
-- 	) tmh_listing_fristtime_nodelete
-- 	on js.SKU = tmh_listing_fristtime_nodelete.SKU
-- 	
-- 
-- ) TMP
-- 
-- 
	