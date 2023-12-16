-- �������ñ�
-- ɾ����
-- import_data.ads_ag_staff_kbh_report_weekly;
-- import_data.ads_staff_kbh_report_weekly;
-- import_data.ads_kbh_staff_stat_weekly;

select * from ads_ag_kbh_report_weekly where FirstDay= '2023-07-01' and ReportType='�±�';

-- ��ձ����أ�״̬���ݣ�
truncate table ads_ag_kbh_report_weekly;
truncate table BadDebtRate;

-- �ȴ�����ʱ�� (AGGREGATE)
CREATE TABLE IF NOT EXISTS 
ads_ag_kbh_report_weekly (
`FirstDay` date NOT NULL COMMENT "��Ӧͳ���ڵĵ�һ��",
`ReportType` varchar(128) NOT NULL COMMENT "��������",
`Team` varchar(64) NOT NULL COMMENT "�Ŷ�",
`Staff` varchar(24) NOT NULL COMMENT "��Ա",
`Year` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "ͳ�����",
`Month` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "ͳ���·�",
`Week` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "ͳ���ܴ�",

`TotalGross` double REPLACE_IF_NOT_NULL NULL  COMMENT "���۶�",
`TotalProfit` double REPLACE_IF_NOT_NULL NULL  COMMENT "�����",
`TotalCost` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ɱ�",
`ProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "ë����",
`OriProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ҵ�ë����",
`AdSpendRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "��滨��ռ��",
`RefundRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�˿���",
`FeeGrossRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�˷�����ռ��",
`BadDebtAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "���˽��",
`BadDebtRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "������",
`NumberOfTeam` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�Ŷ�����",
`ProfitPerformance` double REPLACE_IF_NOT_NULL NULL  COMMENT "�������Ч" ,


`AdSalesRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "���ҵ��ռ��",
`AdSalesRate_manual` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ֶ����ҵ��ռ��",
`AdOtherSkuSalesRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ǹ���Ʒҵ��ռ��",
`ROAS` double REPLACE_IF_NOT_NULL NULL  COMMENT "����������������۶����滨�ѱ�ֵ",
`CPC` double REPLACE_IF_NOT_NULL NULL  COMMENT "��滨������������ֵ",
`AdClickRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�������",
`AdSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "���ת����",
`AdCoverRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "���ӹ��Ͷ����",
`AdClicks` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�������",
`AdExposures` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����ع���",
`AvgAdClicks` double REPLACE_IF_NOT_NULL NULL  COMMENT "�����ӹ������",
`AvgAdExposures` double REPLACE_IF_NOT_NULL NULL  COMMENT "�����ӹ���ع���",
`AvgAdExposuresIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "�����ӿ���7�����ع���",
`RoasIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7����ROI",
`RoasIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14����ROI",
`RoasIn30dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30����ROI",
`ExpoRateIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7�����ع��ʣ�UK/DE/FR/US��",
`ExpoRateIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14�����ع��ʣ�UK/DE/FR/US��",
`ClickRateIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7�������ʣ�UK/DE/FR/US��",
`ClickRateIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14�������ʣ�UK/DE/FR/US��",
`AdSaleRateIn7dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7����ת���ʣ�UK/DE/FR/US��",
`AdSaleRateIn14dLst` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14����ת���ʣ�UK/DE/FR/US��",


`NewDevSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU��",
`NewDevSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU��-����",
`NewDevSkuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SKU��",
`SpuSkuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ�������",
`NewAddSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "���SPU��",
`SpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ��SPU������ͣ����",
`SkuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ��SKU������ͣ����",
`SpuStopCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "ͣ��SPU����̭��SPU����",
`NewSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��90������������ʱ�����2023-03-01��SPU������Ϊ��Ʒ",
`OldSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "δ��ͣ������ƷSPU��-����",
`SaleSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU�����Խ�90��Ϊ��Ʒ",
`SaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��_�����ſ���",
`SaleSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��-���⣬�Խ�90��Ϊ��Ʒ",
`FirstSaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�״γ���SPU��",
`SpuValueIn30dSinceFirstOrd`double REPLACE_IF_NOT_NULL NULL  COMMENT "�׵�30��SPU����",
`SaleAmountIn90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��90�������Ʒ���۶�",
`SaleAmountIn90dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ���۶�_�����ſ���"
`SaleAmount_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "�������۶�-����",

`SaleAmount_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "�������������������ۼ����۶�",
`SaleAmountIn90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "������Ʒ���������������ۼ����۶�" 
`SaleAmountBf90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "������Ʒ���������������ۼ����۶�" 

`SaleAmountIn90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "������Ʒ�������۶�",
`SaleAmountBf90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "������Ʒ�������۶�",
`StopSkuRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��ƷSKUͣ��SPUռ��",

`SaleAmountIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��30�������Ʒ���۶�",
`SpuSaleCntIn30d` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��30�춯��SPU��",
`SpuSaleRateIn30d` double REPLACE_IF_NOT_NULL NULL  COMMENT "��30��SPU������",
`SpuUnitSaleIn30d` double REPLACE_IF_NOT_NULL NULL  COMMENT "��30�춯��SPU����",

`TopSaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU������30�쵥SPU�����˷����۶�>=1500USD",
`TopSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU������",
`TopSaleSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU��-����",
`TopSaleSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��",
`TopSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ��������SPU��",
`TopSaleSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��",
`TopSaleSpuCntBf90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��",
`HotSaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU������30�쵥SPU�����˷����۶�>=500��С��1500USD",
`HotSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU������",
`HotSaleSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU��-����",
`HotSaleSpuCntIn90dDev` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��",
`HotSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ��������SPU��",
`HotSaleSpuCntIn90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��-����",
`HotSaleSpuCntBf90dDev_ele` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��-����",
`PotentialLevelUpRateIn7d` double REPLACE_IF_NOT_NULL NULL  COMMENT "Ǳ����7��ɹ���,��Ǳ����Ϊ������",
`PotentialLevelUpRateIn14d` double REPLACE_IF_NOT_NULL NULL  COMMENT "Ǳ����14��ɹ���,��Ǳ����Ϊ������",
`PotentialLevelUpRateIn28d` double REPLACE_IF_NOT_NULL NULL  COMMENT "Ǳ����28��ɹ���,��Ǳ����Ϊ������",
`HotSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��_�����ſ���",
`TopSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��_�����ſ���",

`TopSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU����ڵ���",
`TopSaleSpuValue_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU����ڵ���-����",
`TopSaleSpuValueIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU����ڵ���",
`HotSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU����ڵ���",
`HotSaleSpuValue_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU����ڵ���-����",
`HotSaleSpuValueIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU����ڵ���",
`UnderHotSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "�Ǳ��������ڵ���",
`TopHotSaleRate_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ҵ��ռ��-����",


`TopSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU�������۶�",
`TopSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ƷSPU�������۶�",
`HotSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU�������۶�",
`HotSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ƷSPU�������۶�",
`TopSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU�������۶�ռ��",
`HotSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU�������۶�ռ��",
`TopHotStopSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ͣ��SPUռ��",

`ALstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "A��������",
`ALstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "A������������",
`SLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "S��������",
`SLstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "S������������",
`BLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "B��������",
`CLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "C��������",
`ALstSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "A�����ӱ������۶�",
`SLstSaleSpuAmount` double REPLACE_IF_NOT_NULL NULL  COMMENT "S�����ӱ������۶�",
`ALstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "A�����ӱ������۶�ռ��",
`SLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "S�����ӱ������۶�ռ��",
`BLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "B�����ӱ������۶�ռ��",
`CLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "C�����ӱ������۶�ռ��",
`ALstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "A�����ӱ���ڵ���",
`SLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "S�����ӱ���ڵ���",
`BLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "B�����ӱ���ڵ���",
`CLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "C�����ӱ���ڵ���",
`SALstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA�����ӱ���䵥��",
`SALstOfflineSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA������δ����ռ��",
`SALstProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA����������";

`SpuSaleRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7��SPU������",
`SpuSaleRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14��SPU������",
`SpuSaleRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30��SPU������",
`SpuSaleRateIn7dDev_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7��SPU������-����",
`SpuSaleRateIn14dDev_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14��SPU������-����",
`SpuSaleRateIn30dDev_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30��SPU������-����",

`SkuExpoRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7��SKU�ع���",
`SkuExpoRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14��SKU�ع���",
`SkuExpoRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30��SKU�ع���",
`SkuClickRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7��SKU�����",
`SkuClickRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14��SKU�����",
`SkuClickRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30��SKU�����",
`SkuAdSaleRateIn7dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7��SKUת����",
`SkuAdSaleRateIn14dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14��SKUת����",
`SkuAdSaleRateIn30dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30��SKUת����",

`SaleShopCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����������",
`SaleLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����������",
`SaleSpuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU��",
`SaleSpuValue` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU����",
`OverShopSkuCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "���ߵ��̳���SKU����һ��SKU�����6������",
`OnlineLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����������",
`LstSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "���Ӷ�����",
`NewLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�¿��������������ڿ��ǣ�",
`LstCntIn30d` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��30�쿯��������",
`LstSaleRateIn7d` double REPLACE_IF_NOT_NULL NULL  COMMENT "����7�����Ӷ�����",
`LstSaleRateIn14d` double REPLACE_IF_NOT_NULL NULL  COMMENT "����14�����Ӷ�����",
`LstSaleRateIn30d` double REPLACE_IF_NOT_NULL NULL  COMMENT "����30�����Ӷ�����",

`PurchaseOrders` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�ɹ�����",
`PurchaseIn1dRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ɹ������µ���",
`DelayShippedOver10dOrders` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "10��δ����������",
`CreatedPackageIn2dPayRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "2�������ʣ�������",
`ShippedIn7dPayRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "7�췢���ʣ�������",
`RecivedIn5dPurcRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ɹ�5�쵽���ʣ��µ���",
`OnTimeDeliveryRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "׼ʱ������",
`RecivedIn24hRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ֿ�24Сʱ�ջ���",
`InstockIn24hRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ֿ�24Сʱ�����",
`ShippedIn24hRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ֿ�24Сʱ������",

`InventoryOccupied` double REPLACE_IF_NOT_NULL NULL  COMMENT "����ʽ�ռ��",
`InventoryTurnover` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�����ת����",
`InventorySkuSaleRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "���SKU������"

`SpuSaleRateIn7dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "����7��SPU�ɶ�������",
`SpuSaleRateIn14dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "����14��SPU�ɶ�������",
`SpuSaleRateIn30dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "����30��SPU�ɶ�������"


) ENGINE=OLAP
AGGREGATE KEY(FirstDay,ReportType,Team,Staff)
COMMENT "��ٻ��Ŷ��ܱ������"
DISTRIBUTED BY HASH(Team,Staff,FirstDay) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- ������

