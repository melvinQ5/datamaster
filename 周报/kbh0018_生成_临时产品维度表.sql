
insert into dep_kbh_product_test (spu, sku, boxsku, isnew, istheme, ispotenial,min_pushdate , cat1, ele_name_priority, ele_name_group,productstatus,unique_brand_shop)
with prod as ( select spu,sku,boxsku,ifnull(cat1,'其他') as cat1 ,productstatus from wt_products where IsDeleted=0 and ProjectTeam='快百货' )
,theme as ( select * ,case when ele_name_group regexp '万圣节' then '万圣节' when ele_name_group regexp '圣诞节' then '圣诞节' else '非主题品' end istheme from view_kbh_element )
,pote as (select  SPU ,min(pushdate) min_pushdate from dep_kbh_product_level_potentail where prod_level='潜力款' and PushDate >= '2023-10-01' group by spu )

select prod.spu ,prod.sku ,ifnull(prod.BoxSku,0)
     ,case when v.sku is not null then '新品' else '老品' end as isnew
     ,case when theme.ele_name_priority regexp '圣诞节|冬季' then '主题品' else '非主题品' end as istheme
     ,case when pote.spu is not null then '高潜品' else '非高潜品' end as ispotenial
     ,min_pushdate
     ,cat1
     ,case when ele_name_group is null then '无元素标签' when ele_name_priority is null then '元素未在优先级名单' else ele_name_priority end ele_name_priority
     ,case when ele_name_group is null then '无元素标签' else ele_name_group end as ele_name_group
    ,productstatus
    ,case when mt1.c1 is null then '一标一店品' else '非一标一店品' end as unique_brand_shop
from prod
left join theme on prod.sku =theme.sku
left join pote on prod.spu = pote.spu
left join view_kbp_new_products v on prod.sku = v.sku
left join manual_table mt1 on prod.spu = mt1.c1 and mt1.handlename ='一标一店商品231102'; -- todo manual_table 表