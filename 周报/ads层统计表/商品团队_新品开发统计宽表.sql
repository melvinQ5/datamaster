/* 
新品分析模块\统计分析表\商品团队_新品统计宽表
定位：分析从产品添加环节 一直到之后的销售表现的全流程表现
输出类型：多维分析表
维度：商品团队 x 产品终审时间（周+月） 
	商品团队维度枚举：1级快百货 2级快百货一二部 3级开发小组 4级开发人员
指标：
	开品量
		终审SPU数
		终审SKU数
	动销结果
		终审7天SPU动销率：
		终审14天SPU动销率：
		终审30天SPU动销率：
		终审7天SKU动销率：
		终审14天SKU动销率：
		终审30天SKU动销率：
	出单
		首单30天SPU销售额
		首单30天SPU单产 首单30天SPU销售额 / 出单SPU数
		终审30天SPU单产: 首单30天SPU销售额 / 终审SPU数
	刊登
		累计链接数
		新刊登新品LST动销率：
	广告投放
		有无曝光
			终审7天曝光SKU占比（对已刊登SKU从终审开始统计后续表现，下同）
			终审14天曝光SKU占比
			终审30天曝光SKU占比
		有曝光链接的广告表现
			终审7/15/30天 花费、曝光、点击、销量、销售额
			终审7/15/30天 点击率、转化率、CPC、ROAS、ACOS	、单链接曝光			
主要数据源：链接表、广告明细表
*/

-- NextStartDay 23-03-01 ，NextStartDay 至今


with
t_prod as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, dd.week_begin_date
 	, dd.week_num_in_year as dev_week
 	, left(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour),7) dev_month
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, vr.department
 	, vr.NodePathName
 	, vr.dep2
from import_data.erp_product_products epp
left join 
	( select split(NodePathNameFull,'>')[2] as dep2 
		,case when  NodePathName = '商品组' then '快节奏-商品组' else NodePathName end NodePathName
		,name ,department
	from view_roles 
	where ProductRole ='开发'
-- 	and NodePathName in ('快次方-商品组','快次元-商品组','商品组')
	) vr on epp.DevelopUserName = vr.name
left join dim_date dd on date(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour)) = dd.full_date
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-01-01' 
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='快百货' 
	and epp.DevelopUserName != '杨春花'
)


-- select * from t_prod where department is null 

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,shopcode ,asin 
	,TransactionType,SellerSku,RefundAmount
	, TotalGross/ExchangeUSD as AfterTax_TotalGross
	, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,wo.BoxSku 
	,PayTime
	,timestampdiff(SECOND,t_prod.DevelopLastAuditTime,PayTime)/86400 as ord_days 
	, timestampdiff(SECOND,spu_min_paytime,PayTime)/86400 as ord_days_since_od 
	,t_prod.Department
	,t_prod.dep2 
	,t_prod.NodePathName 
	,t_prod.DevelopUserName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_prod on wo.Product_SKU = t_prod.sku 
left join ( select Product_SPU , min(PayTime) as spu_min_paytime 
	from import_data.wt_orderdetails  od1
	join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
	and ms1.Department ='快百货' and PayTime >= '2023-01-01'  -- 为了算首单30天 
	where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 
	group by Product_SPU
	) tmp_min on wo.Product_SPU =tmp_min.Product_SPU 
where 
	wo.IsDeleted=0 
-- 	and TransactionType = '付款'  
	and OrderStatus <> '作废' and OrderTotalPrice > 0 
	and ms.Department = '快百货'
)


,t_list as ( -- 新品链接
select  SellerSKU ,ShopCode ,asin 
	, site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, wl.SPU ,wl.SKU ,MinPublicationDate  ,MarketType 
	,DevelopLastAuditTime
	,t_prod.Department
	,t_prod.dep2 
	,t_prod.NodePathName 
	,t_prod.DevelopUserName 
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku -- 只看新品
where 
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
)

,t_ad as ( -- 广告明细
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- 广告
	,t_list.site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, Department
	, dep2 
	, NodePathName 
	, DevelopUserName 
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
)


