
-- 以wt_orderdetails表中的退款记录，视为最全的退款记录。 从daily_RefundOrders表中拿退款时间，这样便实现了既有产品退款金额,又有产品退款时间
create view view_kbh_add_refunddate_to_wtord_tmp as
select a.OrderNumber ,b.max_refunddate
from import_data.wt_orderdetails a
join ( select OrderNumber ,max(RefundDate) max_refunddate from  import_data.daily_RefundOrders where RefundStatus ='已退款' group by OrderNumber ) b
on a.isdeleted = 0 and a.TransactionType = '退款'  and a.ordernumber = b.OrderNumber ;


-- 小海豚调度
insert into wt_ag_orderdetails (id, MaxRefundDate)
select a.id ,b.MaxRefundDate
from import_data.wt_ag_orderdetails a
join ( select OrderNumber ,max(RefundDate) MaxRefundDate from  import_data.daily_RefundOrders where RefundStatus ='已退款' group by OrderNumber ) b
on a.isdeleted = 0 and a.TransactionType = '退款'  and a.ordernumber = b.OrderNumber ;


select * from (
select
    wo.id ,cast(date(max_refunddate)as char ) 退款时间
    ,week_num_in_year 退款周,wo.OrderNumber 塞盒订单号,PlatOrderNumber 平台订单号 ,OrderStatus 订单状态,cast(date(ShipTime) as char ) 发货时间
    ,BoxSku  ,abs(round( refundamount/ExchangeUSD ,2)) 退款金额  ,Product_SPU as spu ,Product_Sku as sku  ,shopcode 店铺简码, ms.Site ,SellerSku 渠道SKU ,asin
    ,cast(date(PayTime) as char ) 付款时间
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
join dim_date dd on vr.max_refunddate = dd.full_date
where max_refunddate >='2023-01-01'  and TransactionType = '退款' ) t where  1=1  {{template}}


                                                                    cast(CreationTime as char ) CreationTime