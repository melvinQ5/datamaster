
select 
	wo.*
	,wp.Spu ,wp.Sku ,wp.ProductName ,wp.Cat1 
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
	,epps.SupplierName `产品库显示供应商` 
from (
	SELECT 
		boxsku
		,case when year(SettlementTime) is null then '合计' else year(SettlementTime) end `结算年份`
		,sum(TotalGross)
		,sum(TotalProfit)
		,sum(SaleCount)
	from  wt_orderdetails  t 
	join mysql_store ms on t.shopcode = ms.Code 
	where SettlementTime >= '2021-01-01' and SettlementTime < '2023-03-20'and ms.Department ='快百货'
	group by grouping sets ((boxsku),(boxsku ,year(SettlementTime)))
	) wo
left join wt_products wp on wo.BoxSku =wp.BoxSku 
left join erp_product_product_suppliers epps on wp.id =epps.ProductId  