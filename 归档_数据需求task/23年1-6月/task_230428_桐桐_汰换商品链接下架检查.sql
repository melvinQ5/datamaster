with 
ta as (
select memo as sku ,*
from manual_table mt
where c1 = '��Ʒ��̭��Ʒ�������Ӻ˶�' and handletime='2023-05-03')

,t_list as ( -- ��������
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from erp_amazon_amazon_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join ta on ta.sku = wl.SKU 
where 
	wl.IsDeleted = 0 and wl.ListingStatus =1
	and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
)

,t_list_stat as ( -- ��1 ���Ǽ���
select sku 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��1��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��2��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ2` 
	,count(distinct case when NodePathName ='��Ӫ��-Ȫ��3��' then concat(t_list.shopcode,t_list.SellerSku) end ) `����������_Ȫ3` 
	,min(PublicationDate) `�״ο���ʱ��`
from t_list
group by sku  
)

-- ��ϸ
-- select 
-- 	t_list.BoxSku 
-- 	,t_list.sku  
-- 	,t_list.shopcode  
-- 	,t_list.sellersku `����sku` 
-- 	,t_list.ASIN 
-- 	,t_list.dep2  
-- 	,t_list.NodePathName  
-- 	,t_list.SellUserName `��ѡҵ��Ա` 
-- from t_list 
-- join t_list_stat tb on t_list.sku = tb.sku and tb.`����������` > 0 

-- ͳ��
select ta.* ,tb.*
from ta 
left join t_list_stat tb on ta.sku = tb.sku

