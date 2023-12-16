
CREATE TABLE IF NOT EXISTS
dep_kbh_product_level (
`FirstDay` date NOT NULL COMMENT "������Ʒ�ֲ�����",
`Department`  varchar(24) NOT NULL COMMENT "���ò���" ,
`SPU` varchar(64)  NOT NULL COMMENT "SPU",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƿ�ɾ��" ,
`Week` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "ͳ���ܴ�",
`prod_level` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ�ֲ�",
`ProductStatus` varchar(24) REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ״̬",
`sales_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�����˷����۶�",
`profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "���˷ѿ۹����˿�����",
`AdSpend_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30���Ʒ��滨��",
`sales_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30�����۶�",
`profit_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30�������",
`AdSpend_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��7���Ʒ��滨��",
`sales_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��7�����۶�",
`profit_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��7�������",
`isnew`  varchar(24) REPLACE_IF_NOT_NULL NULL  COMMENT "����Ʒ�����¼�ǰ������������Ϊ��Ʒ",
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "д��ʱ��"
) ENGINE=OLAP
AGGREGATE KEY(FirstDay,Department,SPU)
COMMENT "��ٻ���Ʒ�ֲ�"
DISTRIBUTED BY HASH(FirstDay,Department,SPU) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- �����ֶ�
ALTER TABLE dep_kbh_product_level ADD COLUMN `sales_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30�����۶�" after sales_no_freight;
ALTER TABLE dep_kbh_product_level ADD COLUMN `sales_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��7�����۶�" after sales_in30d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `profit_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30�������" after sales_in30d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `profit_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��7�������" after sales_in7d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "���˷ѿ۹����˿�����" after sales_no_freight;
ALTER TABLE dep_kbh_product_level ADD COLUMN `isPushByCD` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "�ɶ�����Ǳ����" after prod_level;
ALTER TABLE dep_kbh_product_level ADD COLUMN `isPushByQZ` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "Ȫ�ݸ���Ǳ����" after isPushByCD;
ALTER TABLE dep_kbh_product_level ADD COLUMN `AdSpend_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30���Ʒ��滨��" after profit_no_freight;
ALTER TABLE dep_kbh_product_level ADD COLUMN `AdSpend_in7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��7���Ʒ��滨��" after profit_in30d;
ALTER TABLE dep_kbh_product_level ADD COLUMN `isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƿ�ɾ��" after SPU;



-- ����
-- ����MarkDate
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,MarkDate)
    select FirstDay,Department,SPU, date(date_add(FirstDay,interval 1 week)) as MarkDate
        from dep_kbh_product_level where day(firstday) != 1;
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,MarkDate)
    select FirstDay,Department,SPU, date(date_add(FirstDay,interval 1 month)) as MarkDate
        from dep_kbh_product_level where day(firstday) = 1;

-- ���ɾ������
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where FirstDay ='2023-10-31'
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where MarkDate ='2023-10-16'
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where FirstDay ='2023-09-25'
insert into dep_kbh_product_level (FirstDay ,Department ,SPU ,isdeleted,wttime)
select FirstDay,Department,SPU, 1 as isdeleted ,now()
    from dep_kbh_product_level where FirstDay ='2023-09-01'

-- ��������Ʒ
insert into dep_kbh_product_level (FirstDay,Department,SPU,isnew)
    select FirstDay,Department,dkpl.SPU, case when vknp.spu is not null  then '��Ʒ' else '��Ʒ' end  isnew
    from dep_kbh_product_level dkpl
    left join (select distinct spu from view_kbp_new_products ) vknp on dkpl.spu = vknp.spu
    where FirstDay >= '2023-10-01';

select cast(firstday as varchar) as firstday ,spu ,week ,prod_level,isnew  from dep_kbh_product_level  where firstday > '2023-07-01' and isdeleted = 0



-- ��ѯ
select FirstDay,Department ,count(1) from  dep_kbh_product_level where isdeleted = 0 group by FirstDay,Department;
select count(1) from  dep_kbh_product_level;
select * from  dep_kbh_product_level WHERE Department = '��ٻ�' and FirstDay='2023-06-05' and prod_level regexp '��|��';

select FirstDay ,count(1) spu�� from  dep_kbh_product_level WHERE Department = '��ٻ�' and right(FirstDay,2) = '01' group by FirstDay

-- ���
truncate ---- table dep_kbh_product_level;

