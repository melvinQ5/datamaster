select


`FirstDay` as "��Ӧͳ���ڵĵ�һ��",
`ReportType` as "��������",
case when Team = '��ٻ�һ��' then '��ٻ��ɶ�' when Team = '��ٻ�����' then '��ٻ�Ȫ��' else  Team end as "�Ŷ�",
`Staff` as "��Ա",
`Year` as "ͳ�����",
`Month` as "ͳ���·�",
`Week` as "ͳ���ܴ�",
`TotalGross` as "���۶�",
`TotalProfit` as "�����",
`ProfitRate` as "ë����",
OriProfitRate as `�ҵ�������`,
`AdSpendRate` as "��滨��ռ��",
`RefundRate` as "�˿���",
`FeeGrossRate` as "�˷�����ռ��",
`ProfitRate` - ifnull(`FeeGrossRate`,0) as `���˷�ë����`,
`BadDebtAmount` as "���˽��",
round(BadDebtAmount/TotalGross,4) as `������`,
NumberOfTeam as `�Ŷ�����`,
ProfitPerformance as `�������Ч`,

-- ��Ʒ���ָ��
`SpuSaleCntIn30d` as "��30�춯��SPU��",
`SpuUnitSaleIn30d` as "��Ʒ��SPU����",
ifnull(TopSaleSpuCnt,0) +  ifnull(HotSaleSpuCnt,0) as `������SPU��`,
`TopSaleSpuCnt` as "����SPU��",
`HotSaleSpuCnt` as "����SPU��",
`SpuSaleCntIn30d`  - ifnull(`TopSaleSpuCnt`,0) - ifnull(`HotSaleSpuCnt`,0)  `�Ǳ�������Ʒ��`,
ifnull(TopSaleSpuCnt_NewAdd,0) + ifnull(HotSaleSpuCnt_NewAdd,0) as `������������`,
TopSaleSpuCnt_NewAdd as `����������`,
HotSaleSpuCnt_NewAdd as `����������`,

round ( (ifnull(ALstCnt,0) + ifnull(SLstCnt,0) ) / ( ifnull(TopSaleSpuCnt,0) +  ifnull(HotSaleSpuCnt,0) ) ,2) as `������ƽ��SA������`,
round( ( TopSaleSpuCnt*TopSaleSpuValue + HotSaleSpuCnt*HotSaleSpuValue ) / ( TopSaleSpuCnt + HotSaleSpuCnt ) ,2)  AS `�������`,
`TopSaleSpuValue` as "�����",
`HotSaleSpuValue` as "�����",
UnderHotSaleSpuValue as �Ǳ������,
`TopSaleSpuAmount` + `HotSaleSpuAmount` as "����������۶�",
ifnull(`TopSaleSpuRate`,0) + IFNULL(`HotSaleSpuRate`,0) as "����������۶�ռ��",
`TopSaleSpuRate` as "����SPU�������۶�ռ��",
`HotSaleSpuRate` as "����SPU�������۶�ռ��",
1-(`TopSaleSpuRate` + `HotSaleSpuRate`) as `�Ǳ���������۶�ռ��`,


-- ��Ʒ���ָ��
`SaleAmountIn90dDev` as "��Ʒ���۶�",  -- key���������Ŷ�
round(SaleAmountIn90dDev/TotalGross,4) as `��Ʒ���۶�ռ��`, --
HotSaleSpuAmountIn3m + TopSaleSpuAmountIn3m as ��Ʒ���������۶�,
round( (ifnull(HotSaleSpuAmountIn3m,0) + ifnull(TopSaleSpuAmountIn3m,0) ) /SaleAmountIn90dDev,4)  as ��Ʒ���������۶�ռ��,
ifnull(TopSaleSpuCntIn90dDev,0) + ifnull(HotSaleSpuCntIn90dDev,0) as `��Ʒ������SPU��`,
TopSaleSpuCntIn90dDev_DevbySelf as ��Ʒ����SPU��_�����ſ���,
HotSaleSpuCntIn90dDev_DevbySelf as ��Ʒ����SPU��_�����ſ���,
ifnull(TopSaleSpuCntIn90dDev_DevbySelf,0) + ifnull(HotSaleSpuCntIn90dDev_DevbySelf,0) as `��Ʒ������SPU��_�����ſ���`,
round( ( TopSaleSpuCntIn90dDev*TopSaleSpuValueIn30dDev + HotSaleSpuCntIn90dDev*HotSaleSpuValueIn30dDev ) / ( TopSaleSpuCntIn90dDev + HotSaleSpuCntIn90dDev ) ,2)  AS `��Ʒ�������`,


