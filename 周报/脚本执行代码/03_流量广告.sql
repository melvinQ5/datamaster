
with 
-- step1 ����Դ���� 
t_key as ( -- ���������ά��
select '��˾' as dep
union select '��ٻ�' 
union select '�̳���' 
union 
select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department end as dep from import_data.mysql_store where department regexp '��' 
union 
select NodePathName from import_data.mysql_store where department regexp '��' 
)


,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else '��ٻ�����' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '��'
)

,t_new_list as ( -- �¿�������ά��
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.department ,ms.NodePathName
from import_data.wt_listing  eaal 
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4 and IsDeleted = 0 
)

, t_adse as (
select ad.ShopCode ,ad.SellerSKU ,ad.Asin ,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
		,ad.CreatedTime
		,ms.*
from t_mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code 
) -- �������ݻ���Ϊ�Ӻ�һ����룬����3��8��ֻ�ܲ�ѯ��3��6�յ�����

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `�ÿ���` ,OrderedCount `�ÿ�����` ,ChildAsin ,ShopCode 
	,ms.*
from import_data.ListingManage lm
join t_mysql_store ms
	on lm.ShopCode=ms.Code and ReportType='�ܱ�' and Monday='${StartDay}'
-- 	on lm.ShopCode=ms.Code and ReportType='�±�' and Monday='${StartDay}'
)

-- ��ʱ����
-- select NodePathName , shopcode  ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
-- from t_adse 
-- where department regexp '��' 
-- group by NodePathName , shopcode 

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
, t_adse_stat as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
group by grouping sets ((),(department))
union 
select '��ٻ�' as department ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse where department regexp '��' 
union
select NodePathName ,sum(AdClicks) as AdClicks ,sum(AdExposure) as AdExposure ,sum(AdSaleUnits) as AdSaleUnits
from t_adse where department regexp '��' 
group by NodePathName 
)
-- select * from t_adse_stat

,t_adse_new_lst as ( -- �¿������ӹ��
select case when t_adse.department IS NULL THEN '��˾' ELSE t_adse.department END AS dep 
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(t_adse.department))
union 
select '��ٻ�' as department 
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '��'  
union 
select t_adse.NodePathName
	,sum(AdExposure) as new_lst_exp ,sum(AdClicks) as new_lst_clk ,sum(AdSaleUnits) as new_lst_ad_untis
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '��' 
group by t_adse.NodePathName
)



,t_online_list as (
select case when department IS NULL THEN '��ٻ�' ELSE department END AS dep 
	,count(1) `����������`
from (select shopcode,SellerSku,department
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����'
	where department regexp '��' 
	group by shopcode,SellerSku,department
	) tmp1
group by grouping sets ((),(department))
union all 
select NodePathName ,count(1) `����������`
from ( select ShopCode ,SellerSKU ,ms.NodePathName 
	from erp_amazon_amazon_listing eaal 
	join t_mysql_store ms 
	on eaal.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����'
	where department regexp '��' 
	group by NodePathName,shopcode,SellerSku
	) tmp1
group by NodePathName
)

, t_ad_cover_list as (
select case when department IS NULL THEN '��ٻ�' ELSE department END AS dep 
	, count(1) `Ͷ�Ź������������`
from ( 
	select  ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	from erp_amazon_amazon_listing  ta
	join t_mysql_store ms on ta.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����' and ms.department regexp '��'  
	join ( select ListingId 
		from import_data.erp_amazon_amazon_ad_products 
		where AdState = 'enabled' group by ListingId
		) tb on ta.id =tb.ListingId -- 1�Զ�left join,��ȥ�� 
	group by ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	) tb 
group by grouping sets ((),(department))

union all 
select NodePathName 
	, count(1) `Ͷ�Ź������������`
from ( 
	select ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	from erp_amazon_amazon_listing  ta
	join t_mysql_store ms on ta.ShopCode = ms.Code  and ListingStatus = 1 and ms.ShopStatus = '����' and ms.department regexp '��'  
	join ( select ListingId 
		from import_data.erp_amazon_amazon_ad_products 
		where AdState = 'enabled' group by ListingId
		) tb on ta.id =tb.ListingId -- 1�Զ�left join,��ȥ�� 
	group by ta.sellersku , ta.shopcode  ,ms.department ,ms.NodePathName 
	) tb 
group by NodePathName
)

-- select * from t_ad_cover_list


,t_vist_stat as (
select case when department IS NULL THEN '��˾' ELSE department END AS dep 
	,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` 
from t_vist group by grouping sets ((),(department))
union
select '��ٻ�' as department  ,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` 
from t_vist where department regexp '��'
union
select NodePathName,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) as `�ÿ�����` 
from t_vist where department regexp '��'
group by NodePathName
)

