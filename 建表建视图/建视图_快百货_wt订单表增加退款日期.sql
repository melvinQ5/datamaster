
-- ��wt_orderdetails���е��˿��¼����Ϊ��ȫ���˿��¼�� ��daily_RefundOrders�������˿�ʱ�䣬������ʵ���˼��в�Ʒ�˿���,���в�Ʒ�˿�ʱ��
create view view_kbh_add_refunddate_to_wtord_tmp as
select a.OrderNumber ,b.max_refunddate
from import_data.wt_orderdetails a
join ( select OrderNumber ,max(RefundDate) max_refunddate from  import_data.daily_RefundOrders where RefundStatus ='���˿�' group by OrderNumber ) b
on a.isdeleted = 0 and a.TransactionType = '�˿�'  and a.ordernumber = b.OrderNumber ;


-- С�������
insert into wt_ag_orderdetails (id, MaxRefundDate)
select a.id ,b.MaxRefundDate
from import_data.wt_ag_orderdetails a
join ( select OrderNumber ,max(RefundDate) MaxRefundDate from  import_data.daily_RefundOrders where RefundStatus ='���˿�' group by OrderNumber ) b
on a.isdeleted = 0 and a.TransactionType = '�˿�'  and a.ordernumber = b.OrderNumber ;


select * from (
select
    wo.id ,cast(date(max_refunddate)as char ) �˿�ʱ��
    ,week_num_in_year �˿���,wo.OrderNumber ���ж�����,PlatOrderNumber ƽ̨������ ,OrderStatus ����״̬,cast(date(ShipTime) as char ) ����ʱ��
    ,BoxSku  ,abs(round( refundamount/ExchangeUSD ,2)) �˿���  ,Product_SPU as spu ,Product_Sku as sku  ,shopcode ���̼���, ms.Site ,SellerSku ����SKU ,asin
    ,cast(date(PayTime) as char ) ����ʱ��
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
join dim_date dd on vr.max_refunddate = dd.full_date
where max_refunddate >='2023-01-01'  and TransactionType = '�˿�' ) t where  1=1  {{template}}


                                                                    cast(CreationTime as char ) CreationTime