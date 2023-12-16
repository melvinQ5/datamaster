
with 
t_mysql_store as (  -- ��֯�ܹ���ʱ�ı�ǰ
select 
	Code ,Site 
	,case when NodePathName regexp 'Ȫ��' then '��ٻ�Ȫ��' 
		when NodePathName regexp '�ɶ�' then '��ٻ��ɶ�'  else department 
		end as department
	,NodePathName
	,department as department_old
	,SellUserName 
from import_data.mysql_store
)

,t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}' 
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  < '${NextStartDay}' 
	and IsMatrix = 0 and IsDeleted = 0 
	and ProjectTeam ='��ٻ�' and Status = 10
)

,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site
	,department 
	, NodePathName 
	, date(MinPublicationDate) pub_day
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
from import_data.wt_listing wl 
join t_mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku -- ֻ����Ʒ
where 
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
)

,t_ad as ( -- �����ϸ
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,	asa.SellerSKU 
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days
	, t_list.site
	, department 
	, NodePathName 
	, SellUserName
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
)

-- �������� ���ű�����������	
select ad.*
from t_list t left join t_ad ad on t.shopcode = ad.shopcode and t.sellersku = ad.sellersku 


,t_ad_stat as (
select t.pub_day 
-- ,t.department ,t.NodePathName, t.SellUserName ,t.site ,t.shopcode ,t.sellersku 
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
from t_list t left join t_ad ad on t.shopcode = ad.shopcode and t.sellersku = ad.sellersku 
group by t.pub_day 
-- ,t.department ,t.NodePathName, t.SellUserName ,t.site ,t.shopcode ,t.sellersku 
) 

select * from t_ad_stat


	select '����' `����ά��`, pub_day `������` , department �Ŷ�
		, case dayofweek(pub_day) when 2 then '��һ' when 3 then '�ܶ�' when 4 then '����' when 5 then '����' 
			when 6 then '����' when 7 then '����' when 1 then '����' end `����`
		, '' `���վ��` 
		, list_cnt `������`
		, round(ad3_sku_cnt/list_cnt,4) as `3���ع�����ռ��`
		, round(ad4_sku_cnt/list_cnt,4) as `4���ع�����ռ��`
		, round(ad5_sku_cnt/list_cnt,4) as `5���ع�����ռ��`
		, round(ad6_sku_cnt/list_cnt,4) as `6���ع�����ռ��`
		, round(ad7_sku_cnt/list_cnt,4) as `7���ع�����ռ��`
		, round(ad14_sku_cnt/list_cnt,4) as `14���ع�����ռ��`
		, round(ad30_sku_cnt/list_cnt,4) as `30���ع�����ռ��`
		
		, round(ad3_sku_Exposure/list_cnt,4) as `3������ƽ���ع�`
		, round(ad4_sku_Exposure/list_cnt,4) as `4������ƽ���ع�`
		, round(ad5_sku_Exposure/list_cnt,4) as `5������ƽ���ع�`
		, round(ad6_sku_Exposure/list_cnt,4) as `6������ƽ���ع�`
		, round(ad7_sku_Exposure/list_cnt,4) as `7������ƽ���ع�`
		, round(ad14_sku_Exposure/list_cnt,4) as `14������ƽ���ع�`
		, round(ad30_sku_Exposure/list_cnt,4) as `30������ƽ���ع�`
		
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
		select pub_day ,department 
			,count(distinct concat(shopcode,sellersku) ) list_cnt
			-- ���ع�sku
			, count(distinct case when ad3_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad3_sku_cnt
			, count(distinct case when ad4_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad4_sku_cnt
			, count(distinct case when ad5_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad5_sku_cnt
			, count(distinct case when ad6_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad6_sku_cnt
			, count(distinct case when ad7_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad7_sku_cnt
			, count(distinct case when ad14_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad14_sku_cnt
			, count(distinct case when ad30_sku_Exposure > 0 then concat(shopcode,sellersku) end) as ad30_sku_cnt
			
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
		from t_ad_stat 
		group by pub_day ,department
		) tmp