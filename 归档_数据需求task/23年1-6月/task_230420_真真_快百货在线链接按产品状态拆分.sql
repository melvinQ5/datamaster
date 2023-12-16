-- ����������
with 
list as ( -- 
select 
	count(distinct concat(shopcode,SellerSku)) as `��ٻ�����������`
	,count(distinct case when wp.ProductStatus = 0 then concat(shopcode,SellerSku) end ) as `��ٻ�����������(��Ʒ����)`
	,count(distinct case when wp.ProductStatus = 2 then concat(shopcode,SellerSku) end ) as `��ٻ�����������(��Ʒͣ��)`
	,count(distinct case when wp.ProductStatus = 3 then concat(shopcode,SellerSku) end ) as `��ٻ�����������(��Ʒͣ��)`
	,count(distinct case when wp.ProductStatus = 4 then concat(shopcode,SellerSku) end ) as `��ٻ�����������(��Ʒ��ʱȱ��)`
	,count(distinct case when wp.ProductStatus = 5 then concat(shopcode,SellerSku) end ) as `��ٻ�����������(��Ʒ���)`
from import_data.wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�' and ms.ShopStatus = '����'
join import_data.wt_products wp  on wl.BoxSku = wp.boxsku and wl.IsDeleted = 0 
and ListingStatus = 1 
and wp.projectteam = '��ٻ�'and wp.IsDeleted = 0 
)

,al as (
select s.Department,
     Count( distinct case when ListingStatus=1 and ShopStatus='����' then concat(ShopCode,SellerSKU,ASIN) end ) '����������',
     Count( distinct case when ListingStatus=1 then concat(ShopCode,SellerSKU,ASIN) end ) '����������_�����ǵ���״̬',
     count(distinct concat(ShopCode,SellerSKU,ASIN))   '��������'   
from erp_amazon_amazon_listing al
inner join mysql_store s
on al.ShopCode=s.Code
and s.Department  = '��ٻ�'
where IsDeleted=0
group by s.Department 
)

select  count(1)
from import_data.wt_products wp 
left join list on list.BoxSku = wp.boxsku
where wp.projectteam = '��ٻ�'
	and wp.DevelopLastAuditTime is not null and wp.BoxSku is not null 
	

-- ������������������
SELECT case when ListingStatus = 1 then '����'
	when ListingStatus = 3 then '�¼�'
	when ListingStatus = 4 then '����δ�ϼ�'
	when ListingStatus = 5 then 'ɾ��'
	when ListingStatus is null then '���ܺϼ�'
	end as ListingStatus
	,count(1)
from erp_amazon_amazon_listing al 
inner join mysql_store s on al.ShopCode=s.Code and  s.Department  = '��ٻ�'
group by grouping sets ((),(ListingStatus ))

	
	
	

