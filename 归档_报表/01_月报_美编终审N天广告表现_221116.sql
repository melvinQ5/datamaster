/*
���ܡ��·���
��Ʒ��������ʱ��������7�죬14�죬30�죬60�죬90��
������������ʣ����ת���ʣ��ÿ�ת����
�༭���ع�SKUռ�ȣ����ת���ʣ��ÿ�ת����

7���ع�skuռ��=��������ʱ��7���ڵĹ��������ݣ����ع�������0��sku���� �£����ܿ�����sku����
SKU�ع� >100�� ����Ч�ع⣬��������ٸ��´����������sku10000.01 ��7�����ع����ۼƴﵽ100��sku10000.01�ͱ���Ч�ع�

*/

with 
tmp_epp as (
select BoxSku , SKU, SPU, DevelopLastAuditTime ,GROUP_CONCAT(Product_Artist) as Product_Artist,GROUP_CONCAT(Product_Editor) as Product_Editor,dev_month,dev_week
from (
select
	 epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
	, case when epps.DevelopStage = '40' and epps.HandleUserName in ('������','Ϳ���','�ž�','����','��ѩ��') then HandleUserName end Product_Artist
	, case when epps.DevelopStage = '50' and epps.HandleUserName in ('�����','����','����','������','��ѩ��','�Խ�') then HandleUserName end Product_Editor	
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
from import_data.erp_product_products epp
join import_data.erp_product_product_statuses epps on epp.id=epps.ProductId 
where epp.DevelopLastAuditTime >= '2022-05-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	and epps.DevelopStage in ('40','50')
) tmp 
group by BoxSku , SKU, SPU, DevelopLastAuditTime, dev_month,dev_week
)


, ad as ( 
select asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit, t.SPU, t.SKU, t.BoxSku
	, DevelopLastAuditTime, Product_Artist, Product_Editor
	, timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- ���
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 7*86400 then '��' else '��' end `�Ƿ�7��`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 14 then '��' else '��' end `�Ƿ�14��`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 30 then '��' else '��' end `�Ƿ�30��`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 60 then '��' else '��' end `�Ƿ�60��`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 90 then '��' else '��' end `�Ƿ�90��`
	, case when 0 < timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime) <= 120 then '��' else '��' end `�Ƿ�120��`
from import_data.erp_amazon_amazon_listing eaal 
join tmp_epp t on  eaal.sku = t.SKU 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('���۶���', '��������')
join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
where eaal.ListingStatus = 1  and asa.CreatedTime >= '2022-05-01'
)


-- , ad_group as (  
-- select 
-- from ad 
-- group by ad_days, ShopCode, Asin, SPU, SKU, BoxSku, DevelopLastAuditTime, Product_Artist, Product_Editor
-- )

-- select asa.id ,asa.AdActivityName `�������`, asa.CreatedTime`��洴��ʱ��`, asa.ShopCode ,asa.Asin , asa.Clicks`�����`, asa.Exposure`�ع���`, asa.TotalSale7DayUnit`����`
-- 	, t.SPU, t.SKU, t.BoxSku
-- 	, DevelopLastAuditTime`��������ʱ��`, Product_Artist, Product_Editor
-- 	, datediff(asa.CreatedTime,t.DevelopLastAuditTime) as ad_days -- ���
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 7 then '��' else '��' end `�Ƿ�7��`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 14 then '��' else '��' end `�Ƿ�14��`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 30 then '��' else '��' end `�Ƿ�30��`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 60 then '��' else '��' end `�Ƿ�60��`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 90 then '��' else '��' end `�Ƿ�90��`
-- 	, case when 0 < datediff(asa.CreatedTime,t.DevelopLastAuditTime) and datediff(asa.CreatedTime,t.DevelopLastAuditTime) <= 120 then '��' else '��' end `�Ƿ�120��`
-- from import_data.erp_amazon_amazon_listing eaal 
-- join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
-- join tmp_epp t on  eaal.sku = t.SKU 
-- join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('���۶���', '��������')
-- where eaal.ListingStatus = 1  and asa.CreatedTime >= '2022-10-17'


