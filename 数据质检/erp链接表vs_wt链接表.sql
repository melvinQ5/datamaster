
-- erp链接表 join wt_products p on p.id = al.ProductId 之后的链接数据才会写入 wt_listing

select * from wt_listing
where Id='0c67c948-d7ed-457f-9a0a-c2012f0abbf9';
select * from erp_amazon_amazon_listing
where Id='0c67c948-d7ed-457f-9a0a-c2012f0abbf9';

select Id ,CreationTime ,ListingStatus from wt_listing
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';

-- 获取链接表对应的产品id
select Id ,ProductId ,CreationTime ,LastModificationTime ,ListingStatus from erp_amazon_amazon_listing
where Id='39ff2bff-2640-f4c6-bf08-394c5775d2cb';
-- 拿ProductId 去产品表查对应记录
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
