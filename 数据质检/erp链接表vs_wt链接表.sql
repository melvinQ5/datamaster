
-- erp���ӱ� join wt_products p on p.id = al.ProductId ֮����������ݲŻ�д�� wt_listing

select * from wt_listing
where Id='0c67c948-d7ed-457f-9a0a-c2012f0abbf9';
select * from erp_amazon_amazon_listing
where Id='0c67c948-d7ed-457f-9a0a-c2012f0abbf9';

select Id ,CreationTime ,ListingStatus from wt_listing
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';

-- ��ȡ���ӱ��Ӧ�Ĳ�Ʒid
select Id ,ProductId ,CreationTime ,LastModificationTime ,ListingStatus from erp_amazon_amazon_listing
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';
-- ��ProductId ȥ��Ʒ����Ӧ��¼
select id from erp_product_products
where id = '39fce444-f877-0994-ae01-4dcf25a21788';


select Id ,CreationTime ,LastModificationTime ,ListingStatus from erp_amazon_amazon_listing_delete
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';




select count(1)
from (
select Id as erp_id from erp_amazon_amazon_listing
union all select Id as erp_id from erp_amazon_amazon_listing_delete ) t1
left join wt_listing t2 on t1.erp_id=t2.id
where t2.id is null

select * from wt_adserving_amazon_daily where ListingId is null ;
