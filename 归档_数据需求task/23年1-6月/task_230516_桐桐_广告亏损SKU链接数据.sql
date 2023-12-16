/*
5���ƿ�ר��
ͳ��ʱ�䷶Χ Q1�ϼ� + Q2�����
ά�ȣ����� X ͳ��ʱ�����  x ���� 
ָ�꣺�������ӡ�����ͳ�ơ����ָ��
*/

with 
ta as (
select [
5217877.01,
5212207.01,
5212156.02,
5195459.01,
5214670.01,
5202081.02,
5212215.02,
5212073.01,
5215711.01,
5212156.01,
5141934.01,
5199208.02,
5198722.01,
1042154.01,
5195337.01,
5214995.01,
5201021.01,
5212201.01,
5014847.02,
1009587.01,
1010052.01,
5198115.02,
5214038.01,
5023906.01,
5197096.01,
5200386.01,
5207265.01,
5202090.02,
5196493.01,
1033509.01,
5054144.01,
5010318.01,
5215684.01,
5197606.01
] arr 
)

,tb as (
select * 
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
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
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,DevelopUserName
from import_data.wt_products wp 
join tb on wp.sku =tb.arr
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
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') ͳ��ʱ�䷶Χ
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

