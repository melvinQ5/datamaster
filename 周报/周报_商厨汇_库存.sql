-- 商厨汇
/*
目标：计算全流程库存资金占用
库存资金占用 = 
	FBA在仓产品金额 + FBA头程在途产品金额 + FBA头程运费
	海外仓在仓产品金额 + 海外仓头程在途产品金额 + 海外仓头程运费
	国内采购在途 + 国内在仓产品金额 

import_data.daily_HeadwayDelivery 
	记录头程运费 ，状态表，每天清空刷新
	最小粒度：UNIQUE KEY(`BoxSku`, `ShopCode`, `ReceiveWarehouse`, `PackageNumber`)
	计算指标：
		 -- 1 （FBA+海外仓）在仓产品金额 = RemainQuantity * PurchaseFee = 剩余数量 * 产品采购成本（元/个）
		1 SKU运费  筛选 R》0的 总运费/总数量=单件运费 
		2 SKU产品成本

import_data.daily_FBAInventory_Box 
	来源：官方Api返回
	记录FBA仓库在途 ，快照表 ，使用T-1的数据
	最小粒度：UNIQUE KEY(`GenerateDate`, `BoxSku`, `Shopcode`, `Warehouse`)
	计算指标：FBA 头程在途产品金额  
	
import_data.FBAInventory 
	来源：紫鸟后台
	记录FBA在仓金额
	
		wt_store
import_data.daily_ABroadWarehouse daw
	来源：塞盒\仓储\海外仓备货， 物流供应商API返回
	记录海外仓库 ，快照表 ，使用T-1的数据
	最小粒度：UNIQUE KEY(`GenerateDate`, `BoxSku`, `Warehouse`)
	计算指标：海外仓 头程在途产品金额、在仓产品金额、
*/

-- 关于调拨 
-- 存在一种情况是从海外仓往FBA仓调货，导致 头程表中没有该BOXSKU记录，但实际FBA仓库中有。
-- 目前在解决 不准从海外仓往FBA调货，只能从海外仓发给客户。
-- 结论：不存在海外仓发往FBA

-- =================

select sum(TotalPrice)
from import_data.daily_WarehouseInventory dwi 
where WarehouseName = '东莞-备库仓' and CreatedTime ='2023-03-08'


-- 用sellersku匹配出sku 
select eaac.BoxSKU , eaac.sku , f.*
from import_data.FBAInventory f 
left join erp_amazon_amazon_channelskus eaac on f.SellerSku = eaac.PlatformSku 
where ReportType = '周报' and Monday = '2023-03-06'
)

-- 用asin匹配出sku
select listing_map.sku ,listing_map.boxsku ,f.* 
from import_data.FBAInventory f
left join (
	select wl.SKU ,wl.BoxSku , f.asin 
	from import_data.FBAInventory f 
	join wt_listing wl on f.Asin  = wl.asin and f.ShopCode  = wl.shopcode
	where ReportType = '周报' and Monday = '2023-03-06'
	group by wl.SKU ,wl.BoxSku , f.asin 
	) listing_map
	on f.asin = listing_map.asin 
where ReportType = '周报' and Monday = '2023-03-06'

select 2796/14
-- 导出
select *
from import_data.daily_FBAInventory_Box dfb 
where
-- 	BoxSku =4375397 and 
	GenerateDate = '2023-03-13'

onWarehouse_prod_amount as (
select   
	sum(RemainQuantity * PurchaseFee) `FBA+海外仓在仓产品金额`
	sum(case when ReceiveWarehouse regexp 'FBA' then RemainQuantity * PurchaseFee end)  `FBA在仓产品金额`
	sum(case when ReceiveWarehouse not regexp 'FBA' then RemainQuantity * PurchaseFee end)  `FBA在仓产品金额`
from import_data.daily_HeadwayDelivery dhd 
join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '商厨汇' 
)



-- ,onWarehouse_fee_amount as (
-- select   `FBA+海外仓在途运费`
-- from import_data.daily_HeadwayDelivery dhd 
-- join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '商厨汇' 
-- )

, FBA_onWay AS (
select sum(TransportAmount) `FBA在途产品金额`
from import_data.daily_FBAInventory_Box dhd
join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '商厨汇' 
where GenerateDate ='2023-03-06'
)

, abroad_onWay AS (
select sum(ProductShangjiaStatus) `海外仓在途产品金额`
from import_data.daily_ABroadWarehouse dhd
join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '商厨汇' 
where GenerateDate ='2023-03-06'
)

select `FBA+海外仓在仓产品金额` +  `FBA在途产品金额` +`海外仓在途产品金额`
from onWarehouse_prod_amount,FBA_onWay,abroad_onWay


-- RemainQuantity -- FBA 海外仓 最新仓内剩余数量 = 仓库里的 sku的数量 

-- 
-- 3 FBA在途产品金额 + 在途运费
-- FBA在途产品金额 TransportAmount
-- from import_data.daily_FBAInventory_Box dfb 
-- where GenerateDate= current_date() -1
-- 
-- from daily_ABroadWarehouse daw 