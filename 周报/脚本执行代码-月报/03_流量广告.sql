with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select '��˾' as dep
union
select department as dep from import_data.mysql_store
union
select split_part(NodePathNameFull,'>',2) from import_data.mysql_store
union
select NodePathName from import_data.mysql_store
)

,t_new_list as ( -- �¿�������ά��
select SKU ,MinPublicationDate ,ShopCode ,SellerSKU ,ASIN 
from import_data.wt_listing wl 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' and length(SKU) > 0 and wl.IsDeleted = 0 
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
)

, t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
		,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code 
)

-- select to_date(CreatedTime) ,count(1)
-- from AdServing_Amazon where CreatedTime > '2023-03-01'
-- group by to_date(CreatedTime) 
-- 
-- select to_date(DorisImportTime) ,count(1)
-- from AdServing_Amazon where CreatedTime > '2023-03-01'
-- group by to_date(DorisImportTime) 

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `�ÿ���` ,OrderedCount `�ÿ�����` 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.ListingManage lm
inner join import_data.mysql_store ms
-- --	on lm.ShopCode=ms.Code and ReportType='�ܱ�' and Monday='${StartDay}'
 	on lm.ShopCode=ms.Code and ReportType='�±�' and Monday='${StartDay}'
)

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
, t_adse_stat as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by grouping sets ((),(department))
union 
select dep2 ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by dep2 
union
select NodePathName ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by NodePathName 
)

,t_adse_new_lst as ( -- �¿������ӹ��
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse join t_new_list 
	on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(department))
union 
select dep2
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse join t_new_list 
	on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by dep2
union 
select NodePathName
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse join t_new_list 
	on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by NodePathName
)

,t_vist_stat as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` from t_vist group by grouping sets ((),(department))
union
select dep2 ,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` from t_vist group by dep2
union
select NodePathName,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) as `�ÿ�����` from t_vist group by NodePathName
)

-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep 
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_adse_new_lst.new_lst_exp ,t_adse_new_lst.new_lst_clk ,t_adse_new_lst.new_lst_ad_untis
	,t_vist_stat.`�ÿ���` ,t_vist_stat.`�ÿ�����`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_adse_new_lst on t_key.dep = t_adse_new_lst.dep
left join t_vist_stat on t_key.dep = t_vist_stat.dep
)

-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	'${NextStartDay}' `ͳ������`
	,dep `�Ŷ�` 
	,AdExposure `�ع���`
	,AdClicks `�����`
	,AdSaleUnits `�������`
	,round(AdClicks/AdExposure,4) `�������`
	,round(AdSaleUnits/AdClicks,4) `���ת����`
	,round(new_lst_clk/new_lst_exp,4) `�¿��ǹ������`
	,round(new_lst_ad_untis/new_lst_clk,4) `�¿��ǹ��ת����`
	,round(`�ÿ���`) `�ÿ���`
	,round(`�ÿ�����`/`�ÿ���`,4) `�ÿ�ת����`
	,round((`�ÿ���`-AdClicks)/`�ÿ���`,4) `��Ȼ����ռ��`
from t_merge
order by `�Ŷ�` desc 