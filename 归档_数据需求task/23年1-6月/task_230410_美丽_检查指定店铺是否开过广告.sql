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
	,AdActivityName `广告活动名称` 
	,AdGroupName `广告组名称`
	,Clicks `点击`
	,Exposure `曝光`
	,CTRClicks `点击率`
	,TotalSale7DayUnit `广告销量`
	,TotalSale7Day `广告销售额usd`
	,Spend `广告花费usd`
	,CPC
	,Acost as ACOS 
	,campaignBudget `预算`
	,ExchangeUSD `原币兑美元`
	,campaignBudgetType
from tb ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${NextStartDay}',interval -30 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.arr 
)

select * from t_adse 