insert into ads_ag_kbh_report_weekly (FirstDay,ReportType,Team,Staff)
    select FirstDay,ReportType, case when Team = '��ٻ�һ��' then '��ٻ��ɶ�' when Team = '��ٻ�����' then '��ٻ�Ȫ��' else  Team end Team ,Staff
        from ads_ag_kbh_report_weekly;


insert into ads_ag_kbh_report_weekly (FirstDay,ReportType,Team,Staff)
select FirstDay,ReportType, case when Team = '��ٻ�һ��' then '��ٻ��ɶ�' when Team = '��ٻ�����' then '��ٻ�Ȫ��' else  Team end Team ,Staff
        from ads_ag_kbh_report_weekly ;

-- �޸��� 
-- ALTER TABLE ads_ag_staff_kbh_report_weekly MODIFY COLUMN Team varchar(64) NOT NULL  ;
 ALTER TABLE ads_ag_kbh_report_weekly MODIFY COLUMN AvgAdClicks double REPLACE_IF_NOT_NULL NULL  COMMENT "�����ӹ������" ;
 ALTER TABLE ads_ag_kbh_report_weekly MODIFY COLUMN AvgAdExposures double REPLACE_IF_NOT_NULL NULL  COMMENT "�����ӹ������" ;
 ALTER TABLE ads_ag_kbh_report_weekly MODIFY COLUMN AvgAdExposuresIn7dLst double REPLACE_IF_NOT_NULL NULL  COMMENT "�����ӿ���7�����ع���" ;

