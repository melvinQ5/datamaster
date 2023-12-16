
insert into dep_kbh_product_test (spu, sku, boxsku, isnew, istheme, ispotenial,min_pushdate , cat1, ele_name_priority, ele_name_group,productstatus,unique_brand_shop)
with prod as ( select spu,sku,boxsku,ifnull(cat1,'����') as cat1 ,productstatus from wt_products where IsDeleted=0 and ProjectTeam='��ٻ�' )
,theme as ( select * ,case when ele_name_group regexp '��ʥ��' then '��ʥ��' when ele_name_group regexp 'ʥ����' then 'ʥ����' else '������Ʒ' end istheme from view_kbh_element )
,pote as (select  SPU ,min(pushdate) min_pushdate from dep_kbh_product_level_potentail where prod_level='Ǳ����' and PushDate >= '2023-10-01' group by spu )

select prod.spu ,prod.sku ,ifnull(prod.BoxSku,0)
     ,case when v.sku is not null then '��Ʒ' else '��Ʒ' end as isnew
     ,case when theme.ele_name_priority regexp 'ʥ����|����' then '����Ʒ' else '������Ʒ' end as istheme
     ,case when pote.spu is not null then '��ǱƷ' else '�Ǹ�ǱƷ' end as ispotenial
     ,min_pushdate
     ,cat1
     ,case when ele_name_group is null then '��Ԫ�ر�ǩ' when ele_name_priority is null then 'Ԫ��δ�����ȼ�����' else ele_name_priority end ele_name_priority
     ,case when ele_name_group is null then '��Ԫ�ر�ǩ' else ele_name_group end as ele_name_group
    ,productstatus
    ,case when mt1.c1 is null then 'һ��һ��Ʒ' else '��һ��һ��Ʒ' end as unique_brand_shop
from prod
left join theme on prod.sku =theme.sku
left join pote on prod.spu = pote.spu
left join view_kbp_new_products v on prod.sku = v.sku
left join manual_table mt1 on prod.spu = mt1.c1 and mt1.handlename ='һ��һ����Ʒ231102'; -- todo manual_table ��