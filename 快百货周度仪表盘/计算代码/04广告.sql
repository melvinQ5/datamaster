insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	AdSpendRate ,AdSalesRate ,AdOtherSkuSalesRate,ROAS ,CPC ,AdClickRate ,AdSaleRate ,AdClicks ,AdExposures ,AvgAdExposures ,AvgAdClicks)

select '${StartDay}' ,'${ReportType}' ,Department ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,ifnull(round(B.Spend / A.TotalGross, 4), 0) as AdSpendRate
	,ifnull(round(B.TotalSale7Day / A.TotalGross, 4), 0) as AdSalesRate
	,ifnull(round(B.AdOtherSale7Day / A.TotalGross, 4), 0) as AdOtherSkuSalesRate
	,B.ROAS ,B.CPC ,B.AdClickRate ,B.AdSaleRate ,B.AdClicks ,B.AdExposures
	,ifnull(round(B.AdExposures / B.adlist_cnt, 4), 0) as AvgAdExposures
	,ifnull(round(B.AdClicks / B.adlist_cnt, 4), 0) as AvgAdClicks
from ads_ag_kbh_report_weekly A
join (
	select ifnull(ms.dep2,'快百货') Department
		,sum(TotalSale7Day) TotalSale7Day 
		,sum(AdOtherSale7Day) AdOtherSale7Day 
		,sum(Spend) Spend
		,round(sum(TotalSale7Day)/sum(Spend),4) ROAS
		,round(sum(Spend)/sum(Clicks),4) CPC
		,round(sum(Clicks)/sum(Exposure),4) AdClickRate
		,round(sum(TotalSale7DayUnit)/sum(Clicks),4) AdSaleRate
		,sum(Clicks) AdClicks
		,sum(Exposure) AdExposures
		,count(distinct sellersku,shopcode) adlist_cnt
	from import_data.AdServing_Amazon ad
	join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms
		on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day) and ad.ShopCode = ms.Code  
	group by grouping sets ((),(ms.dep2))
	union all 
	select NodePathName
		,sum(TotalSale7Day) TotalSale7Day 
		,sum(AdOtherSale7Day) AdOtherSale7Day 
		,sum(Spend) Spend
		,round(sum(TotalSale7Day)/sum(Spend),4) ROAS
		,round(sum(Spend)/sum(Clicks),4) CPC
		,round(sum(Clicks)/sum(Exposure),4) AdClickRate
		,round(sum(TotalSale7DayUnit)/sum(Clicks),4) AdSaleRate
		,sum(Clicks) AdClicks
		,sum(Exposure) AdExposures
		,count(distinct sellersku,shopcode) adlist_cnt
	from import_data.AdServing_Amazon ad
	join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms
		on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day) and ad.ShopCode = ms.Code  
	group by NodePathName 
) B on A.Team = B.Department and A.FirstDay  = '${StartDay}';


