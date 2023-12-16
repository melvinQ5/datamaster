-- 按周重跑，写单周逻辑

-- 推荐SPU数
insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType ,FirstDay ,push_spu_cnt)
select md5('快百货') as DimensionId  ,year(PushDate), 0 ,dd.week_num_in_year ,0 ,now() ,'周报',dd.week_begin_date
    ,count(distinct d.spu)
from import_data.dep_kbh_product_level_potentail d
join dim_date dd on d.PushDate =dd.full_date and isStopPush='否'
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}'
group by year(PushDate) ,dd.week_num_in_year ,dd.week_begin_date ;

insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType ,FirstDay ,push_spu_cnt)
select md5(concat('快百货',ifnull(istheme,'非主题品')))  as DimensionId ,year(PushDate), 0 ,dd.week_num_in_year ,0 ,now() ,'周报',dd.week_begin_date
    ,count(distinct d.spu)
from import_data.dep_kbh_product_level_potentail d
left join ( select distinct spu ,case when ele_name_priority regexp '冬季|圣诞' then ele_name_priority else '非主题品' end istheme from  dep_kbh_product_test ) dk on d.spu = dk.spu
join dim_date dd on d.PushDate =dd.full_date and isStopPush='否'
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}'
group by year(PushDate) ,dd.week_num_in_year ,dd.week_begin_date ,ifnull(istheme,'非主题品');

-- 推荐N天动销率 -- 新链接 -- 首单N天指标 -- 新链接
-- 快百货
insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_pushin7d, sale_rate_over1_pushin14d, sale_rate_over1_pushin30d, sale_rate_over1_pushin60d, sale_rate_over1_pushin90d,
sale_rate_over3_pushin14d, sale_rate_over3_pushin30d, sale_rate_over6_pushin14d, sale_rate_over6_pushin30d
,sale_amount_pushin7d ,sale_amount_pushin14d ,sale_amount_pushin30d ,sale_amount_pushin60d ,sale_amount_pushin90d
,profit_rate_pushin7d, profit_rate_pushin14d, profit_rate_pushin30d, profit_rate_pushin60d, profit_rate_pushin90d
,sale_amount_odin30d ,sale_unitamount_odin30d
,spu_tophot_pushin30d_newlst , sale_rate_pushin30d_newlst,sale_amount_tophot_pushin30d_newlst
)

with
prod as ( -- 商品运营组推送  SPUx周次
select distinct  spu ,PushDate
from import_data.dep_kbh_product_level_potentail d
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}'
  -- and isStopPush='否'  -- 以推送日期计算 表主键周次
)

,lst as (
select  shopcode ,SellerSKU
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '快百货'
join prod on prod.spu = wl.spu and timestampdiff(SECOND,PushDate,MinPublicationDate) >= 0 -- 新链接（推荐生效后刊登）
where SellerSku not regexp 'bJ|Bj|bj|BJ'
group by shopcode, SellerSKU
)
-- select * from lst

,od as (
select
    timestampdiff(SECOND,PushDate,PayTime)/86400 as ord_days_since_push -- 用于计算推荐N天（以标签生效日期计算 动销指标）
    ,timestampdiff(SECOND,(min(PayTime) over(partition by prod.spu)),PayTime)/86400 as ord_days_since_od -- 用于计算首单30天（从推荐后首次出单开始计算，每笔订单用时）
    -- ,min(PayTime) over(partition by prod.spu) as min_pay_time
    ,PushDate ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( (TotalGross-FeeGross) /ExchangeUSD ,4) as TotalGross_unfreight_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '快百货'
join prod  on wo.Product_Spu = prod.spu
join lst on lst.SellerSKU = wo.SellerSku and lst.ShopCode = wo.shopcode -- 新老链接筛选
join dim_date dd on date(wo.PayTime) =dd.full_date
where wo.IsDeleted=0 and wo.TransactionType ='付款' and  timestampdiff(SECOND,PushDate,PayTime) >= 0 -- 推荐生效后出单
)
-- select * from od

