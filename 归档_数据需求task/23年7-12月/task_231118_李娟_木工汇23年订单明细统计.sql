
with
prod as (
select memo as sku ,c1 as boxsku
from manual_table where handlename = '���_ľ����SKU_231118'
)

,res as (
select
Id `��ID`,
left(`SettlementTime`,7)  "�����·�",
`SettlementTime`  "����ʱ��",
`PayTime` "����ʱ��",
date(PayTime) "��������",
OrderNumber `ϵͳ������`,
`PlatOrderNumber`"ƽ̨������",
`OrderStatus` "����״̬",
wo.product_spu as spu ,
wo.product_sku as sku ,
wo.`BoxSku` "boxsku",
Product_Name  `��Ʒ����`,
`SellerSku`  "����SKU",
`Asin`,
`shopcode`"����",
  `SalePlatform` "����ƽ̨",
  `OrderCountry`  "��������",
  `ShipWarehouse` "�����ֿ�",
  `TransportType`  "���䷽ʽ",
  `ShipMethod` "������ʽ",
  `GroupSku` "���SKU",
  `GroupSkuNumber` "���SKU����",
    `Currency` "��������",
TransactionType `��������`,
  `TotalGross` "������",
  `TotalProfit`  "������",
  `TotalExpend` "��֧��",
  `SaleCount` "��������",
  `SalePrice` "��Ʒ�ۼ�",
  `ModifyCount` "�޸�����",
  `OrderTotalPrice`  "�����ܽ�ԭ�ң�",
   `ExchangeRMB`  "ԭ�Ҷ�����һ���",
  `ExchangeUSD` "��Ԫ������һ���",
  `FeePrice`  "�˷�",
  `SalesGross`  "��������",
  `FeeGross`  "�˷�����",
  `RefundAmount`  "�˿���",
  `PromotionalDiscounts`  "�����ۿ�",
  `OtherGross` "��������",
  `TradeCommissions`  "����Ӷ��",
  `FBAFee`  "FBA������",
  `OtherExpend`  "ƽ̨����֧��",
  `AdvertisingCosts` "������",
  `PurchaseCosts`  "�ɹ��ɱ�",
  `LocalFreight` "���ز��˷�",
  `OverseasDeliveryFee` "����������˷�",
  `HeadFreight`  "ͷ���˷�",
  `RateDiscount` "��������",
  `PackageCosts`  "��װ�ɱ�",
  `SubsidyAdjustment`  "��������",
  `SellVat`  "����VAT",
  `WarehouseCosts`  "�ֿ����ɱ����Զ�������",
  `OtherExpenseCosts`  "�������óɱ����Զ�������",
  `TaxGross`  "˰������",
  `DeductTaxes`  "�۳��ͻ�֧��˰��",
  `ManualImportCharges`  "�˹��������",
  `memo`  "�ͻ���ע",
    date(product_DevelopLastAuditTime) as ��Ʒ��������
from import_data.wt_orderdetails wo
join prod on wo.Product_Sku =prod.sku
where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
)

select * from res
