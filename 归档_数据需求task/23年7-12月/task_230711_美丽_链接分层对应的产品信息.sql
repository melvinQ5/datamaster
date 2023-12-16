
with lst as (
select  dkll .*
from dep_kbh_listing_level dkll 
where year(dkll.FirstDay)= 2023 and right(dkll.FirstDay,3) = '-01' 
	and dkll.Department = '快百货成都' 
) 

, od as  ( -- site,asin,spu,boxsku 聚合
select * from (
select ROW_NUMBER () over ( partition by site,asin, spu order by orders desc ) as sort ,ta.*
from (
	select wo.site,asin, Product_SPU as spu ,ms.Code ,ms.SellUserName  ,count(distinct PlatOrderNumber) orders -- 订单数
	from import_data.wt_orderdetails wo
	join mysql_store ms on wo.shopcode=ms.Code 
	where PayTime >='2023-01-01' and PayTime< '2023-07-01' and wo.IsDeleted=0
		and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快' and  NodePathName regexp '成都'
	group by wo.site,asin, spu ,ms.Code ,ms.SellUserName  
	) ta
) tb 
where tb.sort = 1 
)

, res as (
select lst.* ,wp.sku ,wp.ProductName ,date(wp.DevelopLastAuditTime) 终审时间 ,od.code 上半年链接单量top1店铺简码, od.SellUserName 首选业务员
from lst 
left join wt_products wp on lst.spu = wp.spu 
left join od on od.asin = lst.asin and od.site =lst.site and od.spu =lst.spu 
)

-- select count(1) from res 
select * from res 
	