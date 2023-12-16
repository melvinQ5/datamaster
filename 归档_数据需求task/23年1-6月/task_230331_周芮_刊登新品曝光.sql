-- 3��30�� 16:14
-- ��Ʒlisting��Ч�ع��ʣ�X��=��Ʒlisting����7�����ع�������1��������/���¿���7�����ϵ���������
with
t_prod as ( -- ��Ʒ
select SKU ,ProjectTeam ,DevelopLastAuditTime ,IsMatrix ,spu ,CreationTime ,boxsku ,SkuSource ,Status 
from import_data.erp_product_products
where IsDeleted =0 and IsMatrix = 0 and DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= '${StartDay}'
)

,t_list as ( -- ��Ʒ��������
select ListingStatus ,eaal.SKU ,PublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,eaal.SPU ,ProductSalesName
	,ms.*
from wt_listing eaal
join t_prod on eaal.SKU = t_prod.sku 
join mysql_store ms on eaal.ShopCode = ms.Code and ListingStatus != 4 and ms.Department = '��ٻ�'
where PublicationDate >= '${StartDay}' and PublicationDate < '${NextStartDay}'
-- where PublicationDate = '2023-03-06' 
)

,t_list_adse as ( -- �������� left JOIN ���
select 
	eaal.SKU ,eaal.ProductSalesName ,eaal.PublicationDate
	,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	,Clicks as AdClicks ,Exposure as AdExposure ,ad.CreatedTime 
from t_list eaal 
left join import_data.AdServing_Amazon ad
	on eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 	
)

,t_list_adse_stat as (
select SKU ,ShopCode , SellerSKU , Asin ,ProductSalesName ,PublicationDate 
	,ifnull(sum(case when timestampdiff(second,PublicationDate,CreatedTime) <= 86400 * 7 then AdExposure end ),0) `����7���ع���` 
	,ifnull(sum(AdExposure ),0) `����0329�ع���` 
	,min(case when AdExposure >=1 then CreatedTime end) `�״��ع�ʱ��`
from t_list_adse
group by SKU ,ShopCode , SellerSKU , Asin ,ProductSalesName ,PublicationDate 
)

-- select count(1) from (

select 
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,t_prod.sku 
	,ShopCode `����`
	,SellerSKU `����SKU`
	,Asin 
	,ProductSalesName `������Ա`
	,ms.NodePathName  `�Ŷ�`
	,to_date(date_add(t_prod.DevelopLastAuditTime,interval -8 hour)) `��Ʒ����ʱ��`
	,to_date(PublicationDate) `����ʱ��`
	,`�״��ع�ʱ��`
	,`����7���ع���` 
	,`����0329�ع���` 
from t_list_adse_stat
left join t_prod on t_list_adse_stat.sku = t_prod.sku 
left join mysql_store ms on ms.Code = t_list_adse_stat.ShopCode


-- ) tmp 