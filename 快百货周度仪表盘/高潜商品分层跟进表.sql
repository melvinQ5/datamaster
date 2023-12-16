

with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '��Ǳ��Ʒ����' and handletime='2023-06-19'
)
select  round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14��ɹ���
from ( select *  from  potential WHERE  FirstDay = '2023-06-19' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����  -- �ֹ���д������һΪstatday
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay in ('2023-06-19')  and Department='��ٻ��ɶ�' and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU


with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '��Ǳ��Ʒ����' and handletime='2023-06-19'
)
select  round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14��ɹ���
from ( select *  from  potential WHERE  FirstDay = '2023-06-12' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����  -- �ֹ���д������һΪstatday
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay in ('2023-06-12' ,'2023-06-19')  and Department='��ٻ��ɶ�' and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU

with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '��Ǳ��Ʒ����' and handletime='2023-06-19'
)
select  round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14��ɹ���
from ( select *  from  potential WHERE  FirstDay = '2023-06-12' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����  -- �ֹ���д������һΪstatday
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay in ('2023-06-12' ,'2023-06-19')  and Department='��ٻ��ɶ�' and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU





, up7d as (
select '${StartDay}' FirstDay ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  7��ɹ���
from ( select * from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
left join ( select distinct spu  from  dep_kbh_product_level WHERE  FirstDay > '${StartDay}'  and Department ='��ٻ��ɶ�'  and FirstDay <= date_add( '${StartDay}' ,interval 1 week) and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU
)

, up14d as (
select '${StartDay}'  FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14��ɹ���
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay > '${StartDay}'  and Department ='��ٻ��ɶ�' and FirstDay <= date_add( '${StartDay}' ,interval 2 week)  and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU
)

, up28d as (
select '${StartDay}' FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  28��ɹ���
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
left join ( select *  from  dep_kbh_product_level WHERE  FirstDay > '${StartDay}'  and Department ='��ٻ��ɶ�' and FirstDay <= date_add( '${StartDay}' ,interval 4 week)  and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU
)

, od7d as ( -- �����վ�ҵ��
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/7 ,2) 7���վ�ҵ��  --   Ǳ����7���վ�ҵ��
     , round( count( distinct PlatOrderNumber )/7 ,2)  7���վ����� --   Ǳ����7���վ�ҵ��
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '����'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='��ٻ�' and ms.NodePathName regexp '�ɶ�'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 1 week)
)

, od14d as ( -- �����վ�ҵ��
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/14 ,2)  14���վ�ҵ�� --   Ǳ����7���վ�ҵ��
     , round( count( distinct PlatOrderNumber )/14 ,2) 14���վ�����  --   Ǳ����7���վ�ҵ��
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '����'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='��ٻ�' and ms.NodePathName regexp '�ɶ�'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 2 week)
)

, od28d as ( -- 4���վ�ҵ��
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/28 ,2)   28���վ�ҵ�� --   Ǳ����7���վ�ҵ��
     , round( count( distinct PlatOrderNumber )/28 ,2) 28���վ�����  --   Ǳ����7���վ�ҵ��
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '����'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='��ٻ�' and ms.NodePathName regexp '�ɶ�'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 4 week)
)


select w0.*
    ,up7d.`7��ɹ���` ,up14d.`14��ɹ���` ,up28d.`28��ɹ���`
    ,od7d.`7���վ�ҵ��` ,od14d.`14���վ�ҵ��`,od28d.`28���վ�ҵ��`
    ,od7d.`7���վ�����` ,od14d.`14���վ�����`,od28d.`28���վ�����`
