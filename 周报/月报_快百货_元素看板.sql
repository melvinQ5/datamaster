-- 计算公司整体销售额 判断元素业绩占比
with 
t_new_prod as ( -- 定义快百货周报新品：终审时间在近90天的SPU数，自2023-03-01
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
 	, epp.ProductStatus 
from import_data.erp_product_products epp
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-01-01'  
	and epp.IsDeleted = 0 
	and ismatrix = 1
	and epp.ProjectTeam ='快百货' 
)

,od as (
select left(SettlementTime,7) set_month ,wo.BoxSku ,wo.Product_Sku as sku
	, round(sum((TotalGross)/ExchangeUSD),2) sales
	, round(sum( case when b.spu is not null then (TotalGross)/ExchangeUSD end  )  ,2) new_pp_sales
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
left join wt_products pp on wo.BoxSku=pp.BoxSku and pp.IsDeleted=0
left join t_new_prod b on  wo.Product_SPU = b.spu  
where wo.IsDeleted = 0 and SettlementTime < '${NextStartDay}' and SettlementTime >= '2022-01-01' 
and ms.Department  = '快百货'
group by left(SettlementTime,7) ,wo.BoxSku ,wo.Product_Sku
)

, ele as ( 
select distinct eppaea.sku ,eppea.Name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
)

, data_set as (
select od.* , ele.name ,pp.Spu
from od
left join ele on od.sku = ele.sku -- 一变多
left join wt_products pp on ele.sku=pp.sku
)
-- ---------
, res1 as (
select set_month , name
	,count( distinct sku ) `出单元素品sku数`
	,sum( sales ) `元素销售额`
	,sum( new_pp_sales ) `元素新品销售额`
    ,count( SPU ) `出单元素品spu数`
from data_set
where name is not null
group by set_month , name
)

, res2 as (
select  set_month 
	, count( distinct boxsku ) `出单sku数`
	, sum( sales ) `当期销售额`
from data_set 
group by set_month 
)

, res3 as ( 
select name ,count(distinct sku) `ERP打标sku数`
from ele 
group by name 
)
         
select res1.name `元素名称` ,res3. `ERP打标sku数` , res1.set_month `统计月份` 
	,`出单元素品sku数` , `出单sku数` , 出单元素品spu数
	,round(`元素销售额`) `元素品销售额` 
	,round(`元素新品销售额`) `23年内终审的元素品销售额` 
	,round(`当期销售额`) `销售额`
	,round( `元素销售额`/`当期销售额`,4) `元素业绩占比`
	,round( `元素销售额`/`出单元素品spu数`,2 ) `元素spu单产`
	,round( `出单元素品sku数`/`ERP打标sku数`,4 ) `出单元素sku占比`
from res1  
left join res2 on res1.set_month =res2.set_month
left join res3 on res1.name =res3.name
order by `元素名称` , `统计月份`