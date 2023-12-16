with 
-- step1 ����Դ���� 
t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
		,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
		,right(ms.Code,2) country ,ms.Market
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
-- 	on ad.CreatedTime >= '${StartDay}' and ad.CreatedTime < '${NextStartDay}'
		and ad.ShopCode = ms.Code 
where ms.Department = '��ٻ�'
) -- �������ݻ���Ϊ�Ӻ�һ����룬����3��8��ֻ�ܲ�ѯ��3��6�յ�����


,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `�ÿ���` ,OrderedCount `�ÿ�����` 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
	,right(ms.Code,2) country ,ms.Market
from import_data.ListingManage lm
inner join import_data.mysql_store ms
	on lm.ShopCode=ms.Code and ReportType='�ܱ�' and Monday='${StartDay}'
-- 	on lm.ShopCode=ms.Code and ReportType='�±�' and Monday='${StartDay}'
where ms.Department = '��ٻ�'
)

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
, t_adse_stat as (
select market , country 
	,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by market , country
)

,t_vist_stat as (
select market , country 
	,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` from t_vist 
group by market , country
)

-- step3 ����ָ�����ݼ�
, t_merge as (
select t_vist_stat.market , t_vist_stat.country 
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_vist_stat.`�ÿ���` ,t_vist_stat.`�ÿ�����`
from t_vist_stat 
left join t_adse_stat on t_adse_stat.country = t_vist_stat.country
)

-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	market , country 
	,AdExposure `�ع���`
	,AdClicks `�����`
	,AdSaleUnits `�������`
	,round(AdClicks/AdExposure,4) `�������`
	,round(AdSaleUnits/AdClicks,4) `���ת����`
	,round(`�ÿ���`) `�ÿ���`
	,round(`�ÿ�����`/`�ÿ���`,4) `�ÿ�ת����`
	,round((`�ÿ���`-AdClicks)/`�ÿ���`,4) `��Ȼ����ռ��`
from t_merge
order by  market , country  desc 