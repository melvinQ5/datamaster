
/*
��ͣ
 */
/*
insert into dep_kbh_listing_level (FirstDay,Department,asin ,site ,list_level)
select FirstDay,Department,dkll.asin ,dkll.site
     ,case when dkll.list_level regexp 'S|A' THEN  dkll.list_level else 'Ǳ��' end potential_mark
from dep_kbh_listing_level dkll
join ( select distinct c2 as site , c4 as asin
from import_data.manual_table  where handletime='2023-08-08' and handlename ='Ǳ�����ӱ�ǩ'  ) t on dkll.asin = t.asin and dkll.site = t.site
    and dkll.FirstDay in ( '2023-07-10','2023-07-17' , '2023-07-24', '2023-07-31','2023-08-07')
*/
    -- and dkll.FirstDay=  date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -1 week )




