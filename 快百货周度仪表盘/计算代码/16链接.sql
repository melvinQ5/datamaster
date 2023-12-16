insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `OverShopSkuCnt`)
select
	'${StartDay}' ,'${ReportType}' ,'快百货' ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1,count(1) 在线店铺超量SKU数
from (
	SELECT sku ,count(distinct CompanyCode )
	from wt_listing wl
	join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wl.shopcode=ms.Code and  ms.ShopStatus='正常' and wl.ListingStatus= 1
	group by sku  having count(distinct CompanyCode ) > 6
	) t;

 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `OverShopSkuCnt`)
select
	'${StartDay}' ,'${ReportType}' ,dep2 ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
 , count(1) 在线店铺超量SKU数
from (
	SELECT ms.dep2 ,sku ,count(distinct CompanyCode )
	from wt_listing wl
	join (select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部' end as dep2,*
	    from import_data.mysql_store where department regexp '快')  ms on wl.shopcode=ms.Code and  ms.ShopStatus='正常' and wl.ListingStatus= 1
	group by ms.dep2 ,sku  having count(distinct CompanyCode ) > 3
	) t
group by dep2;