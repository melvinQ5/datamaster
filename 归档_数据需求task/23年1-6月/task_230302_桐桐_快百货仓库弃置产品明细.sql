with 
ware as (
select dwi.* 
	, case when ProductStatus =  0 then '����'
			when ProductStatus = 2 then 'ͣ��'
			when ProductStatus = 3 then 'ͣ��'
			when ProductStatus = 4 then '��ʱȱ��'
			when ProductStatus = 5 then '���'
		end as ProductStatus
	,wp.ChangeReasons
	,wp.TortType 
	,wp.DevelopLastAuditTime 
from import_data.daily_WarehouseInventory dwi 
join  import_data.wt_products wp on dwi.BoxSku = wp.BoxSku and wp.ProjectTeam = '��ٻ�'
where dwi.CreatedTime = DATE_ADD('2023-03-08',-1) and WarehouseName = '��ݸ��'
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
where wo.IsDeleted = 0 and OrderStatus != '����'  and ms.Department = '��ٻ�'
	and PayTime > '2022-01-01'
group by wo.BoxSku 
)

-- select * from orde

, inst as (
select wp.BoxSku ,max(CompleteTime) as max_InstockTime
from import_data.wt_purchaseorder wp 
join ware on wp.BoxSku = ware.boxsku 
where isOnWay = '��' 
group by wp.BoxSku
)

, list as (
select wl.BoxSku ,count(1) as online_listing_cnt
from import_data.wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
join import_data.wt_products wp  on wl.BoxSku = wp.boxsku and wl.IsDeleted = 0 
and ListingStatus = 1 
and  wp.projectteam = '��ٻ�'and wp.IsDeleted = 0 and wl.BoxSku  = 4390461
group by wl.BoxSku
)

-- select count(1) from (

select 
	wp.BoxSku 
	,ware.BoxSku `�п��boxsku`
	,wp.ProductName `��Ʒ��` 
-- 	,IsPackage `�Ƿ����`
-- 	,AverageUnitPrice `ƽ������`
-- 	,TotalInventory `���������`
-- 	,TotalPrice `����ܽ��`
-- 	,InventoryAge45 `0-45�������`
-- 	,InventoryAge90 `46-90�������`
-- 	,InventoryAge180 `91-180�������`
-- 	,InventoryAge270 `181-270�������`
-- 	,InventoryAge365 `271-365�������`
-- 	,InventoryAgeOver `����365�������`
-- 	,max_InstockTime `���ɹ������`
-- 	,datediff(CURRENT_DATE(),max_InstockTime) `���ɹ����������` 
-- 	, case when wp.ProductStatus =  0 then '����'
-- 			when wp.ProductStatus = 2 then 'ͣ��'
-- 			when wp.ProductStatus = 3 then 'ͣ��'
-- 			when wp.ProductStatus = 4 then '��ʱȱ��'
-- 			when wp.ProductStatus = 5 then '���'
-- 		end as  `��Ʒ״̬`
-- 	,online_listing_cnt `����������`
-- 	,wp.ChangeReasons `ͣ��ԭ��`
-- 	,wp.TortType `��Ȩ����`
-- 	,wp.DevelopLastAuditTime `����ʱ��`	,m202201 `2201����`
	,m202202 `2202����`
	,m202203 `2203����`
	,m202204 `2204����`
	,m202205 `2205����`
	,m202206 `2206����`
	,m202207 `2207����`
	,m202208 `2208����`
	,m202209 `2209����`
	,m202210 `2210����`
	,m202211 `2211����`
	,m202212 `2212����`
	,m202301 `2301����`
	,m202302 `2302����`
	,m202303 `2303����`
from import_data.wt_products wp 
left join ware on ware.BoxSku = wp.boxsku
left join orde on orde.BoxSku = wp.boxsku
left join inst on inst.BoxSku = wp.boxsku
left join list on list.BoxSku = wp.boxsku
where wp.projectteam = '��ٻ�'and wp.DevelopLastAuditTime is not null 
-- ) tmp 



