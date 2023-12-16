-- '园艺用品|庭院、草坪和花园' 快百货1月的销售数据，到产品，账号维度的销额
select  count(1) from (

select ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,TortType,left(SettlementTime,7) `出单月份` 
	,round(sum(TotalGross/ExchangeUSD),2) as `销售额usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `利润额usd`  
	,count(distinct OrderNumber) `订单数`
	,sum(SaleCount) `订单产品件数`
from ods_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '正常' when ProductStatus = 2 then '停产' 
			when ProductStatus = 3 then '停售' when ProductStatus = 4 then '暂时缺货'  
			when ProductStatus = 5 then '清仓' end as ProductStatus
			, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products ) wt 
	on wo.BoxSku = wt.BoxSku 
	and wt.Product_CategoryFullPath REGEXP '园艺用品|庭院、草坪和花园'
	and TransactionType ='付款' and OrderStatus != '作废' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -1 month)
	and IsDeleted = 0 and ws.Department in ('快百货')
group by ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 


) a 

-- '园艺用品|庭院、草坪和花园' 快百货 去年1-12月汇总的到产品，账号维度的销额
select  count(1) from (

select ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,TortType,left(SettlementTime,7) `出单月份` 
	,round(sum(TotalGross/ExchangeUSD),2) as `销售额usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `利润额usd`  
	,count(distinct OrderNumber) `订单数`
	,sum(SaleCount) `订单产品件数`
from ods_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '正常' when ProductStatus = 2 then '停产' 
			when ProductStatus = 3 then '停售' when ProductStatus = 4 then '暂时缺货'  
			when ProductStatus = 5 then '清仓' end as ProductStatus
			, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products ) wt 
	on wo.BoxSku = wt.BoxSku 
	and wt.Product_CategoryFullPath REGEXP '园艺用品|庭院、草坪和花园'
	and TransactionType ='付款' and OrderStatus != '作废' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -12 month)
	and IsDeleted = 0 and ws.Department in ('快百货')
group by ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 


) a 


-- 所有产品 快百货 去年1-12月汇总的到产品，账号维度的销额
select  count(1) from (

select wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,TortType,left(SettlementTime,7) `出单月份` 
	,round(sum(TotalGross/ExchangeUSD),2) as `销售额usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `利润额usd`  
	,count(distinct OrderNumber) `订单数`
	,sum(SaleCount) `订单产品件数`
from ods_orderdetails wo 
FROM wt_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '正常' when ProductStatus = 2 then '停产' 
			when ProductStatus = 3 then '停售' when ProductStatus = 4 then '暂时缺货'  
			when ProductStatus = 5 then '清仓' end as ProductStatus
			, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products ) wt 
	on wo.BoxSku = wt.BoxSku 
-- 	and wt.Product_CategoryFullPath regexp 'A7户外运动>A7骑行|A3娱乐爱好>A3运动与户外>A3运动>A3骑行用品'
	and TransactionType ='付款' and OrderStatus != '作废' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -12 month)
	and IsDeleted = 0 and ws.Department in ('快百货')
group by wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 

) a 

-- 所有产品 快百货 23年1-3月汇总的到产品，账号维度的销额
select  count(1) from (

select wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,wt.TortType,left(SettlementTime,7) `出单月份` 
	,round(sum(TotalGross/ExchangeUSD),2) as `销售额usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `利润额usd`  
	,count(distinct OrderNumber) `订单数`
	,sum(SaleCount) `订单产品件数`
from wt_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '正常' when ProductStatus = 2 then '停产' 
			when ProductStatus = 3 then '停售' when ProductStatus = 4 then '暂时缺货'  
			when ProductStatus = 5 then '清仓' end as ProductStatus
		, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products 
	) wt 
	on wo.BoxSku = wt.BoxSku and IsDeleted = 0 
join import_data.wt_store ws on wo.shopcode  = ws.Code 
where SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -3 month)
	and IsDeleted = 0 and ws.Department in ('快百货')
group by wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,wt.TortType ,left(SettlementTime,7) 

) a 

