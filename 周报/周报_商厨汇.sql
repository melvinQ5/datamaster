with
t_key as ( -- �������ά��
select '�̳���' dep
)

,t_mysql_store as (  
select 
	Code 
	,case when NodePathName regexp 'Ȫ��' then '��ٻ�����' 
		when NodePathName regexp '�ɶ�' then '��ٻ�һ��'  else department 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store
)

,t_orde as (
select OrderNumber ,PlatOrderNumber 
	,TotalGross,TotalProfit,TotalExpend
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate
	,pp.SPU
	,ms.*
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
left join wt_products pp on wo.BoxSku=pp.BoxSku
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0  and ms.Department = '�̳���' 
and OrderStatus != '����'
-- where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
)

-- select round(sum(TotalGross/ExchangeUSD),2) `���۶�`
-- 	,round(sum(TotalProfit/ExchangeUSD),2) `�����`
-- 	,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),2) `������`
-- 	,count(distinct OrderNumber)/ datediff('${NextStartDay}','${StartDay}') `�վ�������`
-- from t_orde

-- select * from t_orde

,t_refd as (
select rf.RefundUSDPrice,RefundReason1,RefundReason2 ,ShipDate 
	,ms.*
from import_data.daily_RefundOrders rf 
join t_mysql_store ms 
	on rf.OrderSource=ms.Code and RefundStatus ='���˿�'
		and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'  and ms.Department = '�̳���'
) 

,t_adse as (
select 
	ad.ShopCode ,ad.SellerSKU ,ad.Asin ,ad.Spend as AdSpend ,ad.TotalSale7Day as AdSales 
	,Clicks as AdClicks ,Exposure as AdExposure ,TotalSale7DayUnit as AdSaleUnits
	,ms.*
from t_mysql_store ms
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
-- 	on ad.CreatedTime >='${StartDay}' and ad.CreatedTime< '${NextStartDay}'
		and ad.ShopCode = ms.Code   and ms.Department = '�̳���'
)

,t_vist as (
select (TotalCount*FeaturedOfferPercent)/100 `�ÿ���` ,OrderedCount `�ÿ�����` ,ChildAsin ,ShopCode 
	,ms.*
from import_data.ListingManage lm
join t_mysql_store ms
	on lm.ShopCode=ms.Code and ReportType='�ܱ�' and Monday='${StartDay}' and ms.Department = '�̳���'
-- 	on lm.ShopCode=ms.Code and ReportType='�±�' and Monday='${StartDay}' and ms.Department = '�̳���'
)

-- step2 ����ָ�� = ͳ����+����ά��+ԭ��ָ��
,t_sale_stat as ( 
select '�̳���' dep
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `˰�����۶�`
	,round( sum((TotalExpend)/ExchangeUSD),2) `�����ɱ�`
	,sum(ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)) `���̷��ÿ۳�`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `�������������ܳɱ�`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `�վ�������`
from t_orde 
)

,t_refd_stat as (
select '�̳���' dep
	,sum(RefundUSDPrice) `�˿���`
from t_refd 
)

,t_adse_stat as (
select '�̳���' dep
	,sum(AdSpend) `�����滨��` 
	,sum(AdSales) Adsale 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
	,sum(AdClicks) as AdClicks 
	,sum(AdExposure) as AdExposure 
	,sum(AdSaleUnits) as AdSaleUnits
from t_adse 
)

,t_vist_stat as (
select '�̳���' dep
	,sum(`�ÿ���`) as `�ÿ���`,sum(`�ÿ�����`) `�ÿ�����` 
from t_vist 
)

-- step3 ����ָ�����ݼ�
, t_merge as (
select t_key.dep 
	,t_sale_stat.`˰�����۶�` ,t_sale_stat.`�������������ܳɱ�` ,t_sale_stat.`�վ�������` 
	,`�����ɱ�`
	, `���̷��ÿ۳�`
	,t_refd_stat.`�˿���` 
	,t_adse_stat.`�����滨��` ,t_adse_stat.Adsale ,t_adse_stat.Acost
	,t_adse_stat.AdExposure ,t_adse_stat.AdClicks  ,t_adse_stat.AdSaleUnits
	,t_vist_stat.`�ÿ���` ,t_vist_stat.`�ÿ�����`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_refd_stat on t_key.dep = t_refd_stat.dep
left join t_sale_stat on t_key.dep = t_sale_stat.dep
left join t_vist_stat on t_key.dep = t_vist_stat.dep
)
-- select * from t_merge 

-- step4 ����ͳ��
--select 
--	'${NextStartDay}' `ͳ������`
--	,dep `�Ŷ�` 
--	,round(`˰�����۶�`-`�˿���`,2) `���۶�`
--	,round(`˰�����۶�`-`�˿���`+(`�������������ܳɱ�`-`�����滨��`),2) `�����`
--	,round( (`˰�����۶�`-`�˿���`+(`�������������ܳɱ�`-`�����滨��`))/(`˰�����۶�`-`�˿���`) ,3) `ë����`
--	,`�����ɱ�`
--	,`�������������ܳɱ�`
--	, `���̷��ÿ۳�`
--	,round(`�վ�������`) `�վ�������`
--	,`˰�����۶�`
--	,round(`�˿���`/`˰�����۶�`,4) `�˿���`
--	,`�˿���`
--	,`�����滨��`
--	,round(`�����滨��`/Adsale,4) `ACOS`
--	,round(`�����滨��`/(`˰�����۶�`-`�˿���`),4) `��滨��ռ��`
--	,round(Adsale/(`˰�����۶�`-`�˿���`),4) `���ҵ��ռ��`	
--	,AdExposure `�ع���`
--	,AdClicks `�����`
--	,AdSaleUnits `�������`
--	,round(AdClicks/AdExposure,4) `�������`
--	,round(AdSaleUnits/AdClicks,4) `���ת����`
--	,round(`�ÿ�����`/`�ÿ���`,4) `�ÿ�ת����`
--	,round(`�ÿ���`) `�ÿ���`
--	,round((`�ÿ���`-AdClicks)/`�ÿ���`,4) `��Ȼ����ռ��`
--from t_merge

