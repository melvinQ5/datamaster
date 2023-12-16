/* 目的：重点产品的新增周滚动
每周五推 当周出单sku业绩单量表现 
使用daily表 才能获取当周四至上周五的数据，需要where TransactionType <> '其他' 以排除脏数据
 */
with orders as (
select 'PM' `模式`, od.BoxSku , count(distinct od.OrderNumber ) as sku_count , round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(ratio, 0))) - RefundAmount ) / ExchangeUSD)) product_sales
from import_data.daily_OrderDetails od join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部') 
left join import_data.TaxRatio  b on right(od.ShopIrobotId,2) = b.site 
where PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -7 day) and TransactionType <> '其他'
	and od.OrderNumber not in 
	( select OrderNumber from 
	( SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype 
	FROM import_data.daily_OrderDetails 
	where ShipmentStatus = '未发货' and OrderStatus = '作废' and PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -7 day) and TransactionType <> '其他'
	group by OrderNumber ) a 
	where alltype = '付款' )
group by od.BoxSku
union 
select 'GM' `模式`, od.BoxSku , count(distinct od.OrderNumber ) as sku_count , round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(ratio, 0))) - RefundAmount ) / ExchangeUSD)) product_sales
from daily_OrderDetails od join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department = '销售一部'
left join import_data.TaxRatio  b on right(od.ShopIrobotId,2) = b.site
where PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -7 day) and TransactionType <> '其他'
	and od.OrderNumber not in 
	( select OrderNumber from 
	( SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype 
	FROM import_data.daily_OrderDetails 
	where ShipmentStatus = '未发货' and OrderStatus = '作废' and PayTime < '${EndDay}' and PayTime >= date_add('${EndDay}',interval -7 day) and TransactionType <> '其他'
	group by OrderNumber ) a 
	where alltype = '付款')
group by od.BoxSku
)

, col as (
select epp.sku , epp.BoxSKU , epp.ProductName , eppc.Id , epp.CreationTime , epp.DevelopLastAuditTime , eppc.CategoryPathByChineseName
	, case when epp.ProductStatus = 2 then '停产' 
	when epp.ProductStatus = 0 then '正常' 
	when epp.ProductStatus = 3 then '停售'
	when epp.ProductStatus = 4 then '暂时缺货'
	when epp.ProductStatus = 5 then '清仓' end as ProductStatus
	, epp.IsDeleted
	, GROUP_CONCAT(wp.TortType) as TortType
	, GROUP_CONCAT(wp.Festival) as Festival
from import_data.erp_product_products epp 
left join import_data.erp_product_product_category eppc on epp.ProductCategoryId = eppc.Id 
left join import_data.wt_products wp on epp.Id =wp.id 
where LENGTH (epp.BoxSKU)>0 and LENGTH (epp.SKU) >0 
group by epp.sku , epp.BoxSKU , epp.ProductName , eppc.Id 
	, epp.CreationTime , epp.DevelopLastAuditTime 
	, eppc.CategoryPathByChineseName, epp.ProductStatus, epp.IsDeleted
)

select 
	weekofyear('${EndDay}') as `周次`, o.`模式`, col.sku, col.BoxSKU, col.ProductName `产品名称`, 
	col.CreationTime `产品创建时间`
	, col.DevelopLastAuditTime `开发终审时间`, col.TortType `侵权类型` , IsDeleted `是否删除`
	, ProductStatus, Festival`季节节日`, CategoryPathByChineseName`全类目`
	, sku_count as sku订单量 
	, rank()over(partition by `模式` order by sku_count desc) as sku订单量排名
	, product_sales `销售额`
	, rank()over(partition by `模式` order by product_sales desc) as sku销售额排名
from orders o
left join col on col.BoxSKU = o.BoxSku
where col.BoxSKU is not null 
order by product_sales desc 





