with
dim as (
select md5('��ٻ�') as DimensionId ,'��ٻ�' team , null istheme_ele
union all select md5('��ٻ�����') as DimensionId ,'��ٻ�' team ,'����' istheme_ele
union all select md5('��ٻ�ʥ����') ,'��ٻ�','ʥ����'
union all select md5('��ٻ�������Ʒ') ,'��ٻ�','������Ʒ'
)

select
team as ����,
istheme_ele as ����Ԫ��,

`Year` as "������",
`Week` as "������",
FirstDay as ���ڵ�һ��,


`push_spu_cnt` as "�Ƽ�SPU��",
`sale_rate_over1_pushin7d` as  "�Ƽ�7��1��������",
`sale_rate_over1_pushin14d` as  "�Ƽ�14��1��������",
`sale_rate_over1_pushin30d` as  "�Ƽ�30��1��������",
`sale_rate_over1_pushin60d` as  "�Ƽ�60��1��������",
`sale_rate_over1_pushin90d` as  "�Ƽ�90��1��������",

`sale_rate_over3_pushin14d` as  "�Ƽ�14��3��������",
`sale_rate_over3_pushin30d` as  "�Ƽ�30��3��������",
    
`sale_rate_over6_pushin14d` as  "�Ƽ�14��6��������",
`sale_rate_over6_pushin30d` as  "�Ƽ�30��6��������",    
    
`sale_rate_over1_lstin7d` as  "����7��1��������",
`sale_rate_over1_lstin14d` as  "����14��1��������",
`sale_rate_over1_lstin30d` as  "����30��1��������",
    
`sale_rate_over3_lstin14d` as  "����14��3��������",
`sale_rate_over3_lstin30d` as  "����30��3��������",
    
`sale_rate_over6_lstin14d` as  "����14��6��������",
`sale_rate_over6_lstin30d` as  "����30��6��������",

`sale_amount_odin30d` as  "�׵�30�����۶�",
`sale_unitamount_odin30d` as  "�׵�30�쵥��",

`sale_amount_pushin7d` as  "�Ƽ�7�����۶�",
`sale_amount_pushin14d` as  "�Ƽ�14�����۶�",
`sale_amount_pushin30d` as  "�Ƽ�30�����۶�",
`sale_amount_pushin60d` as  "�Ƽ�60�����۶�",
`sale_amount_pushin90d` as  "�Ƽ�90�����۶�",
    
`adspend_pushin7d` as  "�Ƽ�7���滨��",
`adspend_pushin14d` as  "�Ƽ�14���滨��",
`adspend_pushin30d` as  "�Ƽ�30���滨��",
`adspend_pushin60d` as  "�Ƽ�60���滨��",
`adspend_pushin90d` as  "�Ƽ�90���滨��",

`profit_rate_pushin7d` as  "�Ƽ�7��������",
`profit_rate_pushin14d` as  "�Ƽ�14��������",
`profit_rate_pushin30d` as  "�Ƽ�30��������",
`profit_rate_pushin60d` as  "�Ƽ�60��������",
`profit_rate_pushin90d` as  "�Ƽ�90��������",
    
`spu_exposure_pushin7d` as  "�Ƽ�7�쵥SPU�ع���",
`spu_exposure_pushin14d` as  "�Ƽ�14�쵥SPU�ع���",
`spu_exposure_pushin30d` as  "�Ƽ�30�쵥SPU�ع���",
    
`spu_clicks_pushin7d` as  "�Ƽ�7�쵥SPU�����",
`spu_clicks_pushin14d` as  "�Ƽ�14�쵥SPU�����",
`spu_clicks_pushin30d` as  "�Ƽ�30�쵥SPU�����",    
    
`spu_profit_rate_pushin7d` as  "�Ƽ�7��SPU�ع���",
`spu_profit_rate_pushin14d` as  "�Ƽ�14��SPU�ع���",
`spu_profit_rate_pushin30d` as  "�Ƽ�30��SPU�ع���",    
    
`spu_clicks_rate_pushin7d` as  "�Ƽ�7��SPU�����",
`spu_clicks_rate_pushin14d` as  "�Ƽ�14��SPU�����",
`spu_clicks_rate_pushin30d` as  "�Ƽ�30��SPU�����",
/*
`avg_lst_exposure_pushin7d` as  "�Ƽ�7�쵥�����ع���",
`avg_lst_exposure_pushin14d` as  "�Ƽ�14�쵥�����ع���",
`avg_lst_exposure_pushin30d` as  "�Ƽ�30�쵥�����ع���",    
    
`ad_exposure_rate_pushin7d` as  "�Ƽ�7�����ع���",
`ad_exposure_rate_pushin14d` as  "�Ƽ�14�����ع���",
`ad_exposure_rate_pushin30d` as  "�Ƽ�30�����ع���",    
    
`ad_clicks_rate_pushin7d` as  "�Ƽ�7��������",
`ad_clicks_rate_pushin14d` as  "�Ƽ�14��������",
`ad_clicks_rate_pushin30d` as  "�Ƽ�30��������",
 */
`ad_sale_rate_pushin7d` as  "�Ƽ�7����ת����",
`ad_sale_rate_pushin14d` as  "�Ƽ�14����ת����",
`ad_sale_rate_pushin30d` as  "�Ƽ�30����ת����",
    
`ad_cpc_pushin7d` as  "�Ƽ�7��CPC",
`ad_cpc_pushin14d` as  "�Ƽ�14��CPC",
`ad_cpc_pushin30d` as  "�Ƽ�30��CPC",

`spu_tophot_pushin30d_newlst` as  "�Ƽ�30���¿��Ǳ�������",
`sale_rate_pushin30d_newlst` as  "�Ƽ�30���¿��Ǳ�����",
`sale_amount_tophot_pushin30d_newlst`as  "�Ƽ�30�챬�������۶�",

`online_spu_cnt_newlst` as "�¿�������SPU��",
`online_spu_cnt_achieved_newlst` as  "�¿������ߴ��SPU��",
`lst_cnt_newlst` as  "����������",
`lst_cnt_newlst_mainsite` as  "����������_��վ��"
-- `avg_days_dev2lst` as  "ƽ���׵�����"

from ads_kbh_prod_potential_track_new_lst t0
join dim on t0.DimensionId = dim.DimensionId
order by ������,������ desc

