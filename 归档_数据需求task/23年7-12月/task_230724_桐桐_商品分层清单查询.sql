
select
    FirstDay as `��Ӧ����һ`
    ,Department as `���ò���`
    ,SPU
    ,prod_level as `��Ʒ�ֲ�`
    ,ProductStatus as `���²�Ʒ״̬`
from  dep_kbh_product_level
where FirstDay  in ('2023-07-10','2023-07-17')
and Department='��ٻ�'

