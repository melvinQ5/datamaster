
with ele as ( -- 元素映射表，最小粒度是 SPU+SKU+NAME
select eppaea.spu ,eppaea.sku ,products.boxsku ,eppea.Name ,products.DevelopLastAuditTime
	,products.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
left join import_data.erp_product_products products on eppaea.sku = products.sku 
where products.ismatrix = 0
group by eppaea.spu ,eppaea.sku ,products.boxsku ,eppea.Name ,products.DevelopLastAuditTime,products.ProjectTeam
)

, sku_sales as (
select wo.boxsku
	,round(sum(TotalGross/ExchangeUSD),2)  as  `元素销售额`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 and ms.Department ='${dep}'
join ( select spu ,BoxSku ,DevelopLastAuditTime from ele group by spu ,BoxSku ,DevelopLastAuditTime ) tmp 
	on wo.BoxSku = tmp.boxsku -- 筛选元素品
where PayTime < '${NextStartDay}' and PayTime >= date_add('${NextStartDay}',interval -7 day)
group by wo.boxsku 
)

, groupName as (
select boxsku ,group_concat(Name)  as ele_name 
from ele group by boxsku
)

select * from (

select pp.SKU, sku_sales.boxsku
	,groupName.ele_name 
	,pp.CategoryPathByChineseName
	,`元素销售额` , row_number() over(order by `元素销售额` desc) sort 
from sku_sales
left join wt_products  pp on sku_sales.BoxSKU=pp.BoxSKU and IsDeleted=0
left join groupName on sku_sales.BoxSKU=groupName.BoxSKU


) tmp 
where sort <= 400
