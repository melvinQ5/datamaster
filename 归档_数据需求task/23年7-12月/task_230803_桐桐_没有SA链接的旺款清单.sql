-- 没有SA链接的旺款

select
    dkpl.SPU as '无SA链接的SPU'
    ,'2023-07-31' 计算分层日期
    , prod_level
    , sales_no_freight 不含运费销售额
    , isnew
from dep_kbh_product_level dkpl
left join (select spu from dep_kbh_listing_level where list_level REGEXP 'S|A' AND FirstDay ='2023-07-24' GROUP BY  SPU ) t
on dkpl.spu = t.spu
where t.spu is null and dkpl.prod_level = '旺款'  AND FirstDay ='2023-07-24'