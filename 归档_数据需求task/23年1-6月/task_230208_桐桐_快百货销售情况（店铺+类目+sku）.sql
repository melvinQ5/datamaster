-- '԰����Ʒ|ͥԺ����ƺ�ͻ�԰' ��ٻ�1�µ��������ݣ�����Ʒ���˺�ά�ȵ�����
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
	on wo.BoxSku = wt.BoxSku 
	and wt.Product_CategoryFullPath REGEXP '԰����Ʒ|ͥԺ����ƺ�ͻ�԰'
	and TransactionType ='����' and OrderStatus != '����' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -1 month)
	and IsDeleted = 0 and ws.Department in ('��ٻ�')
group by ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 


) a 

-- '԰����Ʒ|ͥԺ����ƺ�ͻ�԰' ��ٻ� ȥ��1-12�»��ܵĵ���Ʒ���˺�ά�ȵ�����
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
	on wo.BoxSku = wt.BoxSku 
	and wt.Product_CategoryFullPath REGEXP '԰����Ʒ|ͥԺ����ƺ�ͻ�԰'
	and TransactionType ='����' and OrderStatus != '����' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -12 month)
	and IsDeleted = 0 and ws.Department in ('��ٻ�')
group by ws.Code ,wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 


) a 


-- ���в�Ʒ ��ٻ� ȥ��1-12�»��ܵĵ���Ʒ���˺�ά�ȵ�����
select  count(1) from (

select wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName ,ProductStatus,TortType,left(SettlementTime,7) `�����·�` 
	,round(sum(TotalGross/ExchangeUSD),2) as `���۶�usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `�����usd`  
	,count(distinct OrderNumber) `������`
	,sum(SaleCount) `������Ʒ����`
from ods_orderdetails wo 
FROM wt_orderdetails wo 
join ( select DISTINCT BoxSku,sku , ProductName
		,case when ProductStatus = 0 then '����' when ProductStatus = 2 then 'ͣ��' 
			when ProductStatus = 3 then 'ͣ��' when ProductStatus = 4 then '��ʱȱ��'  
			when ProductStatus = 5 then '���' end as ProductStatus
			, TortType ,CategoryPathByChineseName as Product_CategoryFullPath
	from import_data.wt_products ) wt 
	on wo.BoxSku = wt.BoxSku 
-- 	and wt.Product_CategoryFullPath regexp 'A7�����˶�>A7����|A3���ְ���>A3�˶��뻧��>A3�˶�>A3������Ʒ'
	and TransactionType ='����' and OrderStatus != '����' 
join import_data.wt_store ws on wo.ShopIrobotId = ws.Code 
	and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -12 month)
	and IsDeleted = 0 and ws.Department in ('��ٻ�')
group by wt.Product_CategoryFullPath ,wt.Sku ,wo.BoxSku,ProductName , ProductStatus ,TortType ,left(SettlementTime,7) 

) a 

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

