
with epp as ( -- sku
select SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
from import_data.erp_product_products epp
join dim_date dd on dd.full_date = date(epp.DevelopLastAuditTime) and dd.week_num_in_year in (15,16,17,18,19,20,21,22,23,24,31,32,33,34,35,36,37,38,39) and dd.full_date > '2023_01-01'
where week_num_in_year  >= 15
and IsMatrix = 0 and IsDeleted = 0
and ProjectTeam ='��ٻ�' and Status != 20 and DevelopUserName regexp '��ٻ|������|��|�����|�ķ�'
group by SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
)

-- select * from epp
,t_epp_stat as (
select DevelopUserName,week_num_in_year ,count(distinct spu) dev_spu_cnt
from epp group by DevelopUserName,week_num_in_year
)

,t_list as ( -- ����ʱ����2��1������
select wl.SPU ,wl.SKU  ,wl.SellerSKU ,wl.ShopCode ,wl.asin
	,DevelopLastAuditTime ,full_date ,epp.DevelopUserName,epp.week_num_in_year
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�'
join epp on wl.sku = epp.sku and wl.IsDeleted = 0
)
-- select * from t_list

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU ,PayTime
    ,SellUserName
    ,DevelopUserName,week_num_in_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_Sku  = epp.sku
where
	PayTime >= '2023-04-03' -- ��15����һ
    and wo.IsDeleted=0 and ms.Department = '��ٻ�'
)

,t_orde_stat as (
select DevelopUserName,week_num_in_year
    ,round(sum(TotalGross/ExchangeUSD),2) TotalGross
    ,count( distinct PlatOrderNumber) orders_total
    ,round( sum(TotalGross/ExchangeUSD) /count( distinct PlatOrderNumber),2) TotalGross_per_orders
from t_orde
group by DevelopUserName,week_num_in_year
)


,t_orde_settle_stat as (
select  DevelopUserName ,week_num_in_year ,round( sum(TotalProfit) / sum(TotalGross),4 ) settle_profit_rate
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_Sku  = epp.sku
where
	SettlementTime>= '2023-04-03' and wo.IsDeleted=0
	and ms.Department = '��ٻ�'
group by DevelopUserName,week_num_in_year
)

,t_orde_dev_sale_user_stat as ( -- ÿ������Ĳ�Ʒ�ڵ��ܵ����۶�
select DevelopUserName,week_num_in_year,SellUserName
    ,row_number() over (partition by DevelopUserName,week_num_in_year order by TotalGross desc) sales_sort
    ,sum(TotalGross) over (partition by DevelopUserName,week_num_in_year ) TotalGross_per_seller
    ,round (TotalGross / sum(TotalGross) over (partition by DevelopUserName,week_num_in_year ) ,4 ) TotalGross_seller_rate
from (
    select  DevelopUserName,week_num_in_year,SellUserName
        ,round(sum(TotalGross/ExchangeUSD),2) TotalGross
    from t_orde
    group by DevelopUserName,week_num_in_year,SellUserName
    ) t
)



,t_ad_stat  as (
select DevelopUserName,week_num_in_year
	, round( sum( adspend ) ,2 )  adspend
from t_list
join import_data.wt_adserving_amazon_daily asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU
-- 	and t_list.spu= 5202143
where asa.GenerateDate >= '2023-04-03'
group by DevelopUserName,week_num_in_year
)

,t_top_stat as (
select DevelopUserName,week_num_in_year,count( distinct epp.spu ) as top_spu_cnt
from (select DevelopUserName ,spu ,min(week_num_in_year) week_num_in_year from  epp group by DevelopUserName ,spu ) epp
join dep_kbh_product_level dkpl on epp.spu =dkpl.spu and dkpl.prod_level regexp '����|����' and FirstDay > '2023-01-01'
group by  DevelopUserName,week_num_in_year
)




,t_merage as (
select epp.*
    ,orders_total `�ۼƶ�����`
	,TotalGross `�ۼ����۶�`
    ,settle_profit_rate ����������
    ,TotalGross_per_orders �͵���
    ,round( adspend /TotalGross ,2 ) ��滨��ռ��
    ,round( TotalGross /dev_spu_cnt  ,2 ) ����SPUƽ������
    ,dev_spu_cnt ����SPU��
    ,top_spu_cnt ������������SPU��
    ,t1.SellUserName ����top1����Ա
    ,t1.TotalGross_seller_rate ����top1ҵ��ռ��

    ,t2.SellUserName ����top2����Ա
    ,t2.TotalGross_seller_rate ����top2ҵ��ռ��

    ,t3.SellUserName ����top3����Ա
    ,t3.TotalGross_seller_rate ����top3ҵ��ռ��


from ( select distinct  week_num_in_year ,DevelopUserName  from epp ) epp
left join t_epp_stat on epp.DevelopUserName =t_epp_stat.DevelopUserName and epp.week_num_in_year =t_epp_stat.week_num_in_year
left join t_orde_stat on epp.DevelopUserName =t_orde_stat.DevelopUserName and epp.week_num_in_year =t_orde_stat.week_num_in_year
left join t_orde_settle_stat on epp.DevelopUserName =t_orde_settle_stat.DevelopUserName and epp.week_num_in_year =t_orde_settle_stat.week_num_in_year
left join t_ad_stat on epp.DevelopUserName =t_ad_stat.DevelopUserName and epp.week_num_in_year =t_ad_stat.week_num_in_year
left join t_top_stat on epp.DevelopUserName =t_top_stat.DevelopUserName and epp.week_num_in_year =t_top_stat.week_num_in_year
left join t_orde_dev_sale_user_stat t1 on t1.sales_sort = 1 and epp.DevelopUserName =t1.DevelopUserName and epp.week_num_in_year =t1.week_num_in_year
left join t_orde_dev_sale_user_stat t2 on t2.sales_sort = 2 and epp.DevelopUserName =t2.DevelopUserName and epp.week_num_in_year =t2.week_num_in_year
left join t_orde_dev_sale_user_stat t3 on t3.sales_sort = 3 and epp.DevelopUserName =t3.DevelopUserName and epp.week_num_in_year =t3.week_num_in_year
)


select *
from t_merage
order by  week_num_in_year ,DevelopUserName

