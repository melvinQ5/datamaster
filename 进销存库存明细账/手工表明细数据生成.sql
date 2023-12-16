
-- FBA���ͳ��
select wp.ProjectTeam 
,dfb.boxsku ,Shopcode  ,Warehouse  ,Asin ,CustomSku 
,CurrentInventory ,LocalInventory
,OnlineStatus ,ActivityStatus  ,Sales  ,OnlineDate ,ProductChineseName 
,PurchasePrice ,Transporting , InventoryAmount ,InventoryAge 
, dfb.CurrentInventory  ��ǰ���
from daily_FBAInventory_Box dfb
left join wt_products wp on dfb.BoxSku  =wp.BoxSku 
where GenerateDate = '${NextStartDay}'

  -- and  dfb.BoxSku = 4474967


-- �ɹ���ϸ
select 
	'��˼�Բ�' as ������Դ
	,PurchaseOrderNo �ɹ�����
	,OrderNumber �µ���
	,SupplierName ��Ӧ������
	,dp.BoxSku 
	,Quantity ����
	,UnitPrice ����
	, 0 as  ����ͷ��
	,Quantity*UnitPrice ���
	,GenerateTime ����ʱ��
	,OrderTime �µ�ʱ��
	,WarehouseName as ���ֿ� 
	,case when InstockTime > '2023-07-01' then 0 else InstockQuantity end as �������
	,case when InstockTime > '2023-07-01' then null else  InstockTime end  as ���ʱ��
	,case when InstockTime > '2023-07-01' then '��' else IsComplete end as �Ƿ����
from import_data.daily_PurchaseOrder dp 
-- join ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���' ) prod on dp.boxsku = prod.boxsku 
join ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = 'MRO������' ) prod on dp.boxsku = prod.boxsku 
WHERE GenerateTime >= '2023-06-01' and  GenerateTime < '2023-07-01' 
-- and dp.boxsku = 4474967 
-- and PurchaseOrderNo =20002491085;


-- 
select dp.BoxSku , '�ɹ����' event_type ,OrderNumber event_id ,'�ɹ��µ���' event_id_type 
	, GenerateTime  ,'����ʱ��' as start_time_type
	, InstockTime  ,'���ʱ��' as end_time_type
	, '��Ӧ��' as from_place 
	, SupplierName  as from_place_detail   
	,WarehouseName as reach_place 
	,WarehouseName as reach_place_detail
    ,Quantity as start_quantity -- �µ�����
    ,InstockQuantity as end_quantity -- �������
    , '' as memo 
from import_data.daily_PurchaseOrder dp join prod on dp.boxsku = prod.boxsku WHERE OrderTime >= '2023-01-01' 


-- �̳��� ������ϸ 
with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���' )

, od as ( -- ���۳���-δ�ϲ�����, ��Ҫͬ��3���µ��������۶�����¼���жϷ���
select DeliverProductSku as  boxsku ,OrderChannelSource ,PlatOrderNumber ,ShipTime ,DeliverProductSku ,ProductCount ,ShipWarehouse
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
join prod on prod.boxsku = ooa.DeliverProductSku 
where ShipTime >= '2023-06-01' and  ShipTime < '2023-07-02' and ShipmentStatus = 'ȫ������' and DeliverProductSku not regexp ','
-- where ShipTime >= '2023-05-01' and  ShipTime < '2023-06-01' and ShipmentStatus = 'ȫ������' and DeliverProductSku not regexp ','
and ReportType = '�ܱ�' and FirstDay = '2023-07-10'  
-- and ReportType = '�±�' and FirstDay = '2023-06-01'
union all
select unnest as boxsku ,OrderChannelSource ,PlatOrderNumber ,ShipTime ,DeliverProductSku 
, 1 as ProductCount -- �ϲ�������¼��DeliverProductSkuÿ��SKU����1�Σ�����Ϊ1��eg: 114-9940133-1299455
,ShipWarehouse
from (
select split(DeliverProductSku,',') arr ,*
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
join prod on prod.boxsku = ooa.DeliverProductSku 
where ShipTime >= '2023-07-01' and  ShipTime < '2023-07-02' and ShipmentStatus = 'ȫ������' and DeliverProductSku regexp ','
-- where ShipTime >= '2023-06-01' and  ShipTime < '2023-06-01' and ShipmentStatus = 'ȫ������' and DeliverProductSku regexp ','
and ReportType = '�ܱ�' and FirstDay = '2023-07-10'  
-- and ReportType = '�±�' and FirstDay = '2023-06-01'  
) t,unnest(arr) 
)

