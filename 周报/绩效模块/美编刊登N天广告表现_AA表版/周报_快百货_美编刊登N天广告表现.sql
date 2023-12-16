/*
���ܡ��·���
��Ʒ��������ʱ��������7�죬14�죬30�죬60�죬90��
������������ʣ����ת���ʣ��ÿ�ת����
�༭���ع�SKUռ�ȣ����ת���ʣ��ÿ�ת����

7���ع�skuռ��=��������ʱ��7���ڵĹ��������ݣ����ع�������0��sku���� �£����ܿ�����sku����
*/



with
tmp_epp as ( -- 5�¿��ǹ��Ĳ�Ʒ
select  *
    , DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week
 	, date(date_add(DevelopLastAuditTime,interval -8 hour)) dev_day
from (select wl.BoxSku
   , wl.sku
   , wl.spu
   , Product_Editor
   , Product_Artist
   , min(MinPublicationDate) as DevelopLastAuditTime
from wt_listing wl
join mysql_store ms on wl.ShopCode = ms.code and ms.Department = '��ٻ�'
       left join (select sku, editor as Product_Editor, artist as Product_Artist
                  from import_data.wt_products) staff on wl.sku = staff.sku
left join wt_products wp on wp.sku = wl.sku and wp.ProjectTeam ='��ٻ�' and wp.IsDeleted = 0
where MinPublicationDate >= date_add(current_date(), interval -3 month) and MinPublicationDate < '9999-12-31'
    and wp.DevelopLastAuditTime  >= date_add(MinPublicationDate, interval -3 month)
and wl.IsDeleted = 0
group by wl.BoxSku, wl.sku, wl.spu, Product_Editor, Product_Artist ) t
)

-- tmp_epp as (
-- select BoxSku , SKU, SPU, DevelopLastAuditTime ,GROUP_CONCAT(Product_Artist) as Product_Artist,GROUP_CONCAT(Product_Editor) as Product_Editor,dev_month,dev_week
-- , GROUP_CONCAT(HandleUserName) as HandleUserName
-- from (
-- select
-- 	 epp.BoxSKU
--  	, epp.SKU
--  	, epp.SPU
--  	, epp.DevelopLastAuditTime
--  	, epps.HandleUserName
-- 	, case when epps.DevelopStage = '40' and epps.HandleUserName in ('������','Ϳ���','�ž�','����','��ѩ��','����','��׿','��ף��','������','�Ž�ɼ','��ٻ') then HandleUserName end Product_Artist
-- 	, case when epps.DevelopStage = '50' and epps.HandleUserName in ('�����','����','����','������','��ѩ��','�Խ�','�¿���','������') then HandleUserName end Product_Editor	
--  	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
--  	, if(year(developlastAuditTime)='2022',WEEKOFYEAR(DevelopLastAuditTime)+1,WEEKOFYEAR(DevelopLastAuditTime)) as dev_week 
-- from import_data.erp_product_products epp
-- join import_data.erp_product_product_statuses epps on epp.id=epps.ProductId 
-- where epp.DevelopLastAuditTime >= '2023-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
-- 	and epps.DevelopStage in ('40','50')
-- ) tmp 
-- group by BoxSku , SKU, SPU, DevelopLastAuditTime, dev_month,dev_week
-- )

