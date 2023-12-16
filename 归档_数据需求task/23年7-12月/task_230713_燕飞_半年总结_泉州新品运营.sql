/*
 * 主策略：泉州新品运营
 */

with 
wp as (select sku ,spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01' 
    and ProjectTeam = '快百货' )

,r1 as (
select  left('${StartDay}',7) 统计月份
    ,round(sum(TotalGross/ExchangeUSD),2) 新品销售额
    ,round(sum(TotalProfit/ExchangeUSD),2) 新品利润额
    ,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),4) 新品利润率_未扣广告
    ,count(distinct wo.Product_SPU) 新品出单SPU数
    ,round(sum(TotalGross/ExchangeUSD)/count(distinct wo.Product_SPU),4) 新品出单SPU单产
    
    ,round(sum( case when dkpl.spu is not null then  TotalGross/ExchangeUSD end ),2) 新品爆旺款业绩
    ,round(count( distinct case when dkpl.spu is not null then Product_SPU end ),2) 新品爆旺款数
    ,round( sum( case when dkpl.spu is not null then  TotalGross/ExchangeUSD end ) / count( distinct case when dkpl.spu is not null then Product_SPU end ) ,4)   新品爆旺款单产
--     ,count(distinct tag.spu ) 新品出单SPU数_主题
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	from import_data.mysql_store where department regexp '快' )  ms 
	on wo.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
join wp on wo.product_sku = wp.sku -- 23年内终审算新品
left join ( 
	select distinct spu 
	from dep_kbh_product_level
	where FirstDay = '${StartDay}' and Department = '快百货' and prod_level regexp '爆款|旺款' 
	) dkpl on dkpl.spu = wo.Product_SPU 
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
group by left('${StartDay}',7)
)

-- , r2 as (
-- select left('${StartDay}',7) 统计月份
-- 	,count( distinct case when prod_level regexp '爆款|旺款'  then dkpl.spu end ) 新品爆旺款数
-- 	,sum(  case when prod_level regexp '爆款|旺款'  then sales_in30d  end) 新品爆旺款业绩
-- 	,round( sum(  case when prod_level regexp '爆款|旺款' then sales_in30d end) / count(distinct case when prod_level regexp '爆款|旺款' and isnew='新品' then dkpl.spu end),4 ) 新品爆旺款单产
-- from dep_kbh_product_level dkpl
-- join wp on dkpl.spu = wp.spu -- 23年内终审算新品
-- where FirstDay = '${StartDay}' and Department = '快百货泉州'
-- )

,od_list_in30d as ( -- 临时修改泉州链接定义  按累计出单 
select asin,wo.site,Product_SPU as spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- 含退款不含运费
	,round(sum((totalgross)/ExchangeUSD),2) sales_in30d -- 含退款不含运费
	,round(sum((totalprofit)/ExchangeUSD),2) profit_in30d -- 含退款不含运费
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalgross)/ExchangeUSD end),2),0) sales_in7d
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalprofit)/ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- 订单数
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	from import_data.mysql_store where department regexp '快' )  ms 
	on wo.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快' 
group by wo.site,asin,spu,boxsku
)

, list_mark as (
select site
        , t.asin
        , t.spu 
        , t.sales_in30d
        , case
             when list_orders >= 15 and prod_level regexp '爆款|旺款' THEN 'S'
             when list_orders >= 5 and prod_level regexp '爆款|旺款' THEN 'A'
             when list_orders >= 5 THEN 'B'
             when list_orders < 5 AND list_orders >0 THEN 'C' 
             else '散单'
        END as list_level
    from ( select site, asin, spu, sum(orders) list_orders
               , sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
        from od_list_in30d
        group by site, asin, spu ) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '快百货' and FirstDay = '${StartDay}'
    join wp on t.spu = wp.spu -- 23年内终审算新品
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='正常' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
)

, r3 as (
select left('${StartDay}',7)  统计月份
	, count( DISTINCT case when list_level regexp 'S|A' THEN CONCAT(ASIN,Site) END ) 新品SA链接数
	, sum( case when list_level regexp 'S|A' THEN sales_in30d end ) 新品SA链接业绩
from list_mark
)

, r4 as (
select left('${StartDay}',7)  统计月份
	, round(count(distinct part.Product_SPU)/count(distinct entire.Spu),4) `终审14天SPU动销率`
from wp entire
left join ( -- 出单SKU
	select Product_SPU , Product_SKU 
	from (
        select wo.*
        	, case when dep2 = '快百货二部' then Product_SKU end as Product_SPU_sale_by_cd
        from import_data.wt_orderdetails wo
        join (select case when NodePathName regexp '泉州' then '快百货二部'
                when NodePathName regexp '成都' then '快百货一部' end as dep2, *
             from import_data.mysql_store ms where ms.department regexp '快') ms on wo.shopcode = ms.Code
        join import_data.wt_products wp on wp.BoxSku = wo.BoxSku and  date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01'  and ProjectTeam = '快百货' 
        where wo.Department = '快百货' 
            and paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}' and wp.ProjectTeam = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
            and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
        ) t
	group by Product_SPU , Product_SKU 
	) part on entire.Sku = part.Product_SKU
)

, r5 as ( -- 新品链接数
select left('${StartDay}',7)  统计月份
	,round( count(distinct concat(SellerSKU,ShopCode)) / count(distinct wl.sku) ,1 ) 新品sku当月新刊登平均链接数
from import_data.wt_listing wl 
join wp on wl.spu = wp.spu -- 23年内终审算新品
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	from import_data.mysql_store where department regexp '快' )  ms 
	on wl.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
where MinPublicationDate  >= '${StartDay}' and MinPublicationDate < '${NextStartDay}'
)


select r1.* 
	, r3.新品SA链接数 ,r3.新品SA链接业绩 ,r4.终审14天SPU动销率 ,r5.新品sku当月新刊登平均链接数 
from r1 
left join  r3 on r1.统计月份 = r3.统计月份 
left join  r4 on r1.统计月份 = r4.统计月份 
left join  r5 on r1.统计月份 = r5.统计月份 



