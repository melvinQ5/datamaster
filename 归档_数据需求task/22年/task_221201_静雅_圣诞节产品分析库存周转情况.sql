/*
圣诞节标识的sku+赛盒SKU，库存数量，在途数量，单价，库存资金，在线连接数，近30天上架在线链接数，近4周每周访客数，近4周转化率，近四周每周订单数，
近4周每周销售额@郭新星(郭新星) 
麻烦新星帮我做一份这样的数据，今天下班前出可以吗？
用来圣诞产品分析库存周转情况，该模板可以保留或优化，后续分析各阶段的库存都可以用
*/
with
pt as ( 
select BoxSku , LastPurchasePrice
from wt_products wp
where Festival like '%圣诞节%' and IsDeleted = 0 group by BoxSku, LastPurchasePrice
)

, po as ( -- PurchaseOrder 采购表
select * 
		, sum(Quantity)over(partition by OrderNumber) as total_qy -- 单笔订单采购件数
		, sum(Price - DiscountedPrice)over(PARTITION BY OrderNumber) AS ord_product_price -- 采购单产品金额（不含运费）
from import_data.daily_PurchaseOrder 
	where IsComplete = '否' and InstockQuantity = 0 and WarehouseName = '东莞仓'
)

, po_product as ( -- `在途采购产品金额`
select po.BoxSku, sum(Price - DiscountedPrice) `在途产品金额` , sum(po.Quantity) `在途件数`
from po JOIN  pt on po.BoxSku = pt.BoxSKU  group by po.BoxSku 
)

, po_Freight as ( -- `在途采购运费`
select tmp.BoxSku , sum(fr) `在途运费`
from ( select BoxSku, (Price - DiscountedPrice)/ord_product_price*Freight as fr 
	from po 
	) tmp 
JOIN pt on tmp.BoxSku = pt.BoxSKU 
group by tmp.BoxSku 
)



, local_w as (-- 在仓数量
SELECT wi.BoxSku , sum(TotalPrice) `在仓产品金额`, sum(TotalInventory) `在仓sku件数`
FROM import_data.daily_WarehouseInventory wi
JOIN pt on wi.BoxSku = pt.BoxSKU 
where CreatedTime = DATE_ADD( CURRENT_DATE(), interval -1 day) and  WarehouseName = '东莞仓' and TotalInventory > 0 
group by wi.BoxSku 
)


select pt.BoxSku , pt.LastPurchasePrice, `在仓产品金额`,`在仓sku件数`,round((`在途产品金额`+`在途运费`),2) as `在途资金`, `在途件数`
, `在途产品金额` ,`在途运费`
from pt
left join local_w on pt.BoxSku =local_w.BoxSku
left join po_product on pt.BoxSku = po_product.BoxSku
left join po_Freight on pt.BoxSku = po_Freight.BoxSku