round( ifnull(HotSaleSpuAmountIn3m,0)  /SaleAmountIn90dDev,4)  as ��Ʒ�������۶�ռ��,
round( ifnull(TopSaleSpuAmountIn3m,0)  /SaleAmountIn90dDev,4)  as ��Ʒ�������۶�ռ��,
round( (`SaleAmountIn90dDev`  - ifnull(HotSaleSpuAmountIn3m,0) - ifnull(TopSaleSpuAmountIn3m,0) )/SaleAmountIn90dDev,4)  as ��Ʒ�Ǳ��������۶�ռ��,

`TopSaleSpuCntIn90dDev` as "��Ʒ����SPU��", -- key���������Ŷ�
`HotSaleSpuCntIn90dDev` as "��Ʒ����SPU��", -- key���������Ŷ�
SaleSpuCntIn90dDev -  ifnull(TopSaleSpuCntIn90dDev,0) - ifnull(HotSaleSpuCntIn90dDev,0)  as ��Ʒ�Ǳ�����SPU��,
`TopSaleSpuValueIn30dDev` as "��Ʒ�����", -- key���������Ŷ�
`HotSaleSpuValueIn30dDev` as "��Ʒ�����", -- key���������Ŷ�

round( (`SaleAmountIn90dDev`  - ifnull(HotSaleSpuAmountIn3m,0) - ifnull(TopSaleSpuAmountIn3m,0) )/(SaleSpuCntIn90dDev -  ifnull(TopSaleSpuCntIn90dDev,0) - ifnull(HotSaleSpuCntIn90dDev,0) ) ,2)  as ��Ʒ�Ǳ������,
TopSaleSpuCntIn90dDev_NewAdd as `��Ʒ����������`,
HotSaleSpuCntIn90dDev_NewAdd as `��Ʒ����������`,

-- ���۽��ָ��
ifnull(ALstCnt,0) + ifnull(SLstCnt,0)  as `SA������` ,
ifnull(BLstCnt,0) + ifnull(CLstCnt,0)  as `��SA������` ,
SALstSaleSpuValue as `SA���ӵ���`,
ifnull(ALstCnt_NewAdd,0) + ifnull(SLstCnt_NewAdd,0)  as SA����������,
`SLstCnt` as "S������",
`ALstCnt` as "A������",
BLstCnt as B������,
CLstCnt as C������,
`SLstSaleSpuValue` as "S���ӵ���",
`ALstSaleSpuValue` as "A���ӵ���",

BLstSaleSpuValue as B���ӵ���,
CLstSaleSpuValue as C���ӵ���,

SLstCnt_NewAdd as S����������,
ALstCnt_NewAdd as A����������,
ifnull(`ALstSaleSpuAmount`,0) + ifnull(`SLstSaleSpuAmount`,0) as "SA���ӱ������۶�",
ifnull(`SLstSaleSpuRate`,0) + ifnull(`ALstSaleSpuRate`,0) as "SA���ӱ������۶�ռ��",
1 - ifnull(`SLstSaleSpuRate`,0) - ifnull(`ALstSaleSpuRate`,0) as "��SA���ӱ������۶�ռ��",
`SLstSaleSpuRate` as "S���ӱ������۶�ռ��",
`ALstSaleSpuRate` as "A���ӱ������۶�ռ��",
BLstSaleSpuRate  as "B���ӱ������۶�ռ��",
CLstSaleSpuRate as "C���ӱ������۶�ռ��",

-- ��Ӧ��ָ��
`DelayShippedOver10dOrders` as "10��δ����������",
`CreatedPackageIn2dPayRate` as "2��������",
`ShippedIn7dPayRate` as "����7�췢����",

