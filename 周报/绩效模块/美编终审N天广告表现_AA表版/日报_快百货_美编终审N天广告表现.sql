/*
���ܡ��·���
��Ʒ��������ʱ��������7�죬14�죬30�죬60�죬90��
������������ʣ����ת���ʣ��ÿ�ת����
�༭���ع�SKUռ�ȣ����ת���ʣ��ÿ�ת����

7���ع�skuռ��=��������ʱ��7���ڵĹ��������ݣ����ع�������0��sku���� �£����ܿ�����sku����

*/

with 
tmp_epp as (
select BoxSku , SKU, SPU, DevelopLastAuditTime , editor as Product_Editor , artist as Product_Artist 
	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
 	, date(date_add(developlastAuditTime,interval -8 hour)) dev_day
from import_data.wt_products where DevelopLastAuditTime >= '2023-05-01'
)


-- tmp_epp as (
-- select BoxSku , SKU, SPU, DevelopLastAuditTime ,GROUP_CONCAT(Product_Artist) as Product_Artist,GROUP_CONCAT(Product_Editor) as Product_Editor,dev_month,dev_week,dev_day
-- , GROUP_CONCAT(HandleUserName) as HandleUserName
-- from (
-- 	select
-- 		 epp.BoxSKU
-- 	 	, epp.SKU
-- 	 	, epp.SPU
-- 	 	, epp.DevelopLastAuditTime
-- 	 	, epps.HandleUserName
-- 		, case when epps.DevelopStage = '40' and epps.HandleUserName in ('������','Ϳ���','�ž�','����','��ѩ��','����','��׿','��ף��','������','�Ž�ɼ','��ٻ') then HandleUserName end Product_Artist
-- 		, case when epps.DevelopStage = '50' and epps.HandleUserName in ('�����','����','����','������','��ѩ��','�Խ�','�¿���','������') then HandleUserName end Product_Editor	
-- 		, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
-- 	 	, if(year(developlastAuditTime)='2022',WEEKOFYEAR(DevelopLastAuditTime)+1,WEEKOFYEAR(DevelopLastAuditTime)) as dev_week 
-- 	 	, date(date_add(developlastAuditTime,interval -8 hour)) dev_day
-- 	from import_data.erp_product_products epp
-- 	join import_data.erp_product_product_statuses epps on epp.id=epps.ProductId 
-- 	where date_add(developlastAuditTime,interval -8 hour) >= '2023-03-20' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
-- 		and epps.DevelopStage in ('40','50')
-- 	) tmp 
-- group by BoxSku , SKU, SPU, DevelopLastAuditTime, dev_month,dev_week,dev_day
-- )


, ad as ( 
select asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit, t.SPU, t.SKU, t.BoxSku ,ms.Site 
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
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('��ٻ�')
join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
where  asa.CreatedTime >= '2023-03-20'
)