,od_spu_stat_weekly as ( -- 动销率
select '${StartDay}' as FirstDay
     ,count( case when ord7_orders_since_push >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_push
     ,count( case when ord14_orders_since_push >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_push
     ,count( case when ord30_orders_since_push >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_push
     ,count( case when ord60_orders_since_push >= 1 then SPU end ) as ord60_sale1_spu_cnt_since_push
     ,count( case when ord90_orders_since_push >= 1 then SPU end ) as ord90_sale1_spu_cnt_since_push

     ,count( case when ord14_orders_since_push >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_push
     ,count( case when ord30_orders_since_push >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_push

     ,count( case when ord14_orders_since_push >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_push
     ,count( case when ord30_orders_since_push >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_push
from
    ( select spu
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 7 then PlatOrderNumber end) as ord7_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 14 then PlatOrderNumber end) as ord14_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 30 then PlatOrderNumber end) as ord30_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 60 then PlatOrderNumber end) as ord60_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 90 then PlatOrderNumber end) as ord90_orders_since_push
    from od group by spu
    ) ta
)
-- select * from od_spu_stat_weekly

,od_amount_stat_weekly as ( -- 销售额
select '${StartDay}' as FirstDay
    ,sale_amount_pushin7d ,sale_amount_pushin14d ,sale_amount_pushin30d ,sale_amount_pushin60d ,sale_amount_pushin90d ,sale_amount_odin30d
    ,round( ord7_profit_since_push/sale_amount_pushin7d ,4) profit_rate_pushin7d
    ,round( ord14_profit_since_push/sale_amount_pushin14d ,4) profit_rate_pushin14d
    ,round( ord30_profit_since_push/sale_amount_pushin30d ,4) profit_rate_pushin30d
    ,round( ord60_profit_since_push/sale_amount_pushin60d ,4) profit_rate_pushin60d
    ,round( ord90_profit_since_push/sale_amount_pushin90d ,4) profit_rate_pushin90d

    ,round( sale_amount_odin30d/od_spu_cnt_odin30d ,4) sale_unitamount_odin30d -- 首单30天单产
from (
    select
         round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 7 then TotalGross_usd end) ,2) as sale_amount_pushin7d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 14 then TotalGross_usd end) ,2) as sale_amount_pushin14d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 30 then TotalGross_usd end) ,2) as sale_amount_pushin30d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 60 then TotalGross_usd end) ,2) as sale_amount_pushin60d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 90 then TotalGross_usd end) ,2) as sale_amount_pushin90d

        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 7 then TotalProfit_usd end) ,2) as ord7_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 14 then TotalProfit_usd end) ,2) as ord14_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 30 then TotalProfit_usd end) ,2) as ord30_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 60 then TotalProfit_usd end) ,2) as ord60_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 90 then TotalProfit_usd end) ,2) as ord90_profit_since_push

        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as sale_amount_odin30d
        , count( distinct case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then spu end)  as od_spu_cnt_odin30d

    from od
    ) a
)

,od_tophot_stat_weekly as ( -- 爆旺款
select '${StartDay}' as FirstDay
     ,count( case when ord30_sales_unfreight_since_push >= 500 then SPU end ) as spu_tophot_pushin30d_newlst -- 推荐30天爆旺款数
     ,sum( case when ord30_sales_unfreight_since_push >= 500 then ord30_sales_since_push end ) as sale_amount_tophot_pushin30d_newlst -- 推荐30天爆旺款总销售额
from
    ( select spu
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_unfreight_usd end) ,2) as ord30_sales_unfreight_since_push
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as ord30_sales_since_push
    from od group by spu
    ) ta
)

