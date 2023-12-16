
with prod as (
    select memo as spu ,c2 as 产品状态 ,c3 状态更改原因 ,c4 开发人员 ,c5 部门 ,DevelopLastAuditTime 终审时间
    from manual_table mt
    left join erp_product_products epp on mt.memo =epp.spu and epp.IsMatrix=1 and epp.IsDeleted=0 and ProjectTeam='快百货'
    where handlename = '真真_新产品订单_231124'
)

,od as (
select Product_Spu as spu
	,count( distinct case when month(PayTime) = 8 then PlatOrderNumber end ) 8月订单
	,count( distinct case when month(PayTime) = 9 then PlatOrderNumber end ) 9月订单
	,count( distinct case when month(PayTime) = 10 then PlatOrderNumber end ) 10月订单
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.spu = wo.Product_Spu
join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= '2023-08-01' and PayTime < '2023-11-01'
    and wo.IsDeleted=0
	and ms.Department = '快百货' and TransactionType='付款'
group by Product_Spu )

select prod.* ,ifnull(8月订单,0) 8月订单 ,ifnull(9月订单,0) 9月订单 ,ifnull(10月订单,0) 10月订单
from prod left join od on prod.spu =od.spu