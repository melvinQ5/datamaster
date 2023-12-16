-- �����߼������뵥�ܡ����µĲ�Ʒ�嵥������������������д��洢��

-- ����SPU��
insert into ads_kbh_prod_new_dev_track (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType ,FirstDay ,dev_spu_cnt)
select ifnull(concat('��ٻ�x',istheme),'��ٻ�') ,year, 0 ,dd.week_num_in_year ,0 ,now() ,'�ܱ�',dd.week_begin_date
    ,count(distinct epp.spu)
from import_data.erp_product_products epp
join dim_date dd on date(DevelopLastAuditTime) =dd.full_date
left join dep_kbh_product_test dk on epp.sku = dk.sku
where DevelopLastAuditTime >= '2023-01-01' and IsDeleted=0 and ProjectTeam = '��ٻ�' and IsMatrix =0
group by grouping sets (
    (dd.year ,dd.week_num_in_year ,dd.week_begin_date) ,
    (dd.year ,dd.week_num_in_year ,dd.week_begin_date ,istheme)
    );


-- ����N�춯����  -- �׵�N��ָ�� -- ����N�챬��
insert into ads_kbh_prod_new_dev_track ( DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_devin7d, sale_rate_over1_devin14d, sale_rate_over1_devin30d, sale_rate_over1_devin90d,
sale_rate_over3_devin14d, sale_rate_over3_devin30d, sale_rate_over6_devin14d, sale_rate_over6_devin30d
,sale_amount_devin7d ,sale_amount_devin14d ,sale_amount_devin30d ,sale_amount_devin60d ,sale_amount_devin90d
,profit_rate_devin7d, profit_rate_devin14d, profit_rate_devin30d, profit_rate_devin60d, profit_rate_devin90d
,sale_amount_odin30d ,sale_unitamount_odin30d
,spu_tophot_devin30d , sale_rate_devin30d,sale_amount_tophot_devin30d
)
with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select  spu ,sku ,DevelopLastAuditTime
from import_data.erp_product_products
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsMatrix=0 and ProjectTeam='��ٻ�' and IsDeleted=0
)

,od as (
select
    timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days_since_dev -- ���ڼ�������N�죨�Ա�ǩ��Ч���ڼ��� ����ָ�꣩
    ,timestampdiff(SECOND,(min(PayTime) over(partition by prod.spu)),PayTime)/86400 as ord_days_since_od -- ���ڼ����׵�30�죨��������״γ�����ʼ���㣬ÿ�ʶ�����ʱ��
    -- ,min(PayTime) over(partition by prod.spu) as min_pay_time
    ,DevelopLastAuditTime ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( (TotalGross-FeeGross) /ExchangeUSD ,4) as TotalGross_unfreight_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�' and wo.IsDeleted=0 and wo.TransactionType ='����'
join prod on prod.sku = wo.Product_Sku
join dim_date dd on date(wo.PayTime) =dd.full_date
where timestampdiff(SECOND,DevelopLastAuditTime,PayTime) >= 0 -- ��������
)
-- select * from od

