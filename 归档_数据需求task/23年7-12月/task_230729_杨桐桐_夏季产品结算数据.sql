
with 
ele as ( 
select eppaea.sku ,group_concat(eppea.name) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.name = '夏季'
group by eppaea.sku 
)


, od as (
select wo.BoxSku
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) 近7天销量
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) 近14天销量
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) 近21天销量
     ,SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then SaleCount end ) 近28天销量

     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2) 近7天销售额
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2) 近14天销售额
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2) 近21天销售额
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then TotalGross/ExchangeUSD end ),2)
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) 近7天利润额
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) 近14天利润额
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) 近21天利润额
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) 近28天利润额

     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 7 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) 近7天利润率
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 14 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) 近14天利润率
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 21 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) 近21天利润率
     ,round(SUM( case when SettlementTime >=date_add('${NextStartDay}',interval - 28 day ) and SettlementTime< '${NextStartDay}' then TotalProfit/TotalGross end ),2) 近28天利润率
    from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code
and SettlementTime  >= date_add('${NextStartDay}',interval - 90 day ) and SettlementTime < '${NextStartDay}' and wo.IsDeleted=0
    and asin <>'' and ms.department regexp '快'
    and FeeGross = 0
group by  wo.BoxSku
)

-- 夏季

select wp.sku ,wp.ProductName ,ele.ele_name ,od.*
from wt_products wp
join ele  on wp.sku =ele.sku
left join od on od.BoxSku =wp.BoxSku


-- 非夏季  7月29日查询
/*
select wp.sku ,wp.ProductName ,ele.ele_name ,od.*
-- select count(1)
from wt_products wp
left join ele  on wp.sku =ele.sku
left join od on od.BoxSku =wp.BoxSku
where ele.sku is null and wp.ProjectTeam='快百货' and wp.IsDeleted= 0 and ProductStatus !=2

 */