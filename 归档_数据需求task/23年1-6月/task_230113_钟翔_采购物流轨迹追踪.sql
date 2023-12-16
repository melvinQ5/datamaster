
select  count(1) from (
-- 5��ǰδ���� �ް����� 
) tmp 


-- ��һ������  �ͻ�������5��δ������SKU�޲ɹ��µ���¼
-- 	ɸѡ������֧��ʱ����5����ǰ(2023�꿪ʼͳ�ƣ����ҿͻ�����δ�������Ҷ�ӦSKU�޲ɹ���;��¼
daily_orderdetails_final
select dod.*
from (
	select id ,BoxSku ,OrderNumber ,NodePathNameFull ,SellUserName ,PayTime
	from import_data.daily_OrderDetails_Test d
	join import_data.mysql_store ws on d.ShopIrobotId = ws.Code 
	where TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0 
		and PayTime >= '2023-01-01'
		and PayTime < date_add(CURRENT_DATE(),interval -5 day ) and ShipmentStatus = 'δ����' 
	) dod
left join import_data.daily_OrderDelete od on dod.id =od.id 
left join 
	(
	select BoxSku 
	from import_data.daily_PurchaseOrder dpo 
	where OrderTime >= '2023-01-01' and IsComplete = '��' group by BoxSku
	) dpo 
on dod.BoxSku = dpo.BoxSku 
where od.id is null  and  dpo.BoxSku is null 







-- �ɹ����µ���2�����ջ���¼
-- 	ɸѡ���µ�ʱ����2023��1�£����״̬Ϊδ���ģ�������ǰ���ջ�����Ϣ�ļ�¼
-- 	�ֶΣ��µ��� | ��ݵ��� | �ɹ���Ա | �ɹ�ʱ�� | BoxSku | ����ͻ�����֧��ʱ��  

	
CREATE VIEW `ads_purchase_tracking_list` as 
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
	from import_data.daily_OrderDetails dod 
	where TransactionType = '����' and OrderStatus <> '����' and OrderTotalPrice > 0   
		and ShipTime = '2000-01-01 00:00:00' 
	group by BoxSku
	) b 
on a.BoxSku = b.BoxSku
