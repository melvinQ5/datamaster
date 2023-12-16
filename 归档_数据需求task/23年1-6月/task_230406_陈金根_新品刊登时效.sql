-- 快次元开发，在快次元成都的刊登，快次元泉州的刊登，分开考核的
-- 终审两天内有一条刊登记录的sku 占比


with 
-- step1 数据源处理
de as ( -- 
select case when sku = '李琴' then '李琴1688' else sku end  as name ,boxsku as department,spu as dep2 
from JinqinSku js where Monday= '2023-03-31' and spu in ('快次元商品组','快次方商品组','商品组')
)

,t_prod as ( 
select spu 
	,left(de.dep2,3) as  dev_dep
	,DevelopUserName
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products epp 
left join de on epp.DevelopUserName = de.name 
where IsDeleted =0 and IsMatrix = 1 and ProjectTeam = '快百货'
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour) >= '${StartDay}' and DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}' 
)

,t_list as ( -- 刊登时间在2月1日至今
select wl.spu ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
	,ms.NodePathName 
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code  
where 
	PublicationDate>= '${StartDay}' 
	and PublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
)

,t_min_list as (
select 
	round(timestampdiff(second,`终审时间`,`首次刊登时间` )/86400,2) as `刊登用时（天数）`
	,tb.*
from (
	select t_prod.SPU 
		,t_prod.dev_dep `开发团队`
		, NodePathName `销售团队`
		,DevelopLastAuditTime `终审时间`
		,t_prod.DevelopUserName `开发人员`
		,min(PublicationDate) as  `首次刊登时间` 
	from t_prod
	left join  t_list on t_list.spu = t_prod.spu
	where t_list.spu is not null 
	group by  t_prod.SPU ,t_prod.dev_dep , NodePathName ,DevelopLastAuditTime ,t_prod.DevelopUserName
	order by  t_prod.SPU
	) tb 
)
-- 明细
select * from t_min_list

select 
	'快次元-泉州销售组' `销售组`
	,count(distinct case when `销售团队` = '快次元-泉州销售组' and `开发团队` = '快次元' and `刊登用时（天数）` < 86400*2 then spu end ) `达标SPU数`
	,count(distinct case when `开发团队` = '快次元' then spu end ) `对应开发团队新品SPU数`
	,round(count(distinct case when `销售团队` = '快次元-泉州销售组' and `开发团队` = '快次元' and `刊登用时（天数）` < 86400*2 then spu end ) 
	/ count(distinct case when `开发团队` = '快次元' then spu end ),4) `达标率`
from t_min_list
union all 
select 
	'快次元-成都销售组'
	,count(distinct case when `销售团队` = '快次元-成都销售组' and `开发团队` = '快次元' and `刊登用时（天数）` < 86400*2 then spu end )
	,count(distinct case when `开发团队` = '快次元' then spu end ) 
	,round(count(distinct case when `销售团队` = '快次元-成都销售组' and `开发团队` = '快次元' and `刊登用时（天数）` < 86400*2 then spu end ) 
	/ count(distinct case when `开发团队` = '快次元' then spu end ),4) 
from t_min_list
union all 
select 
	'快次方-泉州销售组'
	,count(distinct case when `销售团队` = '快次方-泉州销售组' and `开发团队` = '快次方' and `刊登用时（天数）` < 86400*2 then spu end ) 
	,count(distinct case when `开发团队` = '快次方' then spu end ) 
	,round(count(distinct case when `销售团队` = '快次方-泉州销售组' and `开发团队` = '快次方' and `刊登用时（天数）` < 86400*2 then spu end ) 
	/ count(distinct case when `开发团队` = '快次方' then spu end ) ,4)
from t_min_list
union all 
select 
	'快次方-成都销售组'
	,count(distinct case when `销售团队` = '快次方-成都销售组' and `开发团队` = '快次方' and `刊登用时（天数）` < 86400*2 then spu end ) 
	,count(distinct case when `开发团队` = '快次方' then spu end ) 
	,round(count(distinct case when `销售团队` = '快次方-成都销售组' and `开发团队` = '快次方' and `刊登用时（天数）` < 86400*2 then spu end ) 
	/ count(distinct case when `开发团队` = '快次方' then spu end ) ,4)
from t_min_list

-- ,count(distinct case when `销售团队` = '快次元-成都销售组' and `开发团队` = '快次元' and `刊登用时（天数）` < 86400*2 then spu end ) 
-- 	/ count(distinct case when `开发团队` = '快次元' then spu end ) `快次元-成都销售组`
-- 	,count(distinct case when `销售团队` = '快次方-泉州销售组' and `开发团队` = '快次方' and `刊登用时（天数）` < 86400*2 then spu end ) 
-- 	/ count(distinct case when `开发团队` = '快次方' then spu end ) `快次方-泉州销售组`
-- 	,count(distinct case when `销售团队` = '快次方-成都销售组' and `开发团队` = '快次方' and `刊登用时（天数）` < 86400*2 then spu end ) 
-- 	/ count(distinct case when `开发团队` = '快次方' then spu end ) `快次方-成都销售组`

