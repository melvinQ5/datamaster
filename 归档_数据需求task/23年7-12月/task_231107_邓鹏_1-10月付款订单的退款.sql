
-- �����š��˿��ͳһ��Ԫ��������ʱ�䡢�����ֿ⡢���š�������Ա�����ҡ�����ʱ�䡢�˿�ԭ���˿����͡�һ��ԭ�򡢶���ԭ�򣩡���������
-- ����ɸѡ������ʱ��1-10�µĶ����� ����1-11�µĶ�Ӧ���˿�

with od_pay as (
select ms.Department ,PlatOrderNumber ,OrderNumber  ,ShipTime ,ShipWarehouse ,wo.Seller ,shopcode ,OrderCountry ,TransportType ,paytime
from wt_orderdetails wo
join mysql_store ms on wo.shopcode =ms.Code and ms.Department regexp '��ٻ�|������'
where PayTime >='2023-01-01' and PayTime < '2023-11-01' and IsDeleted = 0 and TransactionType='����'
group by ms.Department ,PlatOrderNumber ,OrderNumber  ,ShipTime ,ShipWarehouse ,wo.Seller ,shopcode ,OrderCountry ,TransportType ,paytime
)

,od_rf as (
select  p.OrderNumber ,sum( round(RefundAmount/ExchangeUSD) )  RefundAmount_usd
from wt_orderdetails wo
join od_pay p on wo.OrderNumber =p.OrderNumber and wo.IsDeleted = 0 and wo.TransactionType='�˿�'
group by p.OrderNumber
)

,rf as (
select distinct r.OrderNumber ,RefundReason1 ,RefundReason2 ,RefundType ,RefundDate
from daily_RefundOrders r
join od_rf on r.OrderNumber =od_rf.OrderNumber
)

select
PlatOrderNumber ƽ̨������
,od_pay.OrderNumber ���ж�����
,case when ShipTime ='2000-01-01 00:00:00' then 'δ����' else ShipTime end ����ʱ��
,ShipWarehouse �����ֿ�
,seller ������Ա
,Department ����
,TransportType ���䷽ʽ
,OrderCountry ��������
,date(paytime) ����ʱ��
,date(RefundDate) �˿�ʱ��
,RefundAmount_usd �˿���
,rf.RefundReason1 �˿�ԭ��һ��
,rf.RefundReason2 �˿�ԭ�����
,RefundType �˿�����
from od_pay
join od_rf on od_pay.OrderNumber = od_rf.OrderNumber
left join rf on od_pay.OrderNumber = rf.OrderNumber
