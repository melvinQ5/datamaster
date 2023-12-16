-- startday = 2023-07-31
-- 补充漏标数据
insert into dep_kbh_listing_level (`FirstDay`,`Department` , `asin`, `site`,`spu`,`Week`,
	list_level ,old_list_level ,ListingStatus
	,prod_level ,isnew ,ProductStatus ,ele_name ,wttime)

with
others as (
select t.asin , t.site ,t.Department , t.spu
from ( select distinct c2 as site , c4 as asin , c5 as Department ,c7 as spu
    from import_data.manual_table  where handletime='2023-08-08' and handlename ='潜力链接标签' ) t
left join ( select distinct asin ,site from dep_kbh_listing_level where FirstDay in ( '2023-07-10','2023-07-17' , '2023-07-24', '2023-07-31') ) dkll
    on dkll.asin = t.asin and dkll.site = t.site
where dkll.asin is null
)


,lst_1 as ( -- 上周
select  distinct asin ,site ,list_level as mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,lst_2 as (  -- w-2周
select  distinct asin ,site ,list_level as mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,lst_3 as ( -- w-3周
select  distinct asin ,site ,list_level as mark_3 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)

, res as (
    select '${StartDay}', t.Department as  dep2  ,t.asin ,t.site ,tmp.spu ,WEEKOFYEAR('${StartDay}')+1 , '潜力' as list_level
     , concat(ifnull(mark_1,'无'),'-',ifnull(mark_2,'无'),'-',ifnull(mark_3,'无'))  as old_list_level
     , case when tmp.asin is not null then '在线' else '未在线' end as ListingStatus
	,prod_level ,isnew ,ProductStatus ,ele_name ,now()
    from others t
    left join dep_kbh_product_level s on t.spu = s.spu and s.department = '快百货' and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType , spu from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='正常' and eaal.ListingStatus = 1 group by asin, MarketType , spu
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
    left join ( select spu ,GROUP_CONCAT(name)  as ele_name
    	from ( select distinct eppaea.spu , eppea.name
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id ) t
		group by spu ) tag on t.spu = tag.spu
    left join lst_1 on t.site = lst_1.site  and t.Asin =lst_1.Asin
    left join lst_2 on t.site = lst_2.site  and t.Asin =lst_2.Asin
    left join lst_3 on t.site = lst_3.site  and t.Asin =lst_3.Asin


)

select * from res  ;
