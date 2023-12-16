-- ��ٻ�3�²�Ʒsku��������

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
	and ms.Department = '��ٻ�' 
-- 	and NodePathName in ('��η�-�ɶ�������','���Ԫ-�ɶ�������')
-- 	and NodePathName in ('��η�-�ɶ�������')
-- 	and NodePathName in ('���Ԫ-�ɶ�������')
)

,t_orde_stat as (
select sku
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
	,round(sum(salecount),2) salecount
from t_orde 
where orderstatus != '����'
group by sku    
)


,t_merage as (
select epp_sku.sku 
	,epp_sku.boxsku
	,ProductName 
	,ProductStatus `��Ʒ״̬`
-- 	,TortType `��Ȩ״̬`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) `����ʱ��`
	,salecount `����`
from  
	(select sku ,boxsku ,CreationTime ,DevelopLastAuditTime,ProductName ,DevelopUserName
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
	from erp_product_products wp where IsMatrix = 0
	) epp_sku 
left join (
	select sku ,GROUP_CONCAT( case when TortType is null then 'δ���' else TortType end ) TortType 
	from ( select sku ,TortType
		from import_data.wt_products 
		where IsDeleted =0  and ProjectTeam='��ٻ�' 
		group by sku ,TortType 
		) ta
	group by sku
	) epp_Tort on epp_sku.sku =epp_Tort.sku 
join t_orde_stat on epp_sku.sku =t_orde_stat.sku 
)

-- select count(1)
select * ,ROW_NUMBER ()over (order by `����` desc) `��������`
from t_merage
order by `��������` 
