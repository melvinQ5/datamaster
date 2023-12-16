with tOnline as (
select wl.ShopCode ,wl.SellerSKU ,wl.ASIN 
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where IsDeleted = 0 and ms.NodePathName = '快次方-成都销售组' 
	and ListingStatus =1 
	and ms.ShopStatus = '正常'
	and shopcode = 'XW-NL'
group by wl.ShopCode ,wl.SellerSKU ,wl.ASIN 
)

, tOrd as ( 
select wo.ShopCode ,wo.SellerSKU ,wo.ASIN 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.code 
where IsDeleted = 0 and ms.NodePathName = '快次方-成都销售组' and PayTime >= '2023-02-01' and PayTime <= '2023-03-22'
group by  wo.ShopCode ,wo.SellerSKU ,wo.ASIN 
)

select ta.code ,tb.`在线链接数` ,tc.`二月出单连接数`
from 
	(select code from import_data.mysql_store ms where NodePathName = '快次方-成都销售组' and ShopStatus = '正常') ta 
left join 
	(select shopcode ,count( distinct SellerSKU,ASIN ) `在线链接数` from tOnline group by shopcode ) tb on ta.code = tb.shopcode 
left join 
	(select shopcode ,count( distinct SellerSKU,ASIN ) `二月出单连接数` from tOrd group by shopcode ) tc on ta.code = tc.shopcode