-- ��Ʒ key = ��ٻ�
`SpuSaleRateIn7dDev` as "����7��SPU������",
`SpuSaleRateIn14dDev` as "����14��SPU������",
`SpuSaleRateIn30dDev` as "����30��SPU������",
`SpuValueIn30dSinceFirstOrd`as "�׵�30��SPU����",
`NewSpuCntIn90dDev` as "��90������SPU��", -- key ��ʾ��Ʒ�Ŷ�
`SaleSpuCntIn90dDev` as "��Ʒ����SPU��", -- key ��ʾ��Ʒ�Ŷ�

`NewAddSpuCnt` as "��Ʒ������",-- ���SPU��  key ��ʾ��Ʒ�Ŷ�
`NewAddSpuCnt` as "���SPU��",-- ���SPU��  key ��ʾ��Ʒ�Ŷ�
round(`NewAddSpuCnt`/4) as "�˾���Ʒ������",-- ���SPU��  key ��ʾ��Ʒ�Ŷ�
`SpuSkuRate` as "��Ʒ�������",-- key ��ʾ��Ʒ�Ŷ�
`StopSkuRateIn30dDev` as "��ƷSKUͣ��SPUռ��", -- key ��ʾ��Ʒ�Ŷ�

-- ������дһ��SQL��ѯ
-- ��Ʒ key = ��ٻ�һ�� �ɶ����� ��ٻ�����
SaleAmountIn90dDev_DevbySelf as ��Ʒ���۶�_�����ſ���,
 SaleSpuCntIn90dDev_DevbySelf as ��Ʒ����SPU��_�����ſ���,


-- ����
`SaleAmount_ele_Yearly`as "�����ۼ����۶�",
`SaleAmountIn90dDev_ele_Yearly` as "������Ʒ�ۼ����۶�",
`SaleAmountBf90dDev_ele_Yearly` as "������Ʒ�ۼ����۶�",

`SaleAmount_ele_monthly` as "���⵱���ۼ����۶�",
`SaleAmountIn90dDev_ele_monthly` as "������Ʒ�����ۼ����۶�",
`SaleAmountBf90dDev_ele_monthly` as "������Ʒ�����ۼ����۶�",
 TopHotSaleRate_ele as "���ⱬ�������۶�ռ��",
`TopSaleSpuCnt_ele` as "����SPU��-����",
`HotSaleSpuCnt_ele` as "����SPU��-����",
`TopSaleSpuValue_ele` as "�����-����",
`HotSaleSpuValue_ele` as "�����-����",
`HotSaleSpuCntIn90dDev_ele` as "��Ʒ����SPU��-����",
`HotSaleSpuCntBf90dDev_ele` as "��Ʒ����SPU��-����",
`TopSaleSpuCntIn90dDev_ele` as "��Ʒ����SPU��-����",
`TopSaleSpuCntBf90dDev_ele` as "��Ʒ����SPU��-����",
`OldSpuCntIn90dDev_ele` as "δ��ͣ������ƷSPU��-����",
`NewDevSpuCnt_ele` as "����SPU��-����",
`SaleSpuCntIn90dDev_ele` as "��Ʒ����SPU��-����",
`SpuSaleRateIn7dDev_ele` as "����7��SPU������-����",
`SpuSaleRateIn14dDev_ele` as "����14��SPU������-����",
`SpuSaleRateIn30dDev_ele` as "����30��SPU������-����",


-- ��Ʒ��Ӫ-��˾
`SpuSaleCntIn30d` as `��30�춯��SPU��`,
`SpuUnitSaleIn30d` as `��30�춯��SPU����`,
 PotentialLevelUpRateIn7d as `��Ǳ��Ʒ7��ɹ���`,
 PotentialLevelUpRateIn14d as `��Ǳ��Ʒ14��ɹ���`,
 PotentialLevelUpRateIn28d as `��Ǳ��Ʒ28��ɹ���`,
`SkuExpoRateIn7dDev` as "����7��SKU�ع���",
`SkuExpoRateIn14dDev` as "����14��SKU�ع���",
`SkuExpoRateIn30dDev` as "����30��SKU�ع���",
`SkuClickRateIn7dDev` as "����7��SKU�����",
`SkuClickRateIn14dDev` as "����14��SKU�����",
`SkuClickRateIn30dDev` as "����30��SKU�����",
`SkuAdSaleRateIn7dDev` as "����7��SKUת����",
`SkuAdSaleRateIn14dDev` as "����14��SKUת����",
`SkuAdSaleRateIn30dDev` as "����30��SKUת����",


