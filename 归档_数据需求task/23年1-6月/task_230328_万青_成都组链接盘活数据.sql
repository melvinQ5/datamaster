-- 快百货3月产品sku销量排名

with 
t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,SaleCount ,TransactionType ,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount ,orderstatus
	,PayTime ,Product_Sku as sku 
	,boxsku
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
where 
	PayTime >= '2023-03-01' and PayTime < '2023-03-28' and wo.IsDeleted=0 
	and ms.Department = '快百货' 
-- 	and NodePathName in ('快次方-成都销售组','快次元-成都销售组')
-- 	and NodePathName in ('快次方-成都销售组')
-- 	and NodePathName in ('快次元-成都销售组')
)

,t_orde_stat as (
select sku
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
	,round(sum(salecount),2) salecount
from t_orde 
where orderstatus != '作废'
group by sku    
)


,t_merage as (
select epp_sku.sku 
	,epp_sku.boxsku
	,ProductName 
	,ProductStatus `产品状态`
-- 	,TortType `侵权状态`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) `终审时间`
	,salecount `销量`
from  
	(select sku ,boxsku ,CreationTime ,DevelopLastAuditTime,ProductName ,DevelopUserName
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
	from erp_product_products wp where IsMatrix = 0
	) epp_sku 
left join (
	select sku ,GROUP_CONCAT( case when TortType is null then '未标记' else TortType end ) TortType 
	from ( select sku ,TortType
		from import_data.wt_products 
		where IsDeleted =0  and ProjectTeam='快百货' 
		group by sku ,TortType 
		) ta
	group by sku
	) epp_Tort on epp_sku.sku =epp_Tort.sku 
join t_orde_stat on epp_sku.sku =t_orde_stat.sku 
)

-- select count(1)
select * ,ROW_NUMBER ()over (order by `销量` desc) `销量排名`
from t_merage
order by `销量排名` 
