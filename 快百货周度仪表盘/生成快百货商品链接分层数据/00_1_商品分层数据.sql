/*
230721版
商品分层定义是：将近30天出单商品全部分完，分成
爆款 = 按近30天出单的产品中，不含运费金额大于等于1500usd的SPU
旺款 = 按近30天出单的产品中，不含运费金额大于等于500usd的SPU
潜力 = 由商品运营人员从非爆旺款中筛选填报
其他 = 爆|旺|潜力之外的其他的出单产品
 */

-- 生成数据
-- 生成 Department = 快百货

insert into dep_kbh_product_level (`FirstDay`,Department, `SPU`,isdeleted , `Week`,
	prod_level  ,ProductStatus ,sales_no_freight
	,profit_no_freight
	,AdSpend_in30d ,sales_in30d ,profit_in30d
	,AdSpend_in7d ,sales_in7d ,profit_in7d
	,isnew ,markdate ,wttime)
with
od_list_in30d_pay as ( -- 付款数据
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku
    ,round(sum((totalgross-feegross)/wo.ExchangeUSD),2) sales_no_freight
    ,round(sum((totalprofit-feegross)/wo.ExchangeUSD) , 2) profit_no_freight
    ,round(sum(totalgross/wo.ExchangeUSD),2) sales_in30d
    ,round(sum(totalprofit/wo.ExchangeUSD),2) profit_in30d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then (totalgross)/wo.ExchangeUSD end),2),0) sales_in7d
    ,ifnull(round(sum(case when paytime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and paytime<'${NextStartDay}' then totalprofit/wo.ExchangeUSD end),2),0) profit_in7d
    ,count(distinct PlatOrderNumber) orders -- 订单数
    ,count(distinct case when paytime >=date(date_add('${NextStartDay}',INTERVAL -14 day)) and paytime< '${NextStartDay}' then PlatOrderNumber end ) orders_in14d -- 近14天订单数
from import_data.wt_orderdetails wo join mysql_store ms on wo.shopcode=ms.Code
and PayTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and PayTime < '${NextStartDay}' and ms.department regexp '快'
and wo.IsDeleted = 0 and TransactionType = '付款'  and wo.asin <>'' and wo.boxsku<>''
group by wo.site, wo.asin,spu,boxsku
)

,od_list_in30d_refund as ( -- 退款数据
select wo.site, wo.asin ,Product_SPU as spu ,BoxSku
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refund
     ,abs(round(sum( case when SettlementTime >=date_add('${NextStartDay}', INTERVAL -7 DAY) and SettlementTime< date_add('${NextStartDay}', INTERVAL -0 DAY)  then RefundAmount/ExchangeUSD end ),2)) refund_in7d
from wt_orderdetails wo join mysql_store  ms on ms.code=wo.shopcode
and SettlementTime >= date(date_add('${NextStartDay}',INTERVAL -30 day)) and SettlementTime < '${NextStartDay}' and ms.department regexp '快'
and wo.IsDeleted = 0 and TransactionType = '退款'  and wo.asin <>''  and wo.boxsku<>''
group by wo.site, wo.asin,spu,boxsku
)

,od_list_in30d as ( -- 出单链接的销售统计
select p.BoxSku ,p.spu ,p.Asin ,p.Site
    ,sales_no_freight - ifnull(refund,0) as sales_no_freight
    ,profit_no_freight - ifnull(refund,0) as profit_no_freight
    ,sales_in30d - ifnull(refund,0) as sales_in30d
    ,profit_in30d - ifnull(refund,0) as profit_in30d
    ,sales_in7d - ifnull(refund_in7d,0) as sales_in7d
    ,profit_in7d - ifnull(refund_in7d,0) as profit_in7d
from od_list_in30d_pay p
left join  od_list_in30d_refund r on p.Site =r.Site and p.asin = r.Asin and p.BoxSku = r.BoxSku
)

