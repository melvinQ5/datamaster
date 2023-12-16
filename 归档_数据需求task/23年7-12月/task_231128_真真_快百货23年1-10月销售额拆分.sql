
-- 1128版：按快百货现有账号获取订单记录，对这批订单记录中的产品进行划分
with od as (
select
round(TotalGross/ExchangeUSD,2) sales
,case when epp.CreationTime >= '2023-01-01' then '23年添加产品'
    when epp.CreationTime < '2023-01-01' and ProductStatus = 0 then '23年之前添加且当前正常产品'
    when epp.CreationTime < '2023-01-01' and ProductStatus != 0 then '23年之前添加且当前非正常产品' else '23年之前添加且当前非正常产品' end 出单产品拆分
,wo.BoxSku,epp.spu
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code and ms.Department = '快百货'
left join erp_product_products epp on epp.BoxSKU = wo.boxsku and IsMatrix=0  and epp.IsDeleted=0
where
	settlementtime >= '2023-01-01' and settlementtime < '2023-11-01'  and wo.IsDeleted=0
)

select 出单产品拆分 ,round(sum(sales),2) 销售额usd ,count( distinct spu ) 出单spu数
from od
group by 出单产品拆分;

-- 1129版：按快百货现有ERP产品库去获取订单记录，不论这批订单记录中现有店铺归属在哪里
with od as (
select
round(TotalGross/ExchangeUSD,2) sales_usd
,round(TotalGross,2) sales
,case when epp.CreationTime >= '2023-01-01' then '23年添加产品'
    when epp.CreationTime < '2023-01-01' and ProductStatus = 0 then '23年之前添加且当前正常产品'
    when epp.CreationTime < '2023-01-01' and ProductStatus != 0 then '23年之前添加且当前非正常产品' else '23年之前添加且当前非正常产品' end 出单产品拆分
,wo.BoxSku,epp.spu
from import_data.wt_orderdetails wo
join erp_product_products epp on epp.BoxSKU = wo.boxsku and IsMatrix=0  and epp.IsDeleted=0 and epp.projectteam = '快百货' and epp.CreationTime < '2023-11-01'
where
	settlementtime >= '2023-01-01' and settlementtime < '2023-11-01'  and wo.IsDeleted=0
)

,od_stat as (
select 出单产品拆分 ,round(sum(sales_usd),2) 销售额usd ,round(sum(sales),2) 销售额cny  ,count( distinct spu ) 出单spu数
from od
group by 出单产品拆分 )

select * from od_stat