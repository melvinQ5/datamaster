select
DimensionId as 分析维度,
`Year` as "终审年",
`Week` as "终审周",
FirstDay as 当期第一天,
    
`dev_spu_cnt`as "终审SPU数",
`sale_rate_over1_devin7d` as  "终审7天1单动销率",
`sale_rate_over1_devin14d` as  "终审14天1单动销率",
`sale_rate_over1_devin30d` as  "终审30天1单动销率",
`sale_rate_over1_devin90d` as  "终审90天1单动销率",

`sale_rate_over3_devin14d` as  "终审14天3单动销率",
`sale_rate_over3_devin30d` as  "终审30天3单动销率",

`sale_rate_over6_devin14d` as  "终审14天6单动销率",
`sale_rate_over6_devin30d` as  "终审30天6单动销率",

`sale_rate_over1_lstin7d` as  "刊登7天1单动销率",
`sale_rate_over1_lstin14d` as  "刊登14天1单动销率",
`sale_rate_over1_lstin30d` as  "刊登30天1单动销率",

`sale_rate_over3_lstin14d` as  "刊登14天3单动销率",
`sale_rate_over3_lstin30d` as  "刊登30天3单动销率",

`sale_rate_over6_lstin14d` as  "刊登14天6单动销率",
`sale_rate_over6_lstin30d` as  "刊登30天6单动销率",


`sale_amount_odin30d` as  "首单30天销售额",
`sale_unitamount_odin30d` as  "首单30天单产",
    
`spu_tophot_devin30d`as "终审30天爆旺款数",
`sale_rate_devin30d` as "终审30天爆旺率",
`sale_amount_tophot_devin30d` as  "终审30天爆旺款销售额",

`sale_amount_devin7d` as  "终审7天销售额S2",
`sale_amount_devin14d` as  "终审14天销售额S2",
`sale_amount_devin30d` as  "终审30天销售额S2",
`sale_amount_devin60d` as  "终审60天销售额S2",
`sale_amount_devin90d` as  "终审90天销售额S2",
`sale_amount_newprod` as  "新品期销售额S2",

`adspend_devin7d` as  "终审7天广告花费",
`adspend_devin14d` as  "终审14天广告花费",
`adspend_devin30d` as  "终审30天广告花费",
`adspend_devin60d` as  "终审60天广告花费",
`adspend_devin90d` as  "终审90天广告花费",

`profit_rate_devin7d` as  "终审7天利润率R2",
`profit_rate_devin14d` as  "终审14天利润率R2",
`profit_rate_devin30d` as  "终审30天利润率R2",
`profit_rate_devin60d` as  "终审60天利润率R2",
`profit_rate_devin90d` as  "终审90天利润率R2",

`spu_exposure_devin7d` as  "终审7天单SPU曝光量",
`spu_exposure_devin14d` as  "终审14天单SPU曝光量",
`spu_exposure_devin30d` as  "终审30天单SPU曝光量",

`spu_clicks_devin7d` as  "终审7天单SPU点击量",
`spu_clicks_devin14d` as  "终审14天单SPU点击量",
`spu_clicks_devin30d` as  "终审30天单SPU点击量",

`spu_exposure_rate_devin7d` as  "终审7天SPU曝光率",
`spu_exposure_rate_devin14d` as  "终审14天SPU曝光率",
`spu_exposure_rate_devin30d` as  "终审30天SPU曝光率",

`spu_clicks_rate_devin7d` as  "终审7天SPU点击率",
`spu_clicks_rate_devin14d` as  "终审14天SPU点击率",
`spu_clicks_rate_devin30d` as  "终审30天SPU点击率",
/*
`avg_lst_exposure_devin7d` as  "终审7天单链接曝光量",
`avg_lst_exposure_devin14d` as  "终审14天单链接曝光量",
`avg_lst_exposure_devin30d` as  "终审30天单链接曝光量",
 */

`ad_clicks_rate_devin7d` as  "终审7天广告点击率",
`ad_clicks_rate_devin14d` as  "终审14天广告点击率",
`ad_clicks_rate_devin30d` as  "终审30天广告点击率",

`ad_sale_rate_devin7d` as  "终审7天广告转化率",
`ad_sale_rate_devin14d` as  "终审14天广告转化率",
`ad_sale_rate_devin30d` as  "终审30天广告转化率",

`ad_cpc_devin7d` as  "终审7天CPC",
`ad_cpc_devin14d` as  "终审14天CPC",
`ad_cpc_devin30d` as  "终审30天CPC",

`online_spu_cnt`as "在线SPU数",
`online_spu_cnt_achieved`as "在线达标SPU数",
`lst_cnt`as "刊登链接数",
`avg_days_dev2lst` as  "平均首登天数"

from ads_kbh_prod_new_dev_track
order by DimensionId,终审年,终审周 desc