,od_spu_stat_weekly as ( -- ������
select '${StartDay}' as FirstDay
     ,count( case when ord7_orders_since_dev >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_dev
     ,count( case when ord14_orders_since_dev >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_dev
     ,count( case when ord30_orders_since_dev >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_dev
     -- ,count( case when ord60_orders_since_dev >= 1 then SPU end ) as ord60_sale1_spu_cnt_since_dev
     ,count( case when ord90_orders_since_dev >= 1 then SPU end ) as ord90_sale1_spu_cnt_since_dev

     ,count( case when ord14_orders_since_dev >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_dev
     ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_dev

     ,count( case when ord14_orders_since_dev >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_dev
     ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_dev
from
    ( select spu
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 7 then PlatOrderNumber end) as ord7_orders_since_dev
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 14 then PlatOrderNumber end) as ord14_orders_since_dev
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
        -- , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 60 then PlatOrderNumber end) as ord60_orders_since_dev
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 90 then PlatOrderNumber end) as ord90_orders_since_dev
    from od group by spu
    ) ta
)

,od_amount_stat_weekly as ( -- ���۶�
select '${StartDay}' as FirstDay
    ,sale_amount_devin7d ,sale_amount_devin14d ,sale_amount_devin30d ,sale_amount_devin60d ,sale_amount_devin90d ,sale_amount_odin30d
    ,round( ord7_profit_since_dev/sale_amount_devin7d ,4) profit_rate_devin7d
    ,round( ord14_profit_since_dev/sale_amount_devin14d ,4) profit_rate_devin14d
    ,round( ord30_profit_since_dev/sale_amount_devin30d ,4) profit_rate_devin30d
    ,round( ord60_profit_since_dev/sale_amount_devin60d ,4) profit_rate_devin60d
    ,round( ord90_profit_since_dev/sale_amount_devin90d ,4) profit_rate_devin90d

    ,round( sale_amount_odin30d/od_spu_cnt_odin30d ,4) sale_unitamount_odin30d -- �׵�30�쵥��
from (
    select
         round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 7 then TotalGross_usd end) ,2) as sale_amount_devin7d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 14 then TotalGross_usd end) ,2) as sale_amount_devin14d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then TotalGross_usd end) ,2) as sale_amount_devin30d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 60 then TotalGross_usd end) ,2) as sale_amount_devin60d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 90 then TotalGross_usd end) ,2) as sale_amount_devin90d

        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 7 then TotalProfit_usd end) ,2) as ord7_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 14 then TotalProfit_usd end) ,2) as ord14_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then TotalProfit_usd end) ,2) as ord30_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 60 then TotalProfit_usd end) ,2) as ord60_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 90 then TotalProfit_usd end) ,2) as ord90_profit_since_dev

        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as sale_amount_odin30d
        , count( distinct case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then spu end)  as od_spu_cnt_odin30d

    from od
    ) a
)

,od_tophot_stat_weekly as ( -- ������
select '${StartDay}' as FirstDay
     ,count( case when ord30_sales_unfreight_since_dev >= 500 then SPU end ) as spu_tophot_devin30d_newlst -- ����30�챬������
     ,sum( case when ord30_sales_unfreight_since_dev >= 500 then ord30_sales_since_dev end ) as sale_amount_tophot_devin30d_newlst -- ����30�챬���������۶�
from
    ( select spu
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_unfreight_usd end) ,2) as ord30_sales_unfreight_since_dev
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as ord30_sales_since_dev
    from od group by spu
    ) ta
)

