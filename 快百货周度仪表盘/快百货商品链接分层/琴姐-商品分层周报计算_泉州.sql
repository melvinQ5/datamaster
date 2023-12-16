

With cdtopspu as(-- 计算当周的商品分层
select 'week1' weeknum,spu,date(min(DevelopLastAuditTime))AuditTime
,(case when min(DevelopLastAuditTime)>='2023-04-01' then '新品'end) 新品
, (case when sum((totalgross-FeeGross)/ExchangeUSD)>=1500 then '泉州爆款' 
when  sum((totalgross-FeeGross)/ExchangeUSD)>=500 and  sum((totalgross-FeeGross)/ExchangeUSD)<1500 
then '泉州旺款' when sum((totalgross-FeeGross)/ExchangeUSD)<500 then '泉州出单' end) as producttype

,round(sum((totalgross)/ExchangeUSD),2) sales
,round(sum((totalprofit)/ExchangeUSD),2) profit
,count(distinct platordernumber) orders
,round(sum(feegross/ExchangeUSD),2) freightfee
,round(sum(-RefundAmount),2) refund
,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort
,row_number() over(order by count(distinct platordernumber) desc) as ordersort
,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalgross/ExchangeUSD end),2) weeksales
,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
left join erp_product_products pp on pp.boxsku=wo.boxsku
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货' 
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -30 day) and paytime<'${NextStartDay}' and OrderStatus<>'作废'
and wo.boxsku<>''  and wo.boxsku!='shopfee'
and ms.NodePathName regexp '泉州'
group by spu
order by salesort
)


,cdskumark as(-- 当周商品分层后找出sku，用于链接分层
select pp.boxsku ,pp.sku,cdtopspu.spu, cdtopspu.producttype  from cdtopspu
join erp_product_products pp on pp.spu=cdtopspu.spu
where boxsku is not null
)

,allspu as (-- 统计所有商品分层的数据统计
select '全部' type,IFNULL(producttype,'全部')分层,count(distinct spu)数量,round(sum(sales),2) monthsales
,round(sum(profit),2) monthprofit,round(sum(weeksales),2)weeksales
,round(sum(weekprofit),2)weekprofit,round(sum(sales)/count(distinct spu),2) `产值`
from cdtopspu
group by grouping sets((),(producttype))
order by producttype desc
)

,newspu as(-- 统计新品的商品分层数据统计
select '新品' type,IFNULL(producttype,'全部')分层,count(distinct spu)数量,round(sum(sales),2) monthsales,round(sum(profit),2) monthprofit,round(sum(weeksales),2)weeksales,round(sum(weekprofit),2)weekprofit,round(sum(sales)/count(distinct spu),2) `产值`
from cdtopspu
where 新品 is not null
group by grouping sets((),(producttype))
order by producttype desc
)


,listdetail as (
select wo.asin,wo.site,wo.boxsku,producttype,
round(sum((totalgross)/ExchangeUSD),2) sales,round(sum((totalprofit)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort,row_number() over(order by count(distinct platordernumber) desc) as ordersort,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalgross/ExchangeUSD end),2) weeksales,round(sum (case when paytime>=date_add('${NextStartDay}',interval -7 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货' 
and ms.NodePathName regexp '泉州'
left join cdskumark d on d.boxsku=wo.boxsku
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -30 day) and paytime<'${NextStartDay}' and OrderStatus<>'作废'
and asin<>'' and wo.boxsku <>'' and wo.boxsku!='shopfee'
group by wo.asin,wo.site,wo.boxsku,producttype
order by salesort
)

,listtype as (
select listdetail.*,(case when producttype in('泉州爆款','泉州旺款') and orders/30 >= 5 then 'S' 
when orders/30 >= 1  and producttype in('泉州爆款','泉州旺款') then 'A' 
when orders/30>=0.5 then 'B' else 'C' end) as listtype
from listdetail
-- where producttype is not null
)

,list as(
select '链接'type,ifnull(listtype,'全部链接') 分层,count(distinct concat(asin,site))数量, round(sum(sales),2)monthsales,round(sum(profit),2)monthprofit,round(sum(weeksales),2)weeksales,round(sum(weekprofit),2)weekprofit,round(sum(sales)/count(distinct concat(asin,site)),2) `产值`
from listtype
group by grouping sets((),(listtype))
order by 分层
)

-- ,cal as(-- 统计周报字段
select * from allspu
union all
select * from newspu
union all
select * from list
-- )

-- 计算上个周次的数据
,cdtopspu0 as(-- 计算当周的商品分层
select 'week0' weeknum0,spu,date(min(DevelopLastAuditTime))AuditTime,(case when min(DevelopLastAuditTime)>='2023-04-01' then '新品'end) 新品,  (case when sum((totalgross-FeeGross)/ExchangeUSD)>=1500 then '泉州爆款' when  sum((totalgross-FeeGross)/ExchangeUSD)>=500 and  sum((totalgross-FeeGross)/ExchangeUSD)<1500 
then '泉州旺款' when sum((totalgross-FeeGross)/ExchangeUSD)<500 then '泉州出单' end) as producttype0,round(sum((totalgross)/ExchangeUSD),2) sales,round(sum((totalprofit)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort,row_number() over(order by count(distinct platordernumber) desc) as ordersort,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalgross/ExchangeUSD end),2) weeksales,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
left join erp_product_products pp on pp.boxsku=wo.boxsku
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货' 
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -37 day) and paytime<date_add('${NextStartDay}',interval -7 day) and OrderStatus<>'作废'
and wo.boxsku<>''  and wo.boxsku!='shopfee'
and ms.NodePathName regexp '泉州'
group by spu
order by salesort
)

,cdskumark0 as(-- 当周商品分层后找出sku，用于链接分层
select pp.boxsku ,pp.sku,cdtopspu0.spu, cdtopspu0.producttype0  from cdtopspu0
join erp_product_products pp on pp.spu=cdtopspu0.spu
where boxsku is not null
)

,listdetail0 as (
select wo.asin,wo.site,wo.boxsku,producttype0,
round(sum((totalgross)/ExchangeUSD),2) sales,round(sum((totalprofit)/ExchangeUSD),2) profit,count(distinct platordernumber) orders,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(-RefundAmount),2)refund,count(distinct date(PayTime))solddays,row_number() over(order by sum(totalgross) desc) as salesort,row_number() over(order by count(distinct platordernumber) desc) as ordersort,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalgross/ExchangeUSD end),2) weeksales,round(sum (case when paytime>=date_add('${NextStartDay}',interval -14 day) then totalprofit/ExchangeUSD end),2) weekprofit
from wt_orderdetails wo 
join import_data.mysql_store ms on ms.Code = wo.shopcode and ms.Department ='快百货' 
and ms.NodePathName regexp '泉州'
left join cdskumark0 d on d.boxsku=wo.boxsku
where wo.IsDeleted = 0 and paytime>=date_add('${NextStartDay}',interval -37 day) and paytime<date_add('${NextStartDay}',interval -7 day) and OrderStatus<>'作废'
and asin<>'' and wo.boxsku <>'' and wo.boxsku!='shopfee'
group by wo.asin,wo.site,wo.boxsku,producttype0
order by salesort
)

