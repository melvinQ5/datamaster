-- ���壺����ʱ����23��3��1�ż��Ժ�Ĳ�Ʒ����4-6�µ�ҵ�����ף�ÿ����¸���ʱ��=�����ҵ������
-- 


with 
t_prod as ( -- 230301������
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,de.name 
from import_data.erp_product_products epp 
left join (
	select case when sku = '����' then '����1688' else sku end  as name
	,boxsku as department
	,case when spu = '��Ʒ��' then 'Ȫ����Ʒ��' when sku='֣���' then 'Ȫ����Ʒ��' else '�ɶ���Ʒ��' end as dep2
	from JinqinSku js where Monday= '2023-03-31'
	) de
	on epp.DevelopUserName = de.name
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-04-01' 
and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '2023-07-01'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='��ٻ�' 
)

,t_orde as (  -- ÿ�ܳ�����ϸ
select 
	left(PayTime,7) pay_month 
	,WEEKOFYEAR( paytime) pay_week 
	,to_date(PayTime) pay_date 
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin,BoxSku ,PurchaseCosts
	,paytime
	,t.name 
from import_data.wt_orderdetails wo 
join t_prod t on wo.Product_Sku = t.sku 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '2023-06-01' and paytime <'2023-07-01'
-- 	and paytime >= '2023-05-01' and paytime <'2023-06-01'
	and ms.Department = '��ٻ�'
	and wo.IsDeleted=0
) 

select name ,round(sum(TotalGross/ExchangeUSD),2) 6�¿�˰���˿����۶�
from t_orde 
group by name 