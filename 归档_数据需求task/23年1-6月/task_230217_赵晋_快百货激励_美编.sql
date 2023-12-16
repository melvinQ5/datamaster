/*
����ʱ�䣺2023.2.13��2023.3.12
ȡֵ�������ڼ���ʱ�䷶Χ�ڣ��������༭������ɣ����뿪���������Ʒ�����༭�ύʱ��2023.2.13--2023.3.12������Ʒ�������ύʱ��2023.2.13--2023.3.12������Ʒ
����ά�ȣ����ڡ��������༭��SKU�����ع������ع�SKUռ�ȡ�������������
�������ݣ��վ������ﵽ15�����ϣ�ȡ���˵�����ͼƬ����ʣ������ܵ��/�������ع⣩
�༭���ݣ��վ������ﵽ15�����ϣ�ȡ���˵��ع���ռ�ȣ��������ع�SKU����/������SKU������
����˵�����༭���������ݱ����ȡ���ݺ����ù�ʽ���㣨�����߼���ʽ���ϣ�

��������ʵ�ʴ���SPU�����վ�����������ȡ��ʵֵ���ع���ռ���ż�ȷ����Ϊ���վ��ع��1���վ���������������İ�������ĩ��ֻ����ʵ�ʹ����յ��վ�������

*/

-- 0212-0302 ����Ϣ4�� RestDays = 4 
-- 0212-0306 ����Ϣ4�� RestDays = 6 
-- 0212-0312 ����Ϣ4�� RestDays = 7

with art_sku as (
select HandleUserName , SKU ,SPU ,ProductId
from import_data.erp_product_products epp 
join (
	select ProductId  ,HandleUserName 
	from import_data.erp_product_product_statuses
	where AuditTime  < '${NextStartDay}' and AuditTime >= '${StartDay}' 
		and DevelopStage = 40
	group by ProductId  ,HandleUserName 
	) art on epp.Id = art.ProductId
where HandleUserName in ('������','�ž�','Ϳ���','��ѩ��') and DevelopLastAuditTime is not null 
group by HandleUserName , SKU ,SPU ,ProductId
)

, art_adserving as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin 
		,Clicks as AdClicks ,Exposure as AdExposure
		,eaal.SKU 
from (		
	select eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	from import_data.erp_amazon_amazon_listing eaal 
	join art_sku t on eaal.sku = t.SKU and eaal.ListingStatus = 1 
	group by eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	) eaal
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day)/*ʱ��ά��*/
		and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 	
-- join import_data.mysql_store s on ad.ShopCode=s.Code  and department = '��ٻ�'
)

, art_stat as (
 select
 	HandleUserName 
 	, round(sum(AdClicks)/sum(AdExposure),10) `�������`
 	, count(DISTINCT t.sku) `�������������ͨ��SKU��`
 	, count(DISTINCT t.sPU) `��ӦSPU��`
 from art_sku t 
 left join (
	select SKU ,sum(AdClicks) AdClicks,sum(AdExposure) AdExposure
 	from art_adserving 
 	group by SKU ) ads
 	on ads.SKU =t.SKU  
 group by HandleUserName
)

-- ����
select HandleUserName ,`�������` 
	,`�������������ͨ��SKU��` 
-- 	,`��ӦSPU��`
-- 	,round(`��ӦSPU��`/(datediff('${NextStartDay}','2023-02-13')-'${RestDays}') ,1) `�վ�����SPU��` 
from art_stat
where HandleUserName in ('������','�ž�','Ϳ���','��ѩ��')
order by HandleUserName


WITH editor_sku as ( -- �༭�����sku
select HandleUserName , epp.SKU ,epp.SPU 
from import_data.erp_product_products epp 
join ( 
	select ProductId  ,HandleUserName 
	from import_data.erp_product_product_statuses
	where AuditTime  < '${NextStartDay}' and AuditTime >= '${StartDay}' 
		and DevelopStage = 50
	group by ProductId  ,HandleUserName 
	) editor 
on epp.Id = editor.ProductId
where HandleUserName in ('�����','����','��ѩ��','�Խ�') and DevelopLastAuditTime is not null 
group by HandleUserName , epp.SKU ,epp.SPU 
)


, editor_adserving as ( -- �༭����SKU�� �������
select ad.ShopCode ,ad.SellerSKU ,ad.Asin 
		,Clicks as AdClicks ,Exposure as AdExposure
		,eaal.SKU 
from (		
	select eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	from import_data.erp_amazon_amazon_listing eaal 
	join editor_sku t on eaal.sku = t.SKU 
-- 	and eaal.ListingStatus = 1 
	and LENGTH(eaal.SKU) > 0 
	group by eaal.SKU ,eaal.ShopCode ,eaal.SellerSKU ,eaal.Asin 
	) eaal
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day)/*ʱ��ά��*/
		and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and eaal.ShopCode = ad.ShopCode and ad.SellerSKU = eaal.SellerSKU and ad.Asin  = eaal.Asin 	
-- join import_data.mysql_store s on ad.ShopCode=s.Code  and department = '��ٻ�'
)


, editor_stat_expo as ( -- �վ��ع���
select SKU , AdExposure_stat/(datediff('${NextStartDay}','2023-02-13')-'${RestDays}') as daily_ADexpo
from (
	select SKU,sum(AdExposure) AdExposure_stat 
	from editor_adserving group by SKU
	) tmp 
)


, editor_stat as ( -- ȡ���˵��ع���ռ�ȣ��������ع�SKU����/������SKU������
select HandleUserName
	, count(distinct case when daily_ADexpo >= 1
		then editor_stat_expo.sku end)/count(distinct editor_stat_expo.sku) `�վ��ع���ڵ���1��SKUռ��`
	, count(DISTINCT editor_sku.sku) `�༭���������ͨ��SKU��`
	, count(DISTINCT editor_sku.spu) `��ӦSPU��`
from editor_sku
left join editor_stat_expo on editor_sku.SKU =editor_stat_expo.SKU  
group by HandleUserName
)


-- �༭
select HandleUserName 
	,`�վ��ع���ڵ���1��SKUռ��` 
	,`�༭���������ͨ��SKU��` 
from editor_stat
where HandleUserName in ('�����','����','��ѩ��','�Խ�')
order by HandleUserName