select md5('快百货') as uuid  ,year, 0 ,week ,0 ,now() ,'周报'
    ,round( ord7_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin7d
    ,round( ord14_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin14d
    ,round( ord30_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin30d
    ,round( ord60_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin60d
    ,round( ord90_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin90d

    ,round( ord14_sale3_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over3_pushin14d
    ,round( ord30_sale3_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over3_pushin30d

    ,round( ord14_sale6_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over6_pushin14d
    ,round( ord30_sale6_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over6_pushin30d
    ,t2.sale_amount_pushin7d ,t2.sale_amount_pushin14d ,t2.sale_amount_pushin30d ,t2.sale_amount_pushin60d ,t2.sale_amount_pushin90d
    ,t2.profit_rate_pushin7d,t2. profit_rate_pushin14d,t2. profit_rate_pushin30d,t2. profit_rate_pushin60d,t2. profit_rate_pushin90d

    ,t2.sale_amount_odin30d ,t2.sale_unitamount_odin30d

    ,t3.spu_tophot_pushin30d_newlst ,round( t3.spu_tophot_pushin30d_newlst/push_spu_cnt ,4) sale_rate_pushin30d_newlst
    ,t3.sale_amount_tophot_pushin30d_newlst
from ads_kbh_prod_potential_track_new_lst t0
left join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay
left join od_amount_stat_weekly t2 on t0.FirstDay = t2.FirstDay
left join od_tophot_stat_weekly t3 on t0.FirstDay = t3.FirstDay
where  t0.FirstDay >= '${StartDay}' and t0.FirstDay < '${NextStartDay}'  ;

-- 快百货 x 主题品
insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_pushin7d, sale_rate_over1_pushin14d, sale_rate_over1_pushin30d, sale_rate_over1_pushin60d, sale_rate_over1_pushin90d,
sale_rate_over3_pushin14d, sale_rate_over3_pushin30d, sale_rate_over6_pushin14d, sale_rate_over6_pushin30d
,sale_amount_pushin7d ,sale_amount_pushin14d ,sale_amount_pushin30d ,sale_amount_pushin60d ,sale_amount_pushin90d
,profit_rate_pushin7d, profit_rate_pushin14d, profit_rate_pushin30d, profit_rate_pushin60d, profit_rate_pushin90d
,sale_amount_odin30d ,sale_unitamount_odin30d
,spu_tophot_pushin30d_newlst , sale_rate_pushin30d_newlst,sale_amount_tophot_pushin30d_newlst
)

with
prod as ( -- 商品运营组推送  单周SPU，及推送日期
select distinct  d.spu ,PushDate ,ifnull(istheme_ele,'非主题品') istheme_ele
from import_data.dep_kbh_product_level_potentail d
left join ( select distinct spu ,case when ele_name_priority regexp '冬季|圣诞' then ele_name_priority else '非主题品' end istheme_ele from  dep_kbh_product_test ) dk on d.spu = dk.spu
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}'
  -- and isStopPush='否'  -- 以推送日期计算 表主键周次
)

,lst as (
select  shopcode ,SellerSKU
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '快百货'
join prod on prod.spu = wl.spu and timestampdiff(SECOND,PushDate,MinPublicationDate) >= 0 -- 新链接（推荐生效后刊登）
where SellerSku not regexp 'bJ|Bj|bj|BJ'
group by shopcode, SellerSKU
)
-- select * from lst

,od as (
select
    timestampdiff(SECOND,PushDate,PayTime)/86400 as ord_days_since_push -- 用于计算推荐N天（以标签生效日期计算 动销指标）
    ,timestampdiff(SECOND,(min(PayTime) over(partition by prod.spu)),PayTime)/86400 as ord_days_since_od -- 用于计算首单30天（从推荐后首次出单开始计算，每笔订单用时）
    -- ,min(PayTime) over(partition by prod.spu) as min_pay_time
    ,PushDate ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( (TotalGross-FeeGross) /ExchangeUSD ,4) as TotalGross_unfreight_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year ,istheme_ele
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '快百货'
join prod  on wo.Product_Spu = prod.spu
join lst on lst.SellerSKU = wo.SellerSku and lst.ShopCode = wo.shopcode -- 新老链接筛选
join dim_date dd on date(wo.PayTime) =dd.full_date
where wo.IsDeleted=0 and wo.TransactionType ='付款' and  timestampdiff(SECOND,PushDate,PayTime) >= 0 -- 推荐生效后出单
)
-- select * from od

,od_spu_stat_weekly as ( -- 动销率
select '${StartDay}' as FirstDay ,md5(concat('快百货',istheme_ele)) as DimensionId
     ,count( case when ord7_orders_since_push >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_push
     ,count( case when ord14_orders_since_push >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_push
     ,count( case when ord30_orders_since_push >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_push
     ,count( case when ord60_orders_since_push >= 1 then SPU end ) as ord60_sale1_spu_cnt_since_push
     ,count( case when ord90_orders_since_push >= 1 then SPU end ) as ord90_sale1_spu_cnt_since_push

     ,count( case when ord14_orders_since_push >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_push
     ,count( case when ord30_orders_since_push >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_push

     ,count( case when ord14_orders_since_push >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_push
     ,count( case when ord30_orders_since_push >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_push
from
    ( select spu ,istheme_ele
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 7 then PlatOrderNumber end) as ord7_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 14 then PlatOrderNumber end) as ord14_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 30 then PlatOrderNumber end) as ord30_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 60 then PlatOrderNumber end) as ord60_orders_since_push
        , count(distinct case when 0 <= ord_days_since_push and ord_days_since_push  <= 90 then PlatOrderNumber end) as ord90_orders_since_push
    from od group by spu ,istheme_ele
    ) ta group by istheme_ele
)
-- select * from od_spu_stat_weekly

,od_amount_stat_weekly as ( -- 销售额
select '${StartDay}' as FirstDay ,md5(concat('快百货',istheme_ele)) as DimensionId
    ,sale_amount_pushin7d ,sale_amount_pushin14d ,sale_amount_pushin30d ,sale_amount_pushin60d ,sale_amount_pushin90d ,sale_amount_odin30d
    ,round( ord7_profit_since_push/sale_amount_pushin7d ,4) profit_rate_pushin7d
    ,round( ord14_profit_since_push/sale_amount_pushin14d ,4) profit_rate_pushin14d
    ,round( ord30_profit_since_push/sale_amount_pushin30d ,4) profit_rate_pushin30d
    ,round( ord60_profit_since_push/sale_amount_pushin60d ,4) profit_rate_pushin60d
    ,round( ord90_profit_since_push/sale_amount_pushin90d ,4) profit_rate_pushin90d

    ,round( sale_amount_odin30d/od_spu_cnt_odin30d ,4) sale_unitamount_odin30d -- 首单30天单产
from (
    select istheme_ele
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 7 then TotalGross_usd end) ,2) as sale_amount_pushin7d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 14 then TotalGross_usd end) ,2) as sale_amount_pushin14d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 30 then TotalGross_usd end) ,2) as sale_amount_pushin30d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 60 then TotalGross_usd end) ,2) as sale_amount_pushin60d
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 90 then TotalGross_usd end) ,2) as sale_amount_pushin90d

        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 7 then TotalProfit_usd end) ,2) as ord7_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 14 then TotalProfit_usd end) ,2) as ord14_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 30 then TotalProfit_usd end) ,2) as ord30_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 60 then TotalProfit_usd end) ,2) as ord60_profit_since_push
        , round( sum( case when 0 <= ord_days_since_push and ord_days_since_push  <= 90 then TotalProfit_usd end) ,2) as ord90_profit_since_push

        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as sale_amount_odin30d
        , count( distinct case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then spu end)  as od_spu_cnt_odin30d
    from od group by istheme_ele
    ) a
)

