-- 统计商品端提出改善日期之后，该SPU第一个采购单到仓时间的前后数据对比。
-- 订单范围：已发货订单，按发货时间获取订单，仅计算发货时间内发生的付款、退款

with mt as (
select  memo as spu ,c1 as 退款分析 ,c2 as 是否从采购单计算 ,date(c3) as pre_date
from manual_table mt
where handlename='桐桐_质量改善SPU_231118' )

,purc as ( -- 改善日期之后，该SPU第一个采购单到仓时间
select spu ,OrderNumber as min_ordernumber ,DeliveryTime as min_deliverytime
from (
select t.* ,row_number() over (partition by spu order by DeliveryTime) sort
    from (
    select mt.spu ,dp.OrderNumber ,DeliveryTime
    from daily_PurchaseOrder dp
    join wt_products wp on dp.BoxSku = wp.BoxSku and wp.ProjectTeam='快百货' and wp.IsDeleted=0
    join mt on wp.spu =mt.spu
    where timestampdiff(second ,pre_date,OrderTime) >= 0
    group by mt.spu ,dp.OrderNumber,DeliveryTime
    ) t ) t2
where sort = 1 )

,t0 as ( -- 存在提出改善后无新采购单的SPU
select mt.spu ,退款分析 ,pre_date ,ifnull(min_ordernumber,'提出改善后无新采购单') min_ordernumber ,min_deliverytime
from mt left join purc on mt.spu =purc.spu )

,od_pay_bf as (
select wo.Product_Spu as spu
    ,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join t0 on wo.Product_Spu =t0.spu
where wo.IsDeleted = 0
  and timestampdiff(day ,min_deliverytime,ShipTime) >= -30 and timestampdiff(day ,min_deliverytime,ShipTime) < 0 -- 改善提出前30天
  and ShipTime > '2000-01-01 00:00:00' -- 发货订单
group by wo.Product_Spu
)

,od_refund_bf as ( -- 销售额对应退款额，利润额对应退款额
select  wo.Product_Spu as spu
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join t0 on wo.Product_Spu =t0.spu
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and TransactionType = '退款'
  and timestampdiff(day ,min_deliverytime,ShipTime) >= -30 and timestampdiff(day ,min_deliverytime,ShipTime) < 0 -- 改善提出前30天
and ShipTime > '2000-01-01 00:00:00' -- 发货订单
group by wo.Product_Spu
)

,od_stat_bf as(
select a. spu
     ,sales_undeduct_refunds 改善前30天销售额S2
     ,profit_undeduct_refunds 改善前30天利润额M2
     ,sales_refund 改善前30天退款金额
     ,round( sales_refund / (sales_undeduct_refunds) ,4) 改善前30天退款率
     ,round( profit_undeduct_refunds / sales_undeduct_refunds ,4) 改善前30天利润率R2
from od_pay_bf a left join od_refund_bf b on a.spu =b.spu
)
   
,od_pay_af as (
select wo.Product_Spu as spu
    ,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join t0 on wo.Product_Spu =t0.spu
where wo.IsDeleted = 0
  and timestampdiff(day ,min_deliverytime,ShipTime) >= 0 and timestampdiff(day ,min_deliverytime,ShipTime) < 30 -- 改善提出前30天
  and ShipTime > '2000-01-01 00:00:00' -- 发货订单
group by wo.Product_Spu
)

,od_refund_af as ( -- 销售额对应退款额，利润额对应退款额
select  wo.Product_Spu as spu
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join t0 on wo.Product_Spu =t0.spu
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and TransactionType = '退款'
  and timestampdiff(day ,min_deliverytime,ShipTime) >= 0 and timestampdiff(day ,min_deliverytime,ShipTime) < 30 -- 改善提出前30天
    and ShipTime > '2000-01-01 00:00:00' -- 发货订单
group by wo.Product_Spu
)

,od_stat_af as(
select a. spu
     ,sales_undeduct_refunds 改善后30天销售额S2
     ,profit_undeduct_refunds 改善后30天利润额M2
     ,sales_refund 改善后30天退款金额
     ,round( sales_refund / (sales_refund + sales_undeduct_refunds) ,4) 改善后30天退款率
     ,round( profit_undeduct_refunds / sales_undeduct_refunds ,4) 改善后30天利润率R2
from od_pay_af a left join od_refund_af b on a.spu =b.spu
)



select t0.spu ,退款分析 ,pre_date 提出改善日期 ,min_ordernumber 提出后首笔到仓下单号 ,min_deliverytime 该笔到仓时间
     ,case when timestampdiff(day ,min_deliverytime ,current_date()) >= 30 then '是' else '否' end 改善距今是否满30天
     ,case when timestampdiff(day ,min_deliverytime ,current_date()) >= 30 then round( ifnull(改善前30天退款率,0) - ifnull(改善后30天退款率,0) ,4) end 满30天退款率降幅
     ,case when timestampdiff(day ,min_deliverytime ,current_date()) >= 30 and  ifnull(改善前30天退款率,0) - ifnull(改善后30天退款率,0) >= 0.03 then '是' else '否' end 是否改善成功
     , ifnull(改善前30天退款率,0) 改善前30天退款率
     , ifnull(改善后30天退款率,0) 改善后30天退款率

     , 改善前30天销售额S2
     , 改善前30天利润额M2
     , 改善前30天退款金额
     , 改善前30天利润率R2

     , 改善后30天销售额S2
     , 改善后30天利润额M2
     , 改善后30天退款金额
     , 改善后30天利润率R2

from t0 
left join od_stat_af t1 on t0.spu =t1.spu 
left join od_stat_bf t2 on t0.spu =t2.spu
order by 满30天退款率降幅 desc