-- -- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
select * from (
	select '����' `����ά��`, dev_month `������`, '�ϼ�' `����`, '�ϼ�' `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad60_sku_cnt/dev_cnt,4) as `60���ع�SKUռ��`, round(ad90_sku_cnt/dev_cnt,4) as `90���ع�SKUռ��`, round(ad120_sku_cnt/dev_cnt,4) as `120���ع�SKUռ��`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		, round(ad60_sku_Clicks/ad60_sku_Exposure,4) as `60������`, round(ad90_sku_Clicks/ad90_sku_Exposure,4) as `90������`, round(ad120_sku_Clicks/ad120_sku_Exposure,4) as `120������`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		, round(ad60_sku_TotalSale7DayUnit/ad60_sku_Clicks,4) as `60��ת����`, round(ad90_sku_TotalSale7DayUnit/ad90_sku_Clicks,4) as `90��ת����`, round(ad120_sku_TotalSale7DayUnit/ad120_sku_Clicks,4) as `120��ת����`
		, ad7_sku_Exposure `7���ع���`, ad14_sku_Exposure `14���ع���`, ad30_sku_Exposure `30���ع���`, ad60_sku_Exposure `60���ع���`, ad90_sku_Exposure `90���ع���`, ad120_sku_Exposure `120���ع���`
		, ad7_sku_Clicks `7������`, ad14_sku_Clicks `14������`, ad30_sku_Clicks `30������`, ad60_sku_Clicks `60������`, ad90_sku_Clicks `90������`, ad120_sku_Clicks `120������`
		, ad7_sku_TotalSale7DayUnit `7������`, ad14_sku_TotalSale7DayUnit `14������`, ad30_sku_TotalSale7DayUnit `30������`, ad60_sku_TotalSale7DayUnit `60������`, ad90_sku_TotalSale7DayUnit `90������`, ad120_sku_TotalSale7DayUnit `120������`
		from ( 
		select dev_month
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			, count(distinct case when ad60_sku_Exposure > 100 then BoxSKU end) as ad60_sku_cnt
			, count(distinct case when ad90_sku_Exposure > 100 then BoxSKU end) as ad90_sku_cnt
			, count(distinct case when ad120_sku_Exposure > 100 then BoxSKU end) as ad120_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure, sum(ad60_sku_Exposure) as ad60_sku_Exposure, sum(ad90_sku_Exposure) as ad90_sku_Exposure, sum(ad120_sku_Exposure) as ad120_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks, sum(ad60_sku_Clicks) as ad60_sku_Clicks, sum(ad90_sku_Clicks) as ad90_sku_Clicks, sum(ad120_sku_Clicks) as ad120_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit, sum(ad60_sku_TotalSale7DayUnit) as ad60_sku_TotalSale7DayUnit, sum(ad90_sku_TotalSale7DayUnit) as ad90_sku_TotalSale7DayUnit, sum(ad120_sku_TotalSale7DayUnit) as ad120_sku_TotalSale7DayUnit
		from 
			( select t.dev_month , ad.BoxSku,t.BoxSku as t_BoxSku
			-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Exposure end)) as ad60_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Exposure end)) as ad90_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Exposure end)) as ad120_sku_Exposure
				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Clicks end)) as ad60_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Clicks end)) as ad90_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Clicks end)) as ad120_sku_Clicks
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then TotalSale7DayUnit end)) as ad60_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then TotalSale7DayUnit end)) as ad90_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then TotalSale7DayUnit end)) as ad120_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_month ,ad.BoxSku,t.BoxSku
			) tmp1
		group by dev_month
		) tmp
union all 
	select '����\����' `����ά��`, dev_month `������`, Product_Artist `����`, '�ϼ�' `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad60_sku_cnt/dev_cnt,4) as `60���ع�SKUռ��`, round(ad90_sku_cnt/dev_cnt,4) as `90���ع�SKUռ��`, round(ad120_sku_cnt/dev_cnt,4) as `120���ع�SKUռ��`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		, round(ad60_sku_Clicks/ad60_sku_Exposure,4) as `60������`, round(ad90_sku_Clicks/ad90_sku_Exposure,4) as `90������`, round(ad120_sku_Clicks/ad120_sku_Exposure,4) as `120������`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		, round(ad60_sku_TotalSale7DayUnit/ad60_sku_Clicks,4) as `60��ת����`, round(ad90_sku_TotalSale7DayUnit/ad90_sku_Clicks,4) as `90��ת����`, round(ad120_sku_TotalSale7DayUnit/ad120_sku_Clicks,4) as `120��ת����`
		, ad7_sku_Exposure `7���ع���`, ad14_sku_Exposure `14���ع���`, ad30_sku_Exposure `30���ع���`, ad60_sku_Exposure `60���ع���`, ad90_sku_Exposure `90���ع���`, ad120_sku_Exposure `120���ع���`
		, ad7_sku_Clicks `7������`, ad14_sku_Clicks `14������`, ad30_sku_Clicks `30������`, ad60_sku_Clicks `60������`, ad90_sku_Clicks `90������`, ad120_sku_Clicks `120������`
		, ad7_sku_TotalSale7DayUnit `7������`, ad14_sku_TotalSale7DayUnit `14������`, ad30_sku_TotalSale7DayUnit `30������`, ad60_sku_TotalSale7DayUnit `60������`, ad90_sku_TotalSale7DayUnit `90������`, ad120_sku_TotalSale7DayUnit `120������`
		from ( 
		select dev_month, Product_Artist
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			, count(distinct case when ad60_sku_Exposure > 100 then BoxSKU end) as ad60_sku_cnt
			, count(distinct case when ad90_sku_Exposure > 100 then BoxSKU end) as ad90_sku_cnt
			, count(distinct case when ad120_sku_Exposure > 100 then BoxSKU end) as ad120_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure, sum(ad60_sku_Exposure) as ad60_sku_Exposure, sum(ad90_sku_Exposure) as ad90_sku_Exposure, sum(ad120_sku_Exposure) as ad120_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks, sum(ad60_sku_Clicks) as ad60_sku_Clicks, sum(ad90_sku_Clicks) as ad90_sku_Clicks, sum(ad120_sku_Clicks) as ad120_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit, sum(ad60_sku_TotalSale7DayUnit) as ad60_sku_TotalSale7DayUnit, sum(ad90_sku_TotalSale7DayUnit) as ad90_sku_TotalSale7DayUnit, sum(ad120_sku_TotalSale7DayUnit) as ad120_sku_TotalSale7DayUnit
		from 
			( select t.dev_month , ad.BoxSku, t.Product_Artist,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Exposure end)) as ad60_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Exposure end)) as ad90_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Exposure end)) as ad120_sku_Exposure
				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Clicks end)) as ad60_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Clicks end)) as ad90_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Clicks end)) as ad120_sku_Clicks
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then TotalSale7DayUnit end)) as ad60_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then TotalSale7DayUnit end)) as ad90_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then TotalSale7DayUnit end)) as ad120_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_month ,ad.BoxSku, t.Product_Artist,t.BoxSku
			) tmp1
		group by dev_month,Product_Artist
		) tmp
