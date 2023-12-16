-- 开斋节 按站点统计业绩
-- 想复盘看看最后出单的是不是这几个站点

with 
t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.spu , eppea.Name ,DevelopLastAuditTime
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
left join import_data.erp_product_products epp on eppaea.spu = epp.SPU 
where eppea.DataStatus = 1 and epp.IsMatrix = 1 and epp.IsDeleted = 0 and ProjectTeam = '快百货' and epp.Status = 10  AND name = '开斋节'
group by eppaea.spu , eppea.Name ,DevelopLastAuditTime
)

,od as (
select wo.BoxSku ,wo.Product_SPU as spu ,wo.Product_SKU as SKU 
	, round(TotalGross/ExchangeUSD) as sales
	,PayTime , wo.site 
	, tmp.name
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
join
	( -- 一个sku多个元素 变多行订单
	select distinct eppaea.sku ,eppea.Name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id  AND name = '开斋节'
	) tmp
	on wo.Product_SKU = tmp.sku -- 按SKU关联订单
where wo.IsDeleted = 0  and PayTime  < '${NextStartDay}' and PayTime >= '${StartDay}' and ms.Department = '快百货'
)

,dim_new as (
select boxsku from erp_product_products epp 
where  DevelopLastAuditTime >= '2023-01-01' and DevelopLastAuditTime < '2023-04-01'  
	and epp.IsMatrix = 0 and epp.IsDeleted = 0 and ProjectTeam = '快百货' 
group by boxsku 
)

, ele_stat as ( 
select name 
	,count(distinct spu ) `产品库SPU数`
	,count(distinct case when DevelopLastAuditTime < '2023-02-01' then spu end) as `截至1月终审SPU数`  
	,count(distinct case when DevelopLastAuditTime < '2023-03-01' then spu end) as `截至2月终审SPU数`  
	,count(distinct case when DevelopLastAuditTime < '2023-04-01' then spu end) as `截至3月终审SPU数`  
from t_elem 
group by name 
) 

, od_stat as (
select name , site 
	,sum( case when name is not null and left(PayTime,7) = '2023-01' then sales end ) `1月元素销售额`
	,sum( case when name is not null and left(PayTime,7) = '2023-02' then sales end ) `2月元素销售额`
	,sum( case when name is not null and left(PayTime,7) = '2023-03' then sales end ) `3月元素销售额`
	,sum( case when name is not null and MONTH(PayTime) <= 3 then sales end ) `Q1元素销售额`
-- 	,sum( sales) `销售额`
    ,count(distinct case when name is not null and left(PayTime,7) = '2023-01' then spu end ) `1月出单元素品spu数`
    ,count(distinct case when name is not null and left(PayTime,7) = '2023-02' then spu end ) `2月出单元素品spu数`
    ,count(distinct case when name is not null and left(PayTime,7) = '2023-03' then spu end ) `3月出单元素品spu数`
    ,count(distinct case when name is not null and MONTH(PayTime) <= 3  then spu end ) `Q1出单元素品spu数`
from od
join dim_new on od.boxsku = dim_new.boxsku 
group by grouping sets ((name),(name , site)) 
)

select od_stat.name `元素名称`
	,site `站点` 
	,ele_stat.`产品库SPU数`
	,`1月元素销售额` 
	,`2月元素销售额` 
	,`3月元素销售额` 
	,Q1元素销售额
	
	,round(`1月出单元素品spu数`/截至1月终审SPU数,2) `1月SPU动销率`
	,round(`2月出单元素品spu数`/截至2月终审SPU数,2) `2月SPU动销率`
	,round(`3月出单元素品spu数`/截至3月终审SPU数,2) `3月SPU动销率`
	,round(`Q1出单元素品spu数`/截至3月终审SPU数,2) `Q1SPU动销率`
	
	,round(`1月元素销售额`/1月出单元素品spu数,2) `1月SPU单产`
	,round(`2月元素销售额`/2月出单元素品spu数,2) `2月SPU单产`
	,round(`3月元素销售额`/3月出单元素品spu数,2) `3月SPU单产`
	,round(`Q1元素销售额`/Q1出单元素品spu数,2) `Q1SPU单产`

from od_stat
left join ele_stat on ele_stat.name = od_stat.name
WHERE od_stat.name is not null
