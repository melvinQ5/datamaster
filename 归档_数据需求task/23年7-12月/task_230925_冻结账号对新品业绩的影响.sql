-- �����˺�����ʱ����7���Ժ� �� ������ ����Ʒlisting�嵥


SELECT
    CompanyCode
    ,SellUserName ������Ա
    ,wo.AccountCode �˺ż���
    ,wo.site
    ,Product_SPU spu
    ,Product_Sku sku
    ,wo.boxsku boxsku
    ,asin
    ,sum(SaleCount) 7����������
    ,count(distinct PlatOrderNumber) 7�����񶩵���
    ,round(sum(TotalGross/ExchangeUSD) , 2)  7���������۶�
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
