with
dim as (
select md5('快百货') as DimensionId ,'快百货' team , null istheme_ele
union all select md5('快百货冬季') as DimensionId ,'快百货' team ,'冬季' istheme_ele
union all select md5('快百货圣诞节') ,'快百货','圣诞节'
union all select md5('快百货非主题品') ,'快百货','非主题品'
)

select
team as 部门,
istheme_ele as 主题元素,

`Year` as "推送年",
`Week` as "推送周",
FirstDay as 当期第一天,


`push_spu_cnt` as "推荐SPU数",
`sale_rate_over1_pushin7d` as  "推荐7天1单动销率",
`sale_rate_over1_pushin14d` as  "推荐14天1单动销率",
`sale_rate_over1_pushin30d` as  "推荐30天1单动销率",
`sale_rate_over1_pushin60d` as  "推荐60天1单动销率",
`sale_rate_over1_pushin90d` as  "推荐90天1单动销率",

`sale_rate_over3_pushin14d` as  "推荐14天3单动销率",
`sale_rate_over3_pushin30d` as  "推荐30天3单动销率",
    
`sale_rate_over6_pushin14d` as  "推荐14天6单动销率",
`sale_rate_over6_pushin30d` as  "推荐30天6单动销率",    
    
`sale_rate_over1_lstin7d` as  "刊登7天1单动销率",
`sale_rate_over1_lstin14d` as  "刊登14天1单动销率",
`sale_rate_over1_lstin30d` as  "刊登30天1单动销率",
    
`sale_rate_over3_lstin14d` as  "刊登14天3单动销率",
`sale_rate_over3_lstin30d` as  "刊登30天3单动销率",
    
`sale_rate_over6_lstin14d` as  "刊登14天6单动销率",
`sale_rate_over6_lstin30d` as  "刊登30天6单动销率",

`sale_amount_odin30d` as  "首单30天销售额",
`sale_unitamount_odin30d` as  "首单30天单产",

`sale_amount_pushin7d` as  "推荐7天销售额",
`sale_amount_pushin14d` as  "推荐14天销售额",
`sale_amount_pushin30d` as  "推荐30天销售额",
`sale_amount_pushin60d` as  "推荐60天销售额",
`sale_amount_pushin90d` as  "推荐90天销售额",
    
`adspend_pushin7d` as  "推荐7天广告花费",
`adspend_pushin14d` as  "推荐14天广告花费",
`adspend_pushin30d` as  "推荐30天广告花费",
`adspend_pushin60d` as  "推荐60天广告花费",
`adspend_pushin90d` as  "推荐90天广告花费",

`profit_rate_pushin7d` as  "推荐7天利润率",
`profit_rate_pushin14d` as  "推荐14天利润率",
`profit_rate_pushin30d` as  "推荐30天利润率",
`profit_rate_pushin60d` as  "推荐60天利润率",
`profit_rate_pushin90d` as  "推荐90天利润率",
    
`spu_exposure_pushin7d` as  "推荐7天单SPU曝光量",
`spu_exposure_pushin14d` as  "推荐14天单SPU曝光量",
`spu_exposure_pushin30d` as  "推荐30天单SPU曝光量",
    
`spu_clicks_pushin7d` as  "推荐7天单SPU点击量",
`spu_clicks_pushin14d` as  "推荐14天单SPU点击量",
`spu_clicks_pushin30d` as  "推荐30天单SPU点击量",    
    
`spu_profit_rate_pushin7d` as  "推荐7天SPU曝光率",
`spu_profit_rate_pushin14d` as  "推荐14天SPU曝光率",
`spu_profit_rate_pushin30d` as  "推荐30天SPU曝光率",    
    
`spu_clicks_rate_pushin7d` as  "推荐7天SPU点击率",
`spu_clicks_rate_pushin14d` as  "推荐14天SPU点击率",
`spu_clicks_rate_pushin30d` as  "推荐30天SPU点击率",
/*
`avg_lst_exposure_pushin7d` as  "推荐7天单链接曝光量",
`avg_lst_exposure_pushin14d` as  "推荐14天单链接曝光量",
`avg_lst_exposure_pushin30d` as  "推荐30天单链接曝光量",    
    
`ad_exposure_rate_pushin7d` as  "推荐7天广告曝光率",
`ad_exposure_rate_pushin14d` as  "推荐14天广告曝光率",
`ad_exposure_rate_pushin30d` as  "推荐30天广告曝光率",    
    
`ad_clicks_rate_pushin7d` as  "推荐7天广告点击率",
`ad_clicks_rate_pushin14d` as  "推荐14天广告点击率",
`ad_clicks_rate_pushin30d` as  "推荐30天广告点击率",
 */
`ad_sale_rate_pushin7d` as  "推荐7天广告转化率",
`ad_sale_rate_pushin14d` as  "推荐14天广告转化率",
`ad_sale_rate_pushin30d` as  "推荐30天广告转化率",
    
`ad_cpc_pushin7d` as  "推荐7天CPC",
`ad_cpc_pushin14d` as  "推荐14天CPC",
`ad_cpc_pushin30d` as  "推荐30天CPC",

`spu_tophot_pushin30d_newlst` as  "推荐30天新刊登爆旺款数",
`sale_rate_pushin30d_newlst` as  "推荐30天新刊登爆旺率",
`sale_amount_tophot_pushin30d_newlst`as  "推荐30天爆旺款销售额",

`online_spu_cnt_newlst` as "新刊登在线SPU数",
`online_spu_cnt_achieved_newlst` as  "新刊登在线达标SPU数",
`lst_cnt_newlst` as  "刊登链接数",
`lst_cnt_newlst_mainsite` as  "刊登链接数_主站点"
-- `avg_days_dev2lst` as  "平均首登天数"

from ads_kbh_prod_potential_track_new_lst t0
join dim on t0.DimensionId = dim.DimensionId
order by 推送年,推送周 desc

