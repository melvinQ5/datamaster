

/*
 1-6月主要主题（圣帕特里克节，开斋节、复活节，园艺、夏季、户外）的业绩及利润，利润率，广告花费情况，主题新品在当月的业绩总额。 各主题的SKU对应平均链接数
 
 */


with 
newpp as (select sku ,spu from wt_products where date_add(DevelopLastAuditTime , interval - 8 hour) >=  '2023-01-01' 
    and ProjectTeam = '快百货' )
    
, r1 as ( -- 新品链接数
select left('${StartDay}',7)  统计月份
	,round( count(distinct concat(SellerSKU,ShopCode)) / count(distinct wl.sku) ,4 ) 主题新品sku当月新刊登平均链接数
from wt_listing wl 
join ( select eppaea.sku , GROUP_CONCAT( eppea.name ) ele_name 
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name ='${ele_name}'
	group by sku ) tag on wl.sku = tag.sku
join newpp on wl.spu = newpp.spu -- 23年内终审算新品
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	from import_data.mysql_store where department regexp '快' )  ms 
	on wl.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
where MinPublicationDate  >= '${StartDay}' and MinPublicationDate < '${NextStartDay}'
)

, r2 as (
select left('${StartDay}',7)  统计月份 , '${ele_name}' as ele_name
	,round(sum(TotalGross/ExchangeUSD),2) 主题销售额
    ,round(sum(TotalProfit/ExchangeUSD),2) 主题利润额
    ,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),4) 主题利润率_未扣广告
    ,round(sum( case when newpp.sku is not null then TotalGross/ExchangeUSD end ),2) 主题新品销售额
from import_data.wt_orderdetails wo
join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	from import_data.mysql_store where department regexp '快' )  ms 
	on wo.shopcode=ms.Code and dep2 regexp '${team1}|${team2}'
join ( select eppaea.sku 
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	where eppea.name ='${ele_name}'
	group by sku ) tag on wo.Product_SKU = tag.sku
left join newpp on wo.Product_SKU = newpp.sku
where PayTime >= '${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.department regexp '快'
group by left('${StartDay}',7) , ele_name
)


select r1.统计月份 , '${ele_name}' as 主题
	,主题销售额
	,主题利润额
	,主题利润率_未扣广告
	,主题新品销售额
	,主题新品sku当月新刊登平均链接数 
from r1 
left join r2 on r1.统计月份 = r2.统计月份



