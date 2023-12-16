with 
ware as (
select dwi.* 
	, case when ProductStatus =  0 then '正常'
			when ProductStatus = 2 then '停产'
			when ProductStatus = 3 then '停售'
			when ProductStatus = 4 then '暂时缺货'
			when ProductStatus = 5 then '清仓'
		end as ProductStatus
	,wp.ChangeReasons
	,wp.TortType 
	,wp.DevelopLastAuditTime 
from import_data.daily_WarehouseInventory dwi 
join  import_data.wt_products wp on dwi.BoxSku = wp.BoxSku and wp.ProjectTeam = '快百货'
where dwi.CreatedTime = DATE_ADD('2023-03-08',-1) and WarehouseName = '东莞仓'
)

,orde as (
select wo.BoxSku 
	,sum(case when left(PayTime,4)='2022' then SaleCount end ) as y2022
	,sum(case when left(PayTime,7)='2022-01' then SaleCount end ) as m202201
	,sum(case when left(PayTime,7)='2022-02' then SaleCount end ) as m202202
	,sum(case when left(PayTime,7)='2022-03' then SaleCount end ) as m202203
	,sum(case when left(PayTime,7)='2022-04' then SaleCount end ) as m202204
	,sum(case when left(PayTime,7)='2022-05' then SaleCount end ) as m202205
	,sum(case when left(PayTime,7)='2022-06' then SaleCount end ) as m202206
	,sum(case when left(PayTime,7)='2022-07' then SaleCount end ) as m202207
	,sum(case when left(PayTime,7)='2022-08' then SaleCount end ) as m202208
	,sum(case when left(PayTime,7)='2022-09' then SaleCount end ) as m202209
	,sum(case when left(PayTime,7)='2022-10' then SaleCount end ) as m202210
	,sum(case when left(PayTime,7)='2022-11' then SaleCount end ) as m202211
	,sum(case when left(PayTime,7)='2022-12' then SaleCount end ) as m202212
	,sum(case when left(PayTime,7)='2023-01' then SaleCount end ) as m202301
	,sum(case when left(PayTime,7)='2023-02' then SaleCount end ) as m202302
	,sum(case when left(PayTime,7)='2023-03' then SaleCount end ) as m202303
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
where wo.IsDeleted = 0 and OrderStatus != '作废'  and ms.Department = '快百货'
	and PayTime > '2022-01-01'
group by wo.BoxSku 
)

-- select * from orde

, inst as (
select wp.BoxSku ,max(CompleteTime) as max_InstockTime
from import_data.wt_purchaseorder wp 
join ware on wp.BoxSku = ware.boxsku 
where isOnWay = '否' 
group by wp.BoxSku
)

, list as (
select wl.BoxSku ,count(1) as online_listing_cnt
from import_data.wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '快百货' and ms.ShopStatus = '正常'
join import_data.wt_products wp  on wl.BoxSku = wp.boxsku and wl.IsDeleted = 0 
and ListingStatus = 1 
and  wp.projectteam = '快百货'and wp.IsDeleted = 0 and wl.BoxSku  = 4390461
group by wl.BoxSku
)

-- select count(1) from (

select 
	wp.BoxSku 
	,ware.BoxSku `有库存boxsku`
	,wp.ProductName `产品名` 
-- 	,IsPackage `是否包材`
-- 	,AverageUnitPrice `平均单价`
-- 	,TotalInventory `库存总数量`
-- 	,TotalPrice `库存总金额`
-- 	,InventoryAge45 `0-45天库龄金额`
-- 	,InventoryAge90 `46-90天库龄金额`
-- 	,InventoryAge180 `91-180天库龄金额`
-- 	,InventoryAge270 `181-270天库龄金额`
-- 	,InventoryAge365 `271-365天库龄金额`
-- 	,InventoryAgeOver `大于365天库龄金额`
-- 	,max_InstockTime `最后采购完结日`
-- 	,datediff(CURRENT_DATE(),max_InstockTime) `最后采购完结距今天数` 
-- 	, case when wp.ProductStatus =  0 then '正常'
-- 			when wp.ProductStatus = 2 then '停产'
-- 			when wp.ProductStatus = 3 then '停售'
-- 			when wp.ProductStatus = 4 then '暂时缺货'
-- 			when wp.ProductStatus = 5 then '清仓'
-- 		end as  `产品状态`
-- 	,online_listing_cnt `在线链接数`
-- 	,wp.ChangeReasons `停产原因`
-- 	,wp.TortType `侵权类型`
-- 	,wp.DevelopLastAuditTime `终审时间`	,m202201 `2201销量`
	,m202202 `2202销量`
	,m202203 `2203销量`
	,m202204 `2204销量`
	,m202205 `2205销量`
	,m202206 `2206销量`
	,m202207 `2207销量`
	,m202208 `2208销量`
	,m202209 `2209销量`
	,m202210 `2210销量`
	,m202211 `2211销量`
	,m202212 `2212销量`
	,m202301 `2301销量`
	,m202302 `2302销量`
	,m202303 `2303销量`
from import_data.wt_products wp 
left join ware on ware.BoxSku = wp.boxsku
left join orde on orde.BoxSku = wp.boxsku
left join inst on inst.BoxSku = wp.boxsku
left join list on list.BoxSku = wp.boxsku
where wp.projectteam = '快百货'and wp.DevelopLastAuditTime is not null 
-- ) tmp 



