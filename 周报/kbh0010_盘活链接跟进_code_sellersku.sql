
with t_list as ( -- 盘活链接
select wl.shopcode ,wl.sellersku ,sku ,spu ,nodepathname ,SellUserName  ,site ,m.c4 as activate_week ,MinPublicationDate
from manual_table m
join import_data.wt_listing wl on m.handlename ='快百货盘活链接' and handletime = '2023-09-19' and wl.IsDeleted = 0 and m.c2 =wl.shopcode and m.c3=wl.sellersku
join import_data.mysql_store ms on wl.shopcode=ms.Code and department = '快百货'
)




,t_orde_week_stat as ( -- 用于累计订单
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
	,round( sum(FeeGross/ExchangeUSD ),2 ) FeeGross_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   -- 获取更久远的数据是为了包含到表主键的自然周
	and wo.IsDeleted=0
	and ms.Department = '快百货'  and TransactionType != '其他' -- 未含付款类型为其他
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select ta.shopcode  ,ta.sellersku ,week_num_in_year as ad_stat_week
		-- 曝光量
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(Spend),2) as ad_Spend
		-- 广告销售额
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- 广告销量
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_list ta -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
        left join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU
        join dim_date on dim_date.full_date = asa.CreatedTime
        group by ta.shopcode  ,ta.sellersku  ,ad_stat_week
	) tmp
)


,prod as (
select wp.spu ,wp.sku,boxsku ,DevelopLastAuditTime ,prod_level
from wt_products wp
join (select distinct sku from t_list ) l on wp.sku = l.sku
LEFT JOIN ( SELECT distinct spu ,prod_level from dep_kbh_product_level where FirstDay =  date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -1 week) ) dk
    on wp.spu =dk.spu
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku
)

,prod_seller as (
select sku ,group_concat(SellUserName) seller_list
from (
    select sku, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    group by sku, eaapis.SellUserName
    ) tmp
group by sku
)

,t_merage as (
select t1.shopcode ,t1.sellersku
    ,t1.activate_week 盘活周
	,key_week 自然周
    ,pay_week 订单周
    ,case when nodepathname regexp '成都' then '成都' else '泉州' end as 销售部门
    ,nodepathname as 销售小组
    ,SellUserName as 首选业务员
    ,site as 国家
    ,t6.SKU
    ,t6.boxsku
    ,t6.SPU
    ,prod_level 最新商品分层
    ,DevelopLastAuditTime 产品终审时间
    ,ele 元素
    ,seller_list sku销售负责人
    ,DATE(MinPublicationDate) 链接上架时间
    ,TotalGross_weekly `销售额`
    ,round(TotalProfit_weekly - ifnull(ad_Spend,0),2) `扣广告利润额`
    ,salecount_weekly `销量`
    ,FeeGross_weekly `运费收入`
    ,ad_sku_Exposure `当周广告曝光量`
	,ad_Spend `当周广告花费`
	,ad_TotalSale7Day `当周广告销售额`
	,ad_sku_TotalSale7DayUnit `当周广告销量`
	,ad_sku_Clicks `当周广告点击量`
	,click_rate `当周广告点击率`
	,adsale_rate `当周广告转化率`
	,ROAS `当周ROAS`
	,ACOS `当周ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `当周CPC`

from ( select lm.* , week_num_in_year as key_week
	from t_list lm
	join ( select distinct week_num_in_year
	       from dim_date dd
	        join (select max(activate_week) max_activate_week  from t_list ) lmax -- 获取最大盘活周次
	        join (select min(activate_week) min_activate_week  from t_list ) lmax -- 获取最大盘活周次
	       where year= year('${NextStartDay}') and week_num_in_year <= max_activate_week + 4 and week_num_in_year >= min_activate_week ) dd
	) t1
left join t_orde_week_stat t2 on t1.shopcode = t2.shopcode and t1.sellersku = t2.sellersku and t1.key_week = t2.pay_week and t2.pay_week <= t1.activate_week +4
left join t_ad_stat t3 on t1.shopcode = t3.shopcode and t1.sellersku = t3.sellersku and t1.key_week = t3.ad_stat_week and t3.ad_stat_week <= t1.activate_week +4
left join prod_seller t4 on t1.sku =t4.sku
left join t_elem t5 on t1.sku =t5.sku
left join prod t6 on t1.sku =t6.sku
)

select * from t_merage where 订单周 is null and 盘活周 = 自然周
union all
select * from t_merage where 订单周 is not null

-- select * from t_merage order by ShopCode ,SellerSKU ,订单周