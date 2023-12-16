select
    ProjectTeam ����
	,PurchaseOrderNo �ɹ�����
	,OrderNumber �µ���
    ,'��˼�Բ�' as ������Դ
    ,PayMethod ���ʽ
	,SupplierName ��Ӧ������
	,dp.BoxSku as ��ƷSKU
	,Quantity ����
	,UnitPrice ����
	, 0 as  ����ͷ��
	,Quantity*UnitPrice ���
	,GenerateTime ����ʱ��
	,OrderTime �µ�ʱ��
	,WarehouseName as ���ֿ�
    ,InstockQuantity �������
    ,InstockTime ���ʱ��
    ,IsComplete �Ƿ����
    ,case when UnitPrice >  100 then '���' else 'С��' end  as �Ƿ��� -- ��9���±���ʼ��С���ɸ��ʽ��Ϊ����
from import_data.daily_PurchaseOrder dp
join ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam regexp '${department}'  ) prod on dp.boxsku = prod.boxsku
WHERE GenerateTime >= '${StartDay}' and  GenerateTime < '${NextStartDay}'
-- and dp.boxsku = 4747583
-- and PurchaseOrderNo in ( ) -- ��ѯ��ʷ�·�δ���״̬
order by ����,GenerateTime


