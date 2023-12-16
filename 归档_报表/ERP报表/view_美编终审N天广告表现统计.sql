CREATE  VIEW `ads_Editor_Airtst_AdPerformance_stat` AS 
with 
tmp_epp as (
select BoxSku , SKU, SPU, DevelopLastAuditTime , Artist ,Editor 
	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
from import_data.wt_products wp 
where IsDeleted =0 and DevelopLastAuditTime >= '2022-10-03'
)  

, ad as ( 
select waad.GenerateDate, waad.ShopCode ,waad.Asin , waad.AdClicks , waad.AdExposure , waad.AdSaleUnits , t.SPU, t.SKU, t.BoxSku
	, DevelopLastAuditTime, t.Artist, t.Editor
	, datediff(waad.GenerateDate,t.DevelopLastAuditTime) as ad_days -- ���
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 7 then '��' else '��' end `�Ƿ�7��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 14 then '��' else '��' end `�Ƿ�14��`
	, case when 0 < datediff(waad.GenerateDate,t.DevelopLastAuditTime) and datediff(waad.GenerateDate,t.DevelopLastAuditTime) <= 30 then '��' else '��' end `�Ƿ�30��`
from import_data.wt_listing wl 
join tmp_epp t on  wl.sku = t.SKU 
join import_data.mysql_store ms on wl.ShopCode = ms.code and ms.Department in ('���۶���', '��������')
join import_data.wt_adserving_amazon_daily waad  on wl.ShopCode = waad.ShopCode and wl.SellerSKU = waad.SellerSKU and wl.SellerSKU <> ''
where wl.ListingStatus = 1  
and waad.GenerateDate >= '2022-10-03'
)


-- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
select * from (
	select '����' `����ά��`, dev_week `������`, '�ϼ�' `����`, '�ϼ�' `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad7_sku_AdClicks/ad7_sku_AdExposure,4) as `7������`, round(ad14_sku_AdClicks/ad14_sku_AdExposure,4) as `14������`, round(ad30_sku_AdClicks/ad30_sku_AdExposure,4) as `30������`
		, round(ad7_sku_AdSaleUnits/ad7_sku_AdClicks,4) as `7��ת����`, round(ad14_sku_AdSaleUnits/ad14_sku_AdClicks,4) as `14��ת����`, round(ad30_sku_AdSaleUnits/ad30_sku_AdClicks,4) as `30��ת����`
		, ad7_sku_AdExposure `7���ع���`, ad14_sku_AdExposure `14���ع���`, ad30_sku_AdExposure `30���ع���`
		, ad7_sku_AdClicks `7������`, ad14_sku_AdClicks `14������`, ad30_sku_AdClicks `30������`
		, ad7_sku_AdSaleUnits `7������`, ad14_sku_AdSaleUnits `14������`, ad30_sku_AdSaleUnits `30������`
		from ( 
		select dev_week
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_AdExposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_AdExposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_AdExposure > 100 then BoxSKU end) as ad30_sku_cnt
			, sum(ad7_sku_AdExposure) as ad7_sku_AdExposure, sum(ad14_sku_AdExposure) as ad14_sku_AdExposure, sum(ad30_sku_AdExposure) as ad30_sku_AdExposure
			, sum(ad7_sku_AdClicks) as ad7_sku_AdClicks, sum(ad14_sku_AdClicks) as ad14_sku_AdClicks, sum(ad30_sku_AdClicks) as ad30_sku_AdClicks
			, sum(ad7_sku_AdSaleUnits) as ad7_sku_AdSaleUnits, sum(ad14_sku_AdSaleUnits) as ad14_sku_AdSaleUnits, sum(ad30_sku_AdSaleUnits) as ad30_sku_AdSaleUnits
		from 
			( select t.dev_week , ad.BoxSku,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_AdExposure
				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_AdClicks
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_AdSaleUnits
			from tmp_epp t join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku,t.BoxSku
			) tmp1
		group by dev_week
		) tmp
