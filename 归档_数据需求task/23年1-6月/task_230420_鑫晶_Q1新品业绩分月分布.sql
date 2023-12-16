
with 
t_prod as ( -- 23年3月1日至今终审
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) DevelopLastAuditTime
 	, epp.DevelopUserName
 	, epp.ProjectTeam 
from import_data.erp_product_products epp
where date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) >= '2023-01-01' and date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour) < '2023-04-01' 
	and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epp.ProjectTeam ='快百货' 
-- 	and epp.DevelopUserName != '杨春花'
)

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,wo.BoxSku 
	,wo.Department 
	,PayTime
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
where 
	PayTime  >= '2023-01-01' and PayTime < '2023-04-01' and wo.IsDeleted=0 
	and ms.Department = '快百货'
)

,t_new_sale as (
select case when left(paytime,7) is null then '合计' else  left(paytime,7) end 出单月份
	,round( sum((TotalGross)/ExchangeUSD),2) `销售额`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  ),2) `新品销售额`
from t_orde 
left join t_prod on t_orde.boxsku = t_prod.boxsku 
group by grouping sets ((),(left(paytime,7))) 
)


select * from t_new_sale