,od_tophot_stat_weekly as ( -- 爆旺款
select '${StartDay}' as FirstDay ,md5(concat('快百货',istheme_ele)) as DimensionId
     ,count( case when ord30_sales_unfreight_since_push >= 500 then SPU end ) as spu_tophot_pushin30d_newlst -- 推荐30天爆旺款数
     ,sum( case when ord30_sales_unfreight_since_push >= 500 then ord30_sales_since_push end ) as sale_amount_tophot_pushin30d_newlst -- 推荐30天爆旺款总销售额
from
    ( select spu ,istheme_ele
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_unfreight_usd end) ,2) as ord30_sales_unfreight_since_push
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as ord30_sales_since_push
    from od group by spu ,istheme_ele
    ) ta  group by istheme_ele
)

select t0.DimensionId ,year, 0 ,week ,0 ,now() ,'周报'
    ,round( ord7_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin7d
    ,round( ord14_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin14d
    ,round( ord30_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin30d
    ,round( ord60_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin60d
    ,round( ord90_sale1_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over1_pushin90d

    ,round( ord14_sale3_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over3_pushin14d
    ,round( ord30_sale3_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over3_pushin30d

    ,round( ord14_sale6_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over6_pushin14d
    ,round( ord30_sale6_spu_cnt_since_push/push_spu_cnt ,4) sale_rate_over6_pushin30d
    ,t2.sale_amount_pushin7d ,t2.sale_amount_pushin14d ,t2.sale_amount_pushin30d ,t2.sale_amount_pushin60d ,t2.sale_amount_pushin90d
    ,t2.profit_rate_pushin7d,t2. profit_rate_pushin14d,t2. profit_rate_pushin30d,t2. profit_rate_pushin60d,t2. profit_rate_pushin90d
    ,t2.sale_amount_odin30d ,t2.sale_unitamount_odin30d
    ,t3.spu_tophot_pushin30d_newlst ,round( t3.spu_tophot_pushin30d_newlst/push_spu_cnt ,4) sale_rate_pushin30d_newlst
    ,t3.sale_amount_tophot_pushin30d_newlst
from ads_kbh_prod_potential_track_new_lst t0
left join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay and t0.DimensionId =t1.DimensionId
left join od_amount_stat_weekly t2 on t0.FirstDay = t2.FirstDay and t0.DimensionId =t2.DimensionId
left join od_tophot_stat_weekly t3 on t0.FirstDay = t3.FirstDay and t0.DimensionId =t3.DimensionId
where  t0.FirstDay >= '${StartDay}' and t0.FirstDay < '${NextStartDay}'  ;


-- 刊登N天动销率 -- 新链接
insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_lstin7d, sale_rate_over1_lstin14d, sale_rate_over1_lstin30d,
sale_rate_over3_lstin14d, sale_rate_over3_lstin30d, sale_rate_over6_lstin14d, sale_rate_over6_lstin30d
)
with
prod as ( -- 商品运营组推送  SPUx周次
select distinct  spu ,PushDate
from import_data.dep_kbh_product_level_potentail d
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}'  and isStopPush='否' -- 以推送日期计算 表主键周次
)

,lst as (
select  shopcode ,SellerSKU  ,min(MinPublicationDate) as MinPublicationDate_new -- 新链接范围内的最早刊登时间
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '快百货'
join prod on prod.spu = wl.spu and timestampdiff(SECOND,PushDate,MinPublicationDate) >= 0 -- 新链接（推荐生效后刊登）
where SellerSku not regexp 'bJ|Bj|bj|BJ'
group by shopcode, SellerSKU
)

,od as (
select
    timestampdiff(SECOND,MinPublicationDate_new,PayTime)/86400 as ord_days_since_lst -- 以标签生效日期计算 动销指标
    ,PushDate ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '快百货'
join prod  on wo.Product_Spu = prod.spu
join lst on lst.SellerSKU = wo.SellerSku and lst.ShopCode = wo.shopcode -- 新老链接筛选选
join dim_date dd on date(wo.PayTime) =dd.full_date
where wo.IsDeleted=0 and wo.TransactionType ='付款' and  timestampdiff(SECOND,MinPublicationDate_new,PayTime) >= 0 -- 推荐生效后新刊登出单
)
-- select * from od

,od_spu_stat_weekly as ( -- 动销率
select '${StartDay}' as FirstDay ,md5('快百货') DimensionId
     ,count( case when ord7_orders_since_lst >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_lst
     ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_lst
     ,count( case when ord60_orders_since_lst >= 1 then SPU end ) as ord60_sale1_spu_cnt_since_lst
     ,count( case when ord90_orders_since_lst >= 1 then SPU end ) as ord90_sale1_spu_cnt_since_lst

     ,count( case when ord14_orders_since_lst >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_lst

     ,count( case when ord14_orders_since_lst >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_lst
from
    ( select spu
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 7 then PlatOrderNumber end) as ord7_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 60 then PlatOrderNumber end) as ord60_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 90 then PlatOrderNumber end) as ord90_orders_since_lst
    from od group by spu
    ) ta
)


select md5('快百货') DimensionId  ,year, 0 ,week ,0 ,now() ,'周报'
    ,round( ord7_sale1_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over1_lstin7d
    ,round( ord14_sale1_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over1_lstin14d
    ,round( ord30_sale1_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over1_lstin30d

    ,round( ord14_sale3_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over3_lstin14d
    ,round( ord30_sale3_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over3_lstin30d

    ,round( ord14_sale6_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over6_lstin14d
    ,round( ord30_sale6_spu_cnt_since_lst/push_spu_cnt ,4) sale_rate_over6_lstin30d
from ads_kbh_prod_potential_track_new_lst t0
left join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay and t0.DimensionId = t1.DimensionId;

-- 广告N天指标 -- 新链接

insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
adspend_pushin7d,adspend_pushin14d ,adspend_pushin30d ,adspend_pushin60d ,adspend_pushin90d,
spu_exposure_pushin7d, spu_exposure_pushin14d, spu_exposure_pushin30d,
spu_clicks_pushin7d,spu_clicks_pushin14d,spu_clicks_pushin30d,
spu_profit_rate_pushin7d,spu_profit_rate_pushin14d,spu_profit_rate_pushin30d,
spu_clicks_rate_pushin7d,spu_clicks_rate_pushin14d,spu_clicks_rate_pushin30d,
ad_clicks_rate_pushin7d,ad_clicks_rate_pushin14d,ad_clicks_rate_pushin30d,
ad_sale_rate_pushin7d,ad_sale_rate_pushin14d,ad_sale_rate_pushin30d,
ad_cpc_pushin7d,ad_cpc_pushin14d,ad_cpc_pushin30d)

with
prod as ( -- 商品运营组推送  SPUx周次
select distinct  spu ,PushDate
from import_data.dep_kbh_product_level_potentail d
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}' and isStopPush='否' -- 以推送日期计算 表主键周次
)


,ad as (
select prod.spu, waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits ,waad.AdSpend ,waad.AdSales
	, timestampdiff(SECOND,PushDate,waad.GenerateDate)/86400 as ad_days -- 广告
from prod  -- 这里直接广告表 join 推送产品 on sku ,因为是推荐生效日期之后开始算广告7/14天，不是从刊登开始算
join import_data.wt_adserving_amazon_daily waad on prod.spu = left(waad.sku,7)
where SellerSku not regexp 'bJ|Bj|bj|BJ'
and waad.GenerateDate >= '${StartDay}'
)

,ad_stat as (
select '${StartDay}' as FirstDay
	, count( case when ad7_Exposure >= 1 then SPU end ) as ad7_Exposure1_spu_cnt_since_push
    , count( case when ad14_Exposure >= 1 then SPU end ) as ad14_Exposure1_spu_cnt_since_push
    , count( case when ad30_Exposure >= 1 then SPU end ) as ad30_Exposure1_spu_cnt_since_push

	, count( case when ad7_Clicks >= 1 then SPU end ) as ad7_Clicks1_spu_cnt_since_push
    , count( case when ad14_Clicks >= 1 then SPU end ) as ad14_Clicks1_spu_cnt_since_push
    , count( case when ad30_Clicks >= 1 then SPU end ) as ad30_Clicks1_spu_cnt_since_push

    , sum(ad7_Exposure) ad7_Exposure  , sum(ad14_Exposure) ad14_Exposure  , sum(ad30_Exposure) ad30_Exposure
    , sum(ad7_Clicks) ad7_Clicks  , sum(ad14_Clicks) ad14_Clicks  , sum(ad30_Clicks) ad30_Clicks
    , sum(ad7_saleunits) ad7_saleunits  , sum(ad14_saleunits) ad14_saleunits  , sum(ad30_saleunits) ad30_saleunits
    , sum(ad7_spend) ad7_spend  , sum(ad14_spend) ad14_spend  , sum(ad30_spend) ad30_spend , sum(ad60_spend) ad60_spend , sum(ad90_spend) ad90_spend
from
	( select  spu
		-- 曝光量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_Exposure
		-- 点击量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_Clicks
		-- 销量
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_saleunits
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_saleunits
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_saleunits
		-- 花费
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSpend end)) as ad7_spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSpend end)) as ad14_spend
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSpend end)) as ad30_spend
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSpend end)) as ad60_spend
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSpend end)) as ad90_spend
		-- 销售额
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSales end)) as ad7_sales
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSales end)) as ad14_sales
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSales end)) as ad30_sales
		from ad  group by  spu
	) tmp
)

