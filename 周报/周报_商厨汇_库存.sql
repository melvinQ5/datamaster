-- �̳���
/*
Ŀ�꣺����ȫ���̿���ʽ�ռ��
����ʽ�ռ�� = 
	FBA�ڲֲ�Ʒ��� + FBAͷ����;��Ʒ��� + FBAͷ���˷�
	������ڲֲ�Ʒ��� + �����ͷ����;��Ʒ��� + �����ͷ���˷�
	���ڲɹ���; + �����ڲֲ�Ʒ��� 

import_data.daily_HeadwayDelivery 
	��¼ͷ���˷� ��״̬��ÿ�����ˢ��
	��С���ȣ�UNIQUE KEY(`BoxSku`, `ShopCode`, `ReceiveWarehouse`, `PackageNumber`)
	����ָ�꣺
		 -- 1 ��FBA+����֣��ڲֲ�Ʒ��� = RemainQuantity * PurchaseFee = ʣ������ * ��Ʒ�ɹ��ɱ���Ԫ/����
		1 SKU�˷�  ɸѡ R��0�� ���˷�/������=�����˷� 
		2 SKU��Ʒ�ɱ�

import_data.daily_FBAInventory_Box 
	��Դ���ٷ�Api����
	��¼FBA�ֿ���; �����ձ� ��ʹ��T-1������
	��С���ȣ�UNIQUE KEY(`GenerateDate`, `BoxSku`, `Shopcode`, `Warehouse`)
	����ָ�꣺FBA ͷ����;��Ʒ���  
	
import_data.FBAInventory 
	��Դ�������̨
	��¼FBA�ڲֽ��
	
		wt_store
import_data.daily_ABroadWarehouse daw
	��Դ������\�ִ�\����ֱ����� ������Ӧ��API����
	��¼����ֿ� �����ձ� ��ʹ��T-1������
	��С���ȣ�UNIQUE KEY(`GenerateDate`, `BoxSku`, `Warehouse`)
	����ָ�꣺����� ͷ����;��Ʒ���ڲֲ�Ʒ��
*/

-- ���ڵ��� 
-- ����һ������ǴӺ������FBA�ֵ��������� ͷ�̱���û�и�BOXSKU��¼����ʵ��FBA�ֿ����С�
-- Ŀǰ�ڽ�� ��׼�Ӻ������FBA������ֻ�ܴӺ���ַ����ͻ���
-- ���ۣ������ں���ַ���FBA

-- =================

select sum(TotalPrice)
from import_data.daily_WarehouseInventory dwi 
where WarehouseName = '��ݸ-�����' and CreatedTime ='2023-03-08'


-- ��sellerskuƥ���sku 
select eaac.BoxSKU , eaac.sku , f.*
from import_data.FBAInventory f 
left join erp_amazon_amazon_channelskus eaac on f.SellerSku = eaac.PlatformSku 
where ReportType = '�ܱ�' and Monday = '2023-03-06'
)

-- ��asinƥ���sku
select listing_map.sku ,listing_map.boxsku ,f.* 
from import_data.FBAInventory f
left join (
	select wl.SKU ,wl.BoxSku , f.asin 
	from import_data.FBAInventory f 
	join wt_listing wl on f.Asin  = wl.asin and f.ShopCode  = wl.shopcode
	where ReportType = '�ܱ�' and Monday = '2023-03-06'
	group by wl.SKU ,wl.BoxSku , f.asin 
	) listing_map
	on f.asin = listing_map.asin 
where ReportType = '�ܱ�' and Monday = '2023-03-06'

select 2796/14
-- ����
select *
from import_data.daily_FBAInventory_Box dfb 
where
-- 	BoxSku =4375397 and 
	GenerateDate = '2023-03-13'

onWarehouse_prod_amount as (
select   
	sum(RemainQuantity * PurchaseFee) `FBA+������ڲֲ�Ʒ���`
	sum(case when ReceiveWarehouse regexp 'FBA' then RemainQuantity * PurchaseFee end)  `FBA�ڲֲ�Ʒ���`
	sum(case when ReceiveWarehouse not regexp 'FBA' then RemainQuantity * PurchaseFee end)  `FBA�ڲֲ�Ʒ���`
from import_data.daily_HeadwayDelivery dhd 
join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '�̳���' 
)



-- ,onWarehouse_fee_amount as (
-- select   `FBA+�������;�˷�`
-- from import_data.daily_HeadwayDelivery dhd 
-- join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '�̳���' 
-- )

, FBA_onWay AS (
select sum(TransportAmount) `FBA��;��Ʒ���`
from import_data.daily_FBAInventory_Box dhd
join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '�̳���' 
where GenerateDate ='2023-03-06'
)

, abroad_onWay AS (
select sum(ProductShangjiaStatus) `�������;��Ʒ���`
from import_data.daily_ABroadWarehouse dhd
join import_data.erp_product_products epp on dhd.BoxSku = epp.BoxSKU and epp.ProjectTeam = '�̳���' 
where GenerateDate ='2023-03-06'
)

select `FBA+������ڲֲ�Ʒ���` +  `FBA��;��Ʒ���` +`�������;��Ʒ���`
from onWarehouse_prod_amount,FBA_onWay,abroad_onWay


-- RemainQuantity -- FBA ����� ���²���ʣ������ = �ֿ���� sku������ 

-- 
-- 3 FBA��;��Ʒ��� + ��;�˷�
-- FBA��;��Ʒ��� TransportAmount
-- from import_data.daily_FBAInventory_Box dfb 
-- where GenerateDate= current_date() -1
-- 
-- from daily_ABroadWarehouse daw 