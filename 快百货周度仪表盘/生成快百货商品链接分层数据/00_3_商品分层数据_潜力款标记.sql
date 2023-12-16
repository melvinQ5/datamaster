/* 高潜商品标记
首先将近30天出单产品分为 爆 旺 其他，再对其他类进行潜力款标准
 */
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , dl.`SPU` ,'潜力款'
from dep_kbh_product_level dl
join (select distinct spu ,StartDay ,EndDay from dep_kbh_product_level_potentail where prod_level = '潜力款' ) dkplp on dl.spu = dkplp.spu
and dl.prod_level = '其他' and dl.isdeleted=0
and dl.MarkDate >= dkplp.StartDay and dl.MarkDate <= dkplp.EndDay



/*

-- 生成 Department = 快百货成都
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , `SPU` , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
from dep_kbh_product_level dl
left join manual_table mt
on dl.SPU = mt.c2 and dl.Department = mt.c1
	and handlename = '高潜商品跟进' and handletime='2023-06-30'
WHERE dl.FirstDay = '2023-06-22'; -- 0629跑的 0622至0628


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , `SPU` , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
from dep_kbh_product_level dl
left join manual_table mt
on dl.SPU = mt.c2 and dl.Department = mt.c1
	and handlename = '高潜商品跟进' and handletime='2023-07-07'
WHERE dl.FirstDay = '2023-06-29'; -- 0706跑的 0629至0705


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level )
select `FirstDay` ,Department , `SPU`  , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
from dep_kbh_product_level dl
left join manual_table mt
on dl.SPU = mt.c2 and dl.Department = mt.c1
	and handlename = '高潜商品跟进' and handletime='2023-07-17'
WHERE dl.FirstDay = '2023-07-06'; -- 0713跑的 0706至0712


-- 将19日那天的手工潜力清单 标回12号那一周
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`
	,isPushByCD ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , 1 as isPushByCD , 1 as isPushByQZ
from dep_kbh_product_level dl
WHERE dl.FirstDay = '2023-07-12' and  prod_level regexp '爆|旺' ;  -- 0719跑的 0712至0718，临时改周三跑


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByCD )
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
    , 1 as isPushByCD
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '高潜商品跟进' and handletime='2023-07-21' and mt.c1='成都'
WHERE dl.FirstDay = '2023-07-12';  -- 0719跑的 0712至0718，临时改周三跑


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
    , 1 as isPushByQZ
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '高潜商品跟进' and handletime='2023-07-21' and mt.c1='泉州'
WHERE dl.FirstDay = '2023-07-12';


-- 新规则
-- 将19日那天的手工潜力清单 标到17-24这一周，打标日期是24日
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`
	,isPushByCD ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , 1 as isPushByCD , 1 as isPushByQZ
from dep_kbh_product_level dl
WHERE dl.FirstDay = '2023-07-17' and  prod_level regexp '爆|旺' ;  -- 0719跑的 0712至0718，临时改周三跑


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByCD )
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
    , 1 as isPushByCD
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '高潜商品跟进' and handletime='2023-07-21' and mt.c1='成都'
WHERE dl.FirstDay = '2023-07-17';  -- 0719跑的 0712至0718，临时改周三跑


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
    , 1 as isPushByQZ
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '高潜商品跟进' and handletime='2023-07-21' and mt.c1='泉州'
WHERE dl.FirstDay = '2023-07-17';



-- 新规则
-- 将19日那天的手工潜力清单 标到24-31这一周，打标日期是31日
insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`
	,isPushByCD ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , 1 as isPushByCD , 1 as isPushByQZ
from dep_kbh_product_level dl
WHERE dl.FirstDay = '2023-07-24' and  prod_level regexp '爆|旺' ;  -- 0719跑的 0712至0718，临时改周三跑


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByCD )
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
    , 1 as isPushByCD
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '高潜商品跟进' and handletime='2023-07-21' and mt.c1='成都'
WHERE dl.FirstDay = '2023-07-24';  -- 0719跑的 0712至0718，临时改周三跑


insert into import_data.dep_kbh_product_level (`FirstDay`,Department, `SPU`,
	prod_level ,isPushByQZ)
select `FirstDay` ,Department , `SPU`
    , case when mt.c3 = '潜力款' then '潜力款' else dl.prod_level end  prod_level
    , 1 as isPushByQZ
from dep_kbh_product_level dl
join manual_table mt
on dl.SPU = mt.c2 and handlename = '高潜商品跟进' and handletime='2023-07-21' and mt.c1='泉州'
WHERE dl.FirstDay = '2023-07-24';


 */



