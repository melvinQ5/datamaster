select  ifnull(Department,'��˾') as `����`
        ,count(distinct SPU) '0616ͳ������SPU��'
from erp_amazon_amazon_listing al
inner join mysql_store s
on al.ShopCode=s.Code
and al.SKU<>''
where al.ListingStatus=1
and ShopStatus='����'
group by grouping sets((),(department));

select *
from
import_data.ads_product_monthly