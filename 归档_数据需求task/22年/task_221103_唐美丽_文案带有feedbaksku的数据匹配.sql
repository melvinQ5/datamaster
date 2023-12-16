/*
让系统跑的 文案带有feedback词的数据
这部分SKU, 产品状态，产品终审时间，添加时间，开发人员，侵权情况  
对应近30天单量，近3个月单量；
在线listing；如果能有在线listing的清单明细更好了

*/	
with epp as (
select js2.Sku ,js2.Spu,epp.BoxSKU 
	, case when epp.ProductStatus=0 then '正常' when epp.ProductStatus=2 then '停产'
		when epp.ProductStatus=3 then '停售' when epp.ProductStatus=4 then '暂时缺货'
		when epp.ProductStatus=3 then '清仓' end as ProductStatus
	, epp.DevelopLastAuditTime ,epp.CreationTime, epp.DevelopUserName ,epp.Id 
from import_data.JinqinSku js2 
left join import_data.erp_product_products epp on js2.Sku = epp.SKU 
where js2.Monday ='2022-11-3' 
)

, join_orders as ( -- 出单情况
select od.BoxSku 
	, count(distinct case when od.PayTime >= DATE_ADD('${end_day}',interval -30 Day) and od.PayTime <='${end_day}' then PlatOrderNumber end) `近30天单量`
	, count(distinct case when od.PayTime >= DATE_ADD('${end_day}',interval -90 Day) and od.PayTime <='${end_day}' then PlatOrderNumber end) `近90天单量`
from import_data.OrderDetails od 
join epp on od.BoxSku =epp.BoxSKU 
where od.PayTime >= DATE_ADD('${end_day}',interval -90 Day) and od.PayTime <='${end_day}' --2022-11-3
	and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0
group by od.BoxSku 
)

, join_listing as ( -- 链接情况
select eaal.SKU, count(1)over(partition by eaal.SKU ) `在线链接数`, eaal.ASIN ,eaal.Name`标题` ,eaal.Price `售价`,eaal.Quantity`可售数` 
	,eaal.ShopCode `店铺`
	,eaal.PublicationDate `刊登时间`,eaal.ProductSalesName `销售人员` ,eaal.IroboxName`赛盒渠道` 
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join epp on  eaal.sku = epp.sku 
where eaal.ListingStatus = 1  and eaal.PublicationDate <='${end_day}'
)

, infringement as (  -- 侵权情况
select ProductId , group_concat(TortType_name, ',') `侵权情况` from 
	(
	SELECT tt.ProductId,
	case torttype
	when 1 then '版权侵权'
	when 2 then '商标侵权'
	when 3 then '专利侵权'
	when 4 then '违禁品'
	when 5 then '不侵权'
	when 6 then '律所侵权'
	end torttype_name
	FROM import_data.erp_product_product_tort_types tt
	where tt.ProductId in (select id from erp_product_products where IsDeleted = 0 and IsMatrix = 0)
	group by tt.ProductId, TortType
	) a
group by ProductId
)

, res1 as ( -- 指标
select epp.SKU, epp.Spu,epp.BoxSKU , epp.ProductStatus `产品状态`
	, epp.DevelopLastAuditTime `产品终审时间` 
	, epp.CreationTime `添加时间`, epp.DevelopUserName `开发人员`, jo.`近30天单量`, jo.`近90天单量`,i.`侵权情况`
from epp
left join join_orders jo on jo.BoxSku = epp.BoxSKU
left join infringement i on epp.Id = i.ProductId
)

, res2 as ( -- 链接明细
select * from res1 left join join_listing jl on jl.SKU = res1.Sku -- 1个sku多条链接
)

select * from res2




