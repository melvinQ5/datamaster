-- erp�� �Ա� wt��
select wl.*
from import_data.wt_listing wl 
inner join import_data.mysql_store s on wl.shopcode=s.Code/*����ά��*/
join ( -- erp���ӱ�
	select eaal.SellerSKU ,eaal.shopcode 
-- 	,BoxSku 
	,asin ,s.ShopStatus ,spu
	from import_data.erp_amazon_amazon_listing eaal  
	inner join import_data.mysql_store s on eaal.shopcode=s.Code/*����ά��*/
-- 	where AccountCode ='VK-NA'
-- 	where AccountCode ='VK-EU'
	where BoxSku in (
		4390461,
		4301024,
		4430400,
		4399848,
		4475424,
		4476812)
-- 	AND ListingStatus =1 and s.ShopStatus = '����'
	) ta 
	on wl.SellerSKU = ta.SellerSKU and wl.ShopCode = ta.ShopCode
where wl.isdeleted=0 and listingstatus = 1 and s.ShopStatus = '����'



-- �ò�Ʒ���޿������
select * 
from  ( -- erp���ӱ�
	select eaal.SellerSKU ,eaal.shopcode 
	,BoxSku 
	,asin ,s.ShopStatus ,spu
	from import_data.erp_amazon_amazon_listing eaal  
	inner join import_data.mysql_store s on eaal.shopcode=s.Code/*����ά��*/
	where spu =5202143
-- 	AND ListingStatus =1 and s.ShopStatus = '����'
	) ta 
join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU 