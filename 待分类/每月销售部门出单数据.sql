-- 需要替换 统计月份  刊登月份 和 StartDay

-- 员工统计：
-- 当月刊登出单数据 , 部门
select department, ProductSalesName, count(distinct(concat(ShopIrobotId,SellerSku)))`出单链接数`,count(distinct(boxsku))`出单SKU数`,count(distinct(OrderNumber))`订单数`,ROUND(sum(sales/usdratio),0) `业绩`,round(sum(profit/usdratio) ,0)`利润额`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =8 -- 统计月份
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=8 -- 刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '作废'
and year(SettlementTime)=2022 and month(SettlementTime) = 8 -- 统计月份
group by OrderNumber
) a
where alltype in ('付款', '其他')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = '2022-08-01' and reporttype = '月报' limit 1)b 


group by department, ProductSalesName
order by department





-- 按照销售人员计算刊登数量
select s.department,al.ProductSalesName, count(DISTINCT(al.id))`刊登链接数`, count(DISTINCT(al.sku))`刊登SKU数` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
group by s.department,al.ProductSalesName





-- 当月刊登出单数据 , 部门
select 'GM'department, count(distinct(concat(ShopIrobotId,SellerSku)))`出单链接数`,count(distinct(boxsku))`出单SKU数`,count(distinct(OrderNumber))`订单数`,ROUND(sum(sales/usdratio),0) `业绩`,round(sum(profit/usdratio) ,0)`利润额`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId and s.department='销售一部'
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =统计月份
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '作废'
and year(SettlementTime)=2022 and month(SettlementTime) =统计月份
group by OrderNumber
) a
where alltype in ('付款', '其他')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = 'StartDay' and reporttype = '月报' limit 1)b 



union all
select 'PM' department,  count(distinct(concat(ShopIrobotId,SellerSku)))`出单链接数`,count(distinct(boxsku))`出单SKU数`,count(distinct(OrderNumber))`订单数`,ROUND(sum(sales/usdratio),0) `业绩`,round(sum(profit/usdratio) ,0)`利润额`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId and s.department in('销售二部','销售三部')
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =统计月份
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '作废'
and year(SettlementTime)=2022 and month(SettlementTime) =统计月份
group by OrderNumber
) a
where alltype in ('付款', '其他')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = 'StartDay' and reporttype = '月报' limit 1)b 


union all

select department, count(distinct(concat(ShopIrobotId,SellerSku)))`出单链接数`,count(distinct(boxsku))`出单SKU数`,count(distinct(OrderNumber))`订单数`,ROUND(sum(sales/usdratio),0) `业绩`,round(sum(profit/usdratio) ,0)`利润额`
from 

(select s.department,al.ProductSalesName, op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber,sum(income) sales, sum(GrossProfit) profit from import_data.OrderProfitSettle op
join import_data.mysql_store s on s.Code = op.ShopIrobotId 
join import_data.erp_amazon_amazon_listing al on al.SellerSKU = op.SellerSku and op.ShopIrobotId = al.ShopCode
where year(SettlementTime)=2022 and month(SettlementTime) =统计月份
and year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
and op.OrderNumber not in
(
select OrderNumber from (
SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderProfitSettle
where
OrderStatus = '作废'
and year(SettlementTime)=2022 and month(SettlementTime) =统计月份
group by OrderNumber
) a
where alltype in ('付款', '其他')
)
group by s.department,op.ShopIrobotId, op.SellerSku, op.boxsku, op.OrderNumber, al.ProductSalesName
order by department
)a
,
(select usdratio from import_data.Basedata where firstday = 'StartDay' and reporttype = '月报' limit 1)b 


group by department
order by department



-- 按照销售人员计算刊登数量
select 'GM'`部门`, count(DISTINCT(al.id))`刊登链接数`, count(DISTINCT(al.sku))`刊登SKU数` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode and s.department='销售一部'
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''


union all
select 'PM' `部门`, count(DISTINCT(al.id))`刊登链接数`, count(DISTINCT(al.sku))`刊登SKU数` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode and s.department in('销售二部','销售三部')
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''

union all
select s.department `部门`,count(DISTINCT(al.id))`刊登链接数`, count(DISTINCT(al.sku))`刊登SKU数` 
from import_data.erp_amazon_amazon_listing al 
join import_data.mysql_store s on s.Code = al.ShopCode 
Where year(al.PublicationDate)=2022 and  MONTH(al.PublicationDate)=刊登月份
AND al.SellerSKU not regexp '-BJ-|-BJ|BJ-' and al.sku <> ''
group by s.department 