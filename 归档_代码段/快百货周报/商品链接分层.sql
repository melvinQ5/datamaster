-- 清空表
-- truncate table import_data.ads_ag_staff_kbh_report_weekly;
team 列字符串长度不够 ，需要删表重建
 insert into import_data.ads_ag_staff_kbh_report_weekly (`FirstDay`, `AnalysisType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
 SpuCnt ,SpuStopCnt ,SpuSaleCntIn30d ,SpuUnitSaleIn30d ,SpuSaleRateIn30d 
 ,TopSaleSpuCnt,TopSaleSpuCntIn30dDev ,HotSaleSpuCnt,HotSaleSpuCntIn30dDev
 ,TopSaleSpuAmount ,HotSaleSpuAmount ,TopSaleSpuValue ,HotSaleSpuValue ,TopSaleSpuValueIn30dDev ,HotSaleSpuValueIn30dDev
 ,TopSaleSpuRate ,HotSaleSpuRate,TopHotStopSpuRate
 ,NewSpuCntIn90dDev ,SaleSpuCntIn90dDev ,FirstSaleSpuCnt ,NewDevSpuCnt ,NewAddSpuCnt ,SaleAmountIn30dDev  ,StopSkuRateIn30dDev)
with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '快百货' as dep 
union 
select case when NodePathName regexp '泉州' then '快百货泉州' when NodePathName regexp '成都' then '快百货成都'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)

,t_mysql_store as (  -- 组织架构临时改变前
select 
	Code 
	,case when NodePathName regexp '泉州' then '快百货泉州' 
		when NodePathName regexp '成都' then '快百货成都'  else department 
		end as department
	,NodePathName
	,CompanyCode 
	,department as department_old
	,Site
	,case when AccountCode in ('MP-EU','NY-EU','B209-EU','SH-EU','MQ-EU','PX-EU','B209-NA','MR-EU','MR-AU','PP-EU','PK-EU','UH-NA','UL-NA','UI-NA','ST-EU','SW-EU','QJ-EU') 
		then '休假中' else ShopStatus end as ShopStatus
from import_data.mysql_store
)

,t_erp_sku as (
select case when ProjectTeam is null then '公司' else ProjectTeam end as dep
	,count(distinct SKU) `产品库SKU数`
	,count(distinct SPU) `产品库SPU数`
from import_data.erp_product_products epp 
where IsDeleted = 0 and ProductStatus != 2 and DevelopLastAuditTime is not null 
group by grouping sets ((),(ProjectTeam))
)

,t_erp_stop_sku as ( 
select '快百货'  as dep
	,count(distinct SPU) as 汰换SPU数 --  SpuStopCnt 
from import_data.erp_product_products epp 
where IsDeleted = 0 and DevelopLastAuditTime is not null
	and date_add(ProductStopTime, INTERVAL - 8 hour) >= '${StartDay}'
	and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}'
)

,t_erp_stop_in30d_sku as ( 
select '快百货'  as dep
	,count(distinct SPU) as 近30天汰换SPU数 
from import_data.erp_product_products epp 
where IsDeleted = 0 and DevelopLastAuditTime is not null
	and date_add(ProductStopTime, INTERVAL - 8 hour) >= date_add('${NextStartDay}',interval - 30 day )
	and date_add(ProductStopTime, INTERVAL - 8 hour) < '${NextStartDay}'
) 


,t_orde_in30d as ( -- 近30天订单
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,feegross
	,ExchangeUSD,TransactionType,OrderStatus,SellerSku,RefundAmount,AdvertisingCosts 
	,wo.shopcode ,wo.asin ,wo.boxsku ,PayTime 
	,wo.Product_SPU as spu 
	,ms.*
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
-- left join wt_products pp on wo.BoxSku=pp.BoxSku
where PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
	and TransactionType <> '其他'  and asin <>'' -- 每月会有几十到上百条订单数据没有ASIN
	and ms.department regexp '快' 
)

,od_list_in30d as ( -- site,asin,spu,boxsku 聚合
select asin,site,spu,boxsku
	,round(sum((totalgross-feegross)/ExchangeUSD),2) sales_no_freight -- 含退款不含运费
	,round(sum((totalprofit-feegross)/ExchangeUSD),2) profit_no_freight
	,count(distinct platordernumber) orders
	,round(sum(feegross/ExchangeUSD),2) freightfee
	,round(sum(-RefundAmount),2) refund
	,date(min(paytime)) pay_min_time
	,datediff(date_add(CURRENT_DATE(),INTERVAL -2 day)
	,date(min(paytime))) saledays
	,count(distinct date(PayTime))solddays,round(sum((totalgross-feegross)/ExchangeUSD)/( datediff(date_add(CURRENT_DATE(),INTERVAL -2 day),date(min(paytime)))),2) `日均销量`
	,row_number() over(order by count(distinct platordernumber) desc ) as ordersort,row_number() over(order by  round(sum((totalgross-feegross)/ExchangeUSD),2)  desc ) as salessort
from t_orde_in30d 
group by site,asin,spu,boxsku
)
-- select * from od_list_in30d 

-- 商品分层
,prod_mark as ( -- spu聚合
select t.spu
	, case when sales >=1500 then '爆款' when sales>=500 and sales<1500 then'旺款' end as prod_level
	, sales 
	, s.ProductStatus
from (
	select spu ,sum(sales_no_freight) sales 
	from od_list_in30d group by spu 
	) t 
left join ( select spu , ProductStatus from import_data.erp_product_products epp 
	where IsDeleted = 0 and ismatrix = 1 and DevelopLastAuditTime is not null 
	) s on t.spu = s.spu
)
-- select * from prod_mark

,t_new_prod as ( -- 定义快百货周报新品：终审时间在近90天的SPU数，自2023-03-01
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, epp.ProductStatus 
from import_data.erp_product_products epp
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-03-01'  
	and date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= date_add('${NextStartDay}',interval - 90 day) 
	and epp.IsDeleted = 0 
	and ismatrix = 1
	and epp.ProjectTeam ='快百货' 
)

,t_new_prod_stat as ( -- 近90天开发新品数
select '快百货' as dep 
,count(spu) 近90天终审SPU数
,count(case when ProductStatus = 2 then spu end ) 近90天终审且停产SPU数
,count(case when date_add(DevelopLastAuditTime, INTERVAL - 8 hour) >= '${StartDay}' 
	and date_add(DevelopLastAuditTime, INTERVAL - 8 hour) >= '${NextStartDay}'  then spu end ) 终审SPU数 -- 统计期终审
from t_new_prod
)

,t_add_prod_stat as ( -- 添加新品数
select '快百货' as dep 
	,count(spu) 添加SPU数
from import_data.erp_product_products epp
where date_add(epp.CreationTime , INTERVAL - 8 hour) >= '${StartDay}' 
	and date_add(epp.CreationTime, INTERVAL - 8 hour) >= '${NextStartDay}'
	and epp.IsDeleted = 0 
	and ismatrix = 1
	and epp.ProjectTeam ='快百货' 
)

,t_orde as ( -- 统计期订单
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,feegross
	,ExchangeUSD,TransactionType,OrderStatus,SellerSku,RefundAmount,AdvertisingCosts ,wo.shopcode ,wo.Asin 
	,wo.Product_SPU as spu 
	,ms.*
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
-- left join wt_products pp on wo.BoxSku=pp.BoxSku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
)

,t_new_prod_od_stat as ( -- 新品出单
select '快百货' as dep 
,count(distinct a.spu) 新品出单SPU数 
,round(sum((totalgross-feegross)/ExchangeUSD),2) 新品不含运费销售额
from t_orde a  join t_new_prod b on a.spu =b.spu 
)

,t_min_pay_spu as ( -- 首单SPU 
select '快百货' as dep , count(1) 首单SPU数
from (
	select  product_spu as spu  ,min(PayTime) as min_pay_time 
	from wt_orderdetails  wo
	where IsDeleted = 0 and orderstatus != '作废' and department = '快百货'
	group by product_spu 
	) a 
where min_pay_time >='${StartDay}' and min_pay_time<'${NextStartDay}'	
)


,t_prod_mark_stat as ( -- 出单SPU中标记爆旺款 
select '快百货' as dep
	,count(case when prod_level = '旺款' then 1 end ) 近30天旺款SPU数
	,count(case when prod_level = '爆款' then 1 end ) 近30天爆款SPU数
	,sum(case when prod_level = '爆款' then sales end ) 近30天爆款SPU销售额
	,sum(case when prod_level = '旺款' then sales end ) 近30天旺款SPU销售额
	,count(case when prod_level regexp '爆款|旺款' and a.ProductStatus = 2 then 1 end ) 爆旺款停产SPU数
	,count(case when prod_level regexp '爆款|旺款'  then 1 end ) 爆旺款SPU数
	
	,count(case when prod_level = '旺款' and b.spu is not null then 1 end ) 新品旺款SPU数
	,count(case when prod_level = '爆款' and b.spu is not null then 1 end ) 新品爆款SPU数
	,sum(case when prod_level = '爆款' and b.spu is not null then sales end ) 新品爆款SPU销售额
	,sum(case when prod_level = '旺款' and b.spu is not null then sales end ) 新品旺款SPU销售额
from prod_mark a 
left join t_new_prod b on a.spu =b.spu 
)
-- select * from t_prod_mark_stat

,t_od_stat as (
select '快百货' as dep
	,count(distinct spu) 近30天动销SPU数
	,sum(sales_no_freight) 不含运费销售额
from od_list_in30d
)
-- select * from t_od_stat

-- 链接分层
,list_mark as ( -- site,asin 聚合
select site ,asin ,sales
	,case when list_orders >=15 THEN 'S' when list_orders >=5 THEN 'A' END as list_level
from (
	select site ,asin ,sum (orders) list_orders ,sum(sales_no_freight) sales
	from od_list_in30d group by site ,asin 
	) t 
-- left join ( select site ,asin , ListingStatus  -- site ,asin 下有多条链接状态
-- 	from erp_amazon_amazon_listing eaal join t_mysql_store ms 
-- 	on eaal.ShopCode = ms.Code  and ms.ShopStatus = '正常' group by 
-- 	) s on t.site = s.site and t.asin = s.asin    '`'ProductStatus' `' 
) 

,t_list_mark_stat as ( 
select '快百货' as dep
	,count(case when list_level = 'S' then 1 end ) S级链接数
	,count(case when list_level = 'A' then 1 end ) A级链接数
	,sum(case when list_level = 'S' then sales end ) S级链接销售额
	,sum(case when list_level = 'A' then sales end ) A级链接销售额
from list_mark
)
-- select * from t_list_mark_stat

,t_list as (
select spu, sku, sellersku,shopcode,asin,markettype as site,NodePathName ,department 
	,CompanyCode
from erp_amazon_amazon_listing eaal 
join t_mysql_store ms on ms.code= eaal.shopcode 
where eaal.isdeleted=0 
	and ms.department regexp '快百货' 
	and ShopStatus='正常'
	and listingstatus = 1  
	and sku<>'' -- 1 排除母体链接，2 排除未关联sku，等处理关联了再处理
)

,t_large_shop as (
select '快百货' dep , count(case when 快百货在线账号数>6 then sku end ) 在线店铺超量SKU数
from (
	SELECT sku  ,count(distinct CompanyCode ) 快百货在线账号数
	from t_list 
	group by sku
	) t 
)

,t_merge as (
select 
	'${StartDay}' ,concat(t_key.dep,'x周报') ,t_key.dep ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1 
	-- 商品运营
	,产品库SPU数 -- SpuCnt
	,汰换SPU数 -- SpuStopCnt
	,近30天动销SPU数 -- SpuSaleCntIn30d
	,round(不含运费销售额/近30天动销SPU数,2) as 平均动销SPU单产 -- SpuUnitSaleIn30d
	,round(近30天动销SPU数/(产品库SPU数+近30天汰换SPU数),2) as SPU库动销率 -- SpuSaleRateIn30d
	,近30天爆款SPU数 -- TopSaleSpuCnt
	,新品爆款SPU数 -- TopSaleSpuCntIn30dDev
	,近30天旺款SPU数 -- HotSaleSpuCnt
	,新品旺款SPU数 -- HotSaleSpuCntIn30dDev
	,近30天爆款SPU销售额 -- TopSaleSpuAmount
	,近30天旺款SPU销售额 -- HotSaleSpuAmount
	,round(近30天爆款SPU销售额/近30天爆款SPU数,2) as 爆款SPU单产 -- TopSaleSpuValue
	,round(近30天旺款SPU销售额/近30天旺款SPU数,2) as 旺款SPU单产 -- HotSaleSpuValue
	,round(新品爆款SPU销售额/新品爆款SPU数,2) as 新品爆款SPU单产 -- TopSaleSpuValueIn30dDev
	,round(新品旺款SPU销售额/新品旺款SPU数,2) as 新品旺款SPU单产 -- HotSaleSpuValueIn30dDev
	,round(近30天爆款SPU销售额/不含运费销售额,2) as 爆款SPU销售额占比 -- TopSaleSpuRate
	,round(近30天旺款SPU销售额/不含运费销售额,2) as 旺款SPU销售额占比 -- HotSaleSpuRate
	,round(爆旺款停产SPU数/爆旺款SPU数,2) as 爆旺款SPU汰换率 -- TopHotStopSpuRate
	
	-- 商品开发-新品 
	,近90天终审SPU数  -- NewSpuCntIn90dDev
	,新品出单SPU数 -- SaleSpuCntIn90dDev
	,首单SPU数 -- FirstSaleSpuCnt
	,终审SPU数 -- NewDevSpuCnt
	,添加SPU数 -- NewAddSpuCnt
	,新品不含运费销售额 -- SaleAmountIn30dDev
	,round(近90天终审且停产SPU数/近90天终审SPU数,2) as 新品停产SKU占比 -- StopSkuRateIn30dDev
	
-- --	,在线店铺超量SKU数
-- --	-- 链接分层
-- --	,S级链接数
-- --	,A级链接数
-- --	,S级链接销售额
-- --	,round(S级链接销售额/S级链接数,2) as S级链接单产
-- --	,round(A级链接销售额/A级链接数,2) as A级链接单产
-- --	,round(S级链接销售额/不含运费销售额,2) as S级业绩占比
-- --	,round(A级链接销售额/不含运费销售额,2) as A级业绩占比
	
	
from t_key
left join t_prod_mark_stat on t_key.dep = t_prod_mark_stat.dep
left join t_od_stat on t_key.dep = t_od_stat.dep
left join t_list_mark_stat on t_key.dep = t_list_mark_stat.dep
left join t_erp_sku on t_key.dep = t_erp_sku.dep
left join t_erp_stop_sku on t_key.dep = t_erp_stop_sku.dep
left join t_erp_stop_in30d_sku on t_key.dep = t_erp_stop_in30d_sku.dep
left join t_large_shop on t_key.dep = t_large_shop.dep
left join t_add_prod_stat on t_key.dep = t_add_prod_stat.dep
left join t_new_prod_stat on t_key.dep = t_new_prod_stat.dep
left join t_new_prod_od_stat on t_key.dep = t_new_prod_od_stat.dep
left join t_min_pay_spu on t_key.dep = t_min_pay_spu.dep
) 

select *from t_merge 