-- ������
-- ALTER TABLE ads_kbh_staff_stat_weekly ADD COLUMN PurcOrders int(11) DEFAULT '0' COMMENT "�ɹ�����" after SkuAdSaleRateIn30dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCnt_ele` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����SPU��-����" after TopSaleSpuCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmount_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "�������۶�-����" after SaleAmountIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountIn90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "������Ʒ�������۶�" after SaleAmount_ele_monthly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountBf90dDev_ele_monthly` double REPLACE_IF_NOT_NULL NULL COMMENT "������Ʒ�������۶�" after SaleAmountIn90dDev_ele_monthly;

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ƷSPU�������۶�" after TopSaleSpuAmount;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuAmountIn3m` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ƷSPU�������۶�" after HotSaleSpuAmount;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuValue_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU����ڵ���-����" after HotSaleSpuValue;

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn7dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "����7��SPU�ɶ�������";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn14dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "����14��SPU�ɶ�������";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn30dDev_saleby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "����30��SPU�ɶ�������";

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuValueIn30dSinceFirstOrd_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "�׵�30��SPU����_�ޱ����ſ�����Ʒ";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn7dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "����7��SPU������_�ޱ����ſ�����Ʒ";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn14dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "����14��SPU������_�ޱ����ſ�����Ʒ";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn30dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL COMMENT "����30��SPU������_�ޱ����ſ�����Ʒ";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SALstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA�����ӱ���䵥��" after SLstSaleSpuValue ;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `NumberOfTeam` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "�Ŷ�����" after BadDebtRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `OriProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�ҵ�ë����" after ProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ProfitPerformance` double REPLACE_IF_NOT_NULL NULL  COMMENT "�������Ч" after NumberOfTeam;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU������" after TopSaleSpuCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "����SPU������" after HotSaleSpuCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `UnderHotSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "�Ǳ��������ڵ���" after HotSaleSpuValueIn30dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ��������SPU��" after TopSaleSpuCntIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuCntIn90dDev_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ��������SPU��" after HotSaleSpuCntIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ALstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "A������������" after ALstCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SLstCnt_NewAdd` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "S������������" after SLstCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `BLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "B��������" after SLstCnt_NewAdd;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `CLstCnt` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "C��������" after BLstCnt;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `BLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "B�����ӱ���ڵ���" after SLstSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `CLstSaleSpuValue` double REPLACE_IF_NOT_NULL NULL  COMMENT "C�����ӱ���ڵ���" after BLstSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopHotSaleRate_ele` double REPLACE_IF_NOT_NULL NULL  COMMENT "������ҵ��ռ��-����" after UnderHotSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `PotentialLevelUpRateIn7d` double REPLACE_IF_NOT_NULL NULL  COMMENT "Ǳ����7��ɹ���,��Ǳ����Ϊ������" after HotSaleSpuCntBf90dDev_ele;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `PotentialLevelUpRateIn14d` double REPLACE_IF_NOT_NULL NULL  COMMENT "Ǳ����14��ɹ���,��Ǳ����Ϊ������" after PotentialLevelUpRateIn7d;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `PotentialLevelUpRateIn28d` double REPLACE_IF_NOT_NULL NULL  COMMENT "Ǳ����28��ɹ���,��Ǳ����Ϊ������" after PotentialLevelUpRateIn14d;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountIn90dDev_DevbySelf` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ���۶�_�����ſ���" after SaleAmountIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��_�����ſ���" after SaleSpuCntIn90dDev;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `BLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "B�����ӱ������۶�ռ��" after SLstSaleSpuRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `CLstSaleSpuRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "C�����ӱ������۶�ռ��" after BLstSaleSpuRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `HotSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��_�����ſ���" after PotentialLevelUpRateIn28d;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopSaleSpuCntIn90dDev_DevbySelf` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ����SPU��_�����ſ���" after HotSaleSpuCntIn90dDev_DevbySelf;

ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmount_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "�������������������ۼ����۶�" after SaleAmount_ele_monthly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountIn90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "������Ʒ���������������ۼ����۶�" after SaleAmount_ele_Yearly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SaleAmountBf90dDev_ele_Yearly` double REPLACE_IF_NOT_NULL NULL  COMMENT "������Ʒ���������������ۼ����۶�" after SaleAmountIn90dDev_ele_Yearly;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `UnderHotSaleSpuValue_In90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ�Ǳ������" after UnderHotSaleSpuValue;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SALstProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "SA����������" after SALstOfflineSpuRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `otherLstProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "��SA����������" after SALstProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `TopHotProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "������������" after otherLstProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `otherProdProfitRate` double REPLACE_IF_NOT_NULL NULL  COMMENT "�Ǳ�����������" after TopHotProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ProfitRate_In90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ������" after otherProdProfitRate;
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `ProfitRate_Bf90dDev` double REPLACE_IF_NOT_NULL NULL  COMMENT "��Ʒ������" after ProfitRate_In90dDev;



-- �����Ƿ����У���ɾ����ע��Ϊ����
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn7dDev_devby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "�ɶ�����7��SPU�����ʣ��ɶ��Ŷӿ��������޳����Ŷ�";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn14dDev_devby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "�ɶ�����14��SPU�����ʣ��ɶ��Ŷӿ��������޳����Ŷ�";
ALTER TABLE ads_ag_kbh_report_weekly ADD COLUMN `SpuSaleRateIn30dDev_devby_cd` double REPLACE_IF_NOT_NULL NULL COMMENT "�ɶ�����30��SPU�����ʣ��ɶ��Ŷӿ��������޳����Ŷ�";



-- �޸���
-- ALTER TABLE ads_kbh_staff_stat_weekly DROP COLUMN PurcOrders ;
`TotalGross` double REPLACE_IF_NOT_NULL NULL  COMMENT "���۶�",