with 
ta as (
select [
'NA-UK',
'NX-DE',
'OL-DE',
'OL-FR',
'OL-UK',
'OU-US',
'QF-UK',
'RK-UK',
'RK-US',
'RN-UK',
'XF-US',
'XT-US',
'YC-CA',
'YC-US',
'YE-US'
] arr 
)

,tb as (
select * 
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
)


, t_adse as (
select ad.ShopCode 
	,ad.SellerSKU 
	,ad.Asin 
	,StoreSite 
	,CreatedTime ``
	,AdActivityName `�������` 
	,AdGroupName `���������`
	,Clicks `���`
	,Exposure `�ع�`
	,CTRClicks `�����`
	,TotalSale7DayUnit `�������`
	,TotalSale7Day `������۶�usd`
	,Spend `��滨��usd`
	,CPC
	,Acost as ACOS 
	,campaignBudget `Ԥ��`
	,ExchangeUSD `ԭ�Ҷ���Ԫ`
	,campaignBudgetType
from tb ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${NextStartDay}',interval -30 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.arr 
)

select * from t_adse 
