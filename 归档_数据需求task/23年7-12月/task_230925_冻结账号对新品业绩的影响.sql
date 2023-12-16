-- 冻结账号终审时间在7月以后 且 出过单 的商品listing清单


SELECT
    CompanyCode
    ,SellUserName 销售人员
    ,wo.AccountCode 账号简码
    ,wo.site
    ,Product_SPU spu
    ,Product_Sku sku
    ,wo.boxsku boxsku
    ,asin
    ,sum(SaleCount) 7月至今销量
    ,count(distinct PlatOrderNumber) 7月至今订单量
    ,round(sum(TotalGross/ExchangeUSD) , 2)  7月至今销售额
FROM wt_orderdetails wo
-- join view_kbp_new_products vknp on wo.Product_Sku = vknp.sku
join wt_store ws on wo.shopcode =ws.code and SettlementTime >= '2023-07-01' and SettlementTime < '2023-09-25' and IsDeleted = 0
and ws.CompanyCode in (
'ZA',
'QY',
'SD',
'SJ',
'VV',
'XT',
'PN',
'OP',
'CY',
'SG',
'ER',
'YE',
'OU',
'OU',
'MP',
'YD',
'SI',
'SH',
'NG',
'NO',
'NF'
)
group by CompanyCode
    ,SellUserName
    ,wo.AccountCode
    ,wo.site
    ,Product_SPU
    ,Product_Sku
    ,wo.boxsku
    ,asin
order by CompanyCode
    ,SellUserName
    ,wo.AccountCode
    ,wo.site
    ,Product_SPU
    ,Product_Sku
    ,wo.boxsku
    ,asin
