-- 导爆旺款清单

select
    a.FirstDay as `快照日期`
    ,Department as `适用部门`
    ,a.SPU
    ,prod_level as `商品分层`
    ,ProductStatus as `最新产品状态`
    ,sales_in30d as `公司近30天销售额`
    ,泉州近30天销售额
    ,case when 泉州近30天销售额 > 0 then 1 else 0 end `泉州是否出单`
    ,isnew as  `新老品状态`
    ,wttime as `数据更新时间`
from ( select * from dep_kbh_product_level  where right(FirstDay,3)  = '2023-05-01' and Department='快百货' ) a
left join ( select spu ,FirstDay , sales_in30d as 泉州近30天销售额 from dep_kbh_product_level  where right(FirstDay,3)  = '-01' and Department='快百货泉州' ) b
on a.SPU = b.SPU and a.FirstDay = b.FirstDay


-- -- 导链接清单

select
    FirstDay as `当月第一天`
    ,Department as `适用部门`
    ,asin
    ,site
    ,list_level as `链接分层`
    ,ListingStatus as `最新链接状态`
    ,sales_no_freight as `不含运费销售额`
    ,sales_in30d as `近30天销售额`
    ,profit_in30d as `近30天利润额`
--     ,sales_in7d as `近7天销售额`
    ,list_orders as  `近30天订单数`
    ,wttime as `数据更新时间`
from dep_kbh_listing_level where FirstDay = '2023-06-01' and Department='快百货成都'


