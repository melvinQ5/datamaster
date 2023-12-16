
-- ������ wt_online_listing_scd

-- ��ٻ����̳��㡢ľ�������������
-- ��ʼ����ǰ���ӱ� startday = '2023-12-12' endday = '9999-12-31'
select id as listingId ,Department  ,'2023-12-12' as startday , '9999-12-31' as endday
from erp_amazon_amazon_listing eaal
join mysql_store ms  on eaal.ShopCode= ms.code and ms.Department regexp '��ٻ�|�̳���|ľ����' and eaal.ListingStatus=1 and ms.ShopStatus='����';

select count(distinct id ) ����������
from erp_amazon_amazon_listing eaal
join mysql_store ms  on eaal.ShopCode= ms.code and ms.Department regexp '��ٻ�' and eaal.ListingStatus=1 and ms.ShopStatus='����';




-- ˼·��ѡ��dorisimporttime��Χ�����������ǵ��ܶȣ���ѡ����Щ�ܶ�������������

-- �����õ����������µ�ʱ��ֻ������������㣬�м���һ�������󣬺����Ķ�����ˢ��
-- ��ά��ʱ�򣬸��µ�ʱ������������� update ������θ�����

CREATE TABLE `wt_online_listing_snap`
(
`ShopCode` varchar(64) NOT NULL COMMENT "���̼���",
`SellerSKU` varchar(128) NOT NULL COMMENT "����Listing���ص� SellerSKU",
`SKU` varchar(32) NOT NULL COMMENT "����SKU",
`StartDay` date  NULL COMMENT "��ʼ��������",
`EndDay` date NOT NULL COMMENT "�����������",
`ListingId` varchar(64) NOT NULL COMMENT "����ID",
`ReportType` varchar(16) NULL COMMENT "���ɿ�������",
`Department` varchar(64)  NULL COMMENT "����",
`ASIN` varchar(64) NULL COMMENT "asin",
`Site` varchar(64) NULL COMMENT "վ��",
`ProductSalesName` varchar(64) NULL COMMENT "��Ʒ������Ա",
`PublishUserName` varchar(64) NULL COMMENT "������Ա",
`SellUserName` varchar(64) NULL COMMENT "��ѡҵ��Ա",
`NodePathName` varchar(64) NULL COMMENT "��ѡҵ��Ա�Ŷ�",
`SPU` varchar(32) NULL COMMENT "����SPU",
`ProductId` varchar(64) NULL COMMENT "���¹�����Ʒ��Id",
`ListingStatus` varchar(32) NULL COMMENT "listing״̬(1:����,2:����,3:�¼�,4:ɾ��)",
`ShopStatus` varchar(32) NULL COMMENT "����״̬",
`MinPublicationDate` datetime NULL COMMENT "����ʱ��"
) ENGINE=OLAP
DUPLICATE  KEY(`GenerateDate`, `ShopCode`,`ListingId`)
COMMENT "����ѷ���ӿ��ձ�"
PARTITION BY RANGE(`GenerateDate`)
(
PARTITION p202312 VALUES [('2023-12-01'), ('2024-01-01')),
PARTITION p202401 VALUES [('2024-01-01'), ('2024-02-01')),
PARTITION p202402 VALUES [('2024-02-01'), ('2024-03-01')),
PARTITION p202403 VALUES [('2024-03-01'), ('2024-04-01')),
PARTITION p202404 VALUES [('2024-04-01'), ('2024-05-01')),
PARTITION p202405 VALUES [('2024-05-01'), ('2024-06-01')),
PARTITION p202406 VALUES [('2024-06-01'), ('2024-07-01')),
PARTITION p202407 VALUES [('2024-07-01'), ('2024-08-01')),
PARTITION p202408 VALUES [('2024-08-01'), ('2024-09-01')),
PARTITION p202409 VALUES [('2024-09-01'), ('2024-10-01')),
PARTITION p202410 VALUES [('2024-10-01'), ('2024-11-01')),
PARTITION p202411 VALUES [('2024-11-01'), ('2024-12-01')),
PARTITION p202412 VALUES [('2024-12-01'), ('2025-01-01')),
PARTITION p202501 VALUES [('2025-01-01'), ('2025-02-01')),
PARTITION p202502 VALUES [('2025-02-01'), ('2025-03-01')),
PARTITION p202503 VALUES [('2025-03-01'), ('2025-04-01')),
PARTITION p202504 VALUES [('2025-04-01'), ('2025-05-01')),
PARTITION p202505 VALUES [('2025-05-01'), ('2025-06-01')),
PARTITION p202506 VALUES [('2025-06-01'), ('2025-07-01')),
PARTITION p202507 VALUES [('2025-07-01'), ('2025-08-01')),
PARTITION p202508 VALUES [('2025-08-01'), ('2025-09-01')),
PARTITION p202509 VALUES [('2025-09-01'), ('2025-10-01')),
PARTITION p202510 VALUES [('2025-10-01'), ('2025-11-01')),
PARTITION p202511 VALUES [('2025-11-01'), ('2025-12-01')),
PARTITION p202512 VALUES [('2025-12-01'), ('2026-01-01')),
PARTITION p202601 VALUES [('2026-01-01'), ('2026-02-01')),
PARTITION p202602 VALUES [('2026-02-01'), ('2026-03-01')),
PARTITION p202603 VALUES [('2026-03-01'), ('2026-04-01')),
PARTITION p202604 VALUES [('2026-04-01'), ('2026-05-01')),
PARTITION p202605 VALUES [('2026-05-01'), ('2026-06-01')),
PARTITION p202606 VALUES [('2026-06-01'), ('2026-07-01')),
PARTITION p202607 VALUES [('2026-07-01'), ('2026-08-01')),
PARTITION p202608 VALUES [('2026-08-01'), ('2026-09-01')),
PARTITION p202609 VALUES [('2026-09-01'), ('2026-10-01')),
PARTITION p202610 VALUES [('2026-10-01'), ('2026-11-01')),
PARTITION p202611 VALUES [('2026-11-01'), ('2026-12-01')),
PARTITION p202612 VALUES [('2026-12-01'), ('2027-01-01')),
PARTITION p202701 VALUES [('2027-01-01'), ('2027-02-01')),
PARTITION p202702 VALUES [('2027-02-01'), ('2027-03-01')),
PARTITION p202703 VALUES [('2027-03-01'), ('2027-04-01')),
PARTITION p202704 VALUES [('2027-04-01'), ('2027-05-01')),
PARTITION p202705 VALUES [('2027-05-01'), ('2027-06-01')),
PARTITION p202706 VALUES [('2027-06-01'), ('2027-07-01')),
PARTITION p202707 VALUES [('2027-07-01'), ('2027-08-01')),
PARTITION p202708 VALUES [('2027-08-01'), ('2027-09-01')),
PARTITION p202709 VALUES [('2027-09-01'), ('2027-10-01')),
PARTITION p202710 VALUES [('2027-10-01'), ('2027-11-01')),
PARTITION p202711 VALUES [('2027-11-01'), ('2027-12-01')),
PARTITION p202712 VALUES [('2027-12-01'), ('2028-01-01')),
PARTITION p202801 VALUES [('2028-01-01'), ('2028-02-01')),
PARTITION p202802 VALUES [('2028-02-01'), ('2028-03-01')),
PARTITION p202803 VALUES [('2028-03-01'), ('2028-04-01')),
PARTITION p202804 VALUES [('2028-04-01'), ('2028-05-01')),
PARTITION p202805 VALUES [('2028-05-01'), ('2028-06-01')),
PARTITION p202806 VALUES [('2028-06-01'), ('2028-07-01')),
PARTITION p202807 VALUES [('2028-07-01'), ('2028-08-01')),
PARTITION p202808 VALUES [('2028-08-01'), ('2028-09-01')),
PARTITION p202809 VALUES [('2028-09-01'), ('2028-10-01')),
PARTITION p202810 VALUES [('2028-10-01'), ('2028-11-01')),
PARTITION p202811 VALUES [('2028-11-01'), ('2028-12-01')),
PARTITION p202812 VALUES [('2028-12-01'), ('2029-01-01')),
PARTITION p202901 VALUES [('2029-01-01'), ('2029-02-01')),
PARTITION p202902 VALUES [('2029-02-01'), ('2029-03-01')),
PARTITION p202903 VALUES [('2029-03-01'), ('2029-04-01')),
PARTITION p202904 VALUES [('2029-04-01'), ('2029-05-01')),
PARTITION p202905 VALUES [('2029-05-01'), ('2029-06-01')),
PARTITION p202906 VALUES [('2029-06-01'), ('2029-07-01')),
PARTITION p202907 VALUES [('2029-07-01'), ('2029-08-01')),
PARTITION p202908 VALUES [('2029-08-01'), ('2029-09-01')),
PARTITION p202909 VALUES [('2029-09-01'), ('2029-10-01')),
PARTITION p202910 VALUES [('2029-10-01'), ('2029-11-01')),
PARTITION p202911 VALUES [('2029-11-01'), ('2029-12-01')),
PARTITION p202912 VALUES [('2029-12-01'), ('2030-01-01')))
DISTRIBUTED BY HASH( `ListingId`,`ShopCode`) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);