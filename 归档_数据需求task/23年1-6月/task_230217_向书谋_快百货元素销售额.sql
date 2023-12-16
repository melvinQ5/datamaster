-- 统计月份 元素名称 元素总sku数 当月元素出单sku数 当月总出单sku数 

with od as ( 
select left(PayTime,7) set_month ,wo.BoxSku  ,wo.Product_Sku as sku 
	, round(sum((TotalGross+RefundAmount)/ExchangeUSD),2) sales   
	, count(distinct boxsku) `出单sku数`
from wt_orderdetails wo 
where IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}'
group by left(PayTime ,7) ,wo.BoxSku ,wo.Product_Sku 
)

, res as (
select od.* , tmp.name
from od 
left join 
	(
	select distinct eppaea.sku ,eppea.Name
	from import_data.erp_product_product_associated_element_attributes eppaea 
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id 
	) tmp 
	on od.sku = tmp.sku 
)

select a.set_month `统计月份` , name `元素名称`
	, `出单元素品sku数` , `出单sku数` , round(`元素销售额`) `元素销售额` ,round(`销售额`) `销售额`
from (
select set_month , name
	,count(distinct case when name is not null then sku end ) `出单元素品sku数`
	,sum( case when name is not null then sales end ) `元素销售额`
from res
where name is not null 
group by set_month ,name
) a 
left join 
(
select 
	set_month
	,count(distinct sku) `出单sku数`
	,sum(sales) `销售额`
from res 
group by set_month 
) b on a.set_month = b.set_month