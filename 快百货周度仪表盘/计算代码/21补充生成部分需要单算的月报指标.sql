

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'������������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  ������������
    ,count(distinct  w1.spu)  ������������
    ,count( distinct w0.spu) ���ڱ�������
    ,'�±�' ����
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -1 month )) and prod_level regexp '����|����' and Department='��ٻ�' group by spu ) w0
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay =  '${StartDay}'  and prod_level regexp '����|����' and Department='��ٻ�' group by spu ) w1
    on w0.SPU = w1.SPU;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when week_0.prod_level='����' and week_bf1.prod_level != '����' then week_0.spu end )   -- ����������
    ,0 ,0 ,'�±�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when week_0.prod_level='����' and week_bf1.prod_level not regexp  '����|����' then week_0.spu end )
    ,0 ,0 ,'�±�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'������������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,sum(cast(c2 as int))
     ,0 ,0 ,'�±�' type
from manual_table where  handletime = '${StartDay}' and memo regexp '����������|����������' and c5 ='�±�';



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when week_0.prod_level='����' and week_0.isnew = '��Ʒ' and !(week_bf1.prod_level='����' and week_bf1.isnew = '��Ʒ') then week_0.spu end )   -- ��Ʒ����������
    ,0 ,0 ,'�±�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ����������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
     ,count(distinct case when week_0.prod_level='����' and week_0.isnew = '��Ʒ' and !(week_bf1.prod_level='����' and week_bf1.isnew = '��Ʒ') then week_0.spu end )   -- ��Ʒ����������
    ,0 ,0 ,'�±�' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ������������' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,sum(cast(c2 as int))
     ,0 ,0 ,'�±�' type
from manual_table where  handletime = '${StartDay}' and memo regexp '��Ʒ����������|��Ʒ����������' and c5 ='�±�';



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'SA����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type regexp '����A|����S' then CONCAT( asin,site) end ) SA����������
    ,0 ,0 ,'�±�' type
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'S����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type = '����S' then CONCAT( asin,site) end ) S����������
    ,0 ,0 ,'�±�' type
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5  )
select '${StartDay}' as ���ڵ�һ�� ,'A����������' as ָ��  ,ifnull(dep2,'��ٻ�') as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,count(distinct case when  change_type = '����A' then CONCAT( asin,site) end ) A����������
    ,0 ,0 ,'�±�' type
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '�ɶ�' then '��ٻ��ɶ�' when week_0.Department regexp 'Ȫ��' then '��ٻ�Ȫ��'
        when week_0.Department is null then '��ٻ�' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '����S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '����S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp 'Ǳ��|����' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '����A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '����A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ7��ɹ���' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'�±�' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-1 week )) and prod_level regexp 'Ǳ����' group by dkpl.spu ) w0 -- ͬ�ܶ�ָ��ֵ
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-1 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ14��ɹ���' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'�±�' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-2 week )) and prod_level regexp 'Ǳ����' group by dkpl.spu ) w0 -- ͬ�ܶ�ָ��ֵ
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-2 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ28��ɹ���' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'�±�' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-4 week )) and prod_level regexp 'Ǳ����' group by dkpl.spu ) w0 -- ͬ�ܶ�ָ��ֵ
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-4 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ28��ɹ���_��Ʒ' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  ��Ǳ��Ʒ28��ɹ���_��Ʒ
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'�±�' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl join (select spu from view_kbp_new_products group by spu) vknp on dkpl.spu = vknp.spu
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-4 week )) and prod_level regexp 'Ǳ����' group by dkpl.spu ) w0 -- ͬ�ܶ�ָ��ֵ
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-4 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5)
select '${StartDay}' as ���ڵ�һ�� ,'��Ǳ��Ʒ28��ɹ���_��Ʒ' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  ��Ǳ��Ʒ28��ɹ���_��Ʒ
    , count(distinct  w1.spu) ,count( distinct w0.spu) ,'�±�' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl left join (select spu from view_kbp_new_products group by spu) vknp on dkpl.spu = vknp.spu
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-4 week )) and prod_level regexp 'Ǳ����' and vknp.spu is null group by dkpl.spu  ) w0 -- ͬ�ܶ�ָ��ֵ
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-4 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '����|����'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5)
select '${StartDay}' as ���ڵ�һ�� ,'��Ʒ���������۶�' as ָ��  ,'��ٻ�' as �Ŷ� ,'��ٻ��ܱ�ָ���'
    , round(sum(case when prod_level regexp '����|����' and isnew = '��Ʒ' then sales_in30d end), 2)
    ,0 ,0 ,'�±�' as c5
from import_data.dep_kbh_product_level
where FirstDay ='${StartDay}';


