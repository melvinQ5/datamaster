
-- 销售额
insert into ads_kbh_report_metrics ( DimensionId ,year ,month ,week ,isdeleted ,wttime ,ReportType,FirstDay,
TotalGross
)

with
sku_refund as ( -- 按产品销售收入占比分摊订单退款
select rf.PlatOrderNumber ,RefundUSDPrice ,wo.Product_Sku ,wo.SalesGross
    ,RefundUSDPrice * ( wo.SalesGross / sum(SalesGross) over (partition by rf.PlatOrderNumber) ) sku_RefundUSDPrice
from (
select PlatOrderNumber ,sum(RefundUSDPrice) RefundUSDPrice
from daily_RefundOrders a
where RefundDate >='${StartDay}' and RefundDate < '${NextStartDay}' and RefundStatus ='已退款'
group by PlatOrderNumber
) rf
left join wt_orderdetails wo on rf.PlatOrderNumber = wo.PlatOrderNumber and wo.IsDeleted=0 and TransactionType ='付款'
-- where rf.PlatOrderNumber = '206-7603264-9688336'
)

,od as ( -- todo wo表中的很多 porduct_sku 为空, 因为该产品在塞盒中创建 未同步到erp ,比如 BoxSKU=1786914 ,在处理新老品、主题非主题时统一归到 老品、非主中，以便保证勾稽关系
select dep2 ,NodePathName
    ,round( TotalGross/ExchangeUSD - ifnull(sku_RefundUSDPrice,0) ,2) TotalGross_usd
    ,case when d.sku is null then '老品' else isnew end isnew
    ,case when d.sku is null then '非主题品' else istheme end istheme
    ,case when d.sku is null then '非高潜品' else ispotenial end ispotenial
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
left join dep_kbh_product_test d on wo.BoxSku = d.boxsku
left join sku_refund sr on wo.PlatOrderNumber=sr.PlatOrderNumber and wo.Product_Sku = sr.Product_Sku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.Department='快百货' and TransactionType = '付款'
)

 ,od_stat as (
select ifnull(coalesce(dep2,NodePathName),'快百货') team
        ,istheme ,isnew ,ispotenial
        ,round( sum( TotalGross_usd ),2 ) as TotalGross_usd -- 订单表收入加回订单表退款金额
from od
group by grouping sets ((istheme ,isnew ,ispotenial),(istheme ,isnew ,ispotenial,dep2),(istheme ,isnew ,ispotenial,nodepathname))
)


select
    concat(team ,isnew)
     ,year('${StartDay}') , 0 ,weekofyear('${StartDay}')+1 ,0 ,now() ,'周报' ,'${StartDay}'
    ,sum( TotalGross_usd )
from od_stat group by team ,isnew
union all
select
    concat(team ,isnew ,istheme)
     ,year('${StartDay}') , 0 ,weekofyear('${StartDay}')+1 ,0 ,now() ,'周报' ,'${StartDay}'
    ,sum( TotalGross_usd )
from od_stat group by team ,isnew ,istheme
union all
select
    concat(team ,isnew ,ispotenial)
     ,year('${StartDay}') , 0 ,weekofyear('${StartDay}')+1 ,0 ,now() ,'周报' ,'${StartDay}'
    ,sum( TotalGross_usd )
from od_stat group by team ,isnew ,ispotenial
