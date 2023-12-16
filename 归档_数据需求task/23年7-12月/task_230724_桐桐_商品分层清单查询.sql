
select
    FirstDay as `对应当周一`
    ,Department as `适用部门`
    ,SPU
    ,prod_level as `商品分层`
    ,ProductStatus as `最新产品状态`
from  dep_kbh_product_level
where FirstDay  in ('2023-07-10','2023-07-17')
and Department='快百货'

