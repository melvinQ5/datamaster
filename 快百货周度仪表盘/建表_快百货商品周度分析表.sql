

CREATE TABLE IF NOT EXISTS
ads_kbh_product_analysis_weekly (
`spu` varchar(32)  not NULL COMMENT "SPU",
`year` int(11) not NULL COMMENT "��Ȼ��",
`week` int(11) not NULL COMMENT "��Ȼ��",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƿ�ɾ��",
`wttime` datetime REPLACE_IF_NOT_NULL NULL COMMENT "д��ʱ��",
`sales_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�����˷����۶�",
`profit_no_freight` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�����˷������",
`salecount` int(11) REPLACE_IF_NOT_NULL NULL  COMMENT  "����",
`price_range`  varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "�۸��" ,
`refund_rate_in30d` double REPLACE_IF_NOT_NULL NULL COMMENT "��30���˿���",
`ProductStatus` varchar(64) REPLACE_IF_NOT_NULL NULL COMMENT "��Ʒ״̬",
`StopReason` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "ͣ��ԭ��",
`updown_mark` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "�������",
`updown_reason` varchar(32) REPLACE_IF_NOT_NULL NULL COMMENT "����ԭ�����",
`updown_reason_details` varchar(256) REPLACE_IF_NOT_NULL NULL COMMENT "����ԭ����ϸ",
`action` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "���Զ���",
`action_tracks` varchar(128) REPLACE_IF_NOT_NULL NULL COMMENT "�������"
) ENGINE=OLAP
AGGREGATE KEY(spu,year,week)
COMMENT "��ٻ���Ʒ�ǵ����������"
DISTRIBUTED BY HASH(spu,year,week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

-- �����ֶ�
ALTER TABLE ads_kbh_product_analysis_weekly ADD COLUMN `purchase_days_in30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��30��ƽ���ɹ�ʱ��" after refund_rate_in30d;