select '快百货' ,year, 0 ,week ,0 ,now() ,'周报'
    ,ad7_spend ,ad14_spend ,ad30_spend ,ad60_spend ,ad90_spend
    ,round( ad7_Exposure/push_spu_cnt ,4) spu_exposure_pushin7d
    ,round( ad14_Exposure/push_spu_cnt ,4) spu_exposure_pushin14d
    ,round( ad30_Exposure/push_spu_cnt ,4) spu_exposure_pushin30d

    ,round( ad7_Clicks/push_spu_cnt ,4) spu_clicks_pushin7d
    ,round( ad14_Clicks/push_spu_cnt ,4) spu_clicks_pushin14d
    ,round( ad30_Clicks/push_spu_cnt ,4) spu_clicks_pushin30d

    ,round( ad7_Exposure1_spu_cnt_since_push/push_spu_cnt ,4) spu_profit_rate_pushin7d -- 建表字段名错误单词用成了_profit_
    ,round( ad14_Exposure1_spu_cnt_since_push/push_spu_cnt ,4) spu_profit_rate_pushin14d
    ,round( ad30_Exposure1_spu_cnt_since_push/push_spu_cnt ,4) spu_profit_rate_pushin30d

    ,round( ad7_Clicks1_spu_cnt_since_push/push_spu_cnt ,4) spu_clicks_rate_pushin7d
    ,round( ad14_Clicks1_spu_cnt_since_push/push_spu_cnt ,4) spu_clicks_rate_pushin14d
    ,round( ad30_Clicks1_spu_cnt_since_push/push_spu_cnt ,4) spu_clicks_rate_pushin30d

    ,round( ad7_Clicks/ad7_Exposure ,4) ad_clicks_rate_pushin7d
    ,round( ad14_Clicks/ad14_Exposure ,4) ad_clicks_rate_pushin14d
    ,round( ad30_Clicks/ad30_Exposure ,4) ad_clicks_rate_pushin30d

    ,round( ad7_saleunits/ad7_Clicks ,4) ad_sale_rate_pushin7d
    ,round( ad14_saleunits/ad14_Clicks ,4) ad_sale_rate_pushin14d
    ,round( ad30_saleunits/ad30_Clicks ,4) ad_sale_rate_pushin30d

    ,round( ad7_spend/ad7_Clicks ,4) ad_cpc_pushin7d
    ,round( ad14_spend/ad14_Clicks ,4) ad_cpc_pushin14d
    ,round( ad30_spend/ad30_Clicks ,4) ad_cpc_pushin30d

