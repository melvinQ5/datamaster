select  ifnull(Department,'公司') as `部门`
        ,count(distinct SPU) '0616统计在线SPU数'
from erp_amazon_amazon_listing al
inner join mysql_store s
on al.ShopCode=s.Code
and al.SKU<>''
where al.ListingStatus=1
and ShopStatus='正常'
group by grouping sets((),(department));

select *
from
import_data.ads_product_monthly