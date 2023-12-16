/*
帮忙拉一个近2个月，供应商出发：在每家供应商的采购SKU数量，采购金额，贡献销售额；取前500家先试试看
目的：对头部供应商进行新品开发
*/
-- import_data.Supplier_management source

WITH sup as ( -- 每个物流供应商的采购数量、金额
SELECT
    `SupplierName`
    , `BoxSku` 
    , sum(`Price`) + sum(`Freight`) - sum(`DiscountedPrice`) AS sup_money -- `采购金额`
FROM
    import_data.PurchaseOrder pu
WHERE
    `WarehouseName` = '东莞仓'
    AND
    (
        ( `ReportType` = '月报' and Monday = '2022-09-01' and OrderTime > '2022-08-10') -- 0810-0831
		or( `ReportType` = '月报' and Monday = '2022-10-01' ) -- 0901-0930        
        or( `ReportType` = '周报'  and Monday = '2022-10-03'and OrderTime > '2022-10-01') -- 1001-1010
    ) 
    AND ((`IsComplete` = '否')
        OR ((`IsComplete` = '是')
            AND (`InstockTime` != 0.0)))
GROUP BY
    `SupplierName`
    , `BoxSku`
)

, orders as ( -- 每个SKU对应销售额
select 
	ops.BoxSku , sum(InCome) as income_full_site
from  import_data.OrderProfitSettle ops 
join 
	(select BoxSku from sup group by BoxSku) tmp
	on ops.BoxSku = tmp.BoxSku
where  ops.PayTime BETWEEN  '2022-08-10'and'2022-10-10'
group by ops.BoxSku 
)

, skus as ( -- 获取供应商sku数
select SupplierName , count(distinct BoxSku) boxsku_cnt from sup group by SupplierName
)

, sup2 as ( -- 
select 
	sup.*
	, sum(orders.income_full_site) over ( partition by sup.SupplierName ) as income_full_site_total
	, skus.boxsku_cnt
	, sum(sup_money) over ( partition by sup.SupplierName ) as sup_money_total
from sup  
left join orders on orders.BoxSku = sup.BoxSku
left join skus on sup.SupplierName = skus.SupplierName
order by SupplierName
)

, ratio as ( -- 历史汇率
	select
		usdratio -- 汇率
	from
		import_data.Basedata
	where
		firstday = '2022-09-01' -- 'StartDay'
		and reporttype = '月报'
	limit 1
) 


select
	SupplierName as "采购供应商"
	, boxsku_cnt as "供应商采购SKU数"
	, sup_money_total as "供应商采购金额usd"
	, BoxSku 
	, sup_money as "该sku采购金额usd"
	, 采购sku数排名
	, 采购金额排名
-- 	, round(income_full_site_total/usdratio) as "对应sku全站近2月销售额"
	, 按sku全站销售额对供应商排名
from 
	(
	select
	     *
	     , dense_rank() over( order by boxsku_cnt desc ) as "采购sku数排名"
	     , dense_rank() over( order by sup_money_total desc ) as "采购金额排名"
	     , dense_rank() over( order by income_full_site_total desc ) as "按sku全站销售额对供应商排名"
	from sup2
	) tmp , ratio
where 采购金额排名 < 501
order by 采购金额排名

