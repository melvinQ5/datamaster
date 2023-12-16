-- �ܶ��������������İ�����Դ

with 
t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime ,ProductName ,DevelopUserName ,Artist ,Editor
	, case when ProductStatus = 0 then '����'
			when ProductStatus = 2 then 'ͣ��'
			when ProductStatus = 3 then 'ͣ��'
			when ProductStatus = 4 then '��ʱȱ��'
			when ProductStatus = 5 then '���'
		end as `��Ʒ״̬`
    , week_num_in_year dev_week
	, left(DevelopLastAuditTime,7) dev_month
from import_data.wt_products wp
join dim_date dd on date(wp.DevelopLastAuditTime) = dd.full_date
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-01-01' 
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  < '${NextStartDay}' 
	 and IsDeleted = 0 
	and ProjectTeam ='��ٻ�' 
)

,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site
	,  dev_week
	,  dev_month
	, NodePathName 
	, case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code
join t_prod on wl.sku = t_prod.sku -- ֻ����Ʒ
where 
	MinPublicationDate>= '2023-01-01'  
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
)

,t_ad as ( -- �����ϸ
select t_list.spu, t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
	,t_list.site
	,  dev_week
	,  dev_month
	, NodePathName 
	, SellUserName
	, Spend 
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU

where asa.CreatedTime >=  '2023-01-01'  
)

,t_orde as (  -- �¿������Ӷ�Ӧ����
select 
	t_list.SellerSKU ,t_list.ShopCode ,t_list.asin 
	,PlatOrderNumber ,TotalGross,TotalProfit
	,ExchangeUSD
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,t_list.site
	,dev_month
	, NodePathName 
	, SellUserName
from import_data.wt_orderdetails wo 
join t_list on t_list.ShopCode = wo.ShopCode and t_list.SellerSKU = wo.SellerSKU -- ֻ����ٻ� �¿�����Ʒ���ӵĶ�Ӧ����
where PayTime >=  '2023-01-01'   and wo.IsDeleted=0 and OrderStatus != '����' 
)
-- select * from t_orde 

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�ۼƹ������` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7��������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `����30��������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `�ۼƹ��ת����`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `����30����ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `�ۼ�ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `����7��ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `����14��ROAS`, round(ad30_TotalSale7Day/ad30_Spend,2) as `����30��ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `�ۼ�ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `����7��ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `����14��ACOS`, round(ad30_Spend/ad30_TotalSale7Day,2) as `����30��ACOS`
from 
	( select  asin , site ,sku ,spu 
		-- �ع���
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Exposure end)) as ad30_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Spend end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Spend end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Spend end),2) as ad30_Spend
		, round(sum(Spend),2) as ad_Spend
		-- ������۶�
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7Day end),2) as ad30_TotalSale7Day
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- �������	
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then TotalSale7DayUnit end),2) as ad30_sku_TotalSale7DayUnit
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Clicks end)) as ad30_sku_Clicks
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  
		group by asin , site ,sku ,spu 
	) tmp  
)
-- select * from t_ad_stat

,t_groupby_spu as (
select a.spu 
	, round(sum(ad14_sku_TotalSale7DayUnit)/sum(ad14_sku_Clicks),6) as `����14����ת����_spu`
	, round(sum(ad14_sku_Clicks)/sum(ad14_sku_Exposure),4) as `����14��������_spu`
	, sum(ad14_sku_Exposure) ����14���ع���_spu
from t_ad_stat a 
left join t_prod b on a.sku = b.sku 
group by a.spu 
)


-- -- �༭����
 select a.SPU ,DevelopUserName as ������Ա ,ProductName as ��Ʒ�� ,Artist as ���� ,Editor as �༭ , ��Ʒ״̬ ,asin ,site
 ,WEEKOFYEAR(DevelopLastAuditTime)+1 �����ܴ�
 ,ad7_sku_Exposure ����7���ع���
 ,ad14_sku_Exposure ����14���ع���
 ,ad7_sku_Clicks ����7������
 ,ad7_sku_Clicks ����14������
 ,����7��������
 ,����14��������
 ,����7����ת����
 ,����14����ת����
 ,ad7_sku_TotalSale7DayUnit ����7��������
 ,ad14_sku_TotalSale7DayUnit ����14��������
 from t_ad_stat a
 left join t_prod b on a.sku = b.sku
 left join t_groupby_spu c on a.spu =c.spu
 left join dim_date dd on date(DevelopLastAuditTime) = dd.date_key 
 where ����14����ת����_spu >= 0.05
 and ����14���ع���_spu >= 500
 and week_num_in_year = WEEKOFYEAR('${NextStartDay}')+1 -3 -- ͳ������ǰ�����ܣ�����14�� -- �ܴ�+1
