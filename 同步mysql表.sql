insert into ads_amazon_ordersource_asinnum
(with ord as (
select Asin,ShopIrobotId,PayTime,PlatOrderNumber
from ods_orderdetails od
where IsDeleted=0
and PayTime>='2022-01-01'
and TransactionType='����'
)

-- 61:ǰ14���Ʒ������,62:ǰ30���Ʒ������,63:�ϸ��²�Ʒ������,64:ǰ3���²�Ʒ������,65:ǰ6���²�Ʒ������,66:2022�������Ʒ������
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