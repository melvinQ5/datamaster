

-- 对照两边的潜力款数据，按 sales_no_freight 从潜力款还原分层
insert into dep_kbh_product_level(spu,FirstDay,Department,sales_no_freight,prod_level)
with base as ( -- 主表标了潜力款，潜力表未标注潜力款
select a.* ,case when b.spu is null then '多标' end mismark
from
(select spu ,FirstDay ,sales_no_freight from dep_kbh_product_level where prod_level = '潜力款'
) a
left join (select spu, StartDay, EndDay
           from dep_kbh_product_level_potentail
           where prod_level = '潜力款') b on a.spu =b.spu
)

select spu ,FirstDay ,'快百货',sales_no_freight
     , case when sales_no_freight >=1500 then '爆款' when sales_no_freight>=500 and sales_no_freight<1500 then'旺款'
	else '其他' end as prod_level
from base where mismark = '多标'