/* 
��Ʒ����ģ��\ͳ�Ʒ�����\��Ӫ�Ŷ�_��Ʒ����ͳ�ƿ��
��λ����������֮������۱��֣��Դ˶��� �����Ŷ�_��Ʒ����ͳ�ƿ��
ά�ȣ���Ӫ�Ŷ� x ���ǲ�Ʒ�����ܴ� x ����վ��
	��Ӫ�Ŷ�ά��ö�٣�1����ٻ� 2����ٻ�һ���� 3������С�� 4��������Ա
ָ�꣺
	����
		�¿���������
		�¿���SKU��
		�¿���SPU��
	����
		����������
		����SKU��
		����SPU��
	����
		�¿�����ƷSKU�����ʣ�
		�¿�����ƷSPU�����ʣ�
		�¿�����ƷLST�����ʣ�
	���Ͷ��
		�����ع�
			����7���ع�LSTռ�ȣ����ѿ���SKU������ʼͳ�ƺ������֣���ͬ��
			����14���ع�LSTռ��
			����30���ع�LSTռ��
		���ع����ӵĹ�����
			����7/15/30�� ���ѡ��ع⡢��������������۶�
			����7/15/30�� ����ʡ�ת���ʡ�CPC��ROAS��ACOS	���������ع�	
				
��Ҫ����Դ�����ӱ������ϸ��
*/

with 
t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
    , dd.week_begin_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour)) = dd.full_date
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}' 
	and DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  < '${NextStartDay}' 
	and IsMatrix = 0 and IsDeleted = 0 
	and ProjectTeam ='��ٻ�' and Status = 10
)

,t_list as ( -- ��Ʒ����
select  SellerSKU ,ShopCode ,asin 
	, site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, NodePathName 
	,case when ms.SellUserName is null then '��������ѡ����Ա' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,DevelopLastAuditTime
-- 	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku -- ֻ����Ʒ
where 
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
)

,t_ad as ( -- �����ϸ
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days_since_dev -- ���
	,t_list.site
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, NodePathName 
	, SellUserName
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '${StartDay}' and asa.CreatedTime  <'${NextStartDay}' 
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
	, dev_week
	, left(DevelopLastAuditTime,7) dev_month
	, NodePathName 
	, SellUserName
from import_data.wt_orderdetails wo 
join t_list on t_list.ShopCode = wo.ShopCode and t_list.SellerSKU = wo.SellerSKU -- ֻ����ٻ� �¿�����Ʒ���ӵĶ�Ӧ����
where PayTime >= '${StartDay}' and PayTime < '${NextStartDay}' and wo.IsDeleted=0 and OrderStatus != '����' 
)
-- select * from t_orde 

,t_list_stat as ( -- ������
select concat(ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(site,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	,NodePathName,SellUserName,site,dev_month,dev_week
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode) ) list_cnt
	,count(distinct SKU ) list_sku_cnt
	,count(distinct SPU ) list_spu_cnt
from t_list 
group by grouping sets (
	(NodePathName,dev_month) -- С��x��
	,(NodePathName,dev_week) -- С��x��
	,(NodePathName,site,dev_month) -- С��xվ��x��
	,(NodePathName,site,dev_week) -- С��xվ��x��
	,(NodePathName,SellUserName,dev_month) -- ��Աx��
	,(NodePathName,SellUserName,dev_week) -- ��Աx��
	,(NodePathName,SellUserName,site,dev_month) -- ��Աxվ��x��
	,(NodePathName,SellUserName,site,dev_week) -- ��Աxվ��x��
	)
)
-- select * from t_list_stat


,t_orde_stat as ( -- ������
select concat(ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(site,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
	,NodePathName,SellUserName,site,dev_month,dev_week
	,count(distinct concat(SellerSKU,ShopCode) ) od_list_cnt
	,count(distinct SKU ) od_list_sku_cnt
	,count(distinct SPU ) od_list_spu_cnt
	,count( distinct PlatOrderNumber) orders_total
	,round(sum(TotalGross/ExchangeUSD),2) TotalGross
-- 	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
-- 	,round(sum(TotalProfit)/sum(TotalGross) ,4) Profit_rate
from t_orde 
group by grouping sets (
	(NodePathName,dev_month) -- С��x��
	,(NodePathName,dev_week) -- С��x��
	,(NodePathName,site,dev_month) -- С��xվ��x��
	,(NodePathName,site,dev_week) -- С��xվ��x��
	,(NodePathName,SellUserName,dev_month) -- ��Աx��
	,(NodePathName,SellUserName,dev_week) -- ��Աx��
	,(NodePathName,SellUserName,site,dev_month) -- ��Աxվ��x��
	,(NodePathName,SellUserName,site,dev_week) -- ��Աxվ��x��
	)
)
-- select * from t_orde_stat 

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�ۼƹ������` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7��������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `����30��������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `�ۼƹ��ת����`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `����30����ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `�ۼ�ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `����7��ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `����14��ROAS`, round(ad30_TotalSale7Day/ad30_Spend,2) as `����30��ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `�ۼ�ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `����7��ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `����14��ACOS`, round(ad30_Spend/ad30_TotalSale7Day,2) as `����30��ACOS`
from 
	( select concat(ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(site,''),ifnull(dev_month,''),ifnull(dev_week,'')) tbcode 
		,NodePathName,SellUserName,site,dev_month,dev_week
		-- �ع���
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then Exposure end)) as ad30_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 7 then cost*ExchangeUSD end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 14 then cost*ExchangeUSD end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_since_dev and ad_days_since_dev <= 30 then cost*ExchangeUSD end),2) as ad30_Spend
		, round(sum(cost*ExchangeUSD),2) as ad_Spend
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
		group by grouping sets (
			(NodePathName,dev_month) -- С��x��
			,(NodePathName,dev_week) -- С��x��
			,(NodePathName,site,dev_month) -- С��xվ��x��
			,(NodePathName,site,dev_week) -- С��xվ��x��
			,(NodePathName,SellUserName,dev_month) -- ��Աx��
			,(NodePathName,SellUserName,dev_week) -- ��Աx��
			,(NodePathName,SellUserName,site,dev_month) -- ��Աxվ��x��
			,(NodePathName,SellUserName,site,dev_week) -- ��Աxվ��x��
			)
	) tmp  
)
-- select * from t_ad_stat

