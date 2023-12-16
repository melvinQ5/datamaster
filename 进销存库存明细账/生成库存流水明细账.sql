
select *
from dep_purchase_sales_inventory_log
where start_time >= '2023-06-01' and end_time <= '2023-07-01'

-- ��ձ�
TRUNCATE table  dep_purchase_sales_inventory_log

-- ���ɵ�������¼
insert into  dep_purchase_sales_inventory_log ( id ,boxsku ,isdeleted ,purchase_source ,department ,event_type 
,start_time_type ,start_time ,reach_place ,start_quantity ,end_quantity  ,memo ,wttime )
select  concat('NS',2000000+ROW_NUMBER() over(order by c11)) as id
	,c1 as boxsku ,c2 as isdeleted ,c3 as purchase_source  , c5 as department  , c6 as event_type ,c10 as start_time_type 
	,c11 as start_time  ,c17 as reach_place ,c14 as start_quantity ,c19 as end_quantity ,c20 as memo ,now()
from manual_table mt where handlename = 'ȫ���̿��_�˹�У�Ե�' and handletime = '2023-07-06';

-- ����ϵͳ��¼ 
insert into  dep_purchase_sales_inventory_log ( id ,boxsku ,isdeleted ,purchase_source ,department ,event_type ,event_id_type ,event_id,line
,start_time_type ,start_time ,from_place ,from_place_detail ,start_quantity 
,end_time_type ,end_time ,reach_place ,reach_place_detail ,end_quantity ,memo ,wttime )

with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���' )

, od_1 as ( -- ���۳���-δ�ϲ�����, ��Ҫͬ��3���µ��������۶�����¼���жϷ���
select 
	ooa.DeliverProductSku as boxsku 
	,'���۳���' event_type ,PlatOrderNumber event_id ,'ƽ̨������' event_id_type
	, ShipTime as start_time ,'����ʱ��' as start_time_type
	, '-' as end_time ,'��Ͷʱ��' as end_time_type
     , case when ShipWarehouse regexp 'FBA' THEN 'FBA'
         when ShipWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
         when ShipWarehouse regexp '������' THEN '������'
         when ShipWarehouse regexp '���' THEN '���'
         when ShipWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
         else ShipWarehouse
         end as from_place
     , ShipWarehouse from_place_detail
     , '�ͻ�' as reach_place 
     , '�ͻ�' as reach_place_detail     
     , ProductCount as start_quantity -- ��������
     , '-' as end_quantity -- ��Ͷ���� 
     , '' as memo 
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
where ShipTime >= '2023-01-01'  and ShipmentStatus = 'ȫ������' and DeliverProductSku not regexp ','
and ReportType = '�±�' and FirstDay = '2023-06-01'
)
-- select * from od; 


,od_2 as ( -- ���۳���-�ϲ�����
select unnest as boxsku 
	,'���۳���' event_type ,PlatOrderNumber event_id ,'ƽ̨������' event_id_type
	, ShipTime as start_time ,'����ʱ��' as start_time_type
	, '-' as end_time ,'��Ͷʱ��' as end_time_type
     , case when ShipWarehouse regexp 'FBA' THEN 'FBA'
         when ShipWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
         when ShipWarehouse regexp '������' THEN '������'
         when ShipWarehouse regexp '���' THEN '���'
         when ShipWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
         else ShipWarehouse
         end as from_place
     , ShipWarehouse from_place_detail
     , '�ͻ�' as reach_place 
     , '�ͻ�' as reach_place_detail     
     , 1 as start_quantity -- �ϲ�������¼��DeliverProductSkuÿ��SKU����1�Σ�����Ϊ1��eg: 114-9940133-1299455
     , '-' as end_quantity -- ��Ͷ����
     , '' as memo 
from (
select split(DeliverProductSku,',') arr ,*
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
where ShipTime >= '2023-01-01'  and ShipmentStatus = 'ȫ������' and DeliverProductSku regexp ','
and ReportType = '�±�' and FirstDay = '2023-06-01'  
) t,unnest(arr) 
)


, purc as ( -- �ɹ����
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
)


, HeadwayDelivery as ( -- ���ⶩ������Դ: -- ͷ���˷ѱ�
select 
	dh.BoxSku
	,'ͷ�̷���' event_type
	,dh.PackageNumber as event_id
	,'������' event_id_type
	,deliveryTme
	,'����ʱ��' as start_time_type
	,'-' as ReceiveTime
	,'����ʱ��' as end_time_type 
    ,ShipWarehouse as from_place 
    ,ShipWarehouse as from_place_detail 
    ,case when ReceiveWarehouse regexp 'FBA' THEN 'FBA'
         when ReceiveWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
         when ReceiveWarehouse regexp '������' THEN '������'
         when ReceiveWarehouse regexp '���' THEN '���'
         when ReceiveWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
         else ReceiveWarehouse
         end as reach_place
	, ReceiveWarehouse as reach_place_detail 
	, ifnull(Quantity,0) as start_quantity -- ��������
	, Quantity - ifnull(��;��,0) as end_quantity -- ��������
	, case when ms.Department then concat('�ڴ��﷢��,SKU����Ϊ��',prod.projectteam, ',��������Ϊ��',dh.ShopCode) end  as memo 
--        PurchaseFee as �ɹ��ɱ�,
--        Freight     as ͷ���˷�
from import_data.daily_HeadwayDelivery dh
left join prod on dh.BoxSku  = prod.boxsku 
left join ( select c5 as PackageNumber , c7 as boxsku
	,c1 as ��;�� , c2 as ������ , c3 as �������
	from manual_table mt where handlename ='ȫ���̿��_��;��ѯ0704v1' ) mt 
	on dh.BoxSku  = mt.boxsku and dh.PackageNumber = mt.PackageNumber -- ͷ����;�˹�����
left join (select BoxSku ,projectteam from wt_products ) wp on dh.BoxSku  = wp.BoxSku  
left join wt_store ms on dh.ShopCode = ms.code  
where deliveryTme >= '2023-01-01'
)
-- select * from HeadwayDelivery   

, inventory_log as (
select boxsku 
	,event_type ,event_id_type ,event_id  
	,concat( from_place_detail ,' ���� ',reach_place_detail) line
	,start_time_type ,start_time  ,from_place ,from_place_detail ,start_quantity -- �������
	,end_time_type ,end_time  ,reach_place  ,reach_place_detail ,end_quantity -- �ִ���� 
	,memo 
from (
	select * from od_1 
	union all select * from od_2 
	union all select * from purc
	union all select * from HeadwayDelivery
	)  t 
order by boxsku asc , start_time 
)

select concat('NS',1000000+ROW_NUMBER() over(order by start_time)) as id 
	,boxsku 
	,0 as isdeleted 
	,'��˼�Բ�' as purchase_source 
	,'�̳���' department ,event_type ,event_id_type ,event_id,line
	,start_time_type ,start_time ,from_place ,from_place_detail ,start_quantity 
	,end_time_type ,end_time ,reach_place ,reach_place_detail ,end_quantity ,memo , now() wttime 
from inventory_log ;
-- where memo regexp '�ڴ�'