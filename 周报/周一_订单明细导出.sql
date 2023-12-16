with res as (
select
Id `��ID`,
TransactionType `��������`,
left(`SettlementTime`,7)  "�����·�",
case when TransactionType='����' and left(SellerSku,10)='ProductAds' then TotalExpend end  `�������Ͷ�Ӧ�۳����̷���`,
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
ms.AccountCode "������Դ",
ms.nodepathname `����С��`,
  `SalePlatform` "����ƽ̨",
  `OrderCountry`  "��������",
  `ShipWarehouse` "�����ֿ�",
  `TransportType`  "���䷽ʽ",
  `ShipMethod` "������ʽ",
  `GroupSku` "���SKU",
  `GroupSkuNumber` "���SKU����",
  --   `Currency` "��������",
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
join mysql_store ms on wo.shopcode = ms.Code
where PayTime>='${StartDay}' and PayTime<'${NextStartDay}'  and IsDeleted = 0
-- where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
	and wo.Department = '��ٻ�'
)

select * from res



