/*
select
    ���յ�����һ
    �����ܴ�
    ,����SPU��
    ,����3\7\14�춯����
 */

with
lst as ( -- wl��ÿ����¼����һ��MinPublicationDate���޳���δɾ��
select spu ,min(MinPublicationDate) as min_pub_time
    ,date(min(MinPublicationDate)) as min_pub_date
from wt_listing wl
join mysql_store ms on wl.ShopCode = ms.code and ms.Department = '��ٻ�' and IsDeleted = 0
group by spu
)


, od as (
select
    timestampdiff(second,min_pub_time,PayTime)/86400 od_days_since_lst
    ,PlatOrderNumber
    ,Product_SPU as spu
    ,min_pub_date
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code and ms.Department ='��ٻ�' and IsDeleted = 0
join lst on wo.Product_SPU = lst.SPU and lst.min_pub_time >= '2023-01-01'
)
-- select * from od

select
    ta.min_pub_date �״ο�������
    ,dd.day_name ����
    ,dd.week_num_in_year �ܴ�
    ,first_pub_spu_cnt `�׵�SPU��`
    ,round( ord3_sku_cnt / first_pub_spu_cnt ,4) `����3�춯����`
    ,round( ord7_sku_cnt / first_pub_spu_cnt ,4) `����7�춯����`
    ,round( ord14_sku_cnt / first_pub_spu_cnt ,4) `����14�춯����`
    ,round( ord_sku_cnt / first_pub_spu_cnt ,4) `�����ۼƶ�����`
from (select min_pub_date ,count(distinct spu) first_pub_spu_cnt from lst where min_pub_date >= '2023-01-01' group by min_pub_date ) ta
left join (
    select min_pub_date
        , count(distinct case when 0 <= od_days_since_lst and od_days_since_lst <= 3  then od.SPU end) as ord3_sku_cnt
        , count(distinct case when 0 <= od_days_since_lst and od_days_since_lst <= 7  then od.SPU end) as ord7_sku_cnt
        , count(distinct case when 0 <= od_days_since_lst and od_days_since_lst  <= 14 then od.SPU end) as ord14_sku_cnt
        , count(distinct case when 0 <= od_days_since_lst and od_days_since_lst <= current_date() then od.SPU end) as ord_sku_cnt
    from od group by min_pub_date
    ) tb on ta.min_pub_date = tb.min_pub_date
left join dim_date dd on ta.min_pub_date = dd.full_date
where ta.min_pub_date != '9999-12-31'
order by ta.min_pub_date desc