-- select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���'  and boxsku =4332620


select OrderChannelSource �˺�
,PlatOrderNumber ƽ̨������
,ShipTime ��������ʱ��
,boxsku 
,ProductCount ��������
,ShipWarehouse �����ֿ�
,date(ShipTime) ʱ��
,left(ShipTime,7) �·�
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
	 when ShipWarehouse regexp '������' THEN '������'
	 when ShipWarehouse regexp '���' THEN '���'
	 when ShipWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
	 else ShipWarehouse
	 end as �����ֿ�2
from od 
-- where boxsku = 3547351
order by ShipTime ; 


-- MRO ������ϸ
select 
 ms.Department
,ms.Code  �˺�
,PlatOrderNumber ƽ̨������
,ShipTime ��������ʱ��
,boxsku 
,SaleCount  ��������
,ShipWarehouse �����ֿ�
,date(ShipTime) ʱ��
,left(ShipTime,7) �·�
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
	 when ShipWarehouse regexp '������' THEN '������'
	 when ShipWarehouse regexp '���' THEN '���'
	 when ShipWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
	 else ShipWarehouse
	 end as �����ֿ�2
from wt_orderdetails wo 
join mysql_store ms on wo.shopcode = ms.Code and ms.Department = 'MRO������' and ShipWarehouse regexp 'FBA' and TransactionType = '����'
-- join mysql_store ms on wo.shopcode = ms.Code and ms.Department = '��ٻ�' and ShipWarehouse regexp 'FBA' and TransactionType = '����'
where wo.IsDeleted =0 and OrderStatus != '����' and  ShipTime >= '2023-07-01' and  ShipTime < '2023-07-10' and ShipmentStatus = 'ȫ������' 
and BoxSku =4474979
order by ShipTime ; 



-- ת����ϸ
select 
	'' ��������
	,deliveryTme ��������
	,ShipWarehouse ת�ֲֿ�
	,ReceiveWarehouse Ŀ�Ĳֿ�
	,'' ���ⵥ�Ų�ƷSKU
	,dh.BoxSku
	,dh.BoxSku ������Ʒ����
	,Quantity
	,'' ת��ʱ��������
	,PurchaseFee �ɹ��ɱ�
	,Freight ͷ���˷�
	,��;��
	,������
	,�������
	,'' ռλ������
	,'' ռλ�������
	,Quantity*PurchaseFee ��Ʒ�ܲɹ��ɱ�
	,Quantity*Freight ��Ʒ��ͷ���˷�
	,'' ���ⵥ��
	,'��˼�Բ�' �û���ʽ
	, case when prod.projectteam = '�̳���' and ms.Department != '�̳���' then '�ڴ��﷢��' else '��˼�Բ�' end as ������ʽ
	, '' ��ע
	, dh.PackageNumber ������
	,TransportMode ���䷽ʽ
from import_data.daily_HeadwayDelivery dh
join  ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���' ) prod on dh.BoxSku  = prod.boxsku 
-- join  ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '��ٻ�' ) prod on dh.BoxSku  = prod.boxsku 
-- join  ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = 'MRO������' ) prod on dh.BoxSku  = prod.boxsku 
left join ( select c5 as PackageNumber , c7 as boxsku
	,c1 as ��;�� , c2 as ������ , c3 as �������
	from manual_table mt where handlename ='ȫ���̿��_��;��ѯ0704v1' ) mt 
	on dh.BoxSku  = mt.boxsku and dh.PackageNumber = mt.PackageNumber -- ͷ����;�˹�����
left join (select BoxSku ,projectteam from wt_products ) wp on dh.BoxSku  = wp.BoxSku  
left join wt_store ms on dh.ShopCode = ms.code  
where deliveryTme >= '2023-01-01' and  deliveryTme < '2023-07-01' 
	and dh.BoxSku =4624640
-- 	and dh.PackageNumber = 'D38292089' 
-- where deliveryTme >= '2023-07-01'
order by deliveryTme 