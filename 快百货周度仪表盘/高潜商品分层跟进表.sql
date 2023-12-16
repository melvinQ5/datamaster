

with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '高潜商品跟进' and handletime='2023-06-19'
)
select  round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14天成功率
from ( select *  from  potential WHERE  FirstDay = '2023-06-19' and prod_level regexp '潜力') w0 -- 上周潜力款  -- 手工表写的下周一为statday
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay in ('2023-06-19')  and Department='快百货成都' and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU


with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '高潜商品跟进' and handletime='2023-06-19'
)
select  round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14天成功率
from ( select *  from  potential WHERE  FirstDay = '2023-06-12' and prod_level regexp '潜力') w0 -- 上周潜力款  -- 手工表写的下周一为statday
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay in ('2023-06-12' ,'2023-06-19')  and Department='快百货成都' and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU

with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '高潜商品跟进' and handletime='2023-06-19'
)
select  round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14天成功率
from ( select *  from  potential WHERE  FirstDay = '2023-06-12' and prod_level regexp '潜力') w0 -- 上周潜力款  -- 手工表写的下周一为statday
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay in ('2023-06-12' ,'2023-06-19')  and Department='快百货成都' and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU





, up7d as (
select '${StartDay}' FirstDay ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  7天成功率
from ( select * from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
left join ( select distinct spu  from  dep_kbh_product_level WHERE  FirstDay > '${StartDay}'  and Department ='快百货成都'  and FirstDay <= date_add( '${StartDay}' ,interval 1 week) and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU
)

, up14d as (
select '${StartDay}'  FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14天成功率
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay > '${StartDay}'  and Department ='快百货成都' and FirstDay <= date_add( '${StartDay}' ,interval 2 week)  and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU
)

, up28d as (
select '${StartDay}' FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  28天成功率
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay > '${StartDay}'  and Department ='快百货成都' and FirstDay <= date_add( '${StartDay}' ,interval 4 week)  and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU
)

, od7d as ( -- 当周日均业绩
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/7 ,2) 7天日均业绩  --   潜力款7天日均业绩
     , round( count( distinct PlatOrderNumber )/7 ,2)  7天日均订单 --   潜力款7天日均业绩
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '作废'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='快百货' and ms.NodePathName regexp '成都'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 1 week)
)

, od14d as ( -- 两周日均业绩
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/14 ,2)  14天日均业绩 --   潜力款7天日均业绩
     , round( count( distinct PlatOrderNumber )/14 ,2) 14天日均订单  --   潜力款7天日均业绩
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '作废'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='快百货' and ms.NodePathName regexp '成都'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 2 week)
)

, od28d as ( -- 4周日均业绩
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/28 ,2)   28天日均业绩 --   潜力款7天日均业绩
     , round( count( distinct PlatOrderNumber )/28 ,2) 28天日均订单  --   潜力款7天日均业绩
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '作废'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='快百货' and ms.NodePathName regexp '成都'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 4 week)
)


select w0.*
    ,up7d.`7天成功率` ,up14d.`14天成功率` ,up28d.`28天成功率`
    ,od7d.`7天日均业绩` ,od14d.`14天日均业绩`,od28d.`28天日均业绩`
    ,od7d.`7天日均订单` ,od14d.`14天日均订单`,od28d.`28天日均订单`
from ( select '${StartDay}' FirstDay , weekofyear('${StartDay}') , count( distinct spu) `潜力SPU数`
	from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力' ) w0
left join up7d on w0.FirstDay = up7d.FirstDay
left join up14d on w0.FirstDay = up14d.FirstDay
left join up28d on w0.FirstDay = up28d.FirstDay
left join od7d on w0.FirstDay = od7d.FirstDay
left join od14d on w0.FirstDay = od14d.FirstDay
left join od28d on w0.FirstDay = od28d.FirstDay


-- 分周计算


/*
with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '高潜商品跟进' and handletime='2023-06-19'
)

, up7d as (
select '${StartDay}' FirstDay ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  7天成功率
from ( select * from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
left join ( select *  from  potential WHERE  FirstDay > '${StartDay}'  and FirstDay <= date_add( '${StartDay}' ,interval 1 week) and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU
)

, up14d as (
select '${StartDay}'  FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14天成功率
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
left join ( select *  from  potential WHERE  FirstDay > '${StartDay}'  and FirstDay <= date_add( '${StartDay}' ,interval 2 week)  and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU
)

, up28d as (
select '${StartDay}' FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  28天成功率
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
left join ( select *  from  potential WHERE  FirstDay > '${StartDay}'  and FirstDay <= date_add( '${StartDay}' ,interval 4 week)  and prod_level regexp '旺款|爆款') w1
    on w0.SPU = w1.SPU
)

, od7d as ( -- 当周日均业绩
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/7 ,2) 7天日均业绩  --   潜力款7天日均业绩
     , round( count( distinct PlatOrderNumber )/7 ,2)  7天日均订单 --   潜力款7天日均业绩
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '作废'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='快百货' and ms.NodePathName regexp '成都'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 1 week)
)

, od14d as ( -- 两周日均业绩
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/14 ,2)  14天日均业绩 --   潜力款7天日均业绩
     , round( count( distinct PlatOrderNumber )/14 ,2) 14天日均订单  --   潜力款7天日均业绩
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '作废'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='快百货' and ms.NodePathName regexp '成都'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 2 week)
)

, od28d as ( -- 4周日均业绩
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/28 ,2)   28天日均业绩 --   潜力款7天日均业绩
     , round( count( distinct PlatOrderNumber )/28 ,2) 28天日均订单  --   潜力款7天日均业绩
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力') w0 -- 上周潜力款
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '作废'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='快百货' and ms.NodePathName regexp '成都'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 4 week)
)


select w0.*
    ,up7d.`7天成功率` ,up14d.`14天成功率` ,up28d.`28天成功率`
    ,od7d.`7天日均业绩` ,od14d.`14天日均业绩`,od28d.`28天日均业绩`
    ,od7d.`7天日均订单` ,od14d.`14天日均订单`,od28d.`28天日均订单`
from ( select '${StartDay}' FirstDay , weekofyear('${StartDay}') , count( distinct spu) `潜力SPU数`
	from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp '潜力' ) w0
left join up7d on w0.FirstDay = up7d.FirstDay
left join up14d on w0.FirstDay = up14d.FirstDay
left join up28d on w0.FirstDay = up28d.FirstDay
left join od7d on w0.FirstDay = od7d.FirstDay
left join od14d on w0.FirstDay = od14d.FirstDay
left join od28d on w0.FirstDay = od28d.FirstDay

*/