,t_vist_new_lst_stat as (
select case when t_vist.department IS NULL THEN '��˾' ELSE t_vist.department END AS dep 
	,sum(`�ÿ���`) as `�¿��Ƿÿ���`,sum(`�ÿ�����`) `�¿��Ƿÿ�����` 
from t_vist 
join t_new_list on t_vist.ShopCode =t_new_list.ShopCode and t_vist.ChildAsin =t_new_list.Asin 
group by grouping sets ((),(t_vist.department))
union
select '��ٻ�' as department ,sum(`�ÿ���`) as `�¿��Ƿÿ���`,sum(`�ÿ�����`) `�¿��Ƿÿ�����` 
from t_vist 
join t_new_list on t_vist.ShopCode =t_new_list.ShopCode and t_vist.ChildAsin =t_new_list.Asin 
where t_vist.department regexp '��'
union
select t_vist.NodePathName ,sum(`�ÿ���`) as `�¿��Ƿÿ���`,sum(`�ÿ�����`) `�¿��Ƿÿ�����` 
from t_vist join t_new_list on t_vist.ShopCode =t_new_list.ShopCode and t_vist.ChildAsin =t_new_list.Asin
where t_vist.department regexp '��'
group by t_vist.NodePathName
)

, t_list_cnt as (
select case when department is null then '��˾' else department end as dep
	,count(1) `�¿���������`
from (select department,shopcode,SellerSku,Asin from t_new_list 
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' 
	group by department,shopcode,SellerSku,Asin 
	) tmp1 
group by grouping sets ((),(department))
union 
select '��ٻ�' as department ,count(1) `�¿���������`
from (select shopcode,SellerSku,Asin 
	from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' and department regexp '��' 
	group by shopcode,SellerSku,Asin 
	) tmp2 
union 
select NodePathName ,count(1) `�¿���������`
from (select NodePathName,shopcode,SellerSku,Asin from t_new_list
	where t_new_list.SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'  and department regexp '��' 
	group by NodePathName,shopcode,SellerSku,Asin ) tmp3 
group by NodePathName
)

-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep 
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_adse_new_lst.new_lst_exp ,t_adse_new_lst.new_lst_clk ,t_adse_new_lst.new_lst_ad_untis
	,t_vist_stat.`�ÿ���` ,t_vist_stat.`�ÿ�����`
	,t_vist_new_lst_stat.`�¿��Ƿÿ���` ,t_vist_new_lst_stat.`�¿��Ƿÿ�����`
	,t_list_cnt.`�¿���������`
	,t_ad_cover_list.`Ͷ�Ź������������`
	,t_online_list.`����������`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_adse_new_lst on t_key.dep = t_adse_new_lst.dep
left join t_list_cnt on t_key.dep = t_list_cnt.dep
left join t_vist_stat on t_key.dep = t_vist_stat.dep 
left join t_vist_new_lst_stat on t_key.dep = t_vist_new_lst_stat.dep
left join t_online_list on t_key.dep = t_online_list.dep
left join t_ad_cover_list on t_key.dep = t_ad_cover_list.dep
)

-- step4 ����ָ�� = ����ָ����Ӽ���
select 
	'${NextStartDay}' `ͳ������`
	,dep `�Ŷ�` 
	,AdExposure `�����ع���`
	,AdClicks `�������`
	,AdSaleUnits `�������`
	,round(AdClicks/AdExposure,4) `�������`
	,round(AdSaleUnits/AdClicks,4) `���ת����`
	,new_lst_exp `�¿��ǹ���ع���`
	,round(new_lst_exp/`�¿���������`) `�¿���ƽ�������ع���`
	,round(new_lst_clk/new_lst_exp,4) `�¿��ǹ������`
	,round(new_lst_ad_untis/new_lst_clk,4) `�¿��ǹ��ת����`
	,round(`�¿��Ƿÿ�����`/`�¿��Ƿÿ���`,4) `�¿��Ƿÿ�ת����`

	,round(`�¿��Ƿÿ���`) `�¿��Ƿÿ���`
-- 	,round(`�ÿ�����`/`�ÿ���`,4) `�ÿ�ת����`
	,round(`Ͷ�Ź������������`/`����������`,4) `���ӹ��Ͷ����`
-- 	,round(`�ÿ���`) `�ÿ���`
-- 	,round((`�ÿ���`-AdClicks)/`�ÿ���`,4) `��Ȼ����ռ��`
from t_merge
order by `�Ŷ�` desc 
