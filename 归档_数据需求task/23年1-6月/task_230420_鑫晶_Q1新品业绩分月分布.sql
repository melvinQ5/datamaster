
with 
t_prod as ( -- 23��3��1����������
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
	and epp.ProjectTeam ='��ٻ�' 
-- 	and epp.DevelopUserName != '���'
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
	and ms.Department = '��ٻ�'
)

,t_new_sale as (
select case when left(paytime,7) is null then '�ϼ�' else  left(paytime,7) end �����·�
	,round( sum((TotalGross)/ExchangeUSD),2) `���۶�`
	,round( sum(case when t_prod.sku is not null then TotalGross/ExchangeUSD end  ),2) `��Ʒ���۶�`
from t_orde 
left join t_prod on t_orde.boxsku = t_prod.boxsku 
group by grouping sets ((),(left(paytime,7))) 
)


select * from t_new_sale