select '��ٻ�' ,year, 0 ,week ,0 ,now() ,'�ܱ�'
    ,round( ord7_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin7d
    ,round( ord14_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin14d
    ,round( ord30_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin30d
    -- ,round( ord60_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin60d
    ,round( ord90_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin90d

    ,round( ord14_sale3_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over3_devin14d
    ,round( ord30_sale3_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over3_devin30d

    ,round( ord14_sale6_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over6_devin14d
    ,round( ord30_sale6_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over6_devin30d
    ,t2.sale_amount_devin7d ,t2.sale_amount_devin14d ,t2.sale_amount_devin30d ,t2.sale_amount_devin60d ,t2.sale_amount_devin90d
    ,t2.profit_rate_devin7d,t2. profit_rate_devin14d,t2. profit_rate_devin30d,t2. profit_rate_devin60d,t2. profit_rate_devin90d

    ,t2.sale_amount_odin30d ,t2.sale_unitamount_odin30d

    ,t3.spu_tophot_devin30d_newlst ,round( t3.spu_tophot_devin30d_newlst/dev_spu_cnt ,4) sale_rate_devin30d_newlst
    ,t3.sale_amount_tophot_devin30d_newlst
from ads_kbh_prod_new_dev_track t0
left join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay
left join od_amount_stat_weekly t2 on t0.FirstDay = t2.FirstDay
left join od_tophot_stat_weekly t3 on t0.FirstDay = t3.FirstDay
where  t0.FirstDay >= '${StartDay}' and t0.FirstDay < '${NextStartDay}'  and t0.DimensionId = '��ٻ�';


-- [����ά��]  ����N�춯����  -- �׵�N��ָ�� -- ����N�챬��
insert into ads_kbh_prod_new_dev_track ( DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_devin7d, sale_rate_over1_devin14d, sale_rate_over1_devin30d, sale_rate_over1_devin90d,
sale_rate_over3_devin14d, sale_rate_over3_devin30d, sale_rate_over6_devin14d, sale_rate_over6_devin30d
,sale_amount_devin7d ,sale_amount_devin14d ,sale_amount_devin30d ,sale_amount_devin60d ,sale_amount_devin90d
,profit_rate_devin7d, profit_rate_devin14d, profit_rate_devin30d, profit_rate_devin60d, profit_rate_devin90d
,sale_amount_odin30d ,sale_unitamount_odin30d
,spu_tophot_devin30d , sale_rate_devin30d,sale_amount_tophot_devin30d
)
with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select  epp.spu ,epp.sku ,DevelopLastAuditTime ,istheme
from import_data.erp_product_products epp
left join dep_kbh_product_test dk on epp.sku = dk.sku
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsMatrix=0 and ProjectTeam='��ٻ�' and IsDeleted=0
)

,od as (
select
    timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days_since_dev -- ���ڼ�������N�죨�Ա�ǩ��Ч���ڼ��� ����ָ�꣩
    ,timestampdiff(SECOND,(min(PayTime) over(partition by prod.spu)),PayTime)/86400 as ord_days_since_od -- ���ڼ����׵�30�죨��������״γ�����ʼ���㣬ÿ�ʶ�����ʱ��
    -- ,min(PayTime) over(partition by prod.spu) as min_pay_time
    ,DevelopLastAuditTime ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( (TotalGross-FeeGross) /ExchangeUSD ,4) as TotalGross_unfreight_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year
    ,istheme
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�' and wo.IsDeleted=0 and wo.TransactionType ='����'
join prod on prod.sku = wo.Product_Sku
join dim_date dd on date(wo.PayTime) =dd.full_date
where timestampdiff(SECOND,DevelopLastAuditTime,PayTime) >= 0 -- ��������
)
-- select * from od

,od_spu_stat_weekly as ( -- ������
select '${StartDay}' as FirstDay ,istheme
     ,count( case when ord7_orders_since_dev >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_dev
     ,count( case when ord14_orders_since_dev >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_dev
     ,count( case when ord30_orders_since_dev >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_dev
     -- ,count( case when ord60_orders_since_dev >= 1 then SPU end ) as ord60_sale1_spu_cnt_since_dev
     ,count( case when ord90_orders_since_dev >= 1 then SPU end ) as ord90_sale1_spu_cnt_since_dev

     ,count( case when ord14_orders_since_dev >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_dev
     ,count( case when ord30_orders_since_dev >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_dev

     ,count( case when ord14_orders_since_dev >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_dev
     ,count( case when ord30_orders_since_dev >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_dev
from
    ( select spu ,istheme
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 7 then PlatOrderNumber end) as ord7_orders_since_dev
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 14 then PlatOrderNumber end) as ord14_orders_since_dev
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then PlatOrderNumber end) as ord30_orders_since_dev
        -- , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 60 then PlatOrderNumber end) as ord60_orders_since_dev
        , count(distinct case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 90 then PlatOrderNumber end) as ord90_orders_since_dev
    from od group by spu ,istheme
    ) ta
group by istheme
)

,od_amount_stat_weekly as ( -- ���۶�
select '${StartDay}' as FirstDay , istheme
    ,sale_amount_devin7d ,sale_amount_devin14d ,sale_amount_devin30d ,sale_amount_devin60d ,sale_amount_devin90d ,sale_amount_odin30d
    ,round( ord7_profit_since_dev/sale_amount_devin7d ,4) profit_rate_devin7d
    ,round( ord14_profit_since_dev/sale_amount_devin14d ,4) profit_rate_devin14d
    ,round( ord30_profit_since_dev/sale_amount_devin30d ,4) profit_rate_devin30d
    ,round( ord60_profit_since_dev/sale_amount_devin60d ,4) profit_rate_devin60d
    ,round( ord90_profit_since_dev/sale_amount_devin90d ,4) profit_rate_devin90d

    ,round( sale_amount_odin30d/od_spu_cnt_odin30d ,4) sale_unitamount_odin30d -- �׵�30�쵥��
from (
    select istheme
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 7 then TotalGross_usd end) ,2) as sale_amount_devin7d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 14 then TotalGross_usd end) ,2) as sale_amount_devin14d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then TotalGross_usd end) ,2) as sale_amount_devin30d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 60 then TotalGross_usd end) ,2) as sale_amount_devin60d
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 90 then TotalGross_usd end) ,2) as sale_amount_devin90d

        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 7 then TotalProfit_usd end) ,2) as ord7_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 14 then TotalProfit_usd end) ,2) as ord14_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 30 then TotalProfit_usd end) ,2) as ord30_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 60 then TotalProfit_usd end) ,2) as ord60_profit_since_dev
        , round( sum( case when 0 <= ord_days_since_dev and ord_days_since_dev  <= 90 then TotalProfit_usd end) ,2) as ord90_profit_since_dev

        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as sale_amount_odin30d
        , count( distinct case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then spu end)  as od_spu_cnt_odin30d

    from od group by istheme
    ) a
)

