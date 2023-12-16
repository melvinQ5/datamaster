with 
ta as (
select [5202018.01,
5213395.01,
5206254.03,
5195477.01,
5174804.02,
5198357.01,
5199089.04,
5171861.01,
5197602.01,
5213354.05,
5214677.04,
5175296.01,
5197602.01,
5213354.05,
5214677.04,
5175296.01] arr 
)

,tb as (
select * 
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
)


,t_ad as ( 
select wl.boxsku ,wl.sku , asa.CreatedTime ,asa.StoreSite , asa.ShopCode ,asa.Asin  ,asa.SellerSKU , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit 
from wt_listing wl 
join tb on wl.sku =tb.arr 
join import_data.AdServing_Amazon asa on wl.ShopCode = asa.ShopCode and wl.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '2023-02-01' 
)

,t_ad_stat as (
select tmp.* 
	, round(Clicks/Exposure,4) as `�ۼƹ������`
	, round(TotalSale7DayUnit/Clicks,6) as `�ۼƹ��ת����`
from 
	( select boxsku ,sku ,StoreSite ,asin 
		-- �ع���
		, round(sum( Exposure )) as Exposure
		-- �����
		, round(sum(Clicks)) as Clicks
		-- ����	
		, round(sum(TotalSale7DayUnit)) as TotalSale7DayUnit
		from t_ad  group by boxsku ,sku ,StoreSite ,asin 
	) tmp
)

select *
from t_ad_stat