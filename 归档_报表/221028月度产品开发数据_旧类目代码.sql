-- 园林工具配件每月新开发的SKU数
/*
1.按照开发终审时间增加月次的统计
2.由于week of year比我们计算的月次少1，我们人工
*/
select'金磊'`开发人员`,'工具'`产品类目`,month(DevelopLastAuditTime) `开发月次`, count(*) `每月终审通过SKU数` from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-02'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `开发月次`
order by `开发月次`
union all

select'陈倩'`开发人员`,'庆典'`产品类目`, month(DevelopLastAuditTime) `开发月次`, count(pp.sku) `每月终审通过SKU数` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `开发月次`
order by `开发月次`

union all

select'李琴1688'`开发人员`,'庆典'`产品类目`, month(DevelopLastAuditTime) `开发月次`, count(*) `每月终审通过SKU数` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0  and pp.skusource=1
and month(DevelopLastAuditTime)='${cnt_month}'

group by `开发月次`
order by `开发月次`

union all

select'杨梅'`开发人员`,'庆典'`产品类目`, month(DevelopLastAuditTime) `开发月次`, count(*) `每月终审通过SKU数` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `开发月次`
order by `开发月次`
union all

select'李云霞'`开发人员`,'庆典'`产品类目`, month(DevelopLastAuditTime) `开发月次`, count(*) `每月终审通过SKU数` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
and month(DevelopLastAuditTime)='${cnt_month}'

group by `开发月次`
order by `开发月次`

union all

select'陈典明'`开发人员`, 'GM转PM'`产品类目`, month(DevelopLastAuditTime) `开发月次`, count(*) `每月终审通过SKU数` 
from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
and month(DevelopLastAuditTime)='${cnt_month}'
group by `开发月次`
order by `开发月次`;




-- =======================================================================================================================================================================
-- 统计园林工具配件每月的出单SKU的开发月次
/* 
1.SKU范围=园林工具的SKU
2.订单范围是销售2部和3部的订单（付款非作废，销售额大于O）
3.按照开发终审时间增加月次的统计
4.由于week of year比我们计算的月次少1，我们人工

使用方法修改 订单的统计月次的值 month(od.PayTime) =？
*/


select '金磊'`开发人员`,'工具'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all

select '陈倩'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '李琴1688'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`


union all

select '陈倩'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '杨梅'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '李云霞'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all

select '陈典明'`开发人员`, 'GM转PM'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `开发月次`
order by `开发月次`
union all

select '金磊'`开发人员`,'工具'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all

select '陈倩'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '李琴1688'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`


union all

select '陈倩'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '杨梅'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '李云霞'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all

select '陈典明'`开发人员`, 'GM转PM'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = '${StartDay}' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where YEAR(od.PayTime) = 2022 and month(od.PayTime) ='${cnt_month}' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `开发月次`,`销售部门`
order by `开发月次`;






-- 统计不同月次开发的SKU在每月的在线链接数
/*
1.修改EndDay为下月的每月一
2.店铺=正常+链接在线
*/

select'金磊'`开发人员`, '工具'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all

select'陈倩'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`, month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select'李琴1688'`开发人员`, '庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select'杨梅'`开发人员`,'庆典'`产品类目`, '总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '李云霞' `开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all

select'陈典明'`开发人员`, 'GM转PM'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.sku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `开发月次`
order by `开发月次`


union all

select'金磊'`开发人员`, '工具'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all

select'陈倩'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`, month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select'李琴1688'`开发人员`, '庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select'杨梅'`开发人员`,'庆典'`产品类目`, s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '李云霞' `开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.SKU from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all

select'陈典明'`开发人员`, 'GM转PM'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(al.Id)`在线链接数`
from import_data.erp_amazon_amazon_listing al
join import_data.mysql_store s on s.code = al.shopcode and s.Department in ('销售二部', '销售三部') and s.ShopStatus='正常'
join import_data.erp_product_products pp on al.sku = pp.sku 
where al.PublicationDate< '${next_cnt_month}' and al.ListingStatus = 1
and al.sku in 
(
select pp.sku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `开发月次`,`销售部门`
order by `开发月次`;




-- =======================================================================================================================================================================
-- 统计园林工具配件每月的出单SKU的开发月次--累计计算
/* 
1.SKU范围=园林工具的SKU
2.订单范围是销售2部和3部的订单（付款非作废，销售额大于O）
3.按照开发终审时间增加月次的统计
4.由于week of year比我们计算的月次少1，我们人工

使用方法修改 订单的统计月次的值 month(od.PayTime) =？
*/


select '金磊'`开发人员`,'工具'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all

select '陈倩'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '李琴1688'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`


union all

select '陈倩'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '杨梅'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all
select '李云霞'`开发人员`,'庆典'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`
order by `开发月次`

union all

select '陈典明'`开发人员`, 'GM转PM'`产品类目`,'总计'`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `开发月次`
order by `开发月次`
union all

select '金磊'`开发人员`,'工具'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
inner join erp_product_product_category as t2
on pp.ProductCategoryId=t2.Id
and t2.CategoryPathByChineseName in ('A7家居和花园>A7园艺用品>A7园林工具>割草机化油器','A7家居和花园>A7园艺用品>A7园林工具>割草机及配件')
and pp.DevelopUserName='金磊'
where pp.DevelopLastAuditTime >= '2022-04-01'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all

select '陈倩'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '李琴1688'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李琴1688'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`


union all

select '陈倩'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='陈倩'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '杨梅'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='杨梅'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all
select '李云霞'`开发人员`,'庆典'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01' and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-07-04' and pp.DevelopUserName ='李云霞'
and pp.IsDeleted = 0 and pp.IsMatrix = 0 
)
group by `开发月次`,`销售部门`
order by `开发月次`

union all

select '陈典明'`开发人员`, 'GM转PM'`产品类目`,s.Department`销售部门`,month(pp.DevelopLastAuditTime) `开发月次`, count(distinct(od.BoxSku)) `月度出单SKU数` ,round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)) `月度销售额USD`, 
round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD)) `月度利润额USD`, round(round(sum((if (TaxGross > 0, TotalProfit , TotalProfit - TotalGross * ifnull(TaxRatio, 0) ) -  RefundAmount ) / od.ExchangeUSD))/round(sum(( if (TaxGross > 0, TotalGross , TotalGross * (1 - ifnull(TaxRatio, 0))) - RefundAmount ) / od.ExchangeUSD)),2) `月度利润率` , count(distinct(od.PlatOrderNumber))`订单数`, count(DISTINCT(CONCAT(od.SellerSku, od.ShopIrobotId)))`出单链接数`
from import_data.OrderDetails od
join import_data.mysql_store s on s.code = od.ShopIrobotId and s.Department in ('销售二部', '销售三部')
left join import_data.Basedata b on b.ReportType = '月报' and b.FirstDay = 'StartDay' and b.DepSite = s.Site
join import_data.erp_product_products pp on od.BoxSku=pp.BOXSKU
where od.PayTime< '2022-11-01'  and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0 and od.BoxSku in 
(
select BoxSku from import_data.erp_product_products pp
where pp.DevelopLastAuditTime >= '2022-04-01' and pp.DevelopUserName not in ('杨梅','李云霞''李琴1688','金磊')
and pp.IsDeleted = 0 and pp.IsMatrix = 0 and pp.SkuSource=2
)
group by `开发月次`,`销售部门`
order by `开发月次`;








