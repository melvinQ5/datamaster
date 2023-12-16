
with
t_prod as ( -- 23年3月1日至今终审
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, vr.department
 	, vr.NodePathName
 	, vr.dep2
from import_data.erp_product_products epp
left join 
	( select case when name in ('唐美丽','金琴2') then '快百货一部' else split(NodePathNameFull,'>')[2] end as dep2 -- 两人曾协助开品，但非商品组人员
		,case when  NodePathName = '商品组' then '快节奏-商品组' else NodePathName end NodePathName
		,name ,department
	from view_roles 
	where ProductRole ='开发' 
-- 	and NodePathName in ('快次方-商品组','快次元-商品组','商品组')
	) vr on epp.DevelopUserName = vr.name
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-03-01' and date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) < '2023-07-01' 
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='快百货' 
	and epp.DevelopUserName != '杨春花'
)

-- select count(distinct SPU ) from t_prod where DevelopUserName = '张鑫晶'
-- 检查有无问题 新品SPU数 有无收到 view_roles影响

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
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
join t_prod on wo.boxsku = t_prod.boxsku 
left join ( select Product_SPU , min(PayTime) as spu_min_paytime 
	from import_data.wt_orderdetails  od1
	join import_data.mysql_store ms1 on ms1.Code = od1.shopcode and od1.IsDeleted = 0 
	and ms1.Department ='快百货' and PayTime >= '2023-03-01' and PayTime < '2023-07-01' -- 为了算首单30天 
	where TransactionType = '付款'  and OrderStatus <> '作废' and OrderTotalPrice > 0 
	group by Product_SPU
	) tmp_min on wo.Product_SPU =tmp_min.Product_SPU 
where 
	PayTime >= '2023-04-01' and PayTime < '2023-07-01' and wo.IsDeleted=0 
	and ms.Department = '快百货'
)

-- select * from t_orde where dep2 is null 


,t_prod_q2_stat as (
select 
	'快百货' 团队
	,'' 人员
	,count(distinct spu) 4月至今新品SPU数
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
union all
select
	dep2  团队
	,'' 人员
	,count(distinct spu) 4月至今新品SPU数
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
group by dep2
union all
select
	case when NodePathName is null then '支援团队' else NodePathName end  团队
	,'' 人员
	,count(distinct spu) 4月至今新品SPU数
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
group by NodePathName
union all 
select
	case when NodePathName is null then '支援团队' else NodePathName end  团队
	,DevelopUserName 人员
	,count(distinct spu) 4月至今新品SPU数
from t_prod where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < '2023-07-01'
group by NodePathName,DevelopUserName
)

,t_od_q2_stat as (
select 
	'快百货' 团队
	,'' 人员
	,round(sum(TotalGross/ExchangeUSD)) Q2_新品业绩
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU首单30天销售额
from t_orde 
union all
select
	dep2 团队
	,'' 人员
	,round(sum(TotalGross/ExchangeUSD)) Q2_新品业绩
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU首单30天销售额
from t_orde 
group by dep2
union all
select
	case when NodePathName is null then '支援团队' else NodePathName end  团队
	,'' 人员
	,round(sum(TotalGross/ExchangeUSD)) Q2_新品业绩
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU首单30天销售额
from t_orde 
group by NodePathName
union all 
select
	case when NodePathName is null then '支援团队' else NodePathName end  团队
	,DevelopUserName 人员
	,round(sum(TotalGross/ExchangeUSD)) Q2_新品业绩
	,round(sum(case when ord_days_since_od <= 30 and ord_days_since_od > 0 then TotalGross/ExchangeUSD end)) Q2_SPU首单30天销售额
from t_orde 
group by NodePathName,DevelopUserName
)

,t_new_spu_sale_in14d as ( -- 考核周期内终审14天以上的的SPU, 4月15号才开始统计这个指标
select 
	'快百货' 团队
	,'' 人员
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_终审14天SPU动销率`
from ( select wp.SPU from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU ) entire_spu  -- 开发spu
left join ( -- 出单spu
	select SPU 
	from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by SPU  
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU

union all 
select 
	entire_spu.dep2 团队
	,'' 人员
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_终审14天SPU动销率`
from ( select wp.SPU,dep2 from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU,dep2 ) entire_spu  -- 开发spu
left join ( -- 出单spu
	select SPU ,dep2 from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by  SPU ,dep2
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU and entire_spu.dep2 = part_SPU.dep2
group by entire_spu.dep2

union all 
select 
	case when entire_spu.NodePathName is null then '支援团队' else entire_spu.NodePathName end  团队
	,'' 人员
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_终审14天SPU动销率`
from ( select wp.SPU,NodePathName from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU,NodePathName ) entire_spu  -- 开发spu
left join ( -- 出单spu
	select SPU ,NodePathName from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by  SPU ,NodePathName
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU and entire_spu.NodePathName = part_SPU.NodePathName
group by entire_spu.NodePathName

union all 
select 
	case when entire_spu.NodePathName is null then '支援团队' else entire_spu.NodePathName end  团队
	,entire_spu.DevelopUserName 人员
	, round(count(part_SPU.SPU)/count(entire_spu.SPU),4) `Q2_终审14天SPU动销率`
from ( select wp.SPU,NodePathName ,DevelopUserName from t_prod wp
	where DevelopLastAuditTime >= '2023-04-01' and DevelopLastAuditTime < date_add(CURRENT_DATE() ,interval - 14 day) 
	group by wp.SPU,NodePathName,DevelopUserName ) entire_spu  -- 开发spu
left join ( -- 出单spu
	select SPU ,NodePathName ,DevelopUserName from import_data.wt_orderdetails wo  
	join t_prod on t_prod.BoxSku = wo.BoxSku 
		and paytime >= '2023-04-01' and paytime < '2023-07-01'
		and  wo.Department = '快百货' and wo.IsDeleted =0 and orderstatus != '作废'
		and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 <= 14 and timestampdiff(second,DevelopLastAuditTime,paytime)/86400 >= 0
	group by  SPU ,NodePathName ,DevelopUserName
	) part_SPU
	on entire_spu.SPU = part_SPU.SPU and entire_spu.NodePathName = part_SPU.NodePathName 
		and entire_spu.DevelopUserName = part_SPU.DevelopUserName
group by entire_spu.NodePathName,entire_spu.DevelopUserName
)

select 
	case 
		when ta.团队 = '快百货' then 1 
		when ta.团队 = '快百货一部' then 2  
		when ta.团队 = '快百货二部' then 3 
		when ta.团队 = '快次元-商品组' and  ta.人员 = '' then 4
		when ta.团队 = '快次方-商品组' and  ta.人员 = '' then 5
		when ta.团队 = '快节奏-商品组' and  ta.人员 = '' then 6
		when ta.团队 = '支援团队' and  ta.人员 = '' then 7
		when ta.团队 = '快次元-商品组' and  ta.人员 != '' then 8
		when ta.团队 = '快次方-商品组' and  ta.人员 != '' then 9
		when ta.团队 = '快节奏-商品组' and  ta.人员 != '' then 10
		when ta.团队 = '支援团队' and  ta.人员 != '' then 11
	end as 表序
	,ta.* 
	,Q2_新品业绩
	,Q2_SPU首单30天销售额
	,Q2_终审14天SPU动销率
from t_prod_q2_stat ta 
left join t_od_q2_stat tb on ta.团队 = tb.团队 and ta.人员 = tb.人员
left join t_new_spu_sale_in14d tc on ta.团队 = tc.团队 and ta.人员 = tc.人员
order by 表序