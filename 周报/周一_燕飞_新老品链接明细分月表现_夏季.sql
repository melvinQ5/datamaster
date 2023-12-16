
with 
t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.Name = '�ļ�'
group by eppaea.sku 
)

,t_prod as ( -- ��Ʒ:3�º�����
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
from import_data.wt_products wp 
-- where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '${NextStartDay}'
where  IsDeleted = 0 
and ProjectTeam ='��ٻ�' 
)

,t_list as ( 
select wl.SPU ,wl.SKU ,BoxSku , wl.MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,month(MinPublicationDate) pub_month
	,date(DevelopLastAuditTime) dev_date ,DevelopUserName
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code  and ms.Site regexp 'UK|DE|FR|US|CA'
join t_prod on wl.sku = t_prod.sku 
where wl.IsDeleted = 0
	and ms.Department = '��ٻ�' and wl.IsDeleted = 0 
-- 	and MinPublicationDate  >= '2021-01-01'
-- 	and MinPublicationDate < '${NextStartDay}'
)

,t_ad as ( -- �����ϸ
select  asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS ,Spend 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, ms.SellUserName 
	,WEEKOFYEAR(asa.CreatedTime) crea_week 
	,month(asa.CreatedTime) crea_month 
from import_data.AdServing_Amazon asa 
join t_list on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
join mysql_store ms on ms.Code  = asa.ShopCode and ms.Department = '��ٻ�'
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  < '${NextStartDay}'
)

,t_orde as (  
select 
	PlatOrderNumber ,TotalGross,TotalProfit ,FeeGross ,SaleCount 
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,RefundAmount 
	,ms.SellUserName
	,shopcode
	,wo.SellerSku 
	,WEEKOFYEAR(PayTime) pay_week  
	,month(PayTime) pay_month
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on wo.Product_SKU = t_prod.sKU
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
	and OrderStatus != '����' and ms.Department = '��ٻ�' and TransactionType = '����'
)
-- select * from t_orde 'wt_isting'


,t_sale_stat as (
select
	shopcode 
	,sellersku 
	,pay_month 
-- 	,pay_week
	,round(sum(TotalGross/ExchangeUSD),2) `���۶�` 
	,round(sum(RefundAmount/ExchangeUSD),2) `�˿��` 
	,round(sum(TotalProfit/ExchangeUSD),2) `�����` 
	,count(distinct PlatOrderNumber) `������` 
	,round( sum( FeeGross/ExchangeUSD ),2) `�˷�����`
	,round( sum(salecount )) `����`
from t_orde
group by shopcode,sellersku,pay_month 
)

, t_ad_stat as (
select tmp.* 
	, round(Clicks/Exposure,4) as CTR
	, round(TotalSale7DayUnit/Clicks,6) as CVR
	, round(TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/Clicks,4) as `CPC`
from 
	( select 
		shopcode 
		,sellersku 
		,crea_month 
		-- �ع���
		, round(sum( Exposure )) as Exposure
		-- ��滨��
		, round(sum( spend),2) as ad_Spend
		-- ������۶�
		, round(sum( TotalSale7Day ),2) as TotalSale7Day
		-- �������	
		, round(sum( TotalSale7DayUnit )) as TotalSale7DayUnit
		-- �����
		, round(sum( Clicks )) as Clicks
		from t_ad 
		group by shopcode,sellersku,crea_month 
	) tmp  
)



,t_merge as ( 
select 
	Site
	,AccountCode 
	,NodePathName 
	,SellUserName 
	,t_list.shopcode 
	,t_list.sellersku 
	,t_list.asin 
	,t_list.sku
	,ele Ԫ��
	,dev_date �������� 
	,t_list.DevelopUserName ������Ա
	,date(t_list.MinPublicationDate)  `��������`
	,t_list.dim_month ͳ����
	,ta.pay_month �����·�
	,td.crea_month ����·�
	,���۶� -- �����˿�
	,�����  as �����_δ�۹�� 
	,round(�����/���۶�,2) ������_δ�۹��
	,����� - ad_Spend  as �����_�۹��
	,round((����� - ad_Spend)/���۶�,2) ������_�۹��
	,������
	,����
	,ifnull(�˷�����,0) �˷����� -- ���п�ֵ����0���
	,round(ifnull(�˷�����,0)/���۶�,2) �˷�ռ��
	,Exposure
	,Clicks 
	,ad_Spend 
	,if(ad_Spend=0,null,round(ad_Spend/���۶�,2)) ��滨��ռ�� -- ����0ֵ��ȥ�� 
	,TotalSale7Day AS ������۶�_������sku
	,TotalSale7DayUnit AS �������_������sku
	,CTR
	,CVR 
	,CPC
	,ACOS
	,ROAS
	,round(TotalSale7Day/(���۶�-�˿��),2) ���ҵ��ռ��
from (
	select t_list.* ,dim_month 
	from t_list 
	cross join ( select distinct month as dim_month from dim_date where year = 2023 and month in (5,6,7) ) dim 
	where t_list.pub_month <= dim_month  
	) t_list 
left join t_sale_stat ta on t_list.shopcode = ta.shopcode and t_list.sellersku = ta.sellersku  and t_list.dim_month = ta.pay_month 
left join t_ad_stat td on t_list.shopcode = td.shopcode and t_list.sellersku = td.sellersku  and t_list.dim_month = td.crea_month 
join t_elem on t_list.sku = t_elem .sku 
)

-- ������������滨�� �� �����������guang
--  select count(1) from t_merge
select * from t_merge 
