select
createdtime ����ʱ��
,WarehouseName �ֿ�
,WarehouseID �ֿ�ID
,BoxSku ��Ʒsku
,CustomSku �Զ���sku
,ProductName ��Ʒ����
,IsPackage �Ƿ����
,AverageUnitPrice ƽ������
,TotalInventory ���������
,TotalPrice ����ܽ��
,InventoryAge45 `0-45�����`
,InventoryAge90 `46-90�����`
,InventoryAge180 `91-180�����`
,InventoryAge270 `181-270�����`
,InventoryAge365 `271-365�����`
,InventoryAgeOver `����365�����`
,InventoryAgeAmount45 `0-45�������`
,InventoryAgeAmount90 `46-90�������`
,InventoryAgeAmount180 `91-180�������`
,InventoryAgeAmount270 `181-270�������`
,InventoryAgeAmount365 `271-365�������`
,InventoryAgeAmountOver `����365�������`
,Trade Ʒ��
,Buyer �ɹ���Ա
from daily_WarehouseInventory where CreatedTime='${lastday}'
