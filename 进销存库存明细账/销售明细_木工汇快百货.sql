
-- MRO ������ϸ
select
 ms.Department ����
,ms.Code  �˺�
,PlatOrderNumber ƽ̨������
,OrderNumber ϵͳ������
,ShipTime ��������ʱ��
,boxsku + 0 as ��ƷSKU
,SaleCount  ��������
,ShipWarehouse �����ֿ�
,year(ShipTime) ���
,month(ShipTime) �·�
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
	 when ShipWarehouse regexp '������' THEN '������'
	 when ShipWarehouse regexp '���' THEN '���'
	 when ShipWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
	 else ShipWarehouse
	 end as �ֿ���
     ,'' ��ע
,GroupSku + 0 ���SKU
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code and ms.Department regexp '��ٻ�' and ShipWarehouse regexp 'FBA' and TransactionType = '����'
-- join mysql_store ms on wo.shopcode = ms.Code and ms.Department regexp '�̳���'
    -- and ShipWarehouse regexp 'FBA'
    and TransactionType = '����'
where wo.IsDeleted =0 and OrderStatus != '����' and  ShipTime >=  '${StartDay}'  and ShipTime < '${NextStartDay}' and ShipmentStatus = 'ȫ������'
order by ms.Department,ShipTime ;
