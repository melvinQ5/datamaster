
select 
	wo.*
	,wp.Spu ,wp.Sku ,wp.ProductName ,wp.Cat1 
	,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ProductStatus
	,epps.SupplierName `��Ʒ����ʾ��Ӧ��` 
from (
	SELECT 
		boxsku
		,case when year(SettlementTime) is null then '�ϼ�' else year(SettlementTime) end `�������`
		,sum(TotalGross)
		,sum(TotalProfit)
		,sum(SaleCount)
	from  wt_orderdetails  t 
	join mysql_store ms on t.shopcode = ms.Code 
	where SettlementTime >= '2021-01-01' and SettlementTime < '2023-03-20'and ms.Department ='��ٻ�'
	group by grouping sets ((boxsku),(boxsku ,year(SettlementTime)))
	) wo
left join wt_products wp on wo.BoxSku =wp.BoxSku 
left join erp_product_product_suppliers epps on wp.id =epps.ProductId  