from ( select '${StartDay}' FirstDay , weekofyear('${StartDay}') , count( distinct spu) `Ǳ��SPU��`
	from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��' ) w0
left join up7d on w0.FirstDay = up7d.FirstDay
left join up14d on w0.FirstDay = up14d.FirstDay
left join up28d on w0.FirstDay = up28d.FirstDay
left join od7d on w0.FirstDay = od7d.FirstDay
left join od14d on w0.FirstDay = od14d.FirstDay
left join od28d on w0.FirstDay = od28d.FirstDay


-- ���ܼ���


/*
with potential as(
select handlename as prod_level , cast( c2 as date) as FirstDay ,memo as spu
from  manual_table mt
where c1 = '��Ǳ��Ʒ����' and handletime='2023-06-19'
)

, up7d as (
select '${StartDay}' FirstDay ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  7��ɹ���
from ( select * from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
left join ( select *  from  potential WHERE  FirstDay > '${StartDay}'  and FirstDay <= date_add( '${StartDay}' ,interval 1 week) and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU
)

, up14d as (
select '${StartDay}'  FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  14��ɹ���
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
left join ( select *  from  potential WHERE  FirstDay > '${StartDay}'  and FirstDay <= date_add( '${StartDay}' ,interval 2 week)  and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU
)

, up28d as (
select '${StartDay}' FirstDay  ,WEEKOFYEAR('${StartDay}')+1
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  28��ɹ���
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
left join ( select *  from  potential WHERE  FirstDay > '${StartDay}'  and FirstDay <= date_add( '${StartDay}' ,interval 4 week)  and prod_level regexp '����|����') w1
    on w0.SPU = w1.SPU
)

, od7d as ( -- �����վ�ҵ��
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/7 ,2) 7���վ�ҵ��  --   Ǳ����7���վ�ҵ��
     , round( count( distinct PlatOrderNumber )/7 ,2)  7���վ����� --   Ǳ����7���վ�ҵ��
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '����'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='��ٻ�' and ms.NodePathName regexp '�ɶ�'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 1 week)
)

, od14d as ( -- �����վ�ҵ��
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/14 ,2)  14���վ�ҵ�� --   Ǳ����7���վ�ҵ��
     , round( count( distinct PlatOrderNumber )/14 ,2) 14���վ�����  --   Ǳ����7���վ�ҵ��
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '����'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='��ٻ�' and ms.NodePathName regexp '�ɶ�'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 2 week)
)

, od28d as ( -- 4���վ�ҵ��
select  '${StartDay}' FirstDay
     , round( sum(TotalGross/ExchangeUSD)/28 ,2)   28���վ�ҵ�� --   Ǳ����7���վ�ҵ��
     , round( count( distinct PlatOrderNumber )/28 ,2) 28���վ�����  --   Ǳ����7���վ�ҵ��
from ( select *  from  potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��') w0 -- ����Ǳ����
join wt_orderdetails wo on w0.spu = wo.product_spu and wo.IsDeleted=0 and wo.OrderStatus <> '����'
join mysql_store ms on wo.shopcode = ms.Code and ms.Department='��ٻ�' and ms.NodePathName regexp '�ɶ�'
where PayTime >= w0.FirstDay and PayTime < date_add( w0.FirstDay,interval 4 week)
)


select w0.*
    ,up7d.`7��ɹ���` ,up14d.`14��ɹ���` ,up28d.`28��ɹ���`
    ,od7d.`7���վ�ҵ��` ,od14d.`14���վ�ҵ��`,od28d.`28���վ�ҵ��`
    ,od7d.`7���վ�����` ,od14d.`14���վ�����`,od28d.`28���վ�����`
from ( select '${StartDay}' FirstDay , weekofyear('${StartDay}') , count( distinct spu) `Ǳ��SPU��`
	from potential WHERE  FirstDay = '${StartDay}' and prod_level regexp 'Ǳ��' ) w0
left join up7d on w0.FirstDay = up7d.FirstDay
left join up14d on w0.FirstDay = up14d.FirstDay
left join up28d on w0.FirstDay = up28d.FirstDay
left join od7d on w0.FirstDay = od7d.FirstDay
left join od14d on w0.FirstDay = od14d.FirstDay
left join od28d on w0.FirstDay = od28d.FirstDay

*/