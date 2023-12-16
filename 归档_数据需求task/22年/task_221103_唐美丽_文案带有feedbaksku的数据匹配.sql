/*
��ϵͳ�ܵ� �İ�����feedback�ʵ�����
�ⲿ��SKU, ��Ʒ״̬����Ʒ����ʱ�䣬���ʱ�䣬������Ա����Ȩ���  
��Ӧ��30�쵥������3���µ�����
����listing�������������listing���嵥��ϸ������

*/	
with epp as (
select js2.Sku ,js2.Spu,epp.BoxSKU 
	, case when epp.ProductStatus=0 then '����' when epp.ProductStatus=2 then 'ͣ��'
		when epp.ProductStatus=3 then 'ͣ��' when epp.ProductStatus=4 then '��ʱȱ��'
		when epp.ProductStatus=3 then '���' end as ProductStatus
	, epp.DevelopLastAuditTime ,epp.CreationTime, epp.DevelopUserName ,epp.Id 
from import_data.JinqinSku js2 
left join import_data.erp_product_products epp on js2.Sku = epp.SKU 
where js2.Monday ='2022-11-3' 
)

, join_orders as ( -- �������
select od.BoxSku 
	, count(distinct case when od.PayTime >= DATE_ADD('${end_day}',interval -30 Day) and od.PayTime <='${end_day}' then PlatOrderNumber end) `��30�쵥��`
	, count(distinct case when od.PayTime >= DATE_ADD('${end_day}',interval -90 Day) and od.PayTime <='${end_day}' then PlatOrderNumber end) `��90�쵥��`
from import_data.OrderDetails od 
join epp on od.BoxSku =epp.BoxSKU 
where od.PayTime >= DATE_ADD('${end_day}',interval -90 Day) and od.PayTime <='${end_day}' --2022-11-3
	and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0
group by od.BoxSku 
)

, join_listing as ( -- �������
select eaal.SKU, count(1)over(partition by eaal.SKU ) `����������`, eaal.ASIN ,eaal.Name`����` ,eaal.Price `�ۼ�`,eaal.Quantity`������` 
	,eaal.ShopCode `����`
	,eaal.PublicationDate `����ʱ��`,eaal.ProductSalesName `������Ա` ,eaal.IroboxName`��������` 
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('���۶���', '��������') and ms.ShopStatus='����'
join epp on  eaal.sku = epp.sku 
where eaal.ListingStatus = 1  and eaal.PublicationDate <='${end_day}'
)

, infringement as (  -- ��Ȩ���
select ProductId , group_concat(TortType_name, ',') `��Ȩ���` from 
	(
	SELECT tt.ProductId,
	case torttype
	when 1 then '��Ȩ��Ȩ'
	when 2 then '�̱���Ȩ'
	when 3 then 'ר����Ȩ'
	when 4 then 'Υ��Ʒ'
	when 5 then '����Ȩ'
	when 6 then '������Ȩ'
	end torttype_name
	FROM import_data.erp_product_product_tort_types tt
	where tt.ProductId in (select id from erp_product_products where IsDeleted = 0 and IsMatrix = 0)
	group by tt.ProductId, TortType
	) a
group by ProductId
)

, res1 as ( -- ָ��
select epp.SKU, epp.Spu,epp.BoxSKU , epp.ProductStatus `��Ʒ״̬`
	, epp.DevelopLastAuditTime `��Ʒ����ʱ��` 
	, epp.CreationTime `���ʱ��`, epp.DevelopUserName `������Ա`, jo.`��30�쵥��`, jo.`��90�쵥��`,i.`��Ȩ���`
from epp
left join join_orders jo on jo.BoxSku = epp.BoxSKU
left join infringement i on epp.Id = i.ProductId
)

, res2 as ( -- ������ϸ
select * from res1 left join join_listing jl on jl.SKU = res1.Sku -- 1��sku��������
)

select * from res2




