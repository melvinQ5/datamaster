/*
5���ƿ�ר��
ͳ��ʱ�䷶Χ Q1+Q2����
ά�ȣ�SKU X ͳ��ʱ����� x �����Ŷ� x ���� 
ָ�꣺�������ӡ�����ͳ�ơ����ָ��
*/


with 
prod1 as ( -- 4�¸�Ǳ��Ʒ
select c4 as sku ,c5 as push_type
from manual_table mt where c1 = '�ƿ�ר�����+ר�_0511'
)

,prod2 as ( -- �ļ�
select eppaea.sku ,group_concat(eppea.Name) push_type  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.Name = '�ļ�'
group by eppaea.sku 
)

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,group_concat(eppea.Name) ele_name  
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
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
	,ele_name
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,DevelopUserName
	,push_type
from import_data.wt_products wp 
-- join prod1 on wp.sku =prod1.sku
join prod2 on wp.sku =prod2.sku
left join t_elem on wp.sku =t_elem.sku 
)

,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site
	, NodePathName 
	, ms.CompanyCode 
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,push_type
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
	, t_list.push_type
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  < '${NextStartDay}'
)
-- select * from t_ad 

,t_orde as (  
select 
	PlatOrderNumber ,TotalGross,TotalProfit ,FeeGross
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	, t_prod.push_type
	, NodePathName 
	, SellUserName
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
join t_prod on t_prod.sku = wo.Product_Sku  
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 
	and OrderStatus != '����' and ms.Department = '��ٻ�'
)
-- select * from t_orde 

,t_list_stat as (
select SKU , NodePathName ,push_type
	,count(distinct CompanyCode ) `���������˺���` 
	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `����������` 
	,count(distinct case when MarketType in ('UK','DE','FR')  then concat(SellerSKU,ShopCode) end ) `UK_DE_FR����������`
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) `UK����������`
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) `DE����������`
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) `FR����������`
from t_list
group by SKU , NodePathName ,push_type
)

,t_list_uproll_stat as (
select SKU ,push_type
	,count(distinct CompanyCode ) `���������˺���_SKU` 
	,count(distinct case when NodePathName in ('���Ԫ-�ɶ�������','��η�-�ɶ�������') then CompanyCode end ) `���������˺���_�ɶ�` 
	,count(distinct case when NodePathName in ('��Ӫ��-Ȫ��1��','��Ӫ��-Ȫ��2��','��Ӫ��-Ȫ��3��') then CompanyCode end ) `���������˺���_Ȫ��`
from t_list
group by SKU ,push_type
)

,t_sale_stat as (
select sku , NodePathName ,push_type
	,round(sum(TotalGross/ExchangeUSD)) `���۶�` 
	,round(sum(TotalProfit/ExchangeUSD)) `�����` 
	,count(distinct PlatOrderNumber) `������` 
	,round( sum( FeeGross/ExchangeUSD )) `�˷�����`
from t_orde
group by sku , NodePathName ,push_type
)

, t_site_sort as (  -- ÿ��SKU ��3������top2��վ�� 
select sku ,GROUP_CONCAT(site) ������վ��_SKU
from (
	select * , ROW_NUMBER () over (partition by sku order by sales desc ) sort 
	from (
		select Product_Sku as sku ,  ms.Site , sum(SaleCount) sales
		from import_data.wt_orderdetails wo 
		join mysql_store ms on ms.Code = wo.shopcode 
		join t_prod on t_prod.sku = wo.Product_Sku  
		where PayTime >= date_add(current_date(),interval - 3 month) 
			and PayTime < current_date()
			and OrderStatus != '����' and ms.Department = '��ٻ�'
		group by Product_Sku ,  ms.Site
		) tb 
	where sales > 0
	) tc 
where sort <= 2 
group by sku
)

, t_ad_stat as (
select tmp.* 
	, round(Clicks/Exposure,4) as CTR
	, round(TotalSale7DayUnit/Clicks,6) as CVR
	, round(TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/Clicks,4) as `CPC`
from 
	( select sku , NodePathName ,push_type
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
		from t_ad  group by sku , NodePathName ,push_type
	) tmp  
)


,t_merge as (
select 
	ta.push_type ����
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') ͳ��ʱ�䷶Χ
	,ta.NodePathName �����Ŷ�
	,spu
	,ta.sku 
	,ta.boxsku
	,ProductName
	,TortType ��Ȩ״̬
	,Festival ���ڽ���
	,ele_name Ԫ������
	,date(DevelopLastAuditTime) ��������
	,DevelopUserName ������Ա
	,������վ��_SKU
	,���������˺���_SKU
	,���������˺���_�ɶ�
	,���������˺���_Ȫ��
	,���������˺���
	,����������
	,UK_DE_FR����������
	,UK����������
	,DE����������
	,FR����������
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
from (
	select t_prod.* ,t.NodePathName
	from t_prod 
	cross join ( select distinct NodePathName from import_data.mysql_store where department = '��ٻ�' ) t 
	) ta
left join t_list_uproll_stat tb on ta.sku = tb.sku and ta.push_type = tb.push_type 
left join t_sale_stat tc on ta.sku = tc.sku and ta.push_type = tc.push_type and ta.NodePathName = tc.NodePathName
left join t_ad_stat td on ta.sku = td.sku and ta.push_type = td.push_type and ta.NodePathName = td.NodePathName
left join t_list_stat te on ta.sku = te.sku and ta.push_type = te.push_type and ta.NodePathName = te.NodePathName
left join t_site_sort tf on ta.sku = tf.sku
)

select * from t_merge
