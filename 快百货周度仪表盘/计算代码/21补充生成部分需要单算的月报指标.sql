

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆旺款留存率' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  爆旺款留存率
    ,count(distinct  w1.spu)  爆旺款留存数
    ,count( distinct w0.spu) 上期爆旺款数
    ,'月报' 类型
from ( select spu  from  dep_kbh_product_level WHERE  FirstDay = date(date_add('${StartDay}',interval -1 month )) and prod_level regexp '旺款|爆款' and Department='快百货' group by spu ) w0
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay =  '${StartDay}'  and prod_level regexp '旺款|爆款' and Department='快百货' group by spu ) w1
    on w0.SPU = w1.SPU;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct case when week_0.prod_level='爆款' and week_bf1.prod_level != '爆款' then week_0.spu end )   -- 爆款新增数
    ,0 ,0 ,'月报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,count(distinct case when week_0.prod_level='旺款' and week_bf1.prod_level not regexp  '旺款|爆款' then week_0.spu end )
    ,0 ,0 ,'月报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'爆旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,sum(cast(c2 as int))
     ,0 ,0 ,'月报' type
from manual_table where  handletime = '${StartDay}' and memo regexp '爆款新增数|旺款新增数' and c5 ='月报';



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'新品爆款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when week_0.prod_level='爆款' and week_0.isnew = '新品' and !(week_bf1.prod_level='爆款' and week_bf1.isnew = '新品') then week_0.spu end )   -- 新品爆款新增数
    ,0 ,0 ,'月报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'新品旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct case when week_0.prod_level='旺款' and week_0.isnew = '新品' and !(week_bf1.prod_level='旺款' and week_bf1.isnew = '新品') then week_0.spu end )   -- 新品旺款新增数
    ,0 ,0 ,'月报' type
 from (select  * from  dep_kbh_product_level WHERE  FirstDay= '${StartDay}') week_0
left join  (select * from  dep_kbh_product_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.SPU = week_bf1.spu and  week_0.Department = week_bf1.Department
group by week_0.Department;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'新品爆旺款新增数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,sum(cast(c2 as int))
     ,0 ,0 ,'月报' type
from manual_table where  handletime = '${StartDay}' and memo regexp '新品爆款新增数|新品旺款新增数' and c5 ='月报';



insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'SA链接新增数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type regexp '新增A|新增S' then CONCAT( asin,site) end ) SA链接新增数
    ,0 ,0 ,'月报' type
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'S链接新增数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type = '新增S' then CONCAT( asin,site) end ) S链接新增数
    ,0 ,0 ,'月报' type
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5  )
select '${StartDay}' as 当期第一天 ,'A链接新增数' as 指标  ,ifnull(dep2,'快百货') as 团队 ,'快百货周报指标表'
    ,count(distinct case when  change_type = '新增A' then CONCAT( asin,site) end ) A链接新增数
    ,0 ,0 ,'月报' type
from (
select week_0.asin,week_0.site
     , case when week_0.Department regexp '成都' then '快百货成都' when week_0.Department regexp '泉州' then '快百货泉州'
        when week_0.Department is null then '快百货' end as dep2
    ,case
        when week_0.list_level = 'S' and  week_bf1.list_level != 'S' then '新增S'
        when week_0.list_level = 'S' and  week_bf1.list_level = 'S' then '留存S'
        when week_0.list_level = 'A' and  week_bf1.list_level regexp '潜力|其他' then '新增A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'S' then '降至A'
        when week_0.list_level = 'A' and  week_bf1.list_level = 'A' then '留存A'
    end change_type
from ( select  * from  dep_kbh_listing_level WHERE  FirstDay= '${StartDay}' ) week_0
left join  (select * from  dep_kbh_listing_level WHERE  FirstDay = date_add('${StartDay}',interval -1 month )  ) week_bf1
    on week_0.asin = week_bf1.asin  and  week_0.site = week_bf1.site and  week_0.Department = week_bf1.Department
) t
group by grouping sets ((),(dep2));


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as 当期第一天 ,'高潜商品7天成功率' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'月报' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-1 week )) and prod_level regexp '潜力款' group by dkpl.spu ) w0 -- 同周度指标值
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-1 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as 当期第一天 ,'高潜商品14天成功率' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'月报' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-2 week )) and prod_level regexp '潜力款' group by dkpl.spu ) w0 -- 同周度指标值
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-2 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as 当期第一天 ,'高潜商品28天成功率' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'月报' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-4 week )) and prod_level regexp '潜力款' group by dkpl.spu ) w0 -- 同周度指标值
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-4 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4,c5 )
select '${StartDay}' as 当期第一天 ,'高潜商品28天成功率_新品' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  高潜商品28天成功率_新品
     , count(distinct  w1.spu) ,count( distinct w0.spu) ,'月报' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl join (select spu from view_kbp_new_products group by spu) vknp on dkpl.spu = vknp.spu
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-4 week )) and prod_level regexp '潜力款' group by dkpl.spu ) w0 -- 同周度指标值
left join ( select spu from  dep_kbh_product_level
WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-4 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;


insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5)
select '${StartDay}' as 当期第一天 ,'高潜商品28天成功率_老品' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    ,round( count(distinct  w1.spu) / count( distinct w0.spu) ,4)  高潜商品28天成功率_老品
    , count(distinct  w1.spu) ,count( distinct w0.spu) ,'月报' as type
from ( select dkpl.spu  from  dep_kbh_product_level dkpl left join (select spu from view_kbp_new_products group by spu) vknp on dkpl.spu = vknp.spu
    WHERE  FirstDay =  date(date_add('${NextStartDay}',interval -1-4 week )) and prod_level regexp '潜力款' and vknp.spu is null group by dkpl.spu  ) w0 -- 同周度指标值
left join ( select spu from  dep_kbh_product_level WHERE  FirstDay >=  date(date_add('${NextStartDay}',interval -1-4 week )) and FirstDay <=  date(date_add('${NextStartDay}',interval -1 week )) and prod_level regexp '旺款|爆款'  group by spu ) w1
    on w0.SPU = w1.SPU;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5)
select '${StartDay}' as 当期第一天 ,'新品爆旺款销售额' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
    , round(sum(case when prod_level regexp '爆款|旺款' and isnew = '新品' then sales_in30d end), 2)
    ,0 ,0 ,'月报' as c5
from import_data.dep_kbh_product_level
where FirstDay ='${StartDay}';