from ads_kbh_prod_potential_track_new_lst t0
left join ad_stat t1 on t0.FirstDay = t1.FirstDay;


-- 在线SPU数、总刊登链接数
insert into ads_kbh_prod_potential_track_new_lst (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType
,online_spu_cnt_newlst ,lst_cnt_newlst ,lst_cnt_newlst_mainsite ,online_spu_cnt_achieved_newlst,avg_days_dev2lst)
with
prod as ( -- 商品运营组推送  SPUx周次
select distinct  d.spu ,PushDate
from import_data.dep_kbh_product_level_potentail d
where PushDate >= '${StartDay}' and PushDate < '${NextStartDay}' and isStopPush='否' -- 以推送日期计算 表主键周次
)

,lst as (
select distinct shopcode ,SellerSKU ,wl.spu ,wl.sku  ,Site ,ListingStatus ,wl.isdeleted
    , case when Site regexp  'UK|DE|FR|US|CA' THEN 1 ELSE 0 END as is_main_site  ,MinPublicationDate ,ShopStatus
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '快百货'
join prod on prod.spu = wl.spu and timestampdiff(SECOND,PushDate,MinPublicationDate) >= 0 -- 新链接（推荐生效后刊登）
where SellerSku not regexp 'bJ|Bj|bj|BJ'
)

