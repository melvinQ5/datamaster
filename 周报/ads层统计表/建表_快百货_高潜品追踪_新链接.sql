
CREATE TABLE IF NOT EXISTS
ads_kbh_prod_potential_track_new_lst (
`DimensionId` varchar(64) NOT NULL COMMENT "ά��id",
`Year` int(11) NOT NULL COMMENT "ͳ����",
`Month` int(11) NOT NULL COMMENT "ͳ����",
`Week` int(11) NOT NULL COMMENT "ͳ����",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƿ�ɾ��" ,
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "д��ʱ��",


`push_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "�Ƽ�SPU��",
`sale_rate_over1_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��1��������",
`sale_rate_over1_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��1��������",
`sale_rate_over1_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��1��������",
`sale_rate_over1_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�60��1��������",
`sale_rate_over1_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�90��1��������",

`sale_rate_over3_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��3��������",
`sale_rate_over3_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��3��������",
    
`sale_rate_over6_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��6��������",
`sale_rate_over6_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��6��������",    
    
`sale_rate_over1_lstin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����7��1��������",
`sale_rate_over1_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��1��������",
`sale_rate_over1_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��1��������",
    
`sale_rate_over3_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��3��������",
`sale_rate_over3_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��3��������",
    
`sale_rate_over6_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����14��6��������",
`sale_rate_over6_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "����30��6��������",

`sale_amount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�׵�30�����۶�",
`sale_unitamount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�׵�30�쵥��",

`sale_amount_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7�����۶�",
`sale_amount_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14�����۶�",
`sale_amount_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30�����۶�",
`sale_amount_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�60�����۶�",
`sale_amount_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�90�����۶�",
    
`adspend_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7���滨��",
`adspend_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14���滨��",
`adspend_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30���滨��",
`adspend_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�60���滨��",
`adspend_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�90���滨��",

`profit_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��������",
`profit_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��������",
`profit_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��������",
`profit_rate_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�60��������",
`profit_rate_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�90��������",
    
`spu_exposure_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7�쵥SPU�ع���",
`spu_exposure_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14�쵥SPU�ع���",
`spu_exposure_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30�쵥SPU�ع���",
    
`spu_clicks_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7�쵥SPU�����",
`spu_clicks_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14�쵥SPU�����",
`spu_clicks_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30�쵥SPU�����",    
    
`spu_profit_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��SPU�ع���",
`spu_profit_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��SPU�ع���",
`spu_profit_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��SPU�ع���",    
    
`spu_clicks_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��SPU�����",
`spu_clicks_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��SPU�����",
`spu_clicks_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��SPU�����",
    
`avg_lst_exposure_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7�쵥�����ع���",
`avg_lst_exposure_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14�쵥�����ع���",
`avg_lst_exposure_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30�쵥�����ع���",    
    
`ad_exposure_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7�����ع���",
`ad_exposure_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14�����ع���",
`ad_exposure_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30�����ع���",    
    
`ad_clicks_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��������",
`ad_clicks_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��������",
`ad_clicks_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��������",

`ad_sale_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7����ת����",
`ad_sale_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14����ת����",
`ad_sale_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30����ת����",
    
`ad_cpc_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��CPC",
`ad_cpc_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��CPC",
`ad_cpc_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��CPC",

`sale_amount_pushin90d_themes` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�����Ʒ90�����۶�",
`sale_amount_pushin90d_unthemes` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�����Ʒ90�����۶�",

`spu_tophot_pushin30d_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "�Ƽ�30���¿��Ǳ�������",
`sale_rate_pushin30d_newlst` double REPLACE_IF_NOT_NULL NULL COMMENT "�Ƽ�30���¿��Ǳ�����",
`sale_amount_tophot_pushin30d_newlst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30�챬�������۶�",

`online_spu_cnt_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "�¿�������SPU��",
`online_spu_cnt_achieved_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "�¿������ߴ��SPU��",
`lst_cnt_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����������",
`lst_cnt_newlst_mainsite` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "����������_��վ��",
`avg_days_dev2lst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "ƽ���׵�����"

) ENGINE=OLAP
AGGREGATE KEY(DimensionId,Year,Month,Week)
COMMENT "��ٻ���ǱƷ������ͳ�Ʊ�"
DISTRIBUTED BY HASH(DimensionId,Year,Month,Week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

# ����
ALTER TABLE ads_kbh_prod_potential_track_new_lst ADD COLUMN `ReportType` varchar(10) REPLACE_IF_NOT_NULL NULL  COMMENT  "����Ƶ��" after wttime;
ALTER TABLE ads_kbh_prod_potential_track_new_lst ADD COLUMN `FirstDay` date REPLACE_IF_NOT_NULL NULL  COMMENT  "ͳ���ڵ�һ��" after ReportType;
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `spu_profit_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�7��SPU�ع���(Ӣ��������,Ӧexposure)";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `spu_profit_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�14��SPU�ع���(Ӣ��������,Ӧexposure)";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `spu_profit_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�Ƽ�30��SPU�ع���(Ӣ��������,Ӧexposure)";

ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `ad_exposure_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�����ֶ�";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `ad_exposure_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�����ֶ�";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `ad_exposure_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "�����ֶ�";




# ��� truncate table ads_kbh_prod_potential_track_new_lst