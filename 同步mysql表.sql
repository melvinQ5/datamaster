insert into ads_amazon_ordersource_asinnum
(with ord as (
select Asin,ShopIrobotId,PayTime,PlatOrderNumber
from ods_orderdetails od
where IsDeleted=0
and PayTime>='2022-01-01'
and TransactionType='付款'
)

-- 61:前14天产品订单数,62:前30天产品订单数,63:上个月产品订单数,64:前3个月产品订单数,65:前6个月产品订单数,66:2022年至今产品订单数
,tmp as (
select Asin,right(ShopIrobotId,2) SiteCode
,'61'SkuSumType
,count(PlatOrderNumber) 'OrderCount'
from ord
where PayTime>=date_add(current_date(),interval -14 day)
group by Asin,right(ShopIrobotId,2)
union
select Asin,right(ShopIrobotId,2)
,'62'SkuSumType
,count(PlatOrderNumber) 'OrderCount'
from ord
where PayTime>=date_add(current_date(),interval -30 day)
group by Asin,right(ShopIrobotId,2)
union
select Asin,right(ShopIrobotId,2)
,'63'SkuSumType
,count(PlatOrderNumber) 'OrderCount'
from ord
where PayTime>=date_add(date_add(current_date(),interval -(day(current_date())-1) day),interval -1 month)
and  PayTime<date_add(current_date(),interval -(day(current_date())-1) day )
group by Asin,right(ShopIrobotId,2)
union
select Asin,right(ShopIrobotId,2)
,'64'SkuSumType
,count(PlatOrderNumber) 'OrderCount'
from ord
where PayTime>=date_add(current_date(),interval -90 day)
group by Asin,right(ShopIrobotId,2)
union
select Asin,right(ShopIrobotId,2)
,'65'SkuSumType
,count(PlatOrderNumber) 'OrderCount'
from ord
where PayTime>=date_add(current_date(),interval -180 day)
group by Asin,right(ShopIrobotId,2)
union
select Asin,right(ShopIrobotId,2) SiteCode
,'66'SkuSumType
,count(PlatOrderNumber) 'OrderCount'
from ord
where PayTime>='2022-01-01'
group by Asin,right(ShopIrobotId,2))

select uuid() id
     ,now() UpdateTime
     ,now() CreationTime
     ,Asin
     ,SiteCode
     ,SkuSumType
     ,OrderCount
from tmp);