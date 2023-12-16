-- ������ʱ����Ŀ�ڵ� ��ٻ� ȥ��1-12�»��ܵĵ���Ʒ���˺�ά�ȵ�����
select  count(1) from (

select ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,TortType,left(SettlementTime,7) `�����·�` 
	,round(sum(TotalGross/ExchangeUSD),2) as `���۶�usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `�����usd`  
	,count(distinct OrderNumber) `������`
	,sum(SaleCount) `������Ʒ����`
from ods_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '����' when ProductStatus = 2 then 'ͣ��' 
			when ProductStatus = 3 then 'ͣ��' when ProductStatus = 4 then '��ʱȱ��'  
			when ProductStatus = 5 then '���' end as ProductStatus
			, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products ) wt 
	on wo.BoxSku = wt.BoxSku and wt.Product_CategoryFullPath regexp 'A7�����˶�>A7����|A3���ְ���>A3�˶��뻧��>A3�˶�>A3������Ʒ'
	and TransactionType ='����' and OrderStatus != '����' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -12 month)
	and IsDeleted = 0 and ws.Department in ('��ٻ�')
group by ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 


) a 
