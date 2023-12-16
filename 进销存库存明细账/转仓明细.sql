

with res as (
-- ת����ϸ
select
    concat(BackupOrderNumber,'_',dh.BoxSku) as ���ⵥ��ϵͳSKU
    ,'${department}'
	,'' ��������
	,date_format(deliveryTme,'%Y/%m/%d') ��������
	,year(deliveryTme) �������
	,month(deliveryTme) �����·�
	,ShipWarehouse ת�ֲֿ�
	,ReceiveWarehouse Ŀ�Ĳֿ�
	,dh.BoxSku + 0
    , case when ReceiveWarehouse regexp 'FBA' THEN 'FBA'
         when ReceiveWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
         when ReceiveWarehouse regexp '������' THEN '������'
         when ReceiveWarehouse regexp '���' THEN '���'
         when ReceiveWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
         else ReceiveWarehouse
         end as Ŀ�Ĳֿ���
	,Quantity
	,'' ת��ʱ��������
	,PurchaseFee �ɹ��ɱ�
	,null ͷ���˷�
    ,null ������;��
    ,null ���ֵ�ǰSKU�ܿ����
	,'' ��;��
	,'' �����
	,'' �������
    ,'' �ڶ��������
	,'' �ڶ����������
	,'' ��ע
    ,'' ���SKU
	,Quantity*PurchaseFee ��Ʒ�ܲɹ��ɱ�
	,null ��Ʒ��ͷ���˷�
	,BackupOrderNumber ���ⵥ��
	,'��˼�Բ�' �û���ʽ
	, case when ms.code is null then '�ڴ��﷢��' else '��˼�Բ�' end as ������ʽ
	, dh.PackageNumber ������
    , dh.FBAID as Shipmentid
	,TransportMode ���䷽ʽ


from import_data.daily_HeadwayDelivery dh
join  ( select distinct BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam regexp '${department}' ) prod on dh.BoxSku  = prod.boxsku
left join mysql_store ms on dh.ShopCode = ms.code and ms.Department regexp '${department}' -- �����õ���ȥɸѡ��ֻ���ò�Ʒ����Ϊ����������˺ŷ���
-- left join (select BoxSku ,projectteam from wt_products ) wp on dh.BoxSku  = wp.BoxSku
where deliveryTme >= '${StartDay}' and  deliveryTme < '${NextStartDay}'
order by deliveryTme
)

select * from res