-- ������Ӫ����ָ��-��������
`SaleShopCnt` as "����������",
`OnlineLstCnt` as "����������",
`LstSaleRate` as "���Ӷ�����",
`NewLstCnt` as "�¿���������",
`LstCntIn30d` as "��30�쿯��������",
`SpuSaleRateIn7dDev_saleby_cd` as "����7��SPU�ɶ�������",
`SpuSaleRateIn14dDev_saleby_cd` as "����14��SPU�ɶ�������",
`SpuSaleRateIn30dDev_saleby_cd` as "����30��SPU�ɶ�������",
`LstSaleRateIn7d` as "����7�����Ӷ�����",
`LstSaleRateIn14d` as "����14�����Ӷ�����",
`LstSaleRateIn30d` as "����30�����Ӷ�����",
`RoasIn7dLst` as "����7����ROI",
`RoasIn14dLst` as "����14����ROI",
`RoasIn30dLst` as "����30����ROI",
`ExpoRateIn7dLst` as "����7�����ع���",
`ExpoRateIn14dLst` as "����14�����ع���",
`ClickRateIn7dLst` as "����7��������",
`ClickRateIn14dLst` as "����14��������",
`AdSaleRateIn7dLst` as "����7����ת����",
`AdSaleRateIn14dLst` as "����14����ת����",


-- ������Ӫ����ָ�� -Ӫ���ƹ�
`AdSalesRate` as "������۶�ռ��",
`AdOtherSkuSalesRate` as "�ǹ���Ʒ���۶�ռ��",
`ROAS` as "���ROI",
`AdClickRate` as "�������",
`AdSaleRate` as "���ת����",
`AdCoverRate` as "���ӹ��Ͷ����",
`AdExposures` as "����ع���",
`AdClicks` as "�������",
`AvgAdExposures` as "�����ӹ���ع���",
`AvgAdClicks` as "�����ӹ������",
`CPC` as "���CPC",


-- ������Ӫ����ָ��-�ɱ�����
SALstProfitRate as SA����������,
otherLstProfitRate as ��SA����������,
TopHotProfitRate as `������������`,
otherProdProfitRate as `�Ǳ�����������`,
ProfitRate_In90dDev as `��Ʒ������`,
ProfitRate_Bf90dDev as `��Ʒ������`,


-- ������Ӫ����ָ��-���տ���
`SaleAmountIn30dDev` as "��30�������Ʒ���۶�",
`PurchaseOrders` as "�ɹ�����",
`PurchaseIn1dRate` as "�ɹ������µ���",
`RecivedIn5dPurcRate` as "�ɹ�5�쵽����",
`OnTimeDeliveryRate` as "׼ʱ������",
`RecivedIn24hRate` as "�ֿ�24Сʱ�ջ���",
`InstockIn24hRate` as "�ֿ�24Сʱ�����",
`ShippedIn24hRate` as "�ֿ�24Сʱ������",
`InventoryOccupied` as "����ʽ�ռ��",
`InventoryTurnover` as "�����ת����",
`InventorySkuSaleRate` as "���SKU������",
`AdSalesRate_manual` as "�ֶ�������۶�ռ��",
`AvgAdExposuresIn7dLst` as "�����ӿ���7�����ع���",
`NewDevSpuCnt` as "����SPU��",
`NewDevSkuCnt` as "����SKU��",
`SpuCnt` as "��Ʒ��SPU��",
`SkuCnt` as "��Ʒ��SKU��",
`SpuStopCnt` as "ͣ��SPU��",
`FirstSaleSpuCnt` as "�׵�SPU��",
`SALstOfflineSpuRate` as "SA����δ����ռ��",
`TopSaleSpuAmount` as "����SPU�������۶�",
`TopSaleSpuAmountIn3m` as "��Ʒ����SPU�������۶�",
`HotSaleSpuAmount` as "����SPU�������۶�",
`HotSaleSpuAmountIn3m` as "��Ʒ����SPU�������۶�",
`TopHotStopSpuRate` as "������ͣ��SPUռ��",
`SaleLstCnt` as "����������",
`OverShopSkuCnt` as "���ߵ��̳���SKU��"

from ads_ag_kbh_report_weekly
where FirstDay = '${StartDay}' and ReportType ='${ReportType}'
order by  "�Ŷ�";