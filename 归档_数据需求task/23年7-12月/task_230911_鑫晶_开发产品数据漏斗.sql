with epp as ( -- sku
select SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
from import_data.erp_product_products epp
join dim_date dd on dd.full_date = date(epp.DevelopLastAuditTime)
where CreationTime  >= '2023-01-01'
and IsMatrix = 0 and IsDeleted = 0
and ProjectTeam ='快百货' and Status != 20
group by SKU ,SPU ,  DevelopLastAuditTime ,DevelopUserName ,week_num_in_year ,full_date
)


,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU
	,wo.Product_SKU as SKU
    ,PayTime
    ,left(PayTime,7) pay_month
    ,SellUserName
    ,DevelopUserName,week_num_in_year
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_Sku  = epp.sku
where PayTime >= '2023-01-01'and wo.IsDeleted=0 and ms.Department = '快百货' and OrderStatus != '作废' and TransactionType='付款'  -- S1销售额
)

,t_order_year_stat as (
select SKU
    ,round(sum(TotalGross/ExchangeUSD),2) TotalGross_year
from t_orde
group by SKU
)

,t_orde_monthly_stat as (
select * , ROW_NUMBER() over (PARTITION BY sku order by TotalGross_monthly desc) sales_sort
from (
select SKU,pay_month
    ,round(sum(TotalGross/ExchangeUSD),2) TotalGross_monthly
from t_orde
group by SKU,pay_month
) t1
)

,t_orde_dev_sale_user_stat as ( -- 每周终审的产品在当周的销售额
select SKU,week_num_in_year,SellUserName
    ,row_number() over (partition by SKU,week_num_in_year order by TotalGross desc) sales_sort
    ,sum(TotalGross) over (partition by SKU,week_num_in_year ) TotalGross_per_seller
    ,round (TotalGross / sum(TotalGross) over (partition by SKU,week_num_in_year ) ,4 ) TotalGross_seller_rate
from (
    select  SKU,week_num_in_year,SellUserName
        ,round(sum(TotalGross/ExchangeUSD),2) TotalGross
    from t_orde
    group by SKU,week_num_in_year,SellUserName
    ) t
)

,t_merage as (
select epp.*
    ,t1.SellUserName 年内top1销售员
    ,t1.TotalGross_seller_rate 年内top1业绩占比

    ,t2.SellUserName 年内top2销售员
    ,t2.TotalGross_seller_rate 年内top2业绩占比

    ,t3.SellUserName 年内top3销售员
    ,t3.TotalGross_seller_rate 年内top3业绩占比
    ,tm1.TotalGross_monthly 销售Top1月销售额
    ,tm2.TotalGross_monthly 销售Top2月销售额
    ,TotalGross_year `23年销售额`

from ( select distinct  SKU  from epp ) epp
left join t_orde_dev_sale_user_stat t1 on t1.sales_sort = 1 and epp.SKU =t1.SKU
left join t_orde_dev_sale_user_stat t2 on t2.sales_sort = 2 and epp.SKU =t2.SKU
left join t_orde_dev_sale_user_stat t3 on t3.sales_sort = 3 and epp.SKU =t3.SKU
left join t_orde_monthly_stat tm1 on tm1.sales_sort = 1 and epp.SKU =tm1.SKU
left join t_orde_monthly_stat tm2 on tm2.sales_sort = 2 and epp.SKU =tm2.SKU
left join t_order_year_stat ty1 on  epp.SKU =ty1.SKU
)

select *
from (
select * , ROW_NUMBER() over (order by `23年销售额` desc) sales_sort
from t_merage
) tmp
where sales_sort <= 50
