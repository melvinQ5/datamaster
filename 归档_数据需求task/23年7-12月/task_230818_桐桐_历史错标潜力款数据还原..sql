

-- �������ߵ�Ǳ�������ݣ��� sales_no_freight ��Ǳ���ԭ�ֲ�
insert into dep_kbh_product_level(spu,FirstDay,Department,sales_no_freight,prod_level)
with base as ( -- �������Ǳ���Ǳ����δ��עǱ����
select a.* ,case when b.spu is null then '���' end mismark
from
(select spu ,FirstDay ,sales_no_freight from dep_kbh_product_level where prod_level = 'Ǳ����'
) a
left join (select spu, StartDay, EndDay
           from dep_kbh_product_level_potentail
           where prod_level = 'Ǳ����') b on a.spu =b.spu
)

select spu ,FirstDay ,'��ٻ�',sales_no_freight
     , case when sales_no_freight >=1500 then '����' when sales_no_freight>=500 and sales_no_freight<1500 then'����'
	else '����' end as prod_level
from base where mismark = '���'