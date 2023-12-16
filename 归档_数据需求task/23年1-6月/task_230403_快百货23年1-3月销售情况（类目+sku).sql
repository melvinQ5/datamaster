-- ���в�Ʒ ��ٻ� 23��1-3�»��ܵĵ���Ʒ���˺�ά�ȵ�����
select  count(1) from (

select wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,wt.TortType,left(SettlementTime,7) `�����·�` 
	,round(sum(TotalGross/ExchangeUSD),2) as `���۶�usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `�����usd`  
	,count(distinct OrderNumber) `������`
	,sum(SaleCount) `������Ʒ����`
from wt_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '����' when ProductStatus = 2 then 'ͣ��' 
			when ProductStatus = 3 then 'ͣ��' when ProductStatus = 4 then '��ʱȱ��'  
			when ProductStatus = 5 then '���' end as ProductStatus
		, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products 
	) wt 
	on wo.BoxSku = wt.BoxSku and IsDeleted = 0 
join import_data.wt_store ws on wo.shopcode  = ws.Code 
where SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -3 month)
	and IsDeleted = 0 and ws.Department in ('��ٻ�')
group by wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,wt.TortType ,left(SettlementTime,7) 

) a 