, ad as ( 
select asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit, t.SPU, t.SKU, t.BoxSku ,ms.Site
	, DevelopLastAuditTime, Product_Artist, Product_Editor
	, timestampdiff(SECOND,t.DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- ���
from import_data.erp_amazon_amazon_listing eaal 
join tmp_epp t on  eaal.sku = t.SKU 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('��ٻ�')
join import_data.AdServing_Amazon asa on eaal.ShopCode = asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> ''
where  asa.CreatedTime >= date_add(current_date(), interval -3 month)
)

-- -- ���ά�����(��Ϊ����GMתPM���ݣ����Լ��������ʱ ord_days > 0 )
,t_res as (
select * from (
	select '����' `����ά��`, dev_week `�״ο�����`, '�ϼ�' `����`, '�ϼ�' `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7����SKUռ��`, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14����SKUռ��`, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30����SKUռ��`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7��ת��SKUռ��`, round(ad14_sales_sku_cnt/dev_cnt,4) as `14��ת��SKUռ��`, round(ad30_sales_sku_cnt/dev_cnt,4) as `30��ת��SKUռ��`
		
		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		, ad7_sku_Exposure `7���ع���`, ad14_sku_Exposure `14���ع���`, ad30_sku_Exposure `30���ع���`
		, ad7_sku_Clicks `7������`, ad14_sku_Clicks `14������`, ad30_sku_Clicks `30������`
		, ad7_sku_TotalSale7DayUnit `7������`, ad14_sku_TotalSale7DayUnit `14������`, ad30_sku_TotalSale7DayUnit `30������`
		from ( 
		select dev_week
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			-- �е��sku 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			-- �й������sku 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
		from 
			( select t.dev_week , ad.BoxSku,t.BoxSku as t_BoxSku
			-- �ع���
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				-- �����
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				-- ����	
				, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku,t.BoxSku
			) tmp1
		group by dev_week
		) tmp
union all 
	select '����\����' `����ά��`, dev_week `�״ο�����`, Product_Artist `����`, '�ϼ�' `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7����SKUռ��`, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14����SKUռ��`, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30����SKUռ��`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7��ת��SKUռ��`, round(ad14_sales_sku_cnt/dev_cnt,4) as `14��ת��SKUռ��`, round(ad30_sales_sku_cnt/dev_cnt,4) as `30��ת��SKUռ��`

		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		, ad7_sku_Exposure `7���ع���`, ad14_sku_Exposure `14���ع���`, ad30_sku_Exposure `30���ع���`
		, ad7_sku_Clicks `7������`, ad14_sku_Clicks `14������`, ad30_sku_Clicks `30������`
		, ad7_sku_TotalSale7DayUnit `7������`, ad14_sku_TotalSale7DayUnit `14������`, ad30_sku_TotalSale7DayUnit `30������`
		from ( 
		select dev_week, Product_Artist
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			-- �е��sku 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			-- �й������sku 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt

			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
		from 
			( select t.dev_week , ad.BoxSku, t.Product_Artist,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				-- �����
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				-- ����	
				, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU  group by t.dev_week ,ad.BoxSku, t.Product_Artist,t.BoxSku
			) tmp1
		group by dev_week,Product_Artist
		) tmp
		
		
union all 
	select '����\�༭' `����ά��`, dev_week `�״ο�����`,  '�ϼ�' `����`, Product_Editor `�༭`
		, dev_cnt `sku��`
		, round(ad7_sku_cnt/dev_cnt,4) as `7���ع�SKUռ��`, round(ad14_sku_cnt/dev_cnt,4) as `14���ع�SKUռ��`, round(ad30_sku_cnt/dev_cnt,4) as `30���ع�SKUռ��`
		, round(ad7_clicks_sku_cnt/dev_cnt,4) as `7����SKUռ��`, round(ad14_clicks_sku_cnt/dev_cnt,4) as `14����SKUռ��`, round(ad30_clicks_sku_cnt/dev_cnt,4) as `30����SKUռ��`
		, round(ad7_sales_sku_cnt/dev_cnt,4) as `7��ת��SKUռ��`, round(ad14_sales_sku_cnt/dev_cnt,4) as `14��ת��SKUռ��`, round(ad30_sales_sku_cnt/dev_cnt,4) as `30��ת��SKUռ��`

		, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
		, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,4) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,4) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,4) as `30��ת����`
		, ad7_sku_Exposure `7���ع���`, ad14_sku_Exposure `14���ع���`, ad30_sku_Exposure `30���ع���`
		, ad7_sku_Clicks `7������`, ad14_sku_Clicks `14������`, ad30_sku_Clicks `30������`
		, ad7_sku_TotalSale7DayUnit `7������`, ad14_sku_TotalSale7DayUnit `14������`, ad30_sku_TotalSale7DayUnit `30������`
		from ( 
		select dev_week, Product_Editor
			, count(distinct t_BoxSku) as dev_cnt
			-- ���ع�sku
			, count(distinct case when ad7_sku_Exposure > 100 then BoxSKU end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 100 then BoxSKU end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 100 then BoxSKU end) as ad30_sku_cnt
			-- �е��sku 
			, count(distinct case when ad7_sku_Clicks > 0 then BoxSKU end) as ad7_clicks_sku_cnt 
			, count(distinct case when ad14_sku_Clicks > 0 then BoxSKU end) as ad14_clicks_sku_cnt
			, count(distinct case when ad30_sku_Clicks > 0 then BoxSKU end) as ad30_clicks_sku_cnt
			-- �й������sku 
			, count(distinct case when ad7_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad7_sales_sku_cnt 
			, count(distinct case when ad14_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad14_sales_sku_cnt
			, count(distinct case when ad30_sku_TotalSale7DayUnit > 0 then BoxSKU end) as ad30_sales_sku_cnt
			, sum(ad7_sku_Exposure) as ad7_sku_Exposure, sum(ad14_sku_Exposure) as ad14_sku_Exposure, sum(ad30_sku_Exposure) as ad30_sku_Exposure
			, sum(ad7_sku_Clicks) as ad7_sku_Clicks, sum(ad14_sku_Clicks) as ad14_sku_Clicks, sum(ad30_sku_Clicks) as ad30_sku_Clicks
			, sum(ad7_sku_TotalSale7DayUnit) as ad7_sku_TotalSale7DayUnit, sum(ad14_sku_TotalSale7DayUnit) as ad14_sku_TotalSale7DayUnit, sum(ad30_sku_TotalSale7DayUnit) as ad30_sku_TotalSale7DayUnit
		from 
			( select t.dev_week , ad.BoxSku, t.Product_Editor,t.BoxSku as t_BoxSku
				-- �ع���
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
				-- �����
				, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
				, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
				-- ����	
				, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
				, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
			from tmp_epp t left join ad on ad.BoxSku =t.BoxSKU
			group by t.dev_week ,ad.BoxSku, t.Product_Editor,t.BoxSku
			) tmp1
		group by dev_week,Product_Editor
		) tmp
) union_tmp
where `����` is not null and `�༭` is not null -- �����༭��Ա������Ӳ����ģ����������������༭����Ա 'dev_cnt' 
order by  `����ά��`, `�״ο�����` desc , `����`, `�༭`
) 

select * from t_res 