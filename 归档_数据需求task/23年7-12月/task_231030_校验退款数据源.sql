select week_num_in_year �ܴ�  , week_begin_date ����һ  ,date(RefundDate) �˿����� ,OrderSource ���� ,NodePathName ,dep2 ,RefundUSDPrice �˿���_��Ԫ
       ,rf.*
from daily_RefundOrders rf
join ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=rf.OrderSource and ms.department='��ٻ�'
left join dim_date dd on rf.RefundDate =dd.full_date
where  RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='���˿�'
order by RefundDate desc


-- daily�˿�����汾�ܵ��˿�� �Ƿ�����wt�����ҵ�
with rf as (
select distinct PlatOrderNumber
from daily_RefundOrders rf
join ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=rf.OrderSource and ms.department='��ٻ�'
left join dim_date dd on rf.RefundDate =dd.full_date
where  RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='���˿�'
)

select wo.*
from rf
left join wt_orderdetails wo on rf.PlatOrderNumber = wo.PlatOrderNumber and wo.IsDeleted=0 and wo.transactiontype ='�˿�'
join ( select case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=wo.shopcode and ms.department='��ٻ�'
where wo.PlatOrderNumber is null


-- �˿��
select  OrderSource , OrderNumber  from  daily_RefundOrders
group by OrderSource , OrderNumber  having count( distinct RefundDate ) >1