,t_merage as (
select
	case 
		when concat(t_list_stat.NodePathName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.site,t_list_stat.SellUserName,t_list_stat.dev_week) is null then  '��Ӫ�Ŷ�x������' 
		when concat(t_list_stat.NodePathName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.site,t_list_stat.SellUserName,t_list_stat.dev_month) is null then  '��Ӫ�Ŷ�x������' 
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.SellUserName,t_list_stat.dev_week) is null then  '��Ӫ�Ŷ�xվ��x������' 
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.SellUserName,t_list_stat.dev_month) is null then  '��Ӫ�Ŷ�xվ��x������' 
		when concat(t_list_stat.SellUserName,t_list_stat.NodePathName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.site,t_list_stat.dev_week) is null then  '��Ӫ��Աx������'
		when concat(t_list_stat.SellUserName,t_list_stat.NodePathName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.site,t_list_stat.dev_month) is null then  '��Ӫ��Աx������' 
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.SellUserName,t_list_stat.dev_month) is not null and coalesce(t_list_stat.dev_week) is null then  '��Ӫ��Աxվ��x������'
		when concat(t_list_stat.site,t_list_stat.NodePathName,t_list_stat.SellUserName,t_list_stat.dev_week) is not null and coalesce(t_list_stat.dev_month) is null then  '��Ӫ��Աxվ��x������' 
	end as `Ԥ�÷���ά��`
	
	,t_list_stat.NodePathName `��Ӫ�Ŷ�`
	,t_list_stat.SellUserName `��Ӫ��Ա`
	,t_list_stat.site `վ��`
	,t_list_stat.dev_month `�����·�`
	,t_list_stat.dev_week `�����ܴ�`
	
	
	,round(od_list_cnt/list_cnt,2) `�¿������Ӷ�����`
	,round(od_list_sku_cnt/list_sku_cnt,2) `�¿���SKU������`
	,round(od_list_spu_cnt/list_spu_cnt,2) `�¿���SPU������`
	
	,orders_total `�ۼƶ�����`
	,TotalGross `�ۼ����۶�`
-- 	,TotalProfit `�ۼ������`
-- 	,Profit_rate `ë����`
	
	,list_cnt `����������`
	,list_sku_cnt `����SKU��`
	,list_spu_cnt `����SPU��`
	
	,od_list_cnt `����������`
	,od_list_sku_cnt `����SKU��`
	,od_list_spu_cnt `����SPU��`
	
	,ad_sku_Exposure `�ۼ��ع�`
	,ad7_sku_Exposure `����7���ع�`
	,ad14_sku_Exposure `����14���ع�`
	,ad30_sku_Exposure `����30���ع�`
	
	,ad_sku_Clicks `�ۼƵ��` 
	,ad7_sku_Clicks `����7����` 
	,ad14_sku_Clicks `����14����`
	,ad30_sku_Clicks `����30����`
	
	,`�ۼƹ������`
	,`����7��������`
	,`����14��������`
	,`����30��������`
	
	,ad_sku_TotalSale7DayUnit `�ۼƹ������`
	,ad7_sku_TotalSale7DayUnit `����7��������`
	,ad14_sku_TotalSale7DayUnit `����14��������`
	,ad30_sku_TotalSale7DayUnit `����30��������`
	
	,`�ۼƹ��ת����`
	,`����7����ת����`
	,`����14����ת����`
	,`����30����ת����`
	
	,ad_Spend `�ۼƹ�滨��`
	,ad7_Spend `����7���滨��`
	,ad14_Spend `����14���滨��`
	,ad30_Spend `����14���滨��`
	
	,ad_TotalSale7Day `�ۼƹ�����۶�`
	,ad7_TotalSale7Day `����7�������۶�`
	,ad14_TotalSale7Day `����14�������۶�`
	,ad30_TotalSale7Day `����14�������۶�`
	
	,`�ۼ�ROAS`
	,`����7��ROAS`
	,`����14��ROAS`
	,`����30��ROAS`
	
	,`�ۼ�ACOS`
	,`����7��ACOS`
	,`����14��ACOS`
	,`����30��ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `�ۼ�CPC`
	,round(ad7_Spend/ad7_sku_Clicks,2) `����7��CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `����14��CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `����30��CPC`
	
	,replace(concat(right(date('${StartDay}'),5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right(date('${StartDay}'),5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right(date('${StartDay}'),5),'��',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `���ʱ�䷶Χ`


from t_list_stat
left join t_ad_stat on t_list_stat.tbcode =t_ad_stat.tbcode 
left join t_orde_stat on t_list_stat.tbcode =t_orde_stat.tbcode 
)

select t_merage.* ,dd.week_num_in_year as ��������� ,dd.week_begin_date as ���յ�����һ
from t_merage
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date)  dd on year('${StartDay}') = dd.year and t_merage.`�����ܴ�` = dd.week_num_in_year
order by `Ԥ�÷���ά��` desc ,`��Ӫ�Ŷ�`,`��Ӫ��Ա`,`վ��`,`�����·�`,`�����ܴ�`

