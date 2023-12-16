select max(PayTime),max(DorisImportTime)
from wt_orderdetails wo 


select to_date(DorisImportTime) ,count(1)
from wt_orderdetails wo 
where IsDeleted = 0
group by to_date(DorisImportTime)
order by to_date(DorisImportTime)  desc


select to_date(PayTime) ,count(1)
from import_data.ods_orderdetails  wo
group by to_date(PayTime)
order by to_date(PayTime)  desc 


select to_date(PayTime) ,count(1)
from daily_OrderDetails_Test  wo 
group by to_date(PayTime)
order by to_date(PayTime)  desc

select to_date(PayTime) ,count(1)
from wt_orderdetails  wo  where IsDeleted=0
group by to_date(PayTime)
order by to_date(PayTime)  desc


select to_date(DeleteTime) ,count(1)
from daily_OrderDelete
group by to_date(DeleteTime)
order by to_date(DeleteTime)  desc


select to_date(OrderTime) ,count(1)
from import_data.daily_PurchaseOrder wo 
group by to_date(OrderTime)
order by to_date(OrderTime)  desc 


select date(OrderTime) ,count(1)
from import_data.wt_purchaseorder wo 
group by date(OrderTime)
order by date(OrderTime)  desc


select to_date(CreatedTime) ,count( distinct  PlatOrderNumber)
from import_data.PackageDetail wo
group by to_date(CreatedTime)
order by to_date(CreatedTime)  desc


select to_date(PayTime) ,count(1)
from daily_WeightOrders  wo 
group by to_date(PayTime)
order by to_date(PayTime)  desc 

-- Á´½Ó
select date(PublicationDate) ,count(*) from wt_listing where IsDeleted=0 group by date(PublicationDate) order by date(PublicationDate) desc
select date(PublicationDate) ,count(*) from erp_amazon_amazon_listing group by date(PublicationDate) order by date(PublicationDate) desc

select  to_date(CreationTime) ,count(1)
from erp_amazon_amazon_listing eaal where CreationTime > ='2023-04-20'
group by to_date(CreationTime)


select  to_date(PublicationDate) ,count(1)
from erp_amazon_amazon_listing eaal where PublicationDate > ='2023-04-01'
group by to_date(PublicationDate)
order by to_date(PublicationDate) desc 

-- ²É¹º
select to_date(OrderTime) ,count(1)
from wt_purchaseorder wp  
-- where IsDeleted = 0
group by to_date(OrderTime)
order by to_date(OrderTime)  desc 
