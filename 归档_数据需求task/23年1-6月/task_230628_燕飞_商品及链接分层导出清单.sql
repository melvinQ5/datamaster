-- ���������嵥

select
    a.FirstDay as `��������`
    ,Department as `���ò���`
    ,a.SPU
    ,prod_level as `��Ʒ�ֲ�`
    ,ProductStatus as `���²�Ʒ״̬`
    ,sales_in30d as `��˾��30�����۶�`
    ,Ȫ�ݽ�30�����۶�
    ,case when Ȫ�ݽ�30�����۶� > 0 then 1 else 0 end `Ȫ���Ƿ����`
    ,isnew as  `����Ʒ״̬`
    ,wttime as `���ݸ���ʱ��`
from ( select * from dep_kbh_product_level  where right(FirstDay,3)  = '2023-05-01' and Department='��ٻ�' ) a
left join ( select spu ,FirstDay , sales_in30d as Ȫ�ݽ�30�����۶� from dep_kbh_product_level  where right(FirstDay,3)  = '-01' and Department='��ٻ�Ȫ��' ) b
on a.SPU = b.SPU and a.FirstDay = b.FirstDay


-- -- �������嵥

select
    FirstDay as `���µ�һ��`
    ,Department as `���ò���`
    ,asin
    ,site
    ,list_level as `���ӷֲ�`
    ,ListingStatus as `��������״̬`
    ,sales_no_freight as `�����˷����۶�`
    ,sales_in30d as `��30�����۶�`
    ,profit_in30d as `��30�������`
--     ,sales_in7d as `��7�����۶�`
    ,list_orders as  `��30�충����`
    ,wttime as `���ݸ���ʱ��`
from dep_kbh_listing_level where FirstDay = '2023-06-01' and Department='��ٻ��ɶ�'


