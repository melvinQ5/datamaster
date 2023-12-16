
with epp as ( -- sku
select SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
from import_data.erp_product_products epp
join dim_date dd on dd.full_date = date(epp.DevelopLastAuditTime) and dd.week_num_in_year in (15,16,17,18,19,20,21,22,23,24,31,32,33,34,35,36,37,38,39) and dd.full_date > '2023_01-01'
where week_num_in_year  >= 15
and IsMatrix = 0 and IsDeleted = 0
and ProjectTeam ='快百货' and Status != 20 and DevelopUserName regexp '陈倩|丁华丽|沈邦华|王婉君|夏菲'
group by SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
)

-- select * from epp
,t_epp_stat as (
select DevelopUserName,week_num_in_year ,count(distinct spu) dev_spu_cnt
from epp group by DevelopUserName,week_num_in_year
)

,t_list as ( -- 刊登时间在2月1日至今
select wl.SPU ,wl.SKU  ,wl.SellerSKU ,wl.ShopCode ,wl.asin
	,DevelopLastAuditTime ,full_date ,epp.DevelopUserName,epp.week_num_in_year
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '快百货'
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
	PayTime >= '2023-04-03' -- 第15周周一
    and wo.IsDeleted=0 and ms.Department = '快百货'
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
	and ms.Department = '快百货'
group by DevelopUserName,week_num_in_year
)

,t_orde_dev_sale_user_stat as ( -- 每周终审的产品在当周的销售额
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
join dep_kbh_product_level dkpl on epp.spu =dkpl.spu and dkpl.prod_level regexp '爆款|旺款' and FirstDay > '2023-01-01'
group by  DevelopUserName,week_num_in_year
)




,t_merage as (
select epp.*
    ,orders_total `累计订单量`
	,TotalGross `累计销售额`
    ,settle_profit_rate 结算利润率
    ,TotalGross_per_orders 客单价
    ,round( adspend /TotalGross ,2 ) 广告花费占比
    ,round( TotalGross /dev_spu_cnt  ,2 ) 终审SPU平均单产
    ,dev_spu_cnt 终审SPU数
    ,top_spu_cnt 终审至今爆旺款SPU数
    ,t1.SellUserName 当周top1销售员
    ,t1.TotalGross_seller_rate 当周top1业绩占比

    ,t2.SellUserName 当周top2销售员
    ,t2.TotalGross_seller_rate 当周top2业绩占比

    ,t3.SellUserName 当周top3销售员
    ,t3.TotalGross_seller_rate 当周top3业绩占比


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

