-- 视图
select count(distinct vr.OrderNumber),sum(RefundAmount)
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款';

-- 增加字段
select count(distinct OrderNumber),sum(RefundAmount)
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
where wo.IsDeleted = 0 and MaxRefundDate >='${StartDay}' and MaxRefundDate<'${NextStartDay}'  and TransactionType = '退款'