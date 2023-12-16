/* ��Ǳ��Ʒ���
���Ƚ���30�������Ʒ��Ϊ �� �� �������ٶ����������Ǳ�����׼
 */
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , dl.`SPU` ,'Ǳ����'
from dep_kbh_product_level dl
join (select distinct spu ,StartDay ,EndDay from dep_kbh_product_level_potentail where prod_level = 'Ǳ����' ) dkplp on dl.spu = dkplp.spu
and dl.prod_level = '����' and dl.isdeleted=0
and dl.MarkDate >= dkplp.StartDay and dl.MarkDate <= dkplp.EndDay



/*

-- ���� Department = ��ٻ��ɶ�
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , `SPU` , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
from dep_kbh_product_level dl
left join manual_table mt
on dl.SPU = mt.c2 and dl.Department = mt.c1
	and handlename = '��Ǳ��Ʒ����' and handletime='2023-06-30'
WHERE dl.FirstDay = '2023-06-22'; -- 0629�ܵ� 0622��0628


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , `SPU` , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
from dep_kbh_product_level dl
left join manual_table mt
on dl.SPU = mt.c2 and dl.Department = mt.c1
	and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-07'
WHERE dl.FirstDay = '2023-06-29'; -- 0706�ܵ� 0629��0705


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , `SPU`  , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
from dep_kbh_product_level dl
left join manual_table mt
on dl.SPU = mt.c2 and dl.Department = mt.c1
	and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-17'
WHERE dl.FirstDay = '2023-07-06'; -- 0713�ܵ� 0706��0712


-- ��19��������ֹ�Ǳ���嵥 ���12����һ��
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`
	,isPushByCD ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , 1 as isPushByCD , 1 as isPushByQZ
from dep_kbh_product_level dl
WHERE dl.FirstDay = '2023-07-12' and  prod_level regexp '��|��' ;  -- 0719�ܵ� 0712��0718����ʱ��������


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByCD )
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
    , 1 as isPushByCD
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-21' and mt.c1='�ɶ�'
WHERE dl.FirstDay = '2023-07-12';  -- 0719�ܵ� 0712��0718����ʱ��������


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
    , 1 as isPushByQZ
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-21' and mt.c1='Ȫ��'
WHERE dl.FirstDay = '2023-07-12';


-- �¹���
-- ��19��������ֹ�Ǳ���嵥 �굽17-24��һ�ܣ����������24��
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`
	,isPushByCD ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , 1 as isPushByCD , 1 as isPushByQZ
from dep_kbh_product_level dl
WHERE dl.FirstDay = '2023-07-17' and  prod_level regexp '��|��' ;  -- 0719�ܵ� 0712��0718����ʱ��������


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByCD )
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
    , 1 as isPushByCD
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-21' and mt.c1='�ɶ�'
WHERE dl.FirstDay = '2023-07-17';  -- 0719�ܵ� 0712��0718����ʱ��������


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
    , 1 as isPushByQZ
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-21' and mt.c1='Ȫ��'
WHERE dl.FirstDay = '2023-07-17';



-- �¹���
-- ��19��������ֹ�Ǳ���嵥 �굽24-31��һ�ܣ����������31��
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`
	,isPushByCD ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , 1 as isPushByCD , 1 as isPushByQZ
from dep_kbh_product_level dl
WHERE dl.FirstDay = '2023-07-24' and  prod_level regexp '��|��' ;  -- 0719�ܵ� 0712��0718����ʱ��������


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByCD )
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
    , 1 as isPushByCD
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-21' and mt.c1='�ɶ�'
WHERE dl.FirstDay = '2023-07-24';  -- 0719�ܵ� 0712��0718����ʱ��������


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = 'Ǳ����' then 'Ǳ����' else dl.prod_level end  prod_level
    , 1 as isPushByQZ
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '��Ǳ��Ʒ����' and handletime='2023-07-21' and mt.c1='Ȫ��'
WHERE dl.FirstDay = '2023-07-24';


 */



