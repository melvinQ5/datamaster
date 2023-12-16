-- ����1 5��δ����������SQL��

-- Ŀǰ���⣺
-- Q1 mysql_store ���ֵ���û��������Ա.����PS-CA����SQL��������Ա����������ҳ��������� TMH����1�� ������
-- A1 ���Ҳ��޸�mysql_store������Դ���⣬�����޸�SQL

-- ���¼�� 56011 ��23/02/11 10:00��ѯ��
select count(1) from import_data.daily_WeightOrders dwo 

-- ɸѡ������֧��ʱ����5����ǰ(2023�꿪ʼͳ�ƣ������ް������ţ���SKU�޲ɹ��µ���¼

-- ����
select dod.*, dpo.BoxSku as NoBoxSku,dpo.BoxSku as NoPurchaseBoxSku,wi.TotalInventory 
from ( 
	select BoxSku ,SUBSTR(shopcode,instr(shopcode,'-')+1) as ShopIrobotId ,ordernumber ,paytime 
		,NodePathNameFull as SellerDepartment,SellUserName
	from import_data.daily_WeightOrders dwo 
	join import_data.mysql_store ms on dwo.SUBSTR(shopcode,instr(shopcode,'-')+1) = ms.code
	where CreateDate = CURRENT_DATE()
		and PayTime >= '2023-01-01' and PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 
	) dod 
left join( select BoxSku,TotalInventory from import_data.daily_WarehouseInventory where CreatedTime='2023-02-07' ) wi 
	on dod.BoxSku=wi.BoxSku 
left join( select BoxSku  from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '��' and InstockQuantity = 0  group by BoxSku ) dpo  
	on dod.BoxSku = dpo.BoxSku 
) 
select memo
from daily_WeightOrders dwo2 
group by memo

-- У��1 ͳ�ƶ�����
select count(1) from (

select dod.*
	, dpo.BoxSku as NoBoxSku,dpo.BoxSku as NoPurchaseBoxSku,wi.TotalInventory 
from ( 
	select BoxSku ,SUBSTR(shopcode,instr(shopcode,'-')+1) as ShopIrobotId ,ordernumber ,paytime 
		,NodePathNameFull as SellerDepartment,SellUserName
	from import_data.daily_WeightOrders dwo 
	join import_data.mysql_store ms on dwo.SUBSTR(shopcode,instr(shopcode,'-')+1) = ms.code
	where CreateDate = CURRENT_DATE()
		and PayTime >= '2023-01-01' and  PayTime <  date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 
	) dod 
left join( select BoxSku,TotalInventory from import_data.daily_WarehouseInventory where CreatedTime='2023-02-07' ) wi 
	on dod.BoxSku=wi.BoxSku 
left join( select BoxSku  from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '��' and InstockQuantity = 0  group by BoxSku ) dpo  
	on dod.BoxSku = dpo.BoxSku 
	
) tmp 

select OrderStatus ,count(distinct OrderNumber) ,count(1)
from import_data.daily_WeightOrders dwo 
	join import_data.mysql_store ms on dwo.SUBSTR(shopcode,instr(shopcode,'-')+1) = ms.code
	where CreateDate = CURRENT_DATE()
		and PayTime >= '2023-01-01' and  PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and length(PackageNumber)=0 
group by OrderStatus


-- У������2 �ų����϶�����ͨ��ƥ��5��ǰ�������϶�������⣩
select a.* from a
join (select ordernumber ,boxsku from import_data.ods_orderdetails d
		where PayTime >= '2023-01-01'     
		and PayTime < date_add(CURRENT_DATE(),interval -5 day ) 
		and OrderStatus = '����' and IsDeleted=0  ) passorder
	on a.ordernumber = passorder.ordernumber 
	and a.boxsku=passorder.boxsku
	
-- У������3 �ϲ�����
-- select * from a where  OrderNumber = 20230102181841565070
-- select * from a where  OrderNumber = 20230102181841565072
-- select * from a where  OrderNumber = 20230102050041561552
-- select * from a where  OrderNumber = 20230101011941552754
	



-- ��ʷ����
-- ����ǰ 5��δ��
with a as (
select dod.*,od.id as DeleteId, dpo.BoxSku as NoBoxSku,dpo.BoxSku as NoPurchaseBoxSku,wi.TotalInventory 
from (   select id ,BoxSku,ShopIrobotId,OrderNumber ,NodePathNameFull as SellerDepartment,SellUserName ,PayTime   
	from import_data.daily_OrderDetails_Test d 
	join import_data.mysql_store ws on d.ShopIrobotId = ws.Code    
	where TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0     
	and PayTime >= '2023-01-01'     
	and PayTime < date_add(CURRENT_DATE(),interval -5 day ) and ShipmentStatus = 'δ����'    
	) dod 
left join import_data.daily_OrderDelete od on dod.id =od.id  
left join( select BoxSku,TotalInventory from import_data.daily_WarehouseInventory where  CreatedTime='2023-02-06' ) wi 
	on dod.BoxSku=wi.BoxSku 
left join( select BoxSku  from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '��' group by BoxSku ) dpo  
	on dod.BoxSku = dpo.BoxSku and dod.PayTime>='2023-01-01' where od.id is null 
) 

select count(distinct ordernumber) from a


-- -------------------------------------------------------------------
-- -- ����2 �ɹ���׷��
-- ��ͼ1 �ɹ����µ���2�����ջ���¼  ads_purchase_tracking_list
--   ɸѡ���µ�ʱ����2023��1�£����״̬Ϊδ���ģ��������գ������ݸ���ΪT-1�����ջ�����Ϣ�ļ�¼
--   �ֶΣ��µ��� | ��ݵ��� | �ɹ���Ա | �ɹ�ʱ�� | BoxSku | ����ͻ�����֧��ʱ��
select a.* ,b.min_paytime
from (
  select dpo.OrderNumber as purc_OrderNumber ,OrderPerson as purc_OrderPerson 
    ,dpo.ordertime as purc_OrderTime ,dpo.PurchaseOrderNo ,dpo.Quantity
    ,BoxSku ,dpo.DeliveryNumber
  from import_data.daily_PurchaseOrder dpo 
  left join import_data.daily_PurchaseRev dpr on dpo.OrderNumber = dpr.OrderNumber 
  where dpr.OrderNumber is null and OrderTime >= '2023-01-01' and IsComplete = '��' 
    and OrderTime < date_add(CURRENT_DATE(),interval -2 day )
  ) a 
left join (
  select BoxSku , min(PayTime) as min_paytime 
  from import_data.ods_OrderDetails dod 
  join import_data.daily_WeightOrders dwo 
 	on dod.OrderNumber =dwo.OrderNumber and dod.BoxSku =dwo.BoxSku 
 	and dwo.IsDeleted=0 and TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0   
  group by BoxSku
  ) b 
on a.BoxSku = b.BoxSku
	
