/*
select
    对照当周周一
    终审周次
    ,终审SPU数
    ,刊登3\7\14天动销率
 */

with
lst as ( -- wl表每条记录都有一个MinPublicationDate，剔除掉未删除
select spu ,min(MinPublicationDate) as min_pub_time
    ,date(min(MinPublicationDate)) as min_pub_date
from wt_listing wl
join mysql_store ms on wl.ShopCode = ms.code and ms.Department = '快百货' and IsDeleted = 0
group by spu
)


, od as (
select
    timestampdiff(second,min_pub_time,PayTime)/86400 od_days_since_lst
    ,PlatOrderNumber
    ,Product_SPU as spu
    ,min_pub_date
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code and ms.Department ='快百货' and IsDeleted = 0
join lst on wo.Product_SPU = lst.SPU and lst.min_pub_time >= '2023-01-01'
)
-- select * from od

select
    ta.min_pub_date 首次刊登日期
    ,dd.day_name 星期
    ,dd.week_num_in_year 周次
    ,first_pub_spu_cnt `首登SPU数`
    ,round( ord3_sku_cnt / first_pub_spu_cnt ,4) `刊登3天动销率`
    ,round( ord7_sku_cnt / first_pub_spu_cnt ,4) `刊登7天动销率`
    ,round( ord14_sku_cnt / first_pub_spu_cnt ,4) `刊登14天动销率`
    ,round( ord_sku_cnt / first_pub_spu_cnt ,4) `刊登累计动销率`
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