,listtype0 as (
select listdetail0.*,(case when producttype0 in('泉州爆款','泉州旺款') and orders>=15 then 'S' when orders>=5 and orders<15 and producttype0 in('泉州爆款','泉州旺款') then 'A' when orders>=5 then 'B' when  orders>=1 and orders<5 then 'C' end) as listtype0
from listdetail0
-- where producttype is not null
)

,addallproduct as (
select '新品爆旺款新增'mark, cdtopspu.*from cdtopspu
left join cdtopspu0 on cdtopspu0.spu=cdtopspu.spu and  producttype0 in ('泉州爆款','泉州旺款') 
where producttype0 is null 
and producttype in ('泉州爆款','泉州旺款')

)

,deleteallproduct as( -- 统计2个周次中爆旺款减少
select '新品爆旺款减少'mark,cdtopspu0.* from cdtopspu0
left join cdtopspu on cdtopspu.spu=cdtopspu0.spu and  producttype in ('泉州爆款','泉州旺款') 
where producttype is null 
and producttype0 in ('泉州爆款','泉州旺款')
)
,addspu as( -- 统计2个周次中爆旺款新增
select '爆旺款新增' type,producttype 分层, count(*)数量  from addallproduct
group by producttype
order by  producttype desc
)

,deletespu as( -- 统计2个周次中爆旺款减少
select '爆旺款减少' type,producttype0 分层, count(*)数量  from deleteallproduct
group by producttype0
order by  producttype0 desc
)


,addproduct as (
select '新品爆旺款新增'mark, cdtopspu.*from cdtopspu
left join cdtopspu0 on cdtopspu0.spu=cdtopspu.spu and  producttype0 in ('泉州爆款','泉州旺款') and cdtopspu0.新品 is not null
where producttype0 is null 
and producttype in ('泉州爆款','泉州旺款')
and cdtopspu.新品 is not null
)

,deleteproduct as( -- 统计2个周次中爆旺款减少
select '新品爆旺款减少'mark,cdtopspu0.* from cdtopspu0
left join cdtopspu on cdtopspu.spu=cdtopspu0.spu and  producttype in ('泉州爆款','泉州旺款') and cdtopspu.新品 is not null
where producttype is null 
and cdtopspu0.新品 is not null
and producttype0 in ('泉州爆款','泉州旺款')
)

,addnewspu as( -- 统计2个周次中爆旺款新增
select '新品爆旺款新增' type,producttype 分层, count(*)数量  from addproduct
group by producttype
order by  producttype desc
)

,deletenewspu as( -- 统计2个周次中爆旺款减少
select '新品爆旺款减少' type,producttype0 分层, count(*)数量  from deleteproduct
group by producttype0
order by  producttype0 desc
)

,addlistmark as (
select 'SA新增'mark,listtype.*from listtype
left join listtype0 on listtype.asin=listtype0.asin and listtype.site=listtype0.site and listtype0 in ('S','A')
where listtype0 is null 
and listtype in ('S','A')
)

,reducelistmark as(
select 'SA减少'mark,listtype0.*from listtype0
left join listtype on listtype.asin=listtype0.asin and listtype.site=listtype0.site and listtype in ('S','A')
where listtype is null 
and listtype0 in ('S','A')
)


,addlist as( -- 统计2个周次中SA链接新增
select 'SA链接新增' type,listtype 分层, count(*)数量  from  addlistmark
group by listtype
order by listtype desc
)
,deletelist as( -- 统计2个周次中SA链接减少
select 'SA链接减少' type,listtype0 分层, count(*)数量  from reducelistmark
group by listtype0
order by listtype0 desc
)


-- 统计结果数据
-- select * from addspu
-- union all
-- select * from deletespu
-- union all
-- select * from addnewspu
-- union all
-- select * from deletenewspu
-- union all
-- select * from addlist
-- union all
-- select * from deletelist


-- 统计过程数据
-- select * from addallproduct
-- union all
-- select * from deleteallproduct
-- union all
-- select * from addproduct
-- union all
-- select * from deleteproduct
-- 


-- select * from addlistmark
-- union all
-- select * from reducelistmark
-- 