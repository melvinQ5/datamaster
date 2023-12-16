-- ��Ҫ�滻 ͳ���·�  �����·� �� StartDay

-- Ա��ͳ�ƣ�
-- ���¿��ǳ������� , ����
select department, ProductSalesName, count(distinct(concat(ShopIrobotId,SellerSku)))`����������`,count(distinct(boxsku))`����SKU��`,count(distinct(OrderNumber))`������`,ROUND(sum(sales/usdratio),0) `ҵ��`,round(sum(profit/usdratio) ,0)`�����`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =8 -- ͳ���·�
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=8 -- �����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '����'
and year(SettlementTime)=2022 and month(SettlementTime) = 8 -- ͳ���·�
group by OrderNumber
) a
where alltype in ('����', '����')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = '2022-08-01' and reporttype = '�±�' limit 1)b 


group by department, ProductSalesName
order by department





-- ����������Ա���㿯������
select s.department,al.ProductSalesName, count(DISTINCT(al.id))`����������`, count(DISTINCT(al.sku))`����SKU��` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
group by s.department,al.ProductSalesName





-- ���¿��ǳ������� , ����
select 'GM'department, count(distinct(concat(ShopIrobotId,SellerSku)))`����������`,count(distinct(boxsku))`����SKU��`,count(distinct(OrderNumber))`������`,ROUND(sum(sales/usdratio),0) `ҵ��`,round(sum(profit/usdratio) ,0)`�����`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId and s.department='����һ��'
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =ͳ���·�
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '����'
and year(SettlementTime)=2022 and month(SettlementTime) =ͳ���·�
group by OrderNumber
) a
where alltype in ('����', '����')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = 'StartDay' and reporttype = '�±�' limit 1)b 



union all
select 'PM' department,  count(distinct(concat(ShopIrobotId,SellerSku)))`����������`,count(distinct(boxsku))`����SKU��`,count(distinct(OrderNumber))`������`,ROUND(sum(sales/usdratio),0) `ҵ��`,round(sum(profit/usdratio) ,0)`�����`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId and s.department in('���۶���','��������')
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =ͳ���·�
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '����'
and year(SettlementTime)=2022 and month(SettlementTime) =ͳ���·�
group by OrderNumber
) a
where alltype in ('����', '����')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = 'StartDay' and reporttype = '�±�' limit 1)b 


union all

select department, count(distinct(concat(ShopIrobotId,SellerSku)))`����������`,count(distinct(boxsku))`����SKU��`,count(distinct(OrderNumber))`������`,ROUND(sum(sales/usdratio),0) `ҵ��`,round(sum(profit/usdratio) ,0)`�����`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId 
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =ͳ���·�
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '����'
and year(SettlementTime)=2022 and month(SettlementTime) =ͳ���·�
group by OrderNumber
) a
where alltype in ('����', '����')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = 'StartDay' and reporttype = '�±�' limit 1)b 


group by department
order by department



-- ����������Ա���㿯������
select 'GM'`����`, count(DISTINCT(al.id))`����������`, count(DISTINCT(al.sku))`����SKU��` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode and s.department='����һ��'
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''


union all
select 'PM' `����`, count(DISTINCT(al.id))`����������`, count(DISTINCT(al.sku))`����SKU��` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode and s.department in('���۶���','��������')
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''

union all
select s.department `����`,count(DISTINCT(al.id))`����������`, count(DISTINCT(al.sku))`����SKU��` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode 
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=�����·�
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
group by s.department 