, lst_ad_spend as ( -- 刊登链接的广告统计, 聚合到sku粒度才能整体减出
select wl.boxsku
     ,sum(Spend) AdSpend_in30d
     ,sum( case when CreatedTime >=date_add('${NextStartDay}', INTERVAL -7-2 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -2 DAY) then Spend end ) AdSpend_in7d
from ( select sellersku ,shopcode ,boxsku from wt_listing wl join mysql_store ms on wl.shopcode = ms.code and ms.Department = '快百货' group by  sellersku ,shopcode ,boxsku ) wl
join import_data.AdServing_Amazon ad on ad.ShopCode = wl.ShopCode and wl.SellerSKU = ad.SellerSku
    and CreatedTime >=date_add('${NextStartDay}', INTERVAL -30-1 DAY) and CreatedTime< date_add('${NextStartDay}', INTERVAL -1 DAY)
group by wl.boxsku
)

,prod_mark as ( -- 商品分层
select t.spu
	, case when sales_no_freight >=1500 then '爆款' when sales_no_freight>=500 and sales_no_freight<1500 then'旺款'
	else '其他' end as prod_level
    , sales_no_freight
    , profit_no_freight
    , AdSpend_in30d
    , AdSpend_in7d
    , sales_in30d
    , sales_in7d
    , profit_in30d
    , profit_in7d
	, s.ProductStatus
    , isnew
from (
	select
	    spu
       , sum(AdSpend_in30d )  AdSpend_in30d
       , sum(AdSpend_in7d )  AdSpend_in7d
       , sum(sales_no_freight )  sales_no_freight
       , sum(profit_no_freight - ifnull(AdSpend_in30d,0) ) profit_no_freight
       , sum(sales_in30d)       sales_in30d
       , sum(profit_in30d - ifnull(AdSpend_in30d,0) )      profit_in30d
       , sum(sales_in7d)        sales_in7d
       , sum(profit_in7d - ifnull(AdSpend_in7d,0))       profit_in7d
	from (select spu
               , boxsku
               , sum(sales_no_freight)  sales_no_freight
               , sum(profit_no_freight) profit_no_freight
               , sum(sales_in30d)       sales_in30d
               , sum(profit_in30d)      profit_in30d
               , sum(sales_in7d)        sales_in7d
               , sum(profit_in7d)       profit_in7d
          from od_list_in30d
          group by spu, boxsku) oli
	left join lst_ad_spend las on oli.boxsku = las.boxsku
    group by spu
	) t
left join ( select epp.spu
            ,case when ProductStatus = 0 then '正常'
                when ProductStatus = 2 then '停产'
                when ProductStatus = 3 then '停售'
                when ProductStatus = 4 then '暂时缺货'
                when ProductStatus = 5 then '清仓'
                end as ProductStatus
            ,case when new.spu is not null then '新品' else '老品' end isnew
            from import_data.erp_product_products epp
            left join (select distinct spu from view_kbp_new_products) new on epp.spu = new.spu
	where IsDeleted = 0 and ismatrix = 1 and DevelopLastAuditTime is not null
	) s on t.spu = s.spu
)
, res as (
select '${StartDay}' ,'快百货' ,prod_mark.SPU  ,0 as isdeleted ,WEEKOFYEAR('${StartDay}')+1 ,prod_level
    ,ProductStatus
    ,round(sales_no_freight,2) sales_no_freight
    ,round(profit_no_freight,2) profit_no_freight
    ,round(AdSpend_in30d,2) AdSpend_in30d
    ,round(sales_in30d,2) sales_in30d
    ,round(profit_in30d,2) profit_in30d
    ,round(AdSpend_in7d,2) AdSpend_in7d
    ,round(sales_in7d,2) sales_in7d
    ,round(profit_in7d,2) profit_in7d
    ,isnew
    ,'${NextStartDay}' as markdate
    ,now()
from prod_mark
where prod_level is not null and spu is not null )

-- select * from res;
select * from res;

-- select sum(sales_in7d) from res
-- select round(sum(profit_in30d)/sum(sales_in30d),4) from res
-- where prod_level regexp '爆|旺' ;
-- select count(distinct spu) from res where prod_level regexp '爆款|旺款'
-- select sum(sales_in7d) from dep_kbh_product_level where FirstDay='2023-08-07'


