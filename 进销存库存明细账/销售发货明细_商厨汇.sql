
with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���'  )

, od as ( -- ���۳���-δ�ϲ�����, ��Ҫͬ��3���µ��������۶�����¼���жϷ���
select DeliverProductSku as  boxsku ,OrderChannelSource ,PlatOrderNumber ,OrderNumber ,ShipTime ,DeliverProductSku ,ProductCount ,ShipWarehouse
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code -- �ų����
join prod on prod.boxsku = ooa.DeliverProductSku
where ShipTime >= '${StartDay}' and  ShipTime < '${NextStartDay}'  and ShipmentStatus = 'ȫ������' and DeliverProductSku not regexp ','
and ReportType = '�ܱ�' and FirstDay = '2023-11-27'


union all
select unnest as boxsku ,OrderChannelSource ,PlatOrderNumber ,OrderNumber ,ShipTime ,DeliverProductSku
, 1 as ProductCount -- �ϲ�������¼��DeliverProductSkuÿ��SKU����1�Σ�����Ϊ1��eg: 114-9940133-1299455
,ShipWarehouse
from (
select split(DeliverProductSku,',') arr ,*
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
join prod on prod.boxsku = ooa.DeliverProductSku
where ShipTime >= '${StartDay}' and  ShipTime < '${NextStartDay}'  and ShipmentStatus = 'ȫ������' and DeliverProductSku regexp ','
and ReportType = '�ܱ�' and FirstDay = '2023-11-27'

) t,unnest(arr)
)

-- select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '�̳���'  and boxsku =4332620

select
'�̳���' ����
,OrderChannelSource �˺�
,PlatOrderNumber ƽ̨������
,OrderNumber ϵͳ������
,ShipTime ��������ʱ��
,boxsku + 0 as ��ƷSKU
,ProductCount ��������
,ShipWarehouse �����ֿ�
,year(ShipTime) ���
,month(ShipTime) �·�
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '�Ȳ�' THEN '�Ȳ�'
	 when ShipWarehouse regexp '������' THEN '������'
	 when ShipWarehouse regexp '���' THEN '���'
	 when ShipWarehouse regexp '�ʲ�С��' THEN '�ʲ�С��'
	 else ShipWarehouse
	 end as �ֿ�
from od
-- where boxsku = 3547351
order by ShipTime ;