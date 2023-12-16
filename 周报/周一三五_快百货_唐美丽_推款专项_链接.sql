/*
5���ƿ�ר��
ͳ��ʱ�䷶Χ Q1�ϼ� + Q2�����
ά�ȣ����� X ͳ��ʱ�����  x ���� 
ָ�꣺�������ӡ�����ͳ�ơ����ָ��
*/

with 
prod1 as ( -- 4�¸�Ǳ��Ʒ
select c4 as sku ,c5 as push_type
from manual_table mt where c1 = '�ƿ�ר�����+ר�_0511'
)

,prod2 as ( -- �ļ�
select eppaea.sku ,group_concat(eppea.Name) ele_name   ,'�ļ�' as push_type
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.Name = '�ļ�'
group by eppaea.sku 
)

,t_prod as ( 
select wp.SKU ,SPU ,BoxSKU ,ProductName 
	,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
	,TortType
	,Festival
	,push_type
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,DevelopUserName
from import_data.wt_products wp 
-- join prod1 on wp.sku =prod1.sku
join prod2 on wp.sku =prod2.sku
)

,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site ,AccountCode 
	, NodePathName 
	, ms.CompanyCode 
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
where wl.IsDeleted = 0 and ms.Department = '��ٻ�' and ms.ShopStatus = '����' and ListingStatus = 1
)

,t_ad as ( -- �����ϸ
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	,t_list.site
	, NodePathName 
	, SellUserName 
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
)
-- select * from t_ad 

,t_orde as (  
select 
	PlatOrderNumber ,TotalGross,TotalProfit ,FeeGross
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	, NodePathName 
	, SellUserName
	,shopcode 
	,sellersku 
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on t_prod.sku = wo.Product_Sku  
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
	and OrderStatus != '����' and ms.Department = '��ٻ�'
)
-- select * from t_orde 

,t_sale_stat as (
select shopcode ,sellersku 
	,round(sum(TotalGross/ExchangeUSD)) `���۶�` 
	,round(sum(TotalProfit/ExchangeUSD)) `�����` 
	,count(distinct PlatOrderNumber) `������` 
	,round( sum( FeeGross/ExchangeUSD )) `�˷�����`
from t_orde
group by shopcode ,sellersku 
)

, t_ad_stat as (
select tmp.* 
	, round(Clicks/Exposure,4) as CTR
	, round(TotalSale7DayUnit/Clicks,6) as CVR
	, round(TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/Clicks,4) as `CPC`
from 
	( select shopcode ,sellersku 
		-- �ع���
		, round(sum( Exposure )) as Exposure
		-- ��滨��
		, round(sum( cost*ExchangeUSD),2) as ad_Spend
		-- ������۶�
		, round(sum( TotalSale7Day ),2) as TotalSale7Day
		-- �������	
		, round(sum( TotalSale7DayUnit ),2) as TotalSale7DayUnit
		-- �����
		, round(sum( Clicks )) as Clicks
		from t_ad  group by shopcode ,sellersku 
	) tmp  
)

, t_ad_name as ( -- �������
select shopcode  ,sellersku 
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,AdActivityName from t_ad  group by shopcode  ,sellersku  ,AdActivityName) tb 
group by shopcode  ,sellersku 
)


,t_merge as (
select 
	push_type ����
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') ͳ��ʱ�䷶Χ
	,left(DevelopLastAuditTime,7) ��Ʒ�����·�
	,ta.shopcode 
	,ta.sellersku ����sku
	,ta.asin
	,ta.site 
	,ta.AccountCode
	,ta.NodePathName �����Ŷ�
	,ta.SellUserName ��ѡҵ��Ա
	,case when year(MinPublicationDate) >= '2023' then '��' else '��' end �Ƿ�23��󿯵�
	,WEEKOFYEAR(MinPublicationDate) 23�꿯����
	,MinPublicationDate �״ο���ʱ��
	,AdActivityName �������
	
	,���۶�
	,�����  -- ��������Ʒά�Ⱦۺϣ�δ�۹���
	,����� - ad_Spend  as �����_�۹��
	,������
	,�˷�����
	,Exposure
	,Clicks 
	,ad_Spend 
	,TotalSale7Day AS ad_sale_amount
	,TotalSale7DayUnit AS ad_sale_unit
	,CTR
	,CVR 
	,CPC
	,ACOS
	,ROAS
	
	,tb.spu
	,tb.sku 
	,tb.boxsku
	,ProductName
	,TortType ��Ȩ״̬
	,Festival ���ڽ���
	,DevelopUserName ������Ա
from t_list ta
left join t_prod tb on ta.sku = tb.sku 
left join t_sale_stat tc on ta.shopcode = tc.shopcode and ta.sellersku = tc.sellersku
left join t_ad_stat td on ta.shopcode = td.shopcode and ta.sellersku = td.sellersku
left join t_ad_name te on ta.shopcode = te.shopcode and ta.sellersku = te.sellersku
)

select * from t_merge

