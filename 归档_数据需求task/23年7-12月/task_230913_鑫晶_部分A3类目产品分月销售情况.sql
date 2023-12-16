
with
prod as (
select SKU ,SPU , BoxSku ,DATE(DevelopLastAuditTime) 终审日期
,year(DevelopLastAuditTime) 终审年份
,ProductName
,Cat1 ,Cat2 ,Cat3 ,Cat4 ,Cat5
,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
,TortType
from wt_products wp
where ProjectTeam='快百货' and CategoryPathByChineseName regexp 'A3娱乐爱好>A3宠物用品' and IsDeleted = 0
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku
)

,od as (
select wo.BoxSku ,wo.Product_Sku as sku  ,wo.Product_SPU as SPU ,TotalGross ,FeeGross,ExchangeUSD ,salecount ,PayTime ,nodepathname
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code
where wo.IsDeleted = 0
	and OrderStatus !='作废' and TransactionType = '付款' -- S1销售额
	and ms.Department  = '快百货' and PayTime>'2020-01-01'
)

,t_od_stat as (
select
	sku ,boxsku ,spu
    ,year(paytime) 出单年份
    ,month(paytime) 出单月份
    ,sum(salecount) 销量
    ,round(sum(TotalGross/ExchangeUSD  ),2) 销售额
    ,round(sum( (TotalGross-FeeGross)/ExchangeUSD  ),2) 不含运费销售额
from od
group by sku ,boxsku ,spu ,出单年份 ,出单月份
)

select t2.出单年份 ,t2.出单月份 ,t1.* ,t3.ele_name
     ,销量 ,销售额 ,不含运费销售额
from prod t1
left join t_od_stat t2 on t1.sku =t2.sku
left join t_elem t3 on t1.sku =t3.sku
order by  t1.sku ,t2.出单年份 ,t2.出单月份


