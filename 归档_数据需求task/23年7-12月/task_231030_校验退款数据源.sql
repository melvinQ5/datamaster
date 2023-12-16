select week_num_in_year 周次  , week_begin_date 当周一  ,date(RefundDate) 退款日期 ,OrderSource 店铺 ,NodePathName ,dep2 ,RefundUSDPrice 退款金额_美元
       ,rf.*
from daily_RefundOrders rf
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=rf.OrderSource and ms.department='快百货'
left join dim_date dd on rf.RefundDate =dd.full_date
where  RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='已退款'
order by RefundDate desc


-- daily退款表里面本周的退款订单 是否都能在wt表中找到
with rf as (
select distinct PlatOrderNumber
from daily_RefundOrders rf
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=rf.OrderSource and ms.department='快百货'
left join dim_date dd on rf.RefundDate =dd.full_date
where  RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='已退款'
)

select wo.*
from rf
left join wt_orderdetails wo on rf.PlatOrderNumber = wo.PlatOrderNumber and wo.IsDeleted=0 and wo.transactiontype ='退款'
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=wo.shopcode and ms.department='快百货'
where wo.PlatOrderNumber is null


-- 退款订单
select  OrderSource , OrderNumber  from  daily_RefundOrders
group by OrderSource , OrderNumber  having count( distinct RefundDate ) >1

