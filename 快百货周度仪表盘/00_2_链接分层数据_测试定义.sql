/*
 成都链接分层定义是：
S = 按近30天统计爆款或旺款的产品，该产品所有出单链接中，累计订单数 大于等于15单的链接
A = 按近30天统计爆款或旺款的产品，该产品所有出单链接中，累计订单数 5-14单 的链接
B = SA链接之外的其他累计订单数 5-14单 的链接
C = SAB链接之外的其他累计订单数 0-4单 的链接
（把近30天出单链接全部分完）


泉州 调整后 链接分层定义是：
S = 按近30天统计爆款或旺款的产品，该产品所有出单链接中，日均订单数 大于等于5单的链接
A = 按近30天统计爆款或旺款的产品，该产品所有出单链接中，日均订单数 1-4单 的链接
B = 按近30天统计爆款或旺款的产品，该产品所有出单链接中，日均订单数 0.5-1单 的链接
C = 按近30天统计爆款或旺款的产品，该产品所有出单链接中，除开SAB外所有出单链接
（即只把爆款、旺款产品的所有出单链接分完，未把近30天非爆旺款出单产品的链接分完）
 */



-- 生成 快百货成都的SA链接 （订单数筛选定义不同于成都 ， 爆旺款是用整体快百货的）
insert into dep_kbh_listing_level (`FirstDay`,`Department` , `asin`, `site`,`Week`,
	list_level ,ListingStatus ,sales_no_freight,sales_in30d ,profit_in30d ,sales_in7d ,profit_in7d ,list_orders ,wttime)
with od_list_in30d as ( -- site,asin,spu,boxsku 聚合
select asin,wo.site,Product_SPU as spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- 含退款不含运费
	,round(sum((totalgross)/ExchangeUSD),2) sales_in30d -- 含退款不含运费
	,round(sum((totalprofit)/ExchangeUSD),2) profit_in30d -- 含退款不含运费
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalgross)/ExchangeUSD end),2),0) sales_in7d
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalprofit)/ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- 订单数
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'and  NodePathName regexp '成都'
group by wo.site,asin,spu,boxsku
)

select '${StartDay}','快百货成都测试1' ,asin ,site ,WEEKOFYEAR('${StartDay}')+1 ,list_level ,ListingStatus ,sales_no_freight,sales_in30d ,sales_in7d  ,list_orders ,now()
from (select site
        , t.asin
        , t.sales_no_freight
        , t.sales_in30d
        , t.sales_in7d
        , t.profit_in30d
        , t.profit_in7d 
        , t.list_orders
        , case -- 按日均订单数
             when list_orders/30 >= 5 and prod_level regexp '爆款|旺款' THEN 'S'
             when list_orders/30 >= 1 and prod_level regexp '爆款|旺款' THEN 'A'
             when list_orders/30 >= 0.5 and prod_level regexp '爆款|旺款' THEN 'B'
             when list_orders/30 >0 and prod_level regexp '爆款|旺款' THEN 'C'
            ELSE '散单'
            END as list_level
        , case when tmp.asin is not null then '在线' else '未在线' end as ListingStatus
    from (select site, asin, spu, sum(orders) list_orders
    			, sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
        from od_list_in30d
        group by site, asin, spu) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '快百货'  and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='正常' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
) tmp
where list_level is not null;


-- 生成 快百货泉州的SA链接 （订单数筛选定义不同于成都 ， 爆旺款是用整体快百货的）
insert into dep_kbh_listing_level (`FirstDay`,`Department` , `asin`, `site`,`Week`,
	list_level ,ListingStatus ,sales_no_freight,sales_in30d ,profit_in30d ,sales_in7d ,profit_in7d ,list_orders ,wttime)
with od_list_in30d as ( -- site,asin,spu,boxsku 聚合
select asin,wo.site,Product_SPU as spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- 含退款不含运费
	,round(sum((totalgross)/ExchangeUSD),2) sales_in30d -- 含退款不含运费
	,round(sum((totalprofit)/ExchangeUSD),2) profit_in30d -- 含退款不含运费
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalgross)/ExchangeUSD end),2),0) sales_in7d
	,ifnull(round(sum(case when PayTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and PayTime<'${NextStartDay}' then (totalprofit)/ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- 订单数
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0
	and TransactionType <> '其他'  and asin <>'' and ms.department regexp '快'and  NodePathName regexp '泉州'
group by wo.site,asin,spu,boxsku
)

select '${StartDay}','快百货泉州测试1' ,asin ,site ,WEEKOFYEAR('${StartDay}')+1 ,list_level ,ListingStatus ,sales_no_freight,sales_in30d ,sales_in7d  ,list_orders ,now()
from (select site
        , t.asin
        , t.sales_no_freight
        , t.sales_in30d
        , t.sales_in7d
        , t.profit_in30d
        , t.profit_in7d
        , t.list_orders
        , case -- 按日均订单数
             when list_orders/30 >= 5 and prod_level regexp '爆款|旺款' THEN 'S'
             when list_orders/30 >= 1 and prod_level regexp '爆款|旺款' THEN 'A'
             when list_orders/30 >= 0.5 and prod_level regexp '爆款|旺款' THEN 'B'
             when list_orders/30 >0 and prod_level regexp '爆款|旺款' THEN 'C'
            ELSE '散单'
            END as list_level
        , case when tmp.asin is not null then '在线' else '未在线' end as ListingStatus
    from (select site, asin, spu, sum(orders) list_orders
    		, sum(sales_no_freight) sales_no_freight
               , sum(sales_in30d) sales_in30d
               , sum(sales_in7d) sales_in7d
               , sum(profit_in30d) profit_in30d
               , sum(profit_in7d) profit_in7d
        from od_list_in30d
        group by site, asin, spu) t
    join dep_kbh_product_level s on t.spu = s.spu and s.department = '快百货'  and FirstDay = '${StartDay}'
    left join (
        select asin, MarketType from erp_amazon_amazon_listing eaal
        join mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus='正常' and eaal.ListingStatus = 1 group by asin, MarketType
        ) tmp on t.asin = tmp.ASIN and t.Site = tmp.MarketType
) tmp
where list_level is not null;

