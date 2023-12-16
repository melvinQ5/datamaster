-- 个人粒度 的链接删除相关部分未修改完毕

WITH ratio AS (
SELECT
    left(`firstday`,7) AS `RatioMonth`,
    max(`usdratio`) AS `usdratio`
FROM
    `default_cluster:import_data`.`Basedata`
WHERE
    `reporttype` = '月报'
GROUP BY
    left(`firstday`,
    7)
)

, pass_orders AS (
SELECT
    `OrderNumber` AS `OrderNumber`,
    `SettleMonth` AS `SettleMonth`
FROM
    (
    SELECT
        `OrderNumber` AS `OrderNumber`,
        left(`SettlementTime`,
        7) AS `SettleMonth`,
        group_concat(`TransactionType`) AS `alltype`
    FROM
        `default_cluster:import_data`.`OrderProfitSettle`
    WHERE
        `OrderStatus` = '作废'
    GROUP BY
        `OrderNumber`,
        left(`SettlementTime`,7)) tmp
WHERE
    `alltype` IN ('付款', '其他')
)

, al as ( # 回溯数据时部分链接被删除，部分误删链接再次恢复刊登时间改变，因此有以下操作
select count(1)
from (
select  eaal.Id ,eaal.SellerSKU, eaal.ShopCode 
	,ifnull(eaald.PublicationDate ,eaal.PublicationDate) as PublicationDate
	,eaal.sku ,eaal.ProductSalesName  
from import_data.erp_amazon_amazon_listing eaal 
left join import_data.erp_amazon_amazon_listing_delete eaald 
on eaal.SellerSKU = eaald.SellerSKU and eaal.ShopCode = eaald.ShopCode 
and eaal.ASIN = eaald.ASIN 
and DATE_FORMAT(eaald.PublicationDate,"%Y%m") = '${theMonth}'
union 
select  Id ,SellerSKU, ShopCode ,PublicationDate ,sku ,ProductSalesName  from import_data.erp_amazon_amazon_listing_delete eaald 
)

    
select  
-- eaal.Id ,eaal.SellerSKU, eaal.ShopCode 
-- 	,ifnull(eaald.PublicationDate ,eaal.PublicationDate) as PublicationDate
-- 	,eaal.sku ,eaal.ProductSalesName  
	count(*)
from erp_amazon_amazon_listing eaal 
left join erp_amazon_amazon_listing_delete eaald 
on eaal.SellerSKU = eaald.SellerSKU and eaal.ShopCode = eaald.ShopCode
where eaald.PublicationDate is not null 

-- , order_res AS (
SELECT
    `department` AS `department`,
    NodePathName,
    `ProductSalesName` AS `ProductSalesName`,
    `PublicatMonth` AS `PublicatMonth`,
    `SettleMonth` AS `SettleMonth`,
    count(DISTINCT (`OrderNumber`)) AS `orders_cnt`,
    round(sum(`sales` / `usdratio`), 0) AS `sales_rmb`,
    round(sum(`profit` / `usdratio`), 0) AS `profit_rmb`,
    count(DISTINCT (concat(`ShopIrobotId`, `SellerSku`))) AS `od_list_cnt`,
    count(DISTINCT (`boxsku`)) AS `od_sku_cnt`
FROM
    (
    SELECT
        `s`.`department` AS `department`,
        s.NodePathName,
        `al`.`ProductSalesName` AS `ProductSalesName`,
        `op`.`ShopIrobotId` AS `ShopIrobotId`,
        left(`PublicationDate`,7) AS `PublicatMonth`,
        left(`SettlementTime`,7) AS `SettleMonth`,
        `op`.`OrderNumber` AS `OrderNumber`,
        `op`.`SellerSku` AS `SellerSku`,
        `op`.`boxsku` AS `boxsku`,
        sum(`income`) AS `sales`,
        sum(`GrossProfit`) AS `profit`
    FROM
        `default_cluster:import_data`.`OrderProfitSettle` op
    INNER JOIN import_data.mysql_store s ON
        `s`.`Code` = `op`.`ShopIrobotId`
    INNER JOIN al ON
        (`al`.`SellerSKU` = `op`.`SellerSku`)
            AND (`op`.`ShopIrobotId` = `al`.`ShopCode`)
    LEFT OUTER JOIN `pass_orders` po ON
        (`op`.`OrderNumber` = `po`.`OrderNumber`)
            AND (left(`op`.`SettlementTime`,
            7) = `po`.`SettleMonth`)
    WHERE
        (((`po`.`OrderNumber` IS NULL)
            AND (`al`.`PublicationDate` > '2022-01-01 00:00:00'))
            AND (NOT (`al`.`SellerSKU` REGEXP '-BJ-|-BJ|BJ-')))
            AND (`al`.`sku` != '')
            and DATE_FORMAT(al.PublicationDate,"%Y%m") <= DATE_FORMAT(op.SettlementTime ,"%Y%m")
        GROUP BY
            `s`.`department`,s.NodePathName,`al`.`ProductSalesName`,`op`.`ShopIrobotId`,left(`PublicationDate`,7),left(`SettlementTime`,7),
            `op`.`OrderNumber`,`op`.`SellerSku`,`op`.`boxsku`
	) tmp
INNER JOIN `ratio` r ON
    `r`.`RatioMonth` = `tmp`.`SettleMonth`
GROUP BY
    `department`,NodePathName,
    `ProductSalesName`,
    `PublicatMonth`,
    `SettleMonth`
    )
    
, list_res AS (
SELECT
    `s`.`department` AS `department`,
    `al`.`ProductSalesName` AS `ProductSalesName`,
    left(`PublicationDate`,7) AS `PublicatMonth`,
    count(DISTINCT (`al`.`id`)) AS `list_listing_cnt`,
    count(DISTINCT (`al`.`sku`)) AS `list_sku_cnt`
FROM
     al
INNER JOIN `default_cluster:import_data`.`mysql_store` s ON
    `s`.`Code` = `al`.`ShopCode`
WHERE
    ((`PublicationDate` > '2022-01-01 00:00:00')
        AND (NOT (`al`.`SellerSKU` REGEXP '-BJ-|-BJ|BJ-')))
        AND (`al`.`sku` != '')
    GROUP BY
        `s`.`department`,
        `al`.`ProductSalesName`,
        left(`PublicationDate`,7)
)
        
, report_set AS (
SELECT
    `or1`.`department` AS `department`,
    `or1`.`ProductSalesName` AS `ProductSalesName`,
    NodePathName,
    `or1`.`PublicatMonth` AS `PublicatMonth`,
    `or1`.`SettleMonth` AS `SettleMonth`,
    `or1`.`orders_cnt` AS `orders_cnt`,
    `or1`.`sales_rmb` AS `sales_rmb`,
    `or1`.`profit_rmb` AS `profit_rmb`,
    `or1`.`od_list_cnt` AS `od_list_cnt`,
    `or1`.`od_sku_cnt` AS `od_sku_cnt`,
    `lr`.`list_listing_cnt` AS `list_listing_cnt`,
    `lr`.`list_sku_cnt` AS `list_sku_cnt`
FROM
    `order_res` or1
LEFT OUTER JOIN `list_res` lr ON
    ((`or1`.`department` = `lr`.`department`)
        AND (`or1`.`ProductSalesName` = `lr`.`ProductSalesName`))
        AND (`or1`.`PublicatMonth` = `lr`.`PublicatMonth`)
)


SELECT
    CASE
        WHEN `department` = '销售一部' THEN 'GM-销售1部'
        WHEN `department` = '销售二部' THEN 'PM-销售2部'
        WHEN `department` = '销售三部' THEN 'PM-销售3部'
    END AS `销售部门`,
    concat(department,right(NodePathName,2)) as `销售小组`,
    `ProductSalesName` AS `销售人员`,
    `PublicatMonth` AS `上架月份`,
    `SettleMonth` AS `出单月份`,
    `orders_cnt` AS `当月订单数`,
    `sales_rmb` AS `当月销售额usd`,
    `profit_rmb` AS `当月利润额usd`,
    round(`sales_rmb` / `orders_cnt`, 0) AS `客单价`,
    round(`profit_rmb` / `sales_rmb`, 4) AS `利润率`,
    `list_listing_cnt` AS `刊登listing数`,
    `od_list_cnt` AS `出单listing数`,
    round(`od_list_cnt` / `list_listing_cnt`, 4) AS `listing出单率`,
    `list_sku_cnt` AS `刊登SKU数`,
    `od_sku_cnt` AS `出单SKU数`,
    round(`od_sku_cnt` / `list_sku_cnt`, 4) AS `SKU出单率`,
    round(`list_listing_cnt` / `list_sku_cnt`, 1) AS `每SKU平均listing数`
FROM
    `report_set`
where SettleMonth in ('2022-10','2022-11')