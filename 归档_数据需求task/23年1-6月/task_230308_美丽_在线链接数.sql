


select ta.sku ,ProductStatus `��Ʒ״̬`,tb.`����������`
from 
(
select Sku ,boxsku 
	, case when ProductStatus =  0 then '����'
			when ProductStatus = 2 then 'ͣ��'
			when ProductStatus = 3 then 'ͣ��'
			when ProductStatus = 4 then '��ʱȱ��'
			when ProductStatus = 5 then '���'
		end as ProductStatus
from import_data.wt_products wp 
where ProjectTeam = '��ٻ�' and isdeleted= 0 and sku = 1042622.01
group by Sku ,boxsku,ProductStatus
) ta 
left join 
(select sku ,count(distinct ShopCode ,SellerSKU,asin) `����������`
	from wt_listing wl 
-- 	join import_data.mysql_store ms 
-- 	on wl.ShopCode = ms.Code 
-- 		 and ms.ShopStatus = '����'
-- 		and department = '��ٻ�'
	where  wl.IsDeleted = 0 and ListingStatus = 1 
	group by sku
) tb 
on ta.sku =tb.sku
