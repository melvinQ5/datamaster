select
DimensionId as ����ά��,
`Year` as "������",
`Week` as "������",
FirstDay as ���ڵ�һ��,
    
`dev_spu_cnt`as "����SPU��",
`sale_rate_over1_devin7d` as  "����7��1��������",
`sale_rate_over1_devin14d` as  "����14��1��������",
`sale_rate_over1_devin30d` as  "����30��1��������",
`sale_rate_over1_devin90d` as  "����90��1��������",

`sale_rate_over3_devin14d` as  "����14��3��������",
`sale_rate_over3_devin30d` as  "����30��3��������",

`sale_rate_over6_devin14d` as  "����14��6��������",
`sale_rate_over6_devin30d` as  "����30��6��������",

`sale_rate_over1_lstin7d` as  "����7��1��������",
`sale_rate_over1_lstin14d` as  "����14��1��������",
`sale_rate_over1_lstin30d` as  "����30��1��������",

`sale_rate_over3_lstin14d` as  "����14��3��������",
`sale_rate_over3_lstin30d` as  "����30��3��������",

`sale_rate_over6_lstin14d` as  "����14��6��������",
`sale_rate_over6_lstin30d` as  "����30��6��������",


`sale_amount_odin30d` as  "�׵�30�����۶�",
`sale_unitamount_odin30d` as  "�׵�30�쵥��",
    
`spu_tophot_devin30d`as "����30�챬������",
`sale_rate_devin30d` as "����30�챬����",
`sale_amount_tophot_devin30d` as  "����30�챬�������۶�",

`sale_amount_devin7d` as  "����7�����۶�S2",
`sale_amount_devin14d` as  "����14�����۶�S2",
`sale_amount_devin30d` as  "����30�����۶�S2",
`sale_amount_devin60d` as  "����60�����۶�S2",
`sale_amount_devin90d` as  "����90�����۶�S2",
`sale_amount_newprod` as  "��Ʒ�����۶�S2",

`adspend_devin7d` as  "����7���滨��",
`adspend_devin14d` as  "����14���滨��",
`adspend_devin30d` as  "����30���滨��",
`adspend_devin60d` as  "����60���滨��",
`adspend_devin90d` as  "����90���滨��",

`profit_rate_devin7d` as  "����7��������R2",
`profit_rate_devin14d` as  "����14��������R2",
`profit_rate_devin30d` as  "����30��������R2",
`profit_rate_devin60d` as  "����60��������R2",
`profit_rate_devin90d` as  "����90��������R2",

`spu_exposure_devin7d` as  "����7�쵥SPU�ع���",
`spu_exposure_devin14d` as  "����14�쵥SPU�ع���",
`spu_exposure_devin30d` as  "����30�쵥SPU�ع���",

`spu_clicks_devin7d` as  "����7�쵥SPU�����",
`spu_clicks_devin14d` as  "����14�쵥SPU�����",
`spu_clicks_devin30d` as  "����30�쵥SPU�����",

`spu_exposure_rate_devin7d` as  "����7��SPU�ع���",
`spu_exposure_rate_devin14d` as  "����14��SPU�ع���",
`spu_exposure_rate_devin30d` as  "����30��SPU�ع���",

`spu_clicks_rate_devin7d` as  "����7��SPU�����",
`spu_clicks_rate_devin14d` as  "����14��SPU�����",
`spu_clicks_rate_devin30d` as  "����30��SPU�����",
/*
`avg_lst_exposure_devin7d` as  "����7�쵥�����ع���",
`avg_lst_exposure_devin14d` as  "����14�쵥�����ع���",
`avg_lst_exposure_devin30d` as  "����30�쵥�����ع���",
 */

`ad_clicks_rate_devin7d` as  "����7��������",
`ad_clicks_rate_devin14d` as  "����14��������",
`ad_clicks_rate_devin30d` as  "����30��������",

`ad_sale_rate_devin7d` as  "����7����ת����",
`ad_sale_rate_devin14d` as  "����14����ת����",
`ad_sale_rate_devin30d` as  "����30����ת����",

`ad_cpc_devin7d` as  "����7��CPC",
`ad_cpc_devin14d` as  "����14��CPC",
`ad_cpc_devin30d` as  "����30��CPC",

`online_spu_cnt`as "����SPU��",
`online_spu_cnt_achieved`as "���ߴ��SPU��",
`lst_cnt`as "����������",
`avg_days_dev2lst` as  "ƽ���׵�����"

from ads_kbh_prod_new_dev_track
order by DimensionId,������,������ desc