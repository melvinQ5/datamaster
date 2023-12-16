-- 单表查询

select `Year`, Week, wps.Sku, Spu, Boxsku, wps.Festival, wps.CategoryPathByChineseName
	, wps.NewCategory, wps.IsImportant, wps.IsReDev
	, round(TotalSales,2) as TotalSales, round(TotalProfit) as TotalProfit, TotalOrders, TotalVolume, SalesGross, FeeGross
	, RefundAmount, FBAFee, AdvertisingCosts, PurchaseCosts, WarehouseCosts, OtherExpenseCosts, TaxGross, DeductTaxes
	, CustomerRefundAmount, HasOrderListingCount, HasOrderShopCount, OnlineListingCount, OnlineShopCount, AdListingCount
	, Visitors, VisitorSalesUnits, VisitedListingCount, VisitorTurnRate, AdExposure, AdClicks, AdClickRate, AdSaleUnits_7d
	, AdTurnRate, AdSpend, AdCostRate, AdSales, AdProfit, AdPerformanceZb, AdAcost, AdCpc, HasExposure_AdListingCount
	, HasOrder_AdListingCount, ZRLLVisitCount, ZRLLVisitSaleUnit, ZRLLVisitZb, ZRLLTurnRate
FROM import_data.wt_products_stat wps
where 1=1 {{template}}


-- 多表关联查询
select * from  
( 
SELECT `Year`, Week, wps.Sku, wps.Spu, wps.Boxsku, wps.Festival, wps.CategoryPathByChineseName
	, wps.NewCategory, wps.IsImportant, wps.IsReDev
	, wp.CreationTime, wp.ProductStatus, wp.ChangeReasons, wp.DevelopUserName, wp.IsDeleted, wp.ProductName, wp.DevelopLastAuditTime, wp.DevelopLastAuditUserName, wp.PackageWeight
	, wp.FirstImageUrl, wp.Editor, wp.Artist, wp.TortAuditor, wp.LastAuditor, wp.LastPurchasePrice, wp.Logistics_Group_Attr, wp.Logistics_Attr, wp.TortType
	, wp.ReDevLastAuditTime, wp.ReDevLastAuditUserId, wp.ReDevLastAuditUserName, wp.ProductStopTime, wp.FirstShangjiaTime, wp.FirstOrderTime, wp.FirstOrderTimeCost
	, TotalSales, TotalProfit, TotalOrders, TotalVolume, SalesGross, FeeGross
	, RefundAmount, FBAFee, AdvertisingCosts, PurchaseCosts, WarehouseCosts, OtherExpenseCosts, TaxGross, DeductTaxes
	, CustomerRefundAmount, HasOrderListingCount, HasOrderShopCount, OnlineListingCount, OnlineShopCount, AdListingCount
	, Visitors, VisitorSalesUnits, VisitedListingCount, VisitorTurnRate, AdExposure, AdClicks, AdClickRate, AdSaleUnits_7d
	, AdTurnRate, AdSpend, AdCostRate, AdSales, AdProfit, AdPerformanceZb, AdAcost, AdCpc, HasExposure_AdListingCount
	, HasOrder_AdListingCount, ZRLLVisitCount, ZRLLVisitSaleUnit, ZRLLVisitZb, ZRLLTurnRate
FROM import_data.wt_products_stat wps
left join import_data.wt_products wp on wps.Sku = wp.Sku 
) t
where 1=1 {{template}}

SELECT *
FROM
(select `Year`, Week, wps.Sku, wps.Spu, wps.Boxsku, wps.Festival, wps.CategoryPathByChineseName, wps.NewCategory, wps.IsImportant, wps.IsReDev, wp.CreationTime, wp.ProductStatus, wp.ChangeReasons, wp.DevelopUserName, wp.IsDeleted, wp.ProductName, wp.DevelopLastAuditTime, wp.DevelopLastAuditUserName, wp.PackageWeight, wp.FirstImageUrl, wp.Editor, wp.Artist, wp.TortAuditor, wp.LastAuditor, wp.LastPurchasePrice, wp.Logistics_Group_Attr, wp.Logistics_Attr, wp.TortType, wp.ReDevLastAuditTime, wp.ReDevLastAuditUserId, wp.ReDevLastAuditUserName, wp.ProductStopTime, wp.FirstShangjiaTime, wp.FirstOrderTime, wp.FirstOrderTimeCost
from import_data.wt_products_stat wps
left join wt_products wp
on wps.Sku = wp.Sku ) t
 where 1=1 {{template}}
