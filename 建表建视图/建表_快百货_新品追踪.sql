
CREATE TABLE IF NOT EXISTS
ads_kbh_prod_new_dev_track (
`DimensionId` varchar(64) NOT NULL COMMENT "ά��id",
`Year` int(11) NOT NULL COMMENT "ͳ����",
`Month` int(11) NOT NULL COMMENT "ͳ����",
`Week` int(11) NOT NULL COMMENT "ͳ����",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƿ�ɾ��" ,
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "д��ʱ��",
`ReportType` varchar(10) REPLACE_IF_NOT_NULL NULL  COMMENT  "����Ƶ��",
`FirstDay` date REPLACE_IF_NOT_NULL NULL  COMMENT  "ͳ���ڵ�һ��" ,
    
`dev_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����SPU��",
`sale_rate_over1_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��1��������",
`sale_rate_over1_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��1��������",
`sale_rate_over1_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��1��������",
`sale_rate_over1_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����90��1��������",


`sale_rate_over3_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��3��������",
`sale_rate_over3_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��3��������",

`sale_rate_over6_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��6��������",
`sale_rate_over6_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��6��������",

`sale_rate_over1_lstin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��1��������",
`sale_rate_over1_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��1��������",
`sale_rate_over1_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��1��������",

`sale_rate_over3_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��3��������",
`sale_rate_over3_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��3��������",

`sale_rate_over6_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��6��������",
`sale_rate_over6_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��6��������",


`sale_amount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�׵�30�����۶�",
`sale_unitamount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�׵�30�쵥��",
    
`spu_tophot_devin30d` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����30�챬������",
`sale_rate_devin30d` double REPLACE_IF_NOT_NULL NULL COMMENT "����30�챬����",
`sale_amount_tophot_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30�챬�������۶�",

`sale_amount_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7�����۶�",
`sale_amount_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14�����۶�",
`sale_amount_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30�����۶�",
`sale_amount_devin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����60�����۶�",
`sale_amount_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����90�����۶�",
`sale_amount_newprod` double REPLACE_IF_NOT_NULL NULL  COMMENT  "��Ʒ�����۶�",

`adspend_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7���滨��",
`adspend_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14���滨��",
`adspend_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30���滨��",
`adspend_devin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����60���滨��",
`adspend_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����90���滨��",

`profit_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��������",
`profit_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��������",
`profit_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��������",
`profit_rate_devin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����60��������",
`profit_rate_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����90��������",

`spu_exposure_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7�쵥SPU�ع���",
`spu_exposure_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14�쵥SPU�ع���",
`spu_exposure_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30�쵥SPU�ع���",

`spu_clicks_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7�쵥SPU�����",
`spu_clicks_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14�쵥SPU�����",
`spu_clicks_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30�쵥SPU�����",

`spu_exposure_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��SPU�ع���",
`spu_exposure_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��SPU�ع���",
`spu_exposure_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��SPU�ع���",

`spu_clicks_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��SPU�����",
`spu_clicks_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��SPU�����",
`spu_clicks_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��SPU�����",

`avg_lst_exposure_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7�쵥�����ع���",
`avg_lst_exposure_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14�쵥�����ع���",
`avg_lst_exposure_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30�쵥�����ع���",

`ad_clicks_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��������",
`ad_clicks_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��������",
`ad_clicks_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��������",

`ad_sale_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7����ת����",
`ad_sale_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14����ת����",
`ad_sale_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30����ת����",

`ad_cpc_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��CPC",
`ad_cpc_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��CPC",
`ad_cpc_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��CPC",

`online_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����SPU��",
`online_spu_cnt_achieved` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "���ߴ��SPU������SPU����4����20���������ӣ�",
`lst_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����������",
`avg_days_dev2lst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "ƽ���׵�����"


) ENGINE=OLAP
AGGREGATE KEY(DimensionId,Year,Month,Week)
COMMENT "��ٻ���Ʒ����׷��"
DISTRIBUTED BY HASH(DimensionId,Year,Month,Week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

# ����
alter table ads_kbh_prod_new_dev_track ()
select
    adspend_devin7d,adspend_devin14d ,adspend_devin30d ,adspend_devin60d ,adspend_devin90d,
    spu_exposure_devin7d, spu_exposure_devin14d, spu_exposure_devin30d,
    spu_clicks_devin7d,spu_clicks_devin14d,spu_clicks_devin30d,
    spu_exposure_rate_devin7d,spu_exposure_rate_devin14d,spu_exposure_rate_devin30d,
    spu_clicks_rate_devin7d,spu_clicks_rate_devin14d,spu_clicks_rate_devin30d,
    ad_clicks_rate_devin7d,ad_clicks_rate_devin14d,ad_clicks_rate_devin30d,
    ad_sale_rate_devin7d,ad_sale_rate_devin14d,ad_sale_rate_devin30d,
    ad_cpc_devin7d,ad_cpc_devin14d,ad_cpc_devin30d
from ads_kbh_prod_new_dev_track
where FirstDay< '2023-07-03'

# ��� truncate table ads_kbh_prod_potential_track_new_lst