-- -- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
select * from (
	select '����' `����ά��`, dev_day `������`
		, case dayofweek(dev_day) when 2 then '��һ' when 3 then '�ܶ�' when 4 then '����' when 5 then '����' 
			when 6 then '����' when 7 then '����' when 1 then '����' end `����`
		, '' `���վ��` 
		, dev_cnt `sku��`
		, dev_spu_cnt `spu��`
		, round(ad3_sku_cnt/dev_cnt,4) as `3���ع�SKUռ��`
		, round(ad4_sku_cnt/dev_cnt,4) as `4���ع�SKUռ��`
		, round(ad5_sku_cnt/dev_cnt,4) as `5���ع�SKUռ��`
		, round(ad6_sku_cnt/dev_cnt,4) as `6���ع�SKUռ��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`
		, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`
		, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		
		, round(ad3_clicks_sku_cnt/dev_cnt,4) as `3����SKUռ��`
		, round(ad4_clicks_sku_cnt/dev_cnt,4) as `4����SKUռ��`
		, round(ad5_clicks_sku_cnt/dev_cnt,4) as `5����SKUռ��`
		, round(ad6_clicks_sku_cnt/dev_cnt,4) as `6����SKUռ��`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7����SKUռ��`
		, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14����SKUռ��`
		, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30����SKUռ��`
		
		, round(ad3_sales_sku_cnt/dev_cnt,4) as `3��ת��SKUռ��`
		, round(ad4_sales_sku_cnt/dev_cnt,4) as `4��ת��SKUռ��`
		, round(ad5_sales_sku_cnt/dev_cnt,4) as `5��ת��SKUռ��`
		, round(ad6_sales_sku_cnt/dev_cnt,4) as `6��ת��SKUռ��`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7��ת��SKUռ��`
		, round(ad14_sales_sku_cnt/dev_cnt,4) as `14��ת��SKUռ��`
		, round(ad30_sales_sku_cnt/dev_cnt,4) as `30��ת��SKUռ��`
		
		, round(ad3_sku_Clicks/ad3_sku_Exposure,4) as `3������`
		, round(ad4_sku_Clicks/ad4_sku_Exposure,4) as `4������`
		, round(ad5_sku_Clicks/ad5_sku_Exposure,4) as `5������`
		, round(ad6_sku_Clicks/ad6_sku_Exposure,4) as `6������`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`
		, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`
		, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		
		, round(ad3_sku_TotalSale7DayUnit/ad3_sku_Clicks,4) as `3��ת����`
-- 		, round(ad4_sku_TotalSale7DayUnit/ad4_sku_Clicks,4) as `4��ת����`
-- 		, round(ad5_sku_TotalSale7DayUnit/ad5_sku_Clicks,4) as `5��ת����`
-- 		, round(ad6_sku_TotalSale7DayUnit/ad6_sku_Clicks,4) as `6��ת����`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`
		, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`
		, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		
		, ad3_sku_Exposure `3���ع���`
-- 		, ad4_sku_Exposure `4���ع���`
-- 		, ad5_sku_Exposure `5���ع���`
-- 		, ad6_sku_Exposure `6���ع���`
		, ad7_sku_Exposure `7���ع���`
		, ad14_sku_Exposure `14���ع���`
		, ad30_sku_Exposure `30���ع���`
		
		, ad3_sku_Clicks `3������`
-- 		, ad4_sku_Clicks `4������`
-- 		, ad5_sku_Clicks `5������`
-- 		, ad5_sku_Clicks `6������`
		, ad7_sku_Clicks `7������`
		, ad14_sku_Clicks `14������`
		, ad30_sku_Clicks `30������`
		
		, ad3_sku_TotalSale7DayUnit `3������`
-- 		, ad4_sku_TotalSale7DayUnit `4������`
-- 		, ad5_sku_TotalSale7DayUnit `5������`
-- 		, ad6_sku_TotalSale7DayUnit `6������`
		, ad7_sku_TotalSale7DayUnit `7������`
		, ad14_sku_TotalSale7DayUnit `14������`
		, ad30_sku_TotalSale7DayUnit `30������`
		
		from ( 
		select dev_day
			, count(distinct t_BoxSku) as dev_cnt
			, count(distinct SPU) as dev_spu_cnt
			-- ���ع�sku
			, count(distinct case when ad3_sku_Exposure > 100 then BoxSKU end) as ad3_sku_cnt
			, count(distinct case when ad4_sku_Exposure > 100 then BoxSKU end) as ad4_sku_cnt
			, count(distinct case when ad5_sku_Exposure > 100 then BoxSKU end) as ad5_sku_cnt
			, count(distinct case when ad6_sku_Exposure > 100 then BoxSKU end) as ad6_sku_cnt
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			
			-- �е��sku 
			, count(distinct case when ad3_sku_Clicks > 0 then BoxSKU end) as ad3_clicks_sku_cnt 
			, count(distinct case when ad4_sku_Clicks > 0 then BoxSKU end) as ad4_clicks_sku_cnt 
			, count(distinct case when ad5_sku_Clicks > 0 then BoxSKU end) as ad5_clicks_sku_cnt 
			, count(distinct case when ad6_sku_Clicks > 0 then BoxSKU end) as ad6_clicks_sku_cnt 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			
			-- �й������sku 
			, count(distinct case when ad3_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad3_sales_sku_cnt 
			, count(distinct case when ad4_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad4_sales_sku_cnt 
			, count(distinct case when ad5_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad5_sales_sku_cnt 
			, count(distinct case when ad6_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad6_sales_sku_cnt 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			
			, sum(ad3_sku_Exposure) as ad3_sku_Exposure
			, sum(ad4_sku_Exposure) as ad4_sku_Exposure
			, sum(ad5_sku_Exposure) as ad5_sku_Exposure
			, sum(ad6_sku_Exposure) as ad6_sku_Exposure
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure
			, sum(ad14_sku_Exposure) as ad14_sku_Exposure
			, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			
			, sum(ad3_sku_Clicks) as ad3_sku_Clicks
			, sum(ad4_sku_Clicks) as ad4_sku_Clicks
			, sum(ad5_sku_Clicks) as ad5_sku_Clicks
			, sum(ad6_sku_Clicks) as ad6_sku_Clicks
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks
			, sum(ad14_sku_Clicks) as ad14_sku_Clicks
			, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			
			, sum(ad3_sku_TotalSale7DayUnit) as ad3_sku_TotalSale7DayUnit
			, sum(ad4_sku_TotalSale7DayUnit) as ad4_sku_TotalSale7DayUnit
			, sum(ad5_sku_TotalSale7DayUnit) as ad5_sku_TotalSale7DayUnit
			, sum(ad6_sku_TotalSale7DayUnit) as ad6_sku_TotalSale7DayUnit
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit
			, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit
			, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
			
		from 
			( select t.dev_day , ad.BoxSku,t.BoxSku as t_BoxSku ,t.SPU 
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Exposure end)) as ad3_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Exposure end)) as ad4_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Exposure end)) as ad5_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Exposure end)) as ad6_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure

				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Clicks end)) as ad3_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Clicks end)) as ad4_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Clicks end)) as ad5_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Clicks end)) as ad6_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then TotalSale7DayUnit end)) as ad3_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then TotalSale7DayUnit end)) as ad4_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then TotalSale7DayUnit end)) as ad5_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then TotalSale7DayUnit end)) as ad6_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_day ,ad.BoxSku,t.BoxSku ,t.SPU
			) tmp1
		group by dev_day
		) tmp
	union all 
	select '����xվ��' `����ά��`
		, dev_day `������`
		, case dayofweek(dev_day) when 2 then '��һ' when 3 then '�ܶ�' when 4 then '����' when 5 then '����' 
			when 6 then '����' when 7 then '����' when 1 then '����' end `����`
		, site `���վ��` 
		, dev_cnt `sku��`
		, dev_spu_cnt `spu��`
		, round(ad3_sku_cnt/dev_cnt,4) as `3���ع�SKUռ��`
		, round(ad4_sku_cnt/dev_cnt,4) as `4���ع�SKUռ��`
		, round(ad5_sku_cnt/dev_cnt,4) as `5���ع�SKUռ��`
		, round(ad6_sku_cnt/dev_cnt,4) as `6���ع�SKUռ��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`
		, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`
		, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		
		, round(ad3_clicks_sku_cnt/dev_cnt,4) as `3����SKUռ��`
		, round(ad4_clicks_sku_cnt/dev_cnt,4) as `4����SKUռ��`
		, round(ad5_clicks_sku_cnt/dev_cnt,4) as `5����SKUռ��`
		, round(ad6_clicks_sku_cnt/dev_cnt,4) as `6����SKUռ��`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7����SKUռ��`
		, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14����SKUռ��`
		, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30����SKUռ��`
		
		, round(ad3_sales_sku_cnt/dev_cnt,4) as `3��ת��SKUռ��`
		, round(ad4_sales_sku_cnt/dev_cnt,4) as `4��ת��SKUռ��`
		, round(ad5_sales_sku_cnt/dev_cnt,4) as `5��ת��SKUռ��`
		, round(ad6_sales_sku_cnt/dev_cnt,4) as `6��ת��SKUռ��`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7��ת��SKUռ��`
		, round(ad14_sales_sku_cnt/dev_cnt,4) as `14��ת��SKUռ��`
		, round(ad30_sales_sku_cnt/dev_cnt,4) as `30��ת��SKUռ��`
		
		, round(ad3_sku_Clicks/ad3_sku_Exposure,4) as `3������`
		, round(ad4_sku_Clicks/ad4_sku_Exposure,4) as `4������`
		, round(ad5_sku_Clicks/ad5_sku_Exposure,4) as `5������`
		, round(ad6_sku_Clicks/ad6_sku_Exposure,4) as `6������`
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`
		, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`
		, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		
		, round(ad3_sku_TotalSale7DayUnit/ad3_sku_Clicks,4) as `3��ת����`
-- 		, round(ad4_sku_TotalSale7DayUnit/ad4_sku_Clicks,4) as `4��ת����`
-- 		, round(ad5_sku_TotalSale7DayUnit/ad5_sku_Clicks,4) as `5��ת����`
-- 		, round(ad6_sku_TotalSale7DayUnit/ad6_sku_Clicks,4) as `6��ת����`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`
		, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`
		, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		
		, ad3_sku_Exposure `3���ع���`
-- 		, ad4_sku_Exposure `4���ع���`
-- 		, ad5_sku_Exposure `5���ع���`
-- 		, ad6_sku_Exposure `6���ع���`
		, ad7_sku_Exposure `7���ع���`
		, ad14_sku_Exposure `14���ع���`
		, ad30_sku_Exposure `30���ع���`
		
		, ad3_sku_Clicks `3������`
-- 		, ad4_sku_Clicks `4������`
-- 		, ad5_sku_Clicks `5������`
-- 		, ad5_sku_Clicks `6������`
		, ad7_sku_Clicks `7������`
		, ad14_sku_Clicks `14������`
		, ad30_sku_Clicks `30������`
		
		, ad3_sku_TotalSale7DayUnit `3������`
-- 		, ad4_sku_TotalSale7DayUnit `4������`
-- 		, ad5_sku_TotalSale7DayUnit `5������`
-- 		, ad6_sku_TotalSale7DayUnit `6������`
		, ad7_sku_TotalSale7DayUnit `7������`
		, ad14_sku_TotalSale7DayUnit `14������`
		, ad30_sku_TotalSale7DayUnit `30������`
		
		from ( 
		select dev_day ,site
			, count(distinct t_BoxSku) as dev_cnt
			, count(distinct SPU) as dev_spu_cnt
			-- ���ع�sku
			, count(distinct case when ad3_sku_Exposure > 100 then BoxSKU end) as ad3_sku_cnt
			, count(distinct case when ad4_sku_Exposure > 100 then BoxSKU end) as ad4_sku_cnt
			, count(distinct case when ad5_sku_Exposure > 100 then BoxSKU end) as ad5_sku_cnt
			, count(distinct case when ad6_sku_Exposure > 100 then BoxSKU end) as ad6_sku_cnt
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			
			-- �е��sku 
			, count(distinct case when ad3_sku_Clicks > 0 then BoxSKU end) as ad3_clicks_sku_cnt 
			, count(distinct case when ad4_sku_Clicks > 0 then BoxSKU end) as ad4_clicks_sku_cnt 
			, count(distinct case when ad5_sku_Clicks > 0 then BoxSKU end) as ad5_clicks_sku_cnt 
			, count(distinct case when ad6_sku_Clicks > 0 then BoxSKU end) as ad6_clicks_sku_cnt 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			
			-- �й������sku 
			, count(distinct case when ad3_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad3_sales_sku_cnt 
			, count(distinct case when ad4_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad4_sales_sku_cnt 
			, count(distinct case when ad5_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad5_sales_sku_cnt 
			, count(distinct case when ad6_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad6_sales_sku_cnt 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			
			, sum(ad3_sku_Exposure) as ad3_sku_Exposure
			, sum(ad4_sku_Exposure) as ad4_sku_Exposure
			, sum(ad5_sku_Exposure) as ad5_sku_Exposure
			, sum(ad6_sku_Exposure) as ad6_sku_Exposure
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure
			, sum(ad14_sku_Exposure) as ad14_sku_Exposure
			, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			
			, sum(ad3_sku_Clicks) as ad3_sku_Clicks
			, sum(ad4_sku_Clicks) as ad4_sku_Clicks
			, sum(ad5_sku_Clicks) as ad5_sku_Clicks
			, sum(ad6_sku_Clicks) as ad6_sku_Clicks
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks
			, sum(ad14_sku_Clicks) as ad14_sku_Clicks
			, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			
			, sum(ad3_sku_TotalSale7DayUnit) as ad3_sku_TotalSale7DayUnit
			, sum(ad4_sku_TotalSale7DayUnit) as ad4_sku_TotalSale7DayUnit
			, sum(ad5_sku_TotalSale7DayUnit) as ad5_sku_TotalSale7DayUnit
			, sum(ad6_sku_TotalSale7DayUnit) as ad6_sku_TotalSale7DayUnit
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit
			, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit
			, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
			
		from 
			( select t.dev_day , ad.BoxSku,t.BoxSku as t_BoxSku , t.spu ,site 
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Exposure end)) as ad3_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Exposure end)) as ad4_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Exposure end)) as ad5_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Exposure end)) as ad6_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure

				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then Clicks end)) as ad3_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then Clicks end)) as ad4_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then Clicks end)) as ad5_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then Clicks end)) as ad6_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -3 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 3 then TotalSale7DayUnit end)) as ad3_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -4 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 4 then TotalSale7DayUnit end)) as ad4_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -5 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 5 then TotalSale7DayUnit end)) as ad5_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -6 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 6 then TotalSale7DayUnit end)) as ad6_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  
			where site in ('UK','US')
			group by t.dev_day ,ad.BoxSku,t.BoxSku ,ad.site ,t.spu 
			) tmp1
		group by dev_day ,site
		) tmp
) union_tmp
-- where `����` is not null and `�༭` is not null -- �����༭��Ա������Ӳ����ģ����������������༭����Ա
order by  `����ά��`, `���վ��`, `������` desc