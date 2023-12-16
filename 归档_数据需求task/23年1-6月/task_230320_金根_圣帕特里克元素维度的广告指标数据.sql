with 
-- step1 ����Դ���� 
t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku 
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where length(sku) > 0 and eppea.Name  ='ʥ������˽�'
group by  eppaea.sku
)

,t_list as (
select wl.SPU ,wl.SKU ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin ,IsDeleted `�Ƿ�ɾ��`
from erp_amazon_amazon_listing  wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_elem on wl.sku = t_elem.sku 
where 
-- 	PublicationDate >= '${StartDay}' and PublicationDate < '${NextStartDay}' 
-- 	and wl.IsDeleted = 0 
	ms.Department = '��ٻ�' 
)


,t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure 
		,TotalSale7DayUnit as AdSaleUnits
		,TotalSale7Day
		,Spend
		,CPC
		,t_list.sku
		,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
		,right(ms.Code,2) country ,ms.Market
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad on ad.ShopCode = ms.Code  
join t_list on ad.ShopCode  = t_list.ShopCode and ad.SellerSKU  = t_list.SellerSKU and ad.asin  = t_list.asin
where ms.Department = '��ٻ�' and ad.CreatedTime >= '${StartDay}' and ad.CreatedTime < '${NextStartDay}'
) 

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `�ÿ���` ,OrderedCount `�ÿ�����` 
	,department ,dep2 ,NodePathName 
	,country ,Market ,sku
from (
	select t_list.sku ,TotalCount ,FeaturedOfferPercent ,OrderedCount ,ms.department 
		,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,right(ms.Code,2) country ,ms.Market
	from import_data.ListingManage lm
	inner join import_data.mysql_store ms
		on lm.ShopCode=ms.Code and ReportType='�ܱ�' and Monday>='2023-02-26' and Monday <='2023-03-12'
	join t_list on lm.ShopCode  = t_list.ShopCode and lm.ChildAsin  = t_list.asin
	where ms.Department = '��ٻ�'
	union all 
	select t_list.sku ,TotalCount ,FeaturedOfferPercent ,OrderedCount ,ms.department 
		,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,right(ms.Code,2) country ,ms.Market
	from import_data.ListingManage lm
	inner join import_data.mysql_store ms
		on lm.ShopCode=ms.Code and ReportType='�±�' and Monday='2023-02-01'
	join t_list on lm.ShopCode  = t_list.ShopCode and lm.ChildAsin  = t_list.asin
	where ms.Department = '��ٻ�'
	) ta 
)
-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
, t_adse_stat as (
select sku ,ShopCode ,SellerSKU ,asin  
	,sum(AdClicks) as AdClicks 
	,sum(AdExposure) as AdExposure
	,sum(AdSaleUnits) as AdSaleUnits
	,sum(TotalSale7Day) as TotalSale7Day
	,sum(Spend) as Spend
	,sum(CPC) as CPC
from t_adse 
group by sku ,ShopCode ,SellerSKU ,asin  
)
-- 
-- ,t_vist_stat as (
-- select sku
-- 	,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` 
-- from t_vist 
-- group by sku
-- )

-- step3 ����ָ�����ݼ�
-- , t_merge as (
-- select t_vist_stat.sku 
-- 	,,ShopCode ,SellerSKU ,asin  
-- 	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  
-- 	,t_adse_stat.AdSaleUnits
-- 	,t_adse_stat.Spend
-- 	,t_adse_stat.TotalSale7Day
-- 	,t_vist_stat.`�ÿ���` ,t_vist_stat.`�ÿ�����`
-- from t_vist_stat 
-- join t_adse_stat on t_adse_stat.sku = t_vist_stat.sku
-- )

-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	sku
	,ShopCode ,SellerSKU ,asin  
	,AdExposure `�ع���`
	,AdClicks `�����`
	,AdSaleUnits `�������`
	,Spend `��滨��`
	,CPC `���CPC`
	,TotalSale7Day `������۶�`
	,round(AdClicks/AdExposure,4) `�������`
	,round(AdSaleUnits/AdClicks,4) `���ת����`
-- 	,round(`�ÿ���`) `�ÿ���`
-- 	,round(`�ÿ�����`/`�ÿ���`,4) `�ÿ�ת����`
-- 	,round((`�ÿ���`-AdClicks)/`�ÿ���`,4) `��Ȼ����ռ��`
from t_adse_stat

-- order by  sku  desc 