-- ���壺����ʱ����23��3��1�ż��Ժ�Ĳ�Ʒ����4-6�µ�ҵ�����ף�ÿ����¸���ʱ��=�����ҵ������
-- 


with 
t_prod as ( -- 230301������
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,t.name ,t.NodePathName  ,t.Department 
from import_data.erp_product_products pp 
left join view_roles t on pp.DevelopUserName = t.name  and t.Department = '��ٻ�' and t.ProductRole = '����'
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-04-01' and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '2023-07-01'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='��ٻ�' a
)

,t_orde as (  -- ÿ�ܳ�����ϸ
select 
	left(PayTime,7) pay_month 
	,WEEKOFYEAR( paytime) pay_week 
	,to_date(PayTime) pay_date 
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin,BoxSku ,PurchaseCosts
	,paytime
-- 	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
	,t.name ,t.NodePathName  ,t.Department 
from import_data.wt_orderdetails wo 
join t_prod t on wo.Product_Sku = t.sku 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '2023-06-01' and paytime <'2023-07-01'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
) 

,t_list as ( -- 23���ڿ�������
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,left( PublicationDate,7) pub_month
	,WEEKOFYEAR( PublicationDate) pub_week
	,to_date( PublicationDate) pub_date
	-- 	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
	,t.name ,t.NodePathName  ,t.Department 
from wt_listing wl 
join t_prod t on wl.sku = t.sku 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where 
	PublicationDate >=  '2023-03-01' and PublicationDate < '2023-07-01'
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
-- 	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' -- ��Ϊ����Ʒʱ�䷶Χ �����ƿ���ʱ�䷶Χ��
)

-- select count(1) from t_list

, t_list_stat as ( -- ��1 ���Ǽ���
select 
-- 	case when NodePathName is not null and name is not null and pay_month is null and pay_week is null and pay_date is null then '������x��Ա' 
-- 		when NodePathName is not null and name is null and pay_month is null and pay_week is null and pay_date is null then '������' 
-- 		when NodePathName is null and SellUserName is null and pub_week is null then '�Ŷ�' 
-- 		when NodePathName is not null and SellUserName is not null and pub_week is not null then '�Ŷ�xС��x��Աx������' 
-- 		when NodePathName is not null and SellUserName is null and pub_week is not null then '�Ŷ�xС��x������' 
-- 		when NodePathName is null and SellUserName is null and pub_week is not null then '�Ŷ�x������' 
-- 		end as `����ά��`
-- 	,case when dep2 is null then '�ϼ�' else dep2 end as dep2
	case when NodePathName is null then '�ϼ�' else NodePathName end as NodePathName
	,case when name is null then '�ϼ�' else name end as name
-- 	,case when pub_week is null then '�ϼ�' else pub_week end as pub_week
	,pay_date
	,pay_week
	,pay_month
	,count(distinct BoxSku)  `����SKU��`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `����������`
from t_list
group by grouping sets(
	(NodePathName ,name ,pub_date)
	,(NodePathName ,name ,pay_week)
	,(NodePathName ,name ,pay_month)
	,(NodePathName ,pay_date)
	,(NodePathName ,pay_week)
	,(NodePathName ,pay_month)
	)
)
select * from t_list_stat


, t_list_sale_details as ( -- ��1 ÿ��������ÿ�ܵĳ������
select 
	t_list.dep2 ,t_list.NodePathName ,t_list.SellUserName ,t_list.sellersku ,t_list.shopcode ,t_list.pub_week 
	,od.boxsku ,od.pay_week ,od.salecount  ,od.TotalGross ,od.TotalProfit
from t_list 
join (
	select boxsku ,sellersku ,shopcode ,pay_week
		,sum(salecount) salecount
		,round( sum((TotalGross)/ExchangeUSD),2)  TotalGross
		,round( sum((TotalProfit)/ExchangeUSD),2)  TotalProfit
	from t_orde group by boxsku ,sellersku ,shopcode ,pay_week
	) od
	on t_list.shopcode = od.shopcode and t_list.sellersku = od.sellersku and t_list.sellersku = od.sellersku 
)
-- select sum(TotalGross) `���۶�` from t_list_sale_details	

,t_list_sale_stat as (
select 
	case when NodePathName is not null and SellUserName is not null and pub_week is null then 'С��x��Ա' 
		when NodePathName is not null and SellUserName is null and pub_week is null then 'С��' 
		when NodePathName is null and SellUserName is null and pub_week is null then '�Ŷ�' 
		when NodePathName is not null and SellUserName is not null and pub_week is not null then '�Ŷ�xС��x��Աx������' 
		when NodePathName is not null and SellUserName is null and pub_week is not null then '�Ŷ�xС��x������' 
		when NodePathName is null and SellUserName is null and pub_week is not null then '�Ŷ�x������' 
		end as `����ά��`
	,case when dep2 is null then '�ϼ�' else dep2 end as dep2
	,case when NodePathName is null then '�ϼ�' else NodePathName end as NodePathName
	,case when SellUserName is null then '�ϼ�' else SellUserName end as SellUserName
	,case when pub_week is null then '�ϼ�' else pub_week end as pub_week
	,sum(salecount) `����`  
	,sum(TotalGross) `���۶�` 
	,sum(TotalProfit) `�����` 
	,count(distinct concat(shopcode,sellersku)) `����������`
	,count(distinct boxsku) `����sku��`
from t_list_sale_details
group by grouping sets(
	(dep2 ,NodePathName ,SellUserName)
	,(dep2 ,NodePathName)
	,(dep2)
	,(dep2 ,NodePathName ,SellUserName,pub_week)
	,(dep2 ,NodePathName,pub_week)
	,(dep2 ,pub_week)
	)
)

, t_merge as (    
select 
	t_list_stat.`����ά��` 
	,t_list_stat.dep2 
	,t_list_stat.NodePathName 
	,t_list_stat.SellUserName  
	,t_list_stat.pub_week  
	,t_list_stat.`����SKU��`  
	,t_list_stat.`����������`  
	,t_list_sale_stat.`����` 
	,t_list_sale_stat.`���۶�` 
	,t_list_sale_stat.`�����` 
	,t_list_sale_stat.`����������` 
	,t_list_sale_stat.`����sku��` 
from t_list_stat 
left join t_list_sale_stat 
on t_list_sale_stat.dep2 = t_list_stat.dep2 
	and t_list_sale_stat.NodePathName = t_list_stat.NodePathName
	and t_list_sale_stat.SellUserName = t_list_stat.SellUserName
	and t_list_sale_stat.pub_week = t_list_stat.pub_week 

)

-- select * from t_merge
-- where t_merge.SellUserName = '�ֵ���'

-- ���� ����-��Ա-���¿��Ƕ���ͳ��
select
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,`����ά��` 
	,dep2 `�Ŷ�`
	,NodePathName `С��`
	,t_merge.SellUserName `��Ա`
	,pub_week `������`
	,`����`
	,`���۶�`
	,`�����`
	,concat(round(`�����`/`���۶�`*100,2),'%') `ë����`
	,`����������`
	,`����������`
	,concat(round(`����������`/`����������`*100,2),'%') `���ӳ�����`
	,`����SKU��`
	,`����SKU��`
	,concat(round(`����SKU��`/`����SKU��`*100,2),'%') `SKU������`
from t_merge
order by `����ά��`
