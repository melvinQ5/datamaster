with tOnline as (
select wl.ShopCode ,wl.SellerSKU ,wl.ASIN 
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where IsDeleted = 0 and ms.NodePathName = '��η�-�ɶ�������' 
	and ListingStatus =1 
	and ms.ShopStatus = '����'
	and shopcode = 'XW-NL'
group by wl.ShopCode ,wl.SellerSKU ,wl.ASIN 
)

, tOrd as ( 
select wo.ShopCode ,wo.SellerSKU ,wo.ASIN 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.code 
where IsDeleted = 0 and ms.NodePathName = '��η�-�ɶ�������' and PayTime >= '2023-02-01' and PayTime <= '2023-03-22'
group by  wo.ShopCode ,wo.SellerSKU ,wo.ASIN 
)

select ta.code ,tb.`����������` ,tc.`���³���������`
from 
	(select code from import_data.mysql_store ms where NodePathName = '��η�-�ɶ�������' and ShopStatus = '����') ta 
left join 
	(select shopcode ,count( distinct SellerSKU,ASIN ) `����������` from tOnline group by shopcode ) tb on ta.code = tb.shopcode 
left join 
	(select shopcode ,count( distinct SellerSKU,ASIN ) `���³���������` from tOrd group by shopcode ) tc on ta.code = tc.shopcode