,od_tophot_stat_weekly as ( -- ������
select '${StartDay}' as FirstDay  ,istheme
     ,count( case when ord30_sales_unfreight_since_dev >= 500 then SPU end ) as spu_tophot_devin30d_newlst -- ����30�챬������
     ,sum( case when ord30_sales_unfreight_since_dev >= 500 then ord30_sales_since_dev end ) as sale_amount_tophot_devin30d_newlst -- ����30�챬���������۶�
from
    ( select spu  ,istheme
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_unfreight_usd end) ,2) as ord30_sales_unfreight_since_dev
        , round( sum( case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then TotalGross_usd end) ,2) as ord30_sales_since_dev
    from od group by spu ,istheme
    ) ta
group by  istheme
)

select concat('��ٻ�x',t1.istheme) ,year, 0 ,week ,0 ,now() ,'�ܱ�'
    ,round( ord7_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin7d
    ,round( ord14_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin14d
    ,round( ord30_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin30d
    -- ,round( ord60_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin60d
    ,round( ord90_sale1_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over1_devin90d

    ,round( ord14_sale3_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over3_devin14d
    ,round( ord30_sale3_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over3_devin30d

    ,round( ord14_sale6_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over6_devin14d
    ,round( ord30_sale6_spu_cnt_since_dev/dev_spu_cnt ,4) sale_rate_over6_devin30d
    ,t2.sale_amount_devin7d ,t2.sale_amount_devin14d ,t2.sale_amount_devin30d ,t2.sale_amount_devin60d ,t2.sale_amount_devin90d
    ,t2.profit_rate_devin7d,t2. profit_rate_devin14d,t2. profit_rate_devin30d,t2. profit_rate_devin60d,t2. profit_rate_devin90d

    ,t2.sale_amount_odin30d ,t2.sale_unitamount_odin30d

    ,t3.spu_tophot_devin30d_newlst ,round( t3.spu_tophot_devin30d_newlst/dev_spu_cnt ,4) sale_rate_devin30d_newlst
    ,t3.sale_amount_tophot_devin30d_newlst
from ads_kbh_prod_new_dev_track t0
left join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay and t0.DimensionId = concat('��ٻ�x',t1.istheme)
left join od_amount_stat_weekly t2 on t0.FirstDay = t2.FirstDay and t0.DimensionId = concat('��ٻ�x',t2.istheme)
left join od_tophot_stat_weekly t3 on t0.FirstDay = t3.FirstDay and t0.DimensionId = concat('��ٻ�x',t3.istheme)
where  t0.FirstDay >= '${StartDay}' and t0.FirstDay < '${NextStartDay}' and concat('��ٻ�x',t1.istheme) is not null  ;


-- ����N�춯���� -- ������
insert into ads_kbh_prod_new_dev_track ( DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_lstin7d, sale_rate_over1_lstin14d, sale_rate_over1_lstin30d,
sale_rate_over3_lstin14d, sale_rate_over3_lstin30d, sale_rate_over6_lstin14d, sale_rate_over6_lstin30d
)
with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select  spu ,sku ,DevelopLastAuditTime
from import_data.erp_product_products
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsMatrix=0 and ProjectTeam='��ٻ�' and IsDeleted=0
)

,lst as (
select  shopcode ,SellerSKU  ,MinPublicationDate
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '��ٻ�'
join prod on prod.sku = wl.sku and timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate) >= 0
group by shopcode, SellerSKU ,MinPublicationDate
)

,od as (
select
    timestampdiff(SECOND,MinPublicationDate,PayTime)/86400 as ord_days_since_lst -- �Ա�ǩ��Ч���ڼ��� ����ָ��
    ,MinPublicationDate ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�'
join lst on lst.SellerSKU = wo.SellerSku and lst.ShopCode = wo.shopcode  -- ɸѡ����
join dim_date dd on date(wo.PayTime) =dd.full_date
where wo.IsDeleted=0 and wo.TransactionType ='����' and  timestampdiff(SECOND,MinPublicationDate,PayTime) >= 0 -- ������Ч���¿��ǳ���
)
-- select * from od

,od_spu_stat_weekly as ( -- ������
select '${StartDay}' as FirstDay
     ,count( case when ord7_orders_since_lst >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_lst
     ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_lst

     ,count( case when ord14_orders_since_lst >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_lst

     ,count( case when ord14_orders_since_lst >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_lst
from
    ( select spu
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 7 then PlatOrderNumber end) as ord7_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
    from od group by spu
    ) ta
)

select '��ٻ�' ,year, 0 ,week ,0 ,now() ,'�ܱ�'
    ,round( ord7_sale1_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over1_lstin7d
    ,round( ord14_sale1_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over1_lstin14d
    ,round( ord30_sale1_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over1_lstin30d

    ,round( ord14_sale3_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over3_lstin14d
    ,round( ord30_sale3_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over3_lstin30d

    ,round( ord14_sale6_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over6_lstin14d
    ,round( ord30_sale6_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over6_lstin30d
from ads_kbh_prod_new_dev_track t0
left join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay
where  t0.FirstDay >= '${StartDay}' and t0.FirstDay < '${NextStartDay}' and t0.DimensionId='��ٻ�';



-- [����ά��] ����N�춯���� -- ������
insert into ads_kbh_prod_new_dev_track ( DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
sale_rate_over1_lstin7d, sale_rate_over1_lstin14d, sale_rate_over1_lstin30d,
sale_rate_over3_lstin14d, sale_rate_over3_lstin30d, sale_rate_over6_lstin14d, sale_rate_over6_lstin30d
)
with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select  epp.spu ,epp.sku ,DevelopLastAuditTime ,istheme
from import_data.erp_product_products epp
left join dep_kbh_product_test dk on epp.sku = dk.sku
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsMatrix=0 and ProjectTeam='��ٻ�' and IsDeleted=0
)

,lst as (
select  shopcode ,SellerSKU  ,MinPublicationDate ,istheme
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '��ٻ�'
join prod on prod.sku = wl.sku and timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate) >= 0
group by shopcode, SellerSKU ,MinPublicationDate ,istheme
)

,od as (
select
    timestampdiff(SECOND,MinPublicationDate,PayTime)/86400 as ord_days_since_lst -- �Ա�ǩ��Ч���ڼ��� ����ָ��
    ,MinPublicationDate ,PayTime
    ,PlatOrderNumber ,wo.Product_SPU as SPU
    ,round( TotalGross/ExchangeUSD ,4) as TotalGross_usd
    ,round( TotalProfit/ExchangeUSD ,4) as TotalProfit_usd
    ,week_num_in_year as pay_week  ,dd.year as pay_year
    ,istheme
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '��ٻ�'
join lst on lst.SellerSKU = wo.SellerSku and lst.ShopCode = wo.shopcode  -- ɸѡ����
join dim_date dd on date(wo.PayTime) =dd.full_date
where wo.IsDeleted=0 and wo.TransactionType ='����' and  timestampdiff(SECOND,MinPublicationDate,PayTime) >= 0 -- ������Ч���¿��ǳ���
)
-- select * from od

,od_spu_stat_weekly as ( -- ������
select '${StartDay}' as FirstDay ,istheme
     ,count( case when ord7_orders_since_lst >= 1 then SPU end ) as ord7_sale1_spu_cnt_since_lst
     ,count( case when ord14_orders_since_lst >= 1 then SPU end ) as ord14_sale1_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 1 then SPU end ) as ord30_sale1_spu_cnt_since_lst

     ,count( case when ord14_orders_since_lst >= 3 then SPU end ) as ord14_sale3_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 3 then SPU end ) as ord30_sale3_spu_cnt_since_lst

     ,count( case when ord14_orders_since_lst >= 6 then SPU end ) as ord14_sale6_spu_cnt_since_lst
     ,count( case when ord30_orders_since_lst >= 6 then SPU end ) as ord30_sale6_spu_cnt_since_lst
from
    ( select spu ,istheme
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 7 then PlatOrderNumber end) as ord7_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 14 then PlatOrderNumber end) as ord14_orders_since_lst
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
    from od group by spu ,istheme
    ) ta
group by istheme
)

select concat('��ٻ�x',istheme) ,year, 0 ,week ,0 ,now() ,'�ܱ�'
    ,round( ord7_sale1_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over1_lstin7d
    ,round( ord14_sale1_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over1_lstin14d
    ,round( ord30_sale1_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over1_lstin30d

    ,round( ord14_sale3_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over3_lstin14d
    ,round( ord30_sale3_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over3_lstin30d

    ,round( ord14_sale6_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over6_lstin14d
    ,round( ord30_sale6_spu_cnt_since_lst/dev_spu_cnt ,4) sale_rate_over6_lstin30d
from ads_kbh_prod_new_dev_track t0
join od_spu_stat_weekly t1 on t0.FirstDay = t1.FirstDay and t0.DimensionId = concat('��ٻ�x',t1.istheme)
where  t0.FirstDay >= '${StartDay}' and t0.FirstDay < '${NextStartDay}' ;


-- ���N��ָ��
insert into ads_kbh_prod_new_dev_track (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,
adspend_devin7d,adspend_devin14d ,adspend_devin30d ,adspend_devin60d ,adspend_devin90d,
spu_exposure_devin7d, spu_exposure_devin14d, spu_exposure_devin30d,
spu_clicks_devin7d,spu_clicks_devin14d,spu_clicks_devin30d,
spu_exposure_rate_devin7d,spu_exposure_rate_devin14d,spu_exposure_rate_devin30d,
spu_clicks_rate_devin7d,spu_clicks_rate_devin14d,spu_clicks_rate_devin30d,
ad_clicks_rate_devin7d,ad_clicks_rate_devin14d,ad_clicks_rate_devin30d,
ad_sale_rate_devin7d,ad_sale_rate_devin14d,ad_sale_rate_devin30d,
ad_cpc_devin7d,ad_cpc_devin14d,ad_cpc_devin30d)

with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select  spu ,sku ,DevelopLastAuditTime
from import_data.erp_product_products
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}' and IsMatrix=0 and ProjectTeam='��ٻ�' and IsDeleted=0
)

,ad as (
select prod.spu, waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits ,waad.AdSpend ,waad.AdSales
	, timestampdiff(SECOND,DevelopLastAuditTime,waad.GenerateDate)/86400 as ad_days -- ���
from prod
join import_data.wt_adserving_amazon_daily waad on waad.sku = prod.sku
and waad.GenerateDate >= '${StartDay}'
)

,ad_stat as (
select '${StartDay}' as FirstDay
	, count( case when ad7_Exposure >= 100 then SPU end ) as ad7_Exposure1_spu_cnt_since_dev
    , count( case when ad14_Exposure >= 100 then SPU end ) as ad14_Exposure1_spu_cnt_since_dev
    , count( case when ad30_Exposure >= 100 then SPU end ) as ad30_Exposure1_spu_cnt_since_dev

	, count( case when ad7_Clicks >= 1 then SPU end ) as ad7_Clicks1_spu_cnt_since_dev
    , count( case when ad14_Clicks >= 1 then SPU end ) as ad14_Clicks1_spu_cnt_since_dev
    , count( case when ad30_Clicks >= 1 then SPU end ) as ad30_Clicks1_spu_cnt_since_dev

    , sum(ad7_Exposure) ad7_Exposure  , sum(ad14_Exposure) ad14_Exposure  , sum(ad30_Exposure) ad30_Exposure
    , sum(ad7_Clicks) ad7_Clicks  , sum(ad14_Clicks) ad14_Clicks  , sum(ad30_Clicks) ad30_Clicks
    , sum(ad7_saleunits) ad7_saleunits  , sum(ad14_saleunits) ad14_saleunits  , sum(ad30_saleunits) ad30_saleunits
    , sum(ad7_spend) ad7_spend  , sum(ad14_spend) ad14_spend  , sum(ad30_spend) ad30_spend , sum(ad60_spend) ad60_spend , sum(ad90_spend) ad90_spend
from
	( select  spu
		-- �ع���
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_Exposure
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_Clicks
		-- ����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_saleunits
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_saleunits
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_saleunits
		-- ����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSpend end)) as ad7_spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSpend end)) as ad14_spend
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSpend end)) as ad30_spend
		, round(sum(case when 0 < ad_days and ad_days <= 60 then AdSpend end)) as ad60_spend
		, round(sum(case when 0 < ad_days and ad_days <= 90 then AdSpend end)) as ad90_spend
		-- ���۶�
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSales end)) as ad7_sales
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSales end)) as ad14_sales
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSales end)) as ad30_sales
		from ad  group by  spu
	) tmp
)

select '��ٻ�' ,year, 0 ,week ,0 ,now() ,'�ܱ�'
    ,ad7_spend ,ad14_spend ,ad30_spend ,ad60_spend ,ad90_spend
    ,round( ad7_Exposure/dev_spu_cnt ,4) spu_exposure_devin7d
    ,round( ad14_Exposure/dev_spu_cnt ,4) spu_exposure_devin14d
    ,round( ad30_Exposure/dev_spu_cnt ,4) spu_exposure_devin30d

    ,round( ad7_Clicks/dev_spu_cnt ,4) spu_clicks_devin7d
    ,round( ad14_Clicks/dev_spu_cnt ,4) spu_clicks_devin14d
    ,round( ad30_Clicks/dev_spu_cnt ,4) spu_clicks_devin30d

    ,round( ad7_Exposure1_spu_cnt_since_dev/dev_spu_cnt ,4) spu_exposure_rate_devin7d
    ,round( ad14_Exposure1_spu_cnt_since_dev/dev_spu_cnt ,4) spu_exposure_rate_devin14d
    ,round( ad30_Exposure1_spu_cnt_since_dev/dev_spu_cnt ,4) spu_exposure_rate_devin30d

    ,round( ad7_Clicks1_spu_cnt_since_dev/dev_spu_cnt ,4) spu_clicks_rate_devin7d
    ,round( ad14_Clicks1_spu_cnt_since_dev/dev_spu_cnt ,4) spu_clicks_rate_devin14d
    ,round( ad30_Clicks1_spu_cnt_since_dev/dev_spu_cnt ,4) spu_clicks_rate_devin30d

    ,round( ad7_Clicks/ad7_Exposure ,4) ad_clicks_rate_devin7d
    ,round( ad14_Clicks/ad14_Exposure ,4) ad_clicks_rate_devin14d
    ,round( ad30_Clicks/ad30_Exposure ,4) ad_clicks_rate_devin30d

    ,round( ad7_saleunits/ad7_Clicks ,4) ad_sale_rate_devin7d
    ,round( ad14_saleunits/ad14_Clicks ,4) ad_sale_rate_devin14d
    ,round( ad30_saleunits/ad30_Clicks ,4) ad_sale_rate_devin30d

    ,round( ad7_spend/ad7_Clicks ,4) ad_cpc_devin7d
    ,round( ad14_spend/ad14_Clicks ,4) ad_cpc_devin14d
    ,round( ad30_spend/ad30_Clicks ,4) ad_cpc_devin30d

from ads_kbh_prod_new_dev_track t0
left join ad_stat t1 on t0.FirstDay = t1.FirstDay
where t0.FirstDay >= '2023-07-03' and t0.DimensionId='��ٻ�';  -- �ռ������������ֻ��6��20�յģ�ͳһ��7�µ�һ�ܿ�ʼ����



-- ����SPU�����ܿ���������
insert into ads_kbh_prod_new_dev_track (DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType
,online_spu_cnt ,lst_cnt  ,online_spu_cnt_achieved,avg_days_dev2lst)
with
prod as ( -- ��Ʒ��Ӫ������  SPUx�ܴ�
select  spu ,DevelopLastAuditTime
from import_data.erp_product_products
where DevelopLastAuditTime >= '${StartDay}' and DevelopLastAuditTime < '${NextStartDay}'  and IsMatrix=1 and ProjectTeam='��ٻ�' and IsDeleted=0
)

,lst as (
select distinct shopcode ,SellerSKU ,wl.spu ,wl.sku  ,Site ,ListingStatus ,wl.isdeleted
     ,MinPublicationDate ,ShopStatus ,companycode ,DevelopLastAuditTime
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and ms.Department = '��ٻ�'
join prod on prod.spu = wl.spu and timestampdiff(SECOND,DevelopLastAuditTime,MinPublicationDate) >= 0 -- �����ӣ�������Ч�󿯵ǣ�

)

,res1 as (
select
    count( distinct case when ListingStatus = 1 and ShopStatus ='����' and isdeleted = 0 then spu end ) as online_spu_cnt -- �¿�������SPU��
    ,count( distinct concat(ShopCode,SellerSKU) ) as lst_cnt -- ����������
from lst
)

,res2 as (
select count(spu) as online_spu_cnt_achieved -- 231027�涨��: ����SPU����4���˺���20����������
from ( select spu from lst where IsDeleted=0
    group by spu
    having count( distinct case when ListingStatus = 1  and ShopStatus ='����' then concat(ShopCode,SellerSKU) end ) >= 20
        and count( distinct case when ListingStatus = 1  and ShopStatus ='����' then companycode end ) >= 4
    ) t1
)

,res3 as (  -- ʹ��sku����
select round( avg(timestampdiff(SECOND,DevelopLastAuditTime ,MinPublicationDate_by_sku)/86400) ,2 ) as avg_days_dev2lst -- ƽ���׵�����
from (
select lst.spu , lst.sku ,min(MinPublicationDate) as MinPublicationDate_by_sku ,DevelopLastAuditTime
from lst
where timestampdiff(SECOND,DevelopLastAuditTime ,MinPublicationDate)/86400 >= 0 and lst.IsDeleted = 0
group by lst.spu, lst.sku ,DevelopLastAuditTime
) t1
)

select
    '��ٻ�' ,year, 0 ,week_num_in_year ,0 ,now() ,'�ܱ�',
    online_spu_cnt, lst_cnt, online_spu_cnt_achieved ,avg_days_dev2lst
from res1,res2,res3,dim_date
where dim_date.full_date='${StartDay}' ;




