-- ��ѯ
select * from  dep_kbh_product_level_potentail where asin = 'B0C36JVPXG' AND ShopCode = 'QR-CA'


select date_add('2023-07-23',interval -14 day)

CREATE TABLE IF NOT EXISTS
dep_kbh_listing_level_details (
`MarkDate` date NOT NULL COMMENT "��ǩ��������",
`Asin` varchar(64)  NOT NULL COMMENT "ASIN",
`ShopCode` varchar(64)  NOT NULL COMMENT "���̼���",
`SellerSku` varchar(64)  NOT NULL COMMENT "����SKU",

`ListLevel` varchar(64)  REPLACE_IF_NOT_NULL NULL COMMENT "���ӷֲ�",
`OldListLevel` varchar(512)  REPLACE_IF_NOT_NULL NULL COMMENT "��ʷ���ӷֲ�",
`MinPublicationDate` datetime REPLACE_IF_NOT_NULL NULL COMMENT "�״ο���ʱ��" ,
`site` varchar(32)  REPLACE_IF_NOT_NULL NULL COMMENT "վ��",
`AccountCode` varchar(64) REPLACE_IF_NOT_NULL  NULL COMMENT "�˺�",
`NodePathName` varchar(64) REPLACE_IF_NOT_NULL  NULL COMMENT "�����Ŷ�",
`SellUserName` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "��ѡҵ��Ա",

`salescountInt1` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��������T1",
`SalesCountInt2` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "ǰ������T2",
`SalesCountInt3` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3����",
`SalesCountIn1w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��1������",
`SalesCountIn2w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��2������",
`SalesCountIn30d` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��30������",
`SalesCountIn90d` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��90������",

`ExposureInt2` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "ǰ���ع�T2",
`ExposureInt3` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3�ع�",
`ExposureInt4` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T4�ع�",
`ExposureIn1w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��1���ع�",
`ExposureIn2w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��2���ع�",
    
`ClicksInt2` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "ǰ����T2",
`ClicksInt3` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3���",
`ClicksInt4` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T4���",
`ClicksIn1w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��1�ܵ��",
`ClicksIn2w` int(11) REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��2�ܵ��",

`AdSpendInt2` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "ǰ���滨��T-",
`AdSpendInt3` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T3��滨��",
`AdSpendInt4` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "T4��滨��",
`AdSpendIn1w` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��1�ܹ�滨��",
`AdSpendIn2w` double REPLACE_IF_NOT_NULL null  DEFAULT  '0'  COMMENT  "��2�ܹ�滨��",

`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "д��ʱ��"
) ENGINE=OLAP
AGGREGATE KEY(MarkDate,asin,shopcode,sellersku)
COMMENT "��ٻ����ӷֲ���ϸ��"
DISTRIBUTED BY HASH(asin,shopcode,sellersku) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- ������
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `ListingId` varchar(256) REPLACE_IF_NOT_NULL NULL COMMENT  "���ӱ�Id" after SellerSku;
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `BoxSku` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT  "BoxSku" after AdSpendIn2w;
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `SPU` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT  "spu" after BoxSku;
ALTER TABLE dep_kbh_listing_level_details ADD COLUMN `SKU` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT  "SKU" after SPU;

-- �޸���
ALTER TABLE dep_kbh_listing_level_details MODIFY COLUMN MinPublicationDate date REPLACE_IF_NOT_NULL NULL  COMMENT "�״ο���ʱ��" ;