union all 
	select '����\�༭' `����ά��`, dev_month `������`,  '�ϼ�' `����`, Product_Editor `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad60_sku_cnt/dev_cnt,4) as `60���ع�SKUռ��`, round(ad90_sku_cnt/dev_cnt,4) as `90���ع�SKUռ��`, round(ad120_sku_cnt/dev_cnt,4) as `120���ع�SKUռ��`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		, round(ad60_sku_Clicks/ad60_sku_Exposure,4) as `60������`, round(ad90_sku_Clicks/ad90_sku_Exposure,4) as `90������`, round(ad120_sku_Clicks/ad120_sku_Exposure,4) as `120������`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		, round(ad60_sku_TotalSale7DayUnit/ad60_sku_Clicks,4) as `60��ת����`, round(ad90_sku_TotalSale7DayUnit/ad90_sku_Clicks,4) as `90��ת����`, round(ad120_sku_TotalSale7DayUnit/ad120_sku_Clicks,4) as `120��ת����`
		, ad7_sku_Exposure `7���ع���`, ad14_sku_Exposure `14���ع���`, ad30_sku_Exposure `30���ع���`, ad60_sku_Exposure `60���ع���`, ad90_sku_Exposure `90���ع���`, ad120_sku_Exposure `120���ع���`
		, ad7_sku_Clicks `7������`, ad14_sku_Clicks `14������`, ad30_sku_Clicks `30������`, ad60_sku_Clicks `60������`, ad90_sku_Clicks `90������`, ad120_sku_Clicks `120������`
		, ad7_sku_TotalSale7DayUnit `7������`, ad14_sku_TotalSale7DayUnit `14������`, ad30_sku_TotalSale7DayUnit `30������`, ad60_sku_TotalSale7DayUnit `60������`, ad90_sku_TotalSale7DayUnit `90������`, ad120_sku_TotalSale7DayUnit `120������`
		from ( 
		select dev_month, Product_Editor
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			, count(distinct case when ad60_sku_Exposure > 100 then BoxSKU end) as ad60_sku_cnt
			, count(distinct case when ad90_sku_Exposure > 100 then BoxSKU end) as ad90_sku_cnt
			, count(distinct case when ad120_sku_Exposure > 100 then BoxSKU end) as ad120_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure, sum(ad60_sku_Exposure) as ad60_sku_Exposure, sum(ad90_sku_Exposure) as ad90_sku_Exposure, sum(ad120_sku_Exposure) as ad120_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks, sum(ad60_sku_Clicks) as ad60_sku_Clicks, sum(ad90_sku_Clicks) as ad90_sku_Clicks, sum(ad120_sku_Clicks) as ad120_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit, sum(ad60_sku_TotalSale7DayUnit) as ad60_sku_TotalSale7DayUnit, sum(ad90_sku_TotalSale7DayUnit) as ad90_sku_TotalSale7DayUnit, sum(ad120_sku_TotalSale7DayUnit) as ad120_sku_TotalSale7DayUnit
		from 
			( select t.dev_month , ad.BoxSku, t.Product_Editor,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Exposure end)) as ad60_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Exposure end)) as ad90_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Exposure end)) as ad120_sku_Exposure
				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then Clicks end)) as ad60_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then Clicks end)) as ad90_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then Clicks end)) as ad120_sku_Clicks
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -60 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 60 then TotalSale7DayUnit end)) as ad60_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -90 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 90 then TotalSale7DayUnit end)) as ad90_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -120 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 120 then TotalSale7DayUnit end)) as ad120_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_month ,ad.BoxSku, t.Product_Editor,t.BoxSku
			) tmp1
		group by dev_month,Product_Editor
		) tmp
) union_tmp
where `����` is not null and `�༭` is not null -- �����༭��Ա������Ӳ����ģ����������������༭����Ա��������Ҳ��Ϊ������Ŀǰ�ڹ������� 
order by  `����ά��`, `������`, `����`, `�༭`