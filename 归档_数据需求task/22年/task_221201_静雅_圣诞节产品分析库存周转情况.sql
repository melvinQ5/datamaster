/*
ʥ���ڱ�ʶ��sku+����SKU�������������;���������ۣ�����ʽ���������������30���ϼ���������������4��ÿ�ܷÿ�������4��ת���ʣ�������ÿ�ܶ�������
��4��ÿ�����۶�@������(������) 
�鷳���ǰ�����һ�����������ݣ������°�ǰ��������
����ʥ����Ʒ���������ת�������ģ����Ա������Ż��������������׶εĿ�涼������
*/
with
pt as ( 
select BoxSku , LastPurchasePrice
from wt_products wp
where Festival like '%ʥ����%' and IsDeleted = 0 group by BoxSku, LastPurchasePrice
)

, po as ( -- PurchaseOrder �ɹ���
select * 
		, sum(Quantity)over(partition by OrderNumber) as total_qy -- ���ʶ����ɹ�����
		, sum(Price - DiscountedPrice)over(PARTITION BY OrderNumber) AS ord_product_price -- �ɹ�����Ʒ�������˷ѣ�
from import_data.daily_PurchaseOrder 
	where IsComplete = '��' and InstockQuantity = 0 and WarehouseName = '��ݸ��'
)

, po_product as ( -- `��;�ɹ���Ʒ���`
select po.BoxSku, sum(Price - DiscountedPrice) `��;��Ʒ���` , sum(po.Quantity) `��;����`
from po JOIN  pt on po.BoxSku = pt.BoxSKU  group by po.BoxSku 
)

, po_Freight as ( -- `��;�ɹ��˷�`
select tmp.BoxSku , sum(fr) `��;�˷�`
from ( select BoxSku, (Price - DiscountedPrice)/ord_product_price*Freight as fr 
	from po 
	) tmp 
JOIN pt on tmp.BoxSku = pt.BoxSKU 
group by tmp.BoxSku 
)



, local_w as (-- �ڲ�����
SELECT wi.BoxSku , sum(TotalPrice) `�ڲֲ�Ʒ���`, sum(TotalInventory) `�ڲ�sku����`
FROM import_data.daily_WarehouseInventory wi
JOIN pt on wi.BoxSku = pt.BoxSKU 
where CreatedTime = DATE_ADD( CURRENT_DATE(), interval -1 day) and  WarehouseName = '��ݸ��' and TotalInventory > 0 
group by wi.BoxSku 
)


select pt.BoxSku , pt.LastPurchasePrice, `�ڲֲ�Ʒ���`,`�ڲ�sku����`,round((`��;��Ʒ���`+`��;�˷�`),2) as `��;�ʽ�`, `��;����`
, `��;��Ʒ���` ,`��;�˷�`
from pt
left join local_w on pt.BoxSku =local_w.BoxSku
left join po_product on pt.BoxSku = po_product.BoxSku
left join po_Freight on pt.BoxSku = po_Freight.BoxSku

