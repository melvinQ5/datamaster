-- û��SA���ӵ�����

select
    dkpl.SPU as '��SA���ӵ�SPU'
    ,'2023-07-31' ����ֲ�����
    , prod_level
    , sales_no_freight �����˷����۶�
    , isnew
from dep_kbh_product_level dkpl
left join (select spu from dep_kbh_listing_level where list_level REGEXP 'S|A' AND FirstDay ='2023-07-24' GROUP BY  SPU ) t
on dkpl.spu = t.spu
where t.spu is null and dkpl.prod_level = '����'  AND FirstDay ='2023-07-24'