union all 
	select '����\����' `����ά��`, dev_week `������`, Artist `����`, '�ϼ�' `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad7_sku_AdClicks/ad7_sku_AdExposure,4) as `7������`, round(ad14_sku_AdClicks/ad14_sku_AdExposure,4) as `14������`, round(ad30_sku_AdClicks/ad30_sku_AdExposure,4) as `30������`
		, round(ad7_sku_AdSaleUnits/ad7_sku_AdClicks,4) as `7��ת����`, round(ad14_sku_AdSaleUnits/ad14_sku_AdClicks,4) as `14��ת����`, round(ad30_sku_AdSaleUnits/ad30_sku_AdClicks,4) as `30��ת����`
		, ad7_sku_AdExposure `7���ع���`, ad14_sku_AdExposure `14���ع���`, ad30_sku_AdExposure `30���ع���`
		, ad7_sku_AdClicks `7������`, ad14_sku_AdClicks `14������`, ad30_sku_AdClicks `30������`
		, ad7_sku_AdSaleUnits `7������`, ad14_sku_AdSaleUnits `14������`, ad30_sku_AdSaleUnits `30������`
		from ( 
		select dev_week, Artist
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_AdExposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_AdExposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_AdExposure > 100 then BoxSKU end) as ad30_sku_cnt
			, sum(ad7_sku_AdExposure) as ad7_sku_AdExposure, sum(ad14_sku_AdExposure) as ad14_sku_AdExposure, sum(ad30_sku_AdExposure) as ad30_sku_AdExposure
			, sum(ad7_sku_AdClicks) as ad7_sku_AdClicks, sum(ad14_sku_AdClicks) as ad14_sku_AdClicks, sum(ad30_sku_AdClicks) as ad30_sku_AdClicks
			, sum(ad7_sku_AdSaleUnits) as ad7_sku_AdSaleUnits, sum(ad14_sku_AdSaleUnits) as ad14_sku_AdSaleUnits, sum(ad30_sku_AdSaleUnits) as ad30_sku_AdSaleUnits
			from
			( select t.dev_week , ad.BoxSku, t.Artist,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_AdExposure
				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_AdClicks
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_AdSaleUnits
			from tmp_epp t join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku, t.Artist,t.BoxSku
			) tmp1
		group by dev_week,Artist
		) tmp
union all 
	select '����\�༭' `����ά��`, dev_week `������`,  '�ϼ�' `����`, Editor `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad7_sku_AdClicks/ad7_sku_AdExposure,4) as `7������`, round(ad14_sku_AdClicks/ad14_sku_AdExposure,4) as `14������`, round(ad30_sku_AdClicks/ad30_sku_AdExposure,4) as `30������`
		, round(ad7_sku_AdSaleUnits/ad7_sku_AdClicks,4) as `7��ת����`, round(ad14_sku_AdSaleUnits/ad14_sku_AdClicks,4) as `14��ת����`, round(ad30_sku_AdSaleUnits/ad30_sku_AdClicks,4) as `30��ת����`
		, ad7_sku_AdExposure `7���ع���`, ad14_sku_AdExposure `14���ع���`, ad30_sku_AdExposure `30���ع���`
		, ad7_sku_AdClicks `7������`, ad14_sku_AdClicks `14������`, ad30_sku_AdClicks `30������`
		, ad7_sku_AdSaleUnits `7������`, ad14_sku_AdSaleUnits `14������`, ad30_sku_AdSaleUnits `30������`
		from ( 
		select dev_week, Editor
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_AdExposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_AdExposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_AdExposure > 100 then BoxSKU end) as ad30_sku_cnt
			, sum(ad7_sku_AdExposure) as ad7_sku_AdExposure, sum(ad14_sku_AdExposure) as ad14_sku_AdExposure, sum(ad30_sku_AdExposure) as ad30_sku_AdExposure
			, sum(ad7_sku_AdClicks) as ad7_sku_AdClicks, sum(ad14_sku_AdClicks) as ad14_sku_AdClicks, sum(ad30_sku_AdClicks) as ad30_sku_AdClicks
			, sum(ad7_sku_AdSaleUnits) as ad7_sku_AdSaleUnits, sum(ad14_sku_AdSaleUnits) as ad14_sku_AdSaleUnits, sum(ad30_sku_AdSaleUnits) as ad30_sku_AdSaleUnits
			from
			( select t.dev_week , ad.BoxSku, t.Editor,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_AdExposure
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_AdExposure
				-- �����
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_AdClicks
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_AdClicks
				-- ����	
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -7 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_AdSaleUnits
				, round(sum(case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),t.DevelopLastAuditTime)>0 and 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_AdSaleUnits
			from tmp_epp t join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku, t.Editor,t.BoxSku
			) tmp1
		group by dev_week,Editor
		) tmp
) union_tmp
where `����` is not null and `�༭` is not null 
order by  `����ά��`, `������`, `����`, `�༭`
