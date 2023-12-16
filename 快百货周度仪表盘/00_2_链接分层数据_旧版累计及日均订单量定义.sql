
with od_list_in30d as ( -- site,asin,spu,boxsku 聚合
select wo.site, wo.asin,spu,boxsku ,dep2
    ,sum( sales_no_freight ) sales_no_freight
    ,sum( profit_no_freight -ifnull(AdSpend_in30d,0) ) profit_no_freight
    ,sum( sales_in30d ) sales_in30d
    ,sum( profit_in30d  -ifnull(AdSpend_in30d,0)) profit_in30d
    ,sum( sales_in7d ) sales_in7d
    ,sum( profit_in7d -ifnull(AdSpend_in7d,0) ) profit_in7d
    ,sum( orders ) orders
    ,sum( orders_in14d ) orders_in14d
from
    (
    select asin ,wo.site ,ShopCode ,SellerSku ,Product_SPU as spu ,BoxSku ,dep2
        ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight -- 扣运费扣退款
        ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight -- 扣运费扣广告扣退款
        ,round(sum(totalgross/wo.ExchangeUSD),2) sales_in30d -- 扣退款
        ,round(sum(totalprofit/wo.ExchangeUSD),2) profit_in30d -- 扣广告扣退款
        ,ifnull(round(sum(case when SettlementTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and SettlementTime<'${NextStartDay}' then (totalgross)/wo.ExchangeUSD end),2),0) sales_in7d
        ,ifnull(round(sum(case when SettlementTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and SettlementTime<'${NextStartDay}' then totalprofit/wo.ExchangeUSD end),2),0) profit_in7d
        ,count(distinct PlatOrderNumber) orders -- 订单数
        ,count(distinct case when SettlementTime >=date(date_add('${NextStartDay}',INTERVAL -14 day)) and SettlementTime< '${NextStartDay}' then PlatOrderNumber end ) orders_in14d -- 近14天订单数
    from import_data.wt_orderdetails wo
     join ( select case when NodePathName regexp  '成都' then '快百货成都'  when NodePathName regexp  '泉州' then  '快百货泉州' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms
        on wo.shopcode=ms.Code and SettlementTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
        and TransactionType <> '其他' and wo.asin <>''  and wo.boxsku<>''  and ms.department regexp '快'
    group by asin ,wo.site ,ShopCode ,SellerSku ,Product_SPU ,BoxSku ,dep2
    ) wo
left join (
    select  asin ,ShopCode ,SellerSku
         ,sum(Spend) AdSpend_in30d
         ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and CreatedTime<'${NextStartDay}' then Spend end ) AdSpend_in7d
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快') ms on ad.shopcode=ms.Code
    where CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
    group by asin ,ShopCode ,SellerSku
    ) waad
 on wo.shopcode = waad.ShopCode and wo.SellerSku = waad.SellerSku and wo.asin = waad.asin
group by wo.site, wo.asin,spu,boxsku ,dep2
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
select '${StartDay}', dep2  ,asin ,site ,spu ,WEEKOFYEAR('${StartDay}')+1 ,list_level ,old_list_level ,ListingStatus
	,sales_no_freight ,sales_in30d ,profit_in30d ,sales_in7d  ,profit_in7d ,list_orders
	,prod_level ,isnew ,ProductStatus ,ele_name ,now()
from (select t.site
        , t.asin
        , t.spu
        , t.dep2
        , s.prod_level
        , concat(ifnull(mark_1,'无'),'-',ifnull(mark_2,'无'),'-',ifnull(mark_3,'无'))  old_list_level
        , s.isnew
        , s.ProductStatus
        , tag.ele_name
        , t.sales_no_freight
        , t.sales_in30d
        , t.sales_in7d
        , t.profit_in30d
        , t.profit_in7d
        , t.list_orders
        , case
             when t.sales_no_freight >= 750 and prod_level regexp '爆款|旺款' THEN 'S'
             when t.sales_no_freight >= 250 and prod_level regexp '爆款|旺款' THEN 'A'
             else '其他'
        END as list_level
        , case when tmp.asin is not null then '在线' else '未在线' end as ListingStatus
    from (select site, asin, spu,dep2 , sum(orders) list_orders
               , sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
               , sum(orders_in14d) orders_in14d
        from od_list_in30d
        group by site, asin, spu ,dep2 ) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '快百货' and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='正常' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
    left join ( select spu ,GROUP_CONCAT(name)  as ele_name
    	from ( select distinct eppaea.spu , eppea.name
			from import_data.erp_product_product_associated_element_attributes eppaea
			left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id ) t
		group by spu ) tag on t.spu = tag.spu
    left join lst_1 on t.site = lst_1.site  and t.Asin =lst_1.Asin
    left join lst_2 on t.site = lst_2.site  and t.Asin =lst_2.Asin
    left join lst_3 on t.site = lst_3.site  and t.Asin =lst_3.Asin
) tmp
where list_level is not null and dep2 is not null
)


select * from res  ;

