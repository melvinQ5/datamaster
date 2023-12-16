with ta as (
select *
from import_data.manual_table mt 
where c1 = '��Ʒ�Ƽ�_��14��_P1'
)


,t_list_cnt as ( 
select wl.sku 
	,count(distinct concat(SellerSKU,ShopCode)) `����������` 
	,count(distinct case when NodePathName ='���Ԫ-�ɶ�������' then concat(SellerSKU,ShopCode) end ) `����������_��1` 
	,count(distinct case when NodePathName ='���Ԫ-Ȫ��������' then concat(SellerSKU,ShopCode) end ) `����������_Ȫ1` 
	,count(distinct case when NodePathName ='��η�-�ɶ�������' then concat(SellerSKU,ShopCode) end ) `����������_��2` 
	,count(distinct case when NodePathName ='��η�-Ȫ��������' then concat(SellerSKU,ShopCode) end ) `����������_Ȫ2` 
from wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code 
join  ta on wl.sku = ta.c3
where wl.ListingStatus =1 and ms.ShopStatus = '����' and ms.Department = '��ٻ�'
group by wl.sku
)

select ta.c3 ,tb.*
from ta 
left join t_list_cnt tb on ta.c3 = tb.sku 