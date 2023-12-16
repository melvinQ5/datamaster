
CREATE TABLE IF NOT EXISTS
ads_kbh_prod_new_dev_track (
`DimensionId` varchar(64) NOT NULL COMMENT "维度id",
`Year` int(11) NOT NULL COMMENT "统计年",
`Month` int(11) NOT NULL COMMENT "统计月",
`Week` int(11) NOT NULL COMMENT "统计周",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除" ,
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "写入时间",
`ReportType` varchar(10) REPLACE_IF_NOT_NULL NULL  COMMENT  "报表频次",
`FirstDay` date REPLACE_IF_NOT_NULL NULL  COMMENT  "统计期第一天" ,
    
`dev_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "终审SPU数",
`sale_rate_over1_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天1单动销率",
`sale_rate_over1_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天1单动销率",
`sale_rate_over1_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天1单动销率",
`sale_rate_over1_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审90天1单动销率",


`sale_rate_over3_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天3单动销率",
`sale_rate_over3_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天3单动销率",

`sale_rate_over6_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天6单动销率",
`sale_rate_over6_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天6单动销率",

`sale_rate_over1_lstin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登7天1单动销率",
`sale_rate_over1_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登14天1单动销率",
`sale_rate_over1_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登30天1单动销率",

`sale_rate_over3_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登14天3单动销率",
`sale_rate_over3_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登30天3单动销率",

`sale_rate_over6_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登14天6单动销率",
`sale_rate_over6_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登30天6单动销率",


`sale_amount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "首单30天销售额",
`sale_unitamount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "首单30天单产",
    
`spu_tophot_devin30d` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "终审30天爆旺款数",
`sale_rate_devin30d` double REPLACE_IF_NOT_NULL NULL COMMENT "终审30天爆旺率",
`sale_amount_tophot_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天爆旺款销售额",

`sale_amount_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天销售额",
`sale_amount_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天销售额",
`sale_amount_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天销售额",
`sale_amount_devin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审60天销售额",
`sale_amount_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审90天销售额",
`sale_amount_newprod` double REPLACE_IF_NOT_NULL NULL  COMMENT  "新品期销售额",

`adspend_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天广告花费",
`adspend_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天广告花费",
`adspend_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天广告花费",
`adspend_devin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审60天广告花费",
`adspend_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审90天广告花费",

`profit_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天利润率",
`profit_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天利润率",
`profit_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天利润率",
`profit_rate_devin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审60天利润率",
`profit_rate_devin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审90天利润率",

`spu_exposure_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天单SPU曝光量",
`spu_exposure_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天单SPU曝光量",
`spu_exposure_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天单SPU曝光量",

`spu_clicks_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天单SPU点击量",
`spu_clicks_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天单SPU点击量",
`spu_clicks_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天单SPU点击量",

`spu_exposure_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天SPU曝光率",
`spu_exposure_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天SPU曝光率",
`spu_exposure_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天SPU曝光率",

`spu_clicks_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天SPU点击率",
`spu_clicks_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天SPU点击率",
`spu_clicks_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天SPU点击率",

`avg_lst_exposure_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天单链接曝光量",
`avg_lst_exposure_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天单链接曝光量",
`avg_lst_exposure_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天单链接曝光量",

`ad_clicks_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天广告点击率",
`ad_clicks_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天广告点击率",
`ad_clicks_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天广告点击率",

`ad_sale_rate_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天广告转化率",
`ad_sale_rate_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天广告转化率",
`ad_sale_rate_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天广告转化率",

`ad_cpc_devin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审7天CPC",
`ad_cpc_devin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审14天CPC",
`ad_cpc_devin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "终审30天CPC",

`online_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "在线SPU数",
`online_spu_cnt_achieved` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "在线达标SPU数（按SPU在线4套且20条正常链接）",
`lst_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "刊登链接数",
`avg_days_dev2lst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "平均首登天数"


) ENGINE=OLAP
AGGREGATE KEY(DimensionId,Year,Month,Week)
COMMENT "快百货新品表现追踪"
DISTRIBUTED BY HASH(DimensionId,Year,Month,Week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

# 更新
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

# 清空 truncate table ads_kbh_prod_potential_track_new_lst