-- create
alter view view_kbh_element as
with
t1 as ( -- ���ȼ�Ԫ��
select * from (
select * ,ROW_NUMBER () over (partition by spu order by priority)  sort
    from (
    select distinct eppaea.spu
        ,case when mt.c2 is null then 99999 else c1+0 end as priority
        ,case when mt.c2 is null then 'Ԫ�ز������ȼ�����' else Name end as ele_name_priority
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    left join manual_table mt on mt.c2 = eppea.Name and handlename='��Ʒ��Ԫ�����ȼ�231030' -- 231017��ɸ���һ�����ȼ�˳��,����ÿ���Ȼ����
    ) t1
) t2
where sort = 1
)

,t2 as ( -- ����Ԫ��
select spu ,GROUP_CONCAT( Name ) ele_name
from (
select eppaea.spu ,eppea.Name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.spu ,eppea.Name
) tmp
group by spu
)

select wp.spu ,wp.sku ,wp.BoxSku
  ,case when t1.ele_name_priority is null then '��Ԫ�ر�ǩ' else t1.ele_name_priority end ele_name_priority
  ,case when t2.ele_name is null then '��Ԫ�ر�ǩ' else t2.ele_name end ele_name_group
from wt_products wp
join t1 on wp.spu = t1.spu
join t2 on wp.spu = t2.spu
where wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0;