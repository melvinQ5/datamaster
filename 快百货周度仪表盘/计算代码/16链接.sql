insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `OverShopSkuCnt`)
select
	'${StartDay}' ,'${ReportType}' ,'��ٻ�' ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1,count(1) ���ߵ��̳���SKU��
from (
	SELECT sku ,count(distinct CompanyCode )
	from wt_listing wl
	join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wl.shopcode=ms.Code and  ms.ShopStatus='����' and wl.ListingStatus= 1
	group by sku  having count(distinct CompanyCode ) > 6
	) t;

 insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `OverShopSkuCnt`)
select
	'${StartDay}' ,'${ReportType}' ,dep2 ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
 , count(1) ���ߵ��̳���SKU��
from (
	SELECT ms.dep2 ,sku ,count(distinct CompanyCode )
	from wt_listing wl
	join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wl.shopcode=ms.Code and  ms.ShopStatus='����' and wl.ListingStatus= 1
	group by ms.dep2 ,sku  having count(distinct CompanyCode ) > 3
	) t
group by dep2;