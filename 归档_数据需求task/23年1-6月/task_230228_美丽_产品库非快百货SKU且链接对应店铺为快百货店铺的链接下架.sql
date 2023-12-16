-- 
/*
 * ҵ�񱳾�����Ʒ��ǿ�ٻ�SKU�����Ӷ�Ӧ����Ϊ��ٻ����̵����������¼�
�����֮ǰ˵��Ʒ�ֵ���������û�и��Ƶ�SKU��Ӧ������IT��æ���ܵģ��н����
������δ����������������
��������ٿ���δ��������Ҫ������ⲿ������ȫɾ�ˣ����ͷ���
 * 
 */

with 
epp as ( 
select Sku ,SPU ,ProjectTeam
from import_data.erp_product_products epp 
where 
	ProjectTeam = '������'
	and IsDeleted =0 and IsMatrix =0 
group by Sku ,SPU ,ProjectTeam
)

, channel as ( 
select PlatformSku as sellersku , Sku ,ShopCode
from import_data.erp_amazon_amazon_channelskus eaac 
where AssociatedStates = 0 
group by PlatformSku, Sku ,ShopCode
)

-- select count(1) from (

select eaal.ShopCode ,NodePathNameFull  `���ӵ��̶�Ӧ�Ŷ�`
	,eaal.SellerSKU ,ASIN  ,PublicationDate `����ʱ��` 
	,eaal.BoxSku ,eaal.SKU 
	,epp.ProjectTeam `��Ʒ����ʾ����`
from 
	( select BoxSku ,SKU ,SPU ,productid ,PublicationDate ,sellersku ,ls.ShopCode ,ms.NodePathNameFull,ASIN
		from erp_amazon_amazon_listing ls
		join import_data.mysql_store ms on ls.ShopCode = ms.Code 
		where ms.department ='��ٻ�'
			and ls.ListingStatus = 1
	) eaal  
join
	( -- ʹ�� sku ����
	select epp.sku ,ProjectTeam 
	from epp 
	group by epp.sku ,ProjectTeam 
	) epp
	on eaal.sku  = epp.sku 
	
-- ) tmp

		
		