,res1 as (
select
    count( distinct case when ListingStatus = 1 and ShopStatus ='正常' and isdeleted = 0 then spu end ) as online_spu_cnt_newlst -- 新刊登在线SPU数
    ,count( distinct concat(ShopCode,SellerSKU) ) as lst_cnt_newlst -- 刊登链接数
    ,count( distinct case when is_main_site = 1 then concat(ShopCode,SellerSKU) end ) as lst_cnt_newlst_mainsite -- 刊登链接数_主站点
from lst
)

,res2 as (
select count(spu) as online_spu_cnt_achieved_newlst -- 新刊登在线达标SPU数,达10个
from ( select spu from lst where IsDeleted=0
    group by spu having count( distinct case when ListingStatus = 1  and ShopStatus ='正常' then concat(ShopCode,SellerSKU) end ) >= 10 ) t1
)

,res3 as (  -- 使用sku计算
select round( avg(timestampdiff(SECOND,DevelopLastAuditTime ,MinPublicationDate_by_sku)/86400)  ) as avg_days_dev2lst -- 平均首登天数
from (
select lst.spu , lst.sku ,min(MinPublicationDate) as MinPublicationDate_by_sku ,DevelopLastAuditTime
from lst left join wt_products wp on lst.sku = wp.sku and wp.ProjectTeam='快百货' and wp.IsDeleted=0
where timestampdiff(SECOND,DevelopLastAuditTime ,MinPublicationDate)/86400 >= 0 and lst.IsDeleted = 0
group by lst.spu, lst.sku ,DevelopLastAuditTime
) t1
)

select
    '快百货' ,year('${StartDay}'), 0 ,weekofyear('${StartDay}') + 1 ,0 ,now() ,'周报',  -- todo 不能使用weekofyear,要以 dim_date为准
    online_spu_cnt_newlst, lst_cnt_newlst, lst_cnt_newlst_mainsite, online_spu_cnt_achieved_newlst ,avg_days_dev2lst
from res1,res2,res3;
