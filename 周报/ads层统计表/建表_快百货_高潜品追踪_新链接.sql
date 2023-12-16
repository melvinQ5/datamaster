
CREATE TABLE IF NOT EXISTS
ads_kbh_prod_potential_track_new_lst (
`DimensionId` varchar(64) NOT NULL COMMENT "维度id",
`Year` int(11) NOT NULL COMMENT "统计年",
`Month` int(11) NOT NULL COMMENT "统计月",
`Week` int(11) NOT NULL COMMENT "统计周",
`isdeleted` int(8) REPLACE_IF_NOT_NULL NULL  COMMENT  "是否删除" ,
`wttime` datetime REPLACE_IF_NOT_NULL NOT NULL COMMENT "写入时间",


`push_spu_cnt` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "推荐SPU数",
`sale_rate_over1_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天1单动销率",
`sale_rate_over1_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天1单动销率",
`sale_rate_over1_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天1单动销率",
`sale_rate_over1_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐60天1单动销率",
`sale_rate_over1_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐90天1单动销率",

`sale_rate_over3_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天3单动销率",
`sale_rate_over3_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天3单动销率",
    
`sale_rate_over6_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天6单动销率",
`sale_rate_over6_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天6单动销率",    
    
`sale_rate_over1_lstin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登7天1单动销率",
`sale_rate_over1_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登14天1单动销率",
`sale_rate_over1_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登30天1单动销率",
    
`sale_rate_over3_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登14天3单动销率",
`sale_rate_over3_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登30天3单动销率",
    
`sale_rate_over6_lstin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登14天6单动销率",
`sale_rate_over6_lstin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "刊登30天6单动销率",

`sale_amount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "首单30天销售额",
`sale_unitamount_odin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "首单30天单产",

`sale_amount_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天销售额",
`sale_amount_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天销售额",
`sale_amount_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天销售额",
`sale_amount_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐60天销售额",
`sale_amount_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐90天销售额",
    
`adspend_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天广告花费",
`adspend_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天广告花费",
`adspend_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天广告花费",
`adspend_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐60天广告花费",
`adspend_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐90天广告花费",

`profit_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天利润率",
`profit_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天利润率",
`profit_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天利润率",
`profit_rate_pushin60d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐60天利润率",
`profit_rate_pushin90d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐90天利润率",
    
`spu_exposure_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天单SPU曝光量",
`spu_exposure_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天单SPU曝光量",
`spu_exposure_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天单SPU曝光量",
    
`spu_clicks_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天单SPU点击量",
`spu_clicks_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天单SPU点击量",
`spu_clicks_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天单SPU点击量",    
    
`spu_profit_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天SPU曝光率",
`spu_profit_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天SPU曝光率",
`spu_profit_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天SPU曝光率",    
    
`spu_clicks_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天SPU点击率",
`spu_clicks_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天SPU点击率",
`spu_clicks_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天SPU点击率",
    
`avg_lst_exposure_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天单链接曝光量",
`avg_lst_exposure_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天单链接曝光量",
`avg_lst_exposure_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天单链接曝光量",    
    
`ad_exposure_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天广告曝光率",
`ad_exposure_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天广告曝光率",
`ad_exposure_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天广告曝光率",    
    
`ad_clicks_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天广告点击率",
`ad_clicks_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天广告点击率",
`ad_clicks_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天广告点击率",

`ad_sale_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天广告转化率",
`ad_sale_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天广告转化率",
`ad_sale_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天广告转化率",
    
`ad_cpc_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天CPC",
`ad_cpc_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天CPC",
`ad_cpc_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天CPC",

`sale_amount_pushin90d_themes` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐主题品90天销售额",
`sale_amount_pushin90d_unthemes` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐常规品90天销售额",

`spu_tophot_pushin30d_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "推荐30天新刊登爆旺款数",
`sale_rate_pushin30d_newlst` double REPLACE_IF_NOT_NULL NULL COMMENT "推荐30天新刊登爆旺率",
`sale_amount_tophot_pushin30d_newlst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天爆旺款销售额",

`online_spu_cnt_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "新刊登在线SPU数",
`online_spu_cnt_achieved_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "新刊登在线达标SPU数",
`lst_cnt_newlst` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "刊登链接数",
`lst_cnt_newlst_mainsite` int(11) REPLACE_IF_NOT_NULL NULL COMMENT "刊登链接数_主站点",
`avg_days_dev2lst` double REPLACE_IF_NOT_NULL NULL  COMMENT  "平均首登天数"

) ENGINE=OLAP
AGGREGATE KEY(DimensionId,Year,Month,Week)
COMMENT "快百货高潜品新链接统计表"
DISTRIBUTED BY HASH(DimensionId,Year,Month,Week) BUCKETS 10
PROPERTIES (
"replication_num" = "3",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);

# 更新
ALTER TABLE ads_kbh_prod_potential_track_new_lst ADD COLUMN `ReportType` varchar(10) REPLACE_IF_NOT_NULL NULL  COMMENT  "报表频次" after wttime;
ALTER TABLE ads_kbh_prod_potential_track_new_lst ADD COLUMN `FirstDay` date REPLACE_IF_NOT_NULL NULL  COMMENT  "统计期第一天" after ReportType;
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `spu_profit_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐7天SPU曝光率(英文名错误,应exposure)";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `spu_profit_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐14天SPU曝光率(英文名错误,应exposure)";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `spu_profit_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "推荐30天SPU曝光率(英文名错误,应exposure)";

ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `ad_exposure_rate_pushin7d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "废弃字段";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `ad_exposure_rate_pushin14d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "废弃字段";
ALTER TABLE ads_kbh_prod_potential_track_new_lst MODIFY COLUMN  `ad_exposure_rate_pushin30d` double REPLACE_IF_NOT_NULL NULL  COMMENT  "废弃字段";




# 清空 truncate table ads_kbh_prod_potential_track_new_lst