,t_prod_stat as ( 
select concat(ifnull(Department,''),ifnull(NodePathName,''),ifnull(DevelopUserName,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	, Department,NodePathName,DevelopUserName,dev_month,dev_week
	, dev_sku_cnt `开发sku数`
	, dev_spu_cnt `开发spu数`
	, round(ord7_sku_cnt/dev_sku_cnt,4) as `终审7天SKU动销率`, round(ord14_sku_cnt/dev_sku_cnt,4) as `终审14天SKU动销率`, round(ord30_sku_cnt/dev_sku_cnt,4) as `终审30天SKU动销率`
	, round(ord7_spu_cnt/dev_spu_cnt,4) as `终审7天SPU动销率`, round(ord14_spu_cnt/dev_spu_cnt,4) as `终审14天SPU动销率`
	, round(ord30_spu_cnt/dev_spu_cnt,4) as `终审30天SPU动销率`
	, round(ord_spu_cnt/dev_spu_cnt,4) as `累计SPU动销率`
	, ord7_sku_sales `终审7天销售额`, ord14_sku_sales `终审14天销售额`, ord30_sku_sales `终审30天销售额` 
	, ord30_sku_sales_since_od `首单30天销售额`
	,round(ord30_sku_sales_since_od/dev_spu_cnt) `终审30天SPU单产`
	,round(ord30_sku_sales_since_od/ord30_spu_cnt_since_od) `首单30天SPU单产`
	,销售额2301
	,销售额2302
	,销售额2303
	,销售额2304
	,销售额2305
	,销售额2306
	,销售额2307
	,销售额2308
	,销售额2309
	,销售额2310
	,销售额2311
	,销售额2312
from ( 
	select t.Department,t.NodePathName,t.DevelopUserName,t.dev_month ,t.dev_week
		, count(distinct t.SPU) as dev_spu_cnt
		, count(distinct t.SKU) as dev_sku_cnt
		
		, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.SPU end) as ord7_spu_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.SPU end) as ord14_spu_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.SPU end) as ord30_spu_cnt
		, count(distinct case when 0 <= ord_days then od.SPU end) as ord_spu_cnt
		, count(distinct case when 0 <= ord_days_since_od and ord_days_since_od  <= 30 then od.spu end) as ord30_spu_cnt_since_od

		, count(distinct case when 0 <= ord_days and ord_days <= 7  then od.sku end) as ord7_sku_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 14 then od.sku end) as ord14_sku_cnt
		, count(distinct case when 0 <= ord_days and ord_days  <= 30 then od.sku end) as ord30_sku_cnt
		
		, round(sum(case when 0 <= ord_days and ord_days <= 7 then AfterTax_TotalGross end)) as ord7_sku_sales
		, round(sum(case when 0 <= ord_days and ord_days <= 14 then AfterTax_TotalGross end)) as ord14_sku_sales
		, round(sum(case when 0 <= ord_days and ord_days <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales
		, round(sum(case when 0 <= ord_days_since_od and ord_days_since_od <= 30 then AfterTax_TotalGross end)) as ord30_sku_sales_since_od 

			
		,round(sum(case when left(paytime,7)='2023-01' then AfterTax_TotalGross end )) as 销售额2301
		,round(sum(case when left(paytime,7)='2023-02' then AfterTax_TotalGross end )) as 销售额2302
		,round(sum(case when left(paytime,7)='2023-03' then AfterTax_TotalGross end )) as 销售额2303
		,round(sum(case when left(paytime,7)='2023-04' then AfterTax_TotalGross end )) as 销售额2304
		,round(sum(case when left(paytime,7)='2023-05' then AfterTax_TotalGross end )) as 销售额2305
		,round(sum(case when left(paytime,7)='2023-06' then AfterTax_TotalGross end )) as 销售额2306
		,round(sum(case when left(paytime,7)='2023-07' then AfterTax_TotalGross end )) as 销售额2307
		,round(sum(case when left(paytime,7)='2023-08' then AfterTax_TotalGross end )) as 销售额2308
		,round(sum(case when left(paytime,7)='2023-09' then AfterTax_TotalGross end )) as 销售额2309
		,round(sum(case when left(paytime,7)='2023-10' then AfterTax_TotalGross end )) as 销售额2310
		,round(sum(case when left(paytime,7)='2023-11' then AfterTax_TotalGross end )) as 销售额2311
		,round(sum(case when left(paytime,7)='2023-12' then AfterTax_TotalGross end )) as 销售额2312
		
		-- 3月终审的产品在付款时间3月的销售额
	from t_prod t left join t_orde od on od.BoxSku =t.BoxSKU  
	group by grouping sets (
		(t.Department,t.dev_month) -- 部门x月
		,(t.Department,t.dev_week) -- 部门x周
		,(t.Department,t.NodePathName,t.dev_month) -- 开发组x月
		,(t.Department,t.NodePathName,t.dev_week) -- 开发组x周
		,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_month) -- 开发人员x月
		,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_week) -- 开发人员x周
		) 
	) tmp
)
-- select * from t_prod_stat where 

,t_list_stat as ( -- 刊登统计
select concat(ifnull(Department,''),ifnull(NodePathName,''),ifnull(DevelopUserName,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	,Department,NodePathName,DevelopUserName,dev_month,dev_week
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when timestampdiff(second,DevelopLastAuditTime,MinPublicationDate)/86400 <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode) ) list_cnt
	,count(distinct t_list.SKU ) list_sku_cnt
	,count(distinct t_list.SPU ) list_spu_cnt
	from t_list 
group by grouping sets (
	(Department,dev_month) -- 部门x月
	,(Department,dev_week) -- 部门x周
	,(Department,NodePathName,dev_month) -- 开发组x月
	,(Department,NodePathName,dev_week) -- 开发组x周
	,(Department,NodePathName,DevelopUserName,dev_month) -- 开发人员x月
	,(Department,NodePathName,DevelopUserName,dev_week) -- 开发人员x周
	) 
)
-- select * from t_list_stat

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `累计广告点击率` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `终审7天广告点击率`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `终审14天广告点击率`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `终审30天广告点击率`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `累计广告转化率`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `终审7天广告转化率`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `终审14天广告转化率`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `终审30天广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,2) as `累计ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `终审7天ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `终审14天ROAS`, round(ad30_TotalSale7Day/ad30_Spend,2) as `终审30天ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `累计ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `终审7天ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `终审14天ACOS`, round(ad30_Spend/ad30_TotalSale7Day,2) as `终审30天ACOS`
from 
	( select 
		concat(ifnull(t.Department,''),ifnull(t.NodePathName,''),ifnull(t.DevelopUserName,''),ifnull(t.dev_month,''),ifnull(t.dev_week,'')) tbcode 
		,t.Department,t.NodePathName,t.DevelopUserName,t.dev_month ,t.dev_week
		-- 曝光量
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Exposure end)) as ad30_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- 广告花费
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then cost*ExchangeUSD end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then cost*ExchangeUSD end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then cost*ExchangeUSD end),2) as ad30_Spend
		, round(sum(cost*ExchangeUSD),2) as ad_Spend
		-- 广告销售额
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7Day end),2) as ad30_TotalSale7Day
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- 广告销量	
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7DayUnit end),2) as ad30_sku_TotalSale7DayUnit
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Clicks end)) as ad30_sku_Clicks
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad t
		group by grouping sets (
			(t.Department,t.dev_month) -- 部门x月
			,(t.Department,t.dev_week) -- 部门x周
			,(t.Department,t.NodePathName,t.dev_month) -- 开发组x月
			,(t.Department,t.NodePathName,t.dev_week) -- 开发组x周
			,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_month) -- 开发人员x月
			,(t.Department,t.NodePathName,t.DevelopUserName,t.dev_week) -- 开发人员x周
			) 
	) tmp  
)
-- select * from t_ad_stat

,t_merage as (
select
	case 
		when concat(t_prod_stat.Department,t_prod_stat.dev_month) is not null and coalesce(t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_week) is null then  '快百货x终审月' 
		when concat(t_prod_stat.Department,t_prod_stat.dev_week) is not null and coalesce(t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_month) is null then  '快百货x终审周' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.dev_month) is not null and coalesce(t_prod_stat.DevelopUserName,t_prod_stat.dev_week) is null then  '开发团队x终审月' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.dev_week) is not null and coalesce(t_prod_stat.DevelopUserName,t_prod_stat.dev_month) is null then  '开发团队x终审周' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_month) is not null and coalesce(t_prod_stat.dev_week) is null then  '开发人员x终审月' 
		when concat(t_prod_stat.Department,t_prod_stat.NodePathName,t_prod_stat.DevelopUserName,t_prod_stat.dev_week) is not null and coalesce(t_prod_stat.dev_month) is null then  '开发人员x终审周' 
	end as `预置分析维度`
-- 	,t_prod_stat.Department
	,t_prod_stat.NodePathName `开发团队`
	,t_prod_stat.DevelopUserName `开发人员`
	,t_prod_stat.dev_month  `终审月份`
	,t_prod_stat.dev_week `终审周次`

	,`开发sku数`
	,`开发spu数`
	
	,`终审7天SPU动销率`
	,`终审14天SPU动销率`
	,`终审30天SPU动销率`
	,`累计SPU动销率`

	,`终审7天SKU动销率`
	,`终审14天SKU动销率`
	,`终审30天SKU动销率`
	
	,销售额2301
	,销售额2302
	,销售额2303
	,销售额2304
	,销售额2305
	,销售额2306
	,销售额2307
	,销售额2308
	,销售额2309
	,销售额2310
	,销售额2311
	,销售额2312
	
	,`终审7天销售额`
	,`终审14天销售额`
	,`终审30天销售额` 
	
	,`首单30天销售额`
	,`终审30天SPU单产`
	,`首单30天SPU单产`
	
	,round(list_cnt/list_sku_cnt,1) `单SKU刊登链接数`
	,round(list_cnt/list_spu_cnt,1) `单SPU刊登链接数`
	,list_cnt `刊登链接数`
	,list_cnt_in3d `终审3天刊登链接数`
	,list_cnt_in7d `终审7天刊登链接数`
	
	,ad_sku_Exposure `累计曝光`
	,ad7_sku_Exposure `终审7天曝光`
	,ad14_sku_Exposure `终审14天曝光`
	,ad30_sku_Exposure `终审30天曝光`
	
	,ad_sku_Clicks `累计点击` 
	,ad7_sku_Clicks `终审7天点击` 
	,ad14_sku_Clicks `终审14天点击`
	,ad30_sku_Clicks `终审30天点击`
	
	,`累计广告点击率`
	,`终审7天广告点击率`
	,`终审14天广告点击率`
	,`终审30天广告点击率`
	
	,ad_sku_TotalSale7DayUnit `累计广告销量`
	,ad7_sku_TotalSale7DayUnit `终审7天广告销量`
	,ad14_sku_TotalSale7DayUnit `终审14天广告销量`
	,ad30_sku_TotalSale7DayUnit `终审30天广告销量`
	,`累计广告转化率`
	,`终审7天广告转化率`
	,`终审14天广告转化率`
	,`终审30天广告转化率`
	
	,ad_Spend `累计广告花费`
	,ad7_Spend `终审7天广告花费`
	,ad14_Spend `终审14天广告花费`
	,ad30_Spend `终审14天广告花费`
	
	,ad_TotalSale7Day `累计广告销售额`
	,ad7_TotalSale7Day `终审7天广告销售额`
	,ad14_TotalSale7Day `终审14天广告销售额`
	,ad30_TotalSale7Day `终审14天广告销售额`
	
	,`累计ROAS`
	,`终审7天ROAS`
	,`终审14天ROAS`
	,`终审30天ROAS`
	
	,`累计ACOS`
	,`终审7天ACOS`
	,`终审14天ACOS`
	,`终审30天ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `累计CPC`
	,round(ad7_Spend/ad7_sku_Clicks,2) `终审7天CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `终审14天CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `终审30天CPC`
	
	,replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `终审时间范围`
	,replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `广告时间范围`

from t_prod_stat
left join t_ad_stat on t_prod_stat.tbcode =t_ad_stat.tbcode 
left join t_list_stat on t_prod_stat.tbcode =t_list_stat.tbcode 
)

select t_merage.* ,dd.week_num_in_year as 终审周序号 ,dd.week_begin_date as 对照当周周一
from t_merage
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date)  dd on year('${StartDay}') = dd.year and t_merage.`终审周次` = dd.week_num_in_year
order by `预置分析维度` desc ,`开发团队`,`开发人员`,`终审月份`,`终审周次`


