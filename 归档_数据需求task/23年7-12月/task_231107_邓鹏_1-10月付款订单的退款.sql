
-- 订单号、退款金额（统一美元）、发货时间、发货仓库、部门、销售人员、国家、订单时间、退款原因（退款类型、一级原因、二级原因）、物流渠道
-- 订单筛选：付款时间1-10月的订单号 ，在1-11月的对应的退款

with od_pay as (
select ms.Department ,PlatOrderNumber ,OrderNumber  ,ShipTime ,ShipWarehouse ,wo.Seller ,shopcode ,OrderCountry ,TransportType ,paytime
from wt_orderdetails wo
join mysql_store ms on wo.shopcode =ms.Code and ms.Department regexp '快百货|特卖汇'
where PayTime >='2023-01-01' and PayTime < '2023-11-01' and IsDeleted = 0 and TransactionType='付款'
group by ms.Department ,PlatOrderNumber ,OrderNumber  ,ShipTime ,ShipWarehouse ,wo.Seller ,shopcode ,OrderCountry ,TransportType ,paytime
)

,od_rf as (
select  p.OrderNumber ,sum( round(RefundAmount/ExchangeUSD) )  RefundAmount_usd
from wt_orderdetails wo
join od_pay p on wo.OrderNumber =p.OrderNumber and wo.IsDeleted = 0 and wo.TransactionType='退款'
group by p.OrderNumber
)

,rf as (
select distinct r.OrderNumber ,RefundReason1 ,RefundReason2 ,RefundType ,RefundDate
from daily_RefundOrders r
join od_rf on r.OrderNumber =od_rf.OrderNumber
)

select
PlatOrderNumber 平台订单号
,od_pay.OrderNumber 塞盒订单号
,case when ShipTime ='2000-01-01 00:00:00' then '未发货' else ShipTime end 发货时间
,ShipWarehouse 发货仓库
,seller 销售人员
,Department 部门
,TransportType 运输方式
,OrderCountry 订单国家
,date(paytime) 付款时间
,date(RefundDate) 退款时间
,RefundAmount_usd 退款金额
,rf.RefundReason1 退款原因一级
,rf.RefundReason2 退款原因二级
,RefundType 退款类型
from od_pay
join od_rf on od_pay.OrderNumber = od_rf.OrderNumber
left join rf on od_pay.OrderNumber = rf.OrderNumber
