
with
prod as (
select memo as sku ,c1 as boxsku
from manual_table where handlename = '李娟_木工汇SKU_231118'
)

,res as (
select
Id `表ID`,
left(`SettlementTime`,7)  "结算月份",
`SettlementTime`  "结算时间",
`PayTime` "付款时间",
date(PayTime) "付款日期",
OrderNumber `系统订单号`,
`PlatOrderNumber`"平台订单号",
`OrderStatus` "订单状态",
wo.product_spu as spu ,
wo.product_sku as sku ,
wo.`BoxSku` "boxsku",
Product_Name  `产品名称`,
`SellerSku`  "渠道SKU",
`Asin`,
`shopcode`"店铺",
  `SalePlatform` "销售平台",
  `OrderCountry`  "订单国家",
  `ShipWarehouse` "发货仓库",
  `TransportType`  "运输方式",
  `ShipMethod` "发货方式",
  `GroupSku` "组合SKU",
  `GroupSkuNumber` "组合SKU数量",
    `Currency` "订单币种",
TransactionType `交易类型`,
  `TotalGross` "总收入",
  `TotalProfit`  "总利润",
  `TotalExpend` "总支出",
  `SaleCount` "销售数量",
  `SalePrice` "产品售价",
  `ModifyCount` "修改数量",
  `OrderTotalPrice`  "订单总金额（原币）",
   `ExchangeRMB`  "原币对人民币汇率",
  `ExchangeUSD` "美元对人民币汇率",
  `FeePrice`  "运费",
  `SalesGross`  "销售收入",
  `FeeGross`  "运费收入",
  `RefundAmount`  "退款金额",
  `PromotionalDiscounts`  "促销折扣",
  `OtherGross` "其他收入",
  `TradeCommissions`  "交易佣金",
  `FBAFee`  "FBA操作费",
  `OtherExpend`  "平台其他支出",
  `AdvertisingCosts` "广告费用",
  `PurchaseCosts`  "采购成本",
  `LocalFreight` "本地仓运费",
  `OverseasDeliveryFee` "海外仓派送运费",
  `HeadFreight`  "头程运费",
  `RateDiscount` "汇率折损",
  `PackageCosts`  "包装成本",
  `SubsidyAdjustment`  "补贴调整",
  `SellVat`  "销售VAT",
  `WarehouseCosts`  "仓库管理成本（自定义费用项）",
  `OtherExpenseCosts`  "其它费用成本（自定义费用项）",
  `TaxGross`  "税费收入",
  `DeductTaxes`  "扣除客户支付税费",
  `ManualImportCharges`  "人工导入费用",
  `memo`  "客户备注",
    date(product_DevelopLastAuditTime) as 产品终审日期
from import_data.wt_orderdetails wo
join prod on wo.Product_Sku =prod.sku
where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
)

select * from res
