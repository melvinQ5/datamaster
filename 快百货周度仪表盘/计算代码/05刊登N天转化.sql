
-- ֻ����Ʒ
-- ����7�����Ӷ�����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	LstSaleRateIn7d)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(part.lst_id)/count(entire.lst_id),6) `����7�춯����`
--      ,round(count(part.lst_id_newpp)/count(entire.lst_id_newpp),6) `������Ʒ7�춯����`
from ( -- ��������
	select concat(asin,site) lst_id
	     ,case when wp.spu is not null then concat(asin,ms.site) end as lst_id_newpp -- �Ƿ���Ʒ����
	     ,dep2
	from import_data.wt_listing wl
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wl.ShopCode =ms.code
    join view_kbp_new_products vn on wl.sku = wl.sku  -- ��Ʒ
	left join ( select spu from wt_products where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day)
	    and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�' group by spu
        ) wp on wl.spu = wp.spu
	where MinPublicationDate >= date_add('${StartDay}',interval -7 day) and MinPublicationDate < date_add('${NextStartDay}',interval -7 day)
	  and IsDeleted = 0
	group by lst_id ,lst_id_newpp ,dep2 ) entire
left join
    ( -- ��������
	select concat(asin,wo.site) lst_id
	from import_data.wt_orderdetails wo
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.ShopCode =ms.code
	where paytime >= date_add('${StartDay}',interval -7 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,PublicationDate,paytime)/86400 <= 7 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
	group by lst_id ) part
on entire.lst_id = part.lst_id
group by grouping sets ((),(entire.dep2));


-- ����14�����Ӷ�����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	LstSaleRateIn14d)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(part.lst_id)/count(entire.lst_id),6) `����14�춯����` -- ��������Ʒ
--      ,round(count(part.lst_id_newpp)/count(entire.lst_id_newpp),6) `������Ʒ14�춯����`
from ( -- ��������
	select concat(asin,site) lst_id
	     ,case when wp.spu is not null then concat(asin,ms.site) end as lst_id_newpp -- �Ƿ���Ʒ����
	     ,dep2
	from import_data.wt_listing wl
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wl.ShopCode =ms.code
	join view_kbp_new_products vn on wl.sku = wl.sku  -- ��Ʒ
	left join ( select spu from wt_products where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day)
	    and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�' group by spu
        ) wp on wl.spu = wp.spu
	where MinPublicationDate >= date_add('${StartDay}',interval -14 day) and MinPublicationDate < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0
	group by lst_id ,lst_id_newpp ,dep2 ) entire
left join
    ( -- ��������
	select concat(asin,wo.site) lst_id
	from import_data.wt_orderdetails wo
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.ShopCode =ms.code
	where paytime >= date_add('${StartDay}',interval -14 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,PublicationDate,paytime)/86400 <= 14 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
	group by lst_id ) part
on entire.lst_id = part.lst_id
group by grouping sets ((),(entire.dep2));


-- ����30�����Ӷ�����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	LstSaleRateIn30d)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(part.lst_id)/count(entire.lst_id),6) `����30�춯����` -- ��������Ʒ
--      ,round(count(part.lst_id_newpp)/count(entire.lst_id_newpp),6) `������Ʒ30�춯����`
from ( -- ��������
	select concat(asin,site) lst_id
	     ,case when wp.spu is not null then concat(asin,ms.site) end as lst_id_newpp -- �Ƿ���Ʒ����
	     ,dep2
	from import_data.wt_listing wl
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wl.ShopCode =ms.code
	join view_kbp_new_products vn on wl.sku = wl.sku  -- ��Ʒ
	left join ( select spu from wt_products where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day)
	    and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�' group by spu
        ) wp on wl.spu = wp.spu
	where MinPublicationDate >= date_add('${StartDay}',interval -30 day) and MinPublicationDate < date_add('${NextStartDay}',interval -30 day)
	  and IsDeleted = 0
	group by lst_id ,lst_id_newpp ,dep2 ) entire
left join
    ( -- ��������
	select concat(asin,wo.site) lst_id
	from import_data.wt_orderdetails wo
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wo.ShopCode =ms.code
	where paytime >= date_add('${StartDay}',interval -30 day) and paytime < '${NextStartDay}'  and wo.IsDeleted =0 and orderstatus != '����'
		and timestampdiff(second,PublicationDate,paytime)/86400 <= 30 and timestampdiff(second,PublicationDate,paytime)/86400 >= 0
	group by lst_id ) part
on entire.lst_id = part.lst_id
group by grouping sets ((),(entire.dep2));


-- ����7���ع���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	ExpoRateIn7dLst)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(part.lst_id)/count(entire.lst_id),6) `����7���ع���` -- ��������Ʒ
--      ,round(count(part.lst_id_newpp)/count(entire.lst_id_newpp),6) `������Ʒ7���ع���`
from ( -- ��������
	select concat(asin,site) lst_id
	     ,case when wp.spu is not null then concat(asin,ms.site) end as lst_id_newpp -- �Ƿ���Ʒ����
	     ,dep2
	from import_data.wt_listing wl
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wl.ShopCode =ms.code and site regexp 'UK|DE|FR|US'
	join view_kbp_new_products vn on wl.sku = wl.sku  -- ��Ʒ
	left join ( select spu from wt_products where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day)
	    and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�' group by spu
        ) wp on wl.spu = wp.spu
	where MinPublicationDate >= date_add('${StartDay}',interval -7 day) and MinPublicationDate < date_add('${NextStartDay}',interval -7 day)
	  and IsDeleted = 0
	group by lst_id ,lst_id_newpp ,dep2 ) entire
left join
    ( -- �ع�����
    select concat(wl.asin,site) lst_id
    from wt_listing wl
    join (select case when NodePathName regexp 'Ȫ��' then '��ٻ�����' when NodePathName regexp '�ɶ�' then '��ٻ�һ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wl.ShopCode =ms.code and site regexp 'UK|DE|FR|US'
    left join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -7 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -7 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
         ) wp on wl.sku = wp.sku
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
        and wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day)
    where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 7 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
    group by lst_id ) part
on entire.lst_id = part.lst_id
group by grouping sets ((),(entire.dep2));


-- ����14���ع���
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	ExpoRateIn14dLst)
select '${StartDay}' ,'${ReportType}' ,ifnull(entire.dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
     ,round(count(part.lst_id)/count(entire.lst_id),6) `����14���ع���` -- ��������Ʒ
--      ,round(count(part.lst_id_newpp)/count(entire.lst_id_newpp),6) `������Ʒ14���ع���`
from ( -- ��������
	select concat(asin,site) lst_id
	     ,case when wp.spu is not null then concat(asin,ms.site) end as lst_id_newpp -- �Ƿ���Ʒ����
	     ,dep2
	from import_data.wt_listing wl
	join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wl.ShopCode =ms.code and site regexp 'UK|DE|FR|US'
	join view_kbp_new_products vn on wl.sku = wl.sku  -- ��Ʒ
	left join ( select spu from wt_products where DevelopLastAuditTime < '${NextStartDay}' and DevelopLastAuditTime >= date_add('${NextStartDay}',interval - 90 day)
	    and DevelopLastAuditTime > '2023-03-01' and ProjectTeam = '��ٻ�' group by spu
        ) wp on wl.spu = wp.spu
	where MinPublicationDate >= date_add('${StartDay}',interval -14 day) and MinPublicationDate < date_add('${NextStartDay}',interval -14 day)
	  and IsDeleted = 0
	group by lst_id ,lst_id_newpp ,dep2 ) entire
left join
    ( -- �ع�����
    select concat(wl.asin,site) lst_id
    from wt_listing wl
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms  on wl.ShopCode =ms.code and site regexp 'UK|DE|FR|US'
    left join (select wp.SKU ,ProjectTeam,DevelopLastAuditTime from import_data.wt_products wp
        where DevelopLastAuditTime >= date_add('${StartDay}',interval -14 day) and DevelopLastAuditTime < date_add('${NextStartDay}',interval -14 day) and IsDeleted = 0 and wp.ProjectTeam = '��ٻ�'
         ) wp on wl.sku = wp.sku
    join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU
        and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
        and wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day)
    where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 14 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
    group by lst_id ) part
on entire.lst_id = part.lst_id
group by grouping sets ((),(entire.dep2));






-- ����7����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	RoasIn7dLst ,ClickRateIn7dLst ,AdSaleRateIn7dLst,AvgAdExposuresIn7dLst)
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalSale7Day)/sum(Spend),4) RoasIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then Clicks end )/sum(case when site regexp 'UK|DE|FR|US' then Exposure end),4) ClickRateIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then TotalSale7DayUnit end)/sum(case when site regexp 'UK|DE|FR|US' then Clicks end ),4) AdSaleRateIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then Exposure end)/count(distinct case when site regexp 'UK|DE|FR|US' then concat(ad.sellersku,ad.ShopCode) end )) AvgAdExposuresIn7dLst
from wt_listing wl
join view_kbp_new_products vn on wl.sku = vn.sku and wl.IsDeleted  = 0  -- ��Ʒ
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
	on wl.ShopCode =ms.code and  wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day) and wl.MinPublicationDate < date_add('${NextStartDay}',interval -7 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU and wl.asin = ad.asin
	and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 7 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
group by grouping sets ((),(ms.dep2));


insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	RoasIn7dLst ,ClickRateIn7dLst ,AdSaleRateIn7dLst,AvgAdExposuresIn7dLst)
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalSale7Day)/sum(Spend),4) RoasIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then Clicks end )/sum(case when site regexp 'UK|DE|FR|US' then Exposure end),4) ClickRateIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then TotalSale7DayUnit end)/sum(case when site regexp 'UK|DE|FR|US' then Clicks end ),4) AdSaleRateIn7dLst
    ,round(sum(case when site regexp 'UK|DE|FR|US' then Exposure end)/count(distinct case when site regexp 'UK|DE|FR|US' then concat(wl.asin,site) end )) AvgAdExposuresIn7dLst
from wt_listing wl
join view_kbp_new_products vn on wl.sku = vn.sku  -- ��Ʒ
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
	on wl.ShopCode =ms.code and  wl.MinPublicationDate >= date_add('${StartDay}',interval -7 day) and wl.MinPublicationDate < date_add('${NextStartDay}',interval -7 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU 
	and ad.CreatedTime >= date_add('${StartDay}',interval -7 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 7 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
group by ms.NodePathName; 


-- ����14����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	RoasIn14dLst ,ClickRateIn14dLst ,AdSaleRateIn14dLst)
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalSale7Day)/sum(Spend),4) RoasIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then Clicks end )/sum(case when site regexp 'UK|DE|FR|US' then Exposure end),4) ClickRateIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then TotalSale7DayUnit end)/sum(case when site regexp 'UK|DE|FR|US' then Clicks end ),4) AdSaleRateIn7dLst
from wt_listing wl
join view_kbp_new_products vn on wl.sku = vn.sku  -- ��Ʒ
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
	on wl.ShopCode =ms.code and  wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day) and wl.MinPublicationDate < date_add('${NextStartDay}',interval -14 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU 
	and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 14 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
group by grouping sets ((),(ms.dep2));

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	RoasIn14dLst ,ClickRateIn14dLst ,AdSaleRateIn14dLst)
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalSale7Day)/sum(Spend),4) RoasIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then Clicks end )/sum(case when site regexp 'UK|DE|FR|US' then Exposure end),4) ClickRateIn7dLst
	,round(sum(case when site regexp 'UK|DE|FR|US' then TotalSale7DayUnit end)/sum(case when site regexp 'UK|DE|FR|US' then Clicks end ),4) AdSaleRateIn7dLst
from wt_listing wl
join view_kbp_new_products vn on wl.sku = vn.sku  -- ��Ʒ
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
	on wl.ShopCode =ms.code and  wl.MinPublicationDate >= date_add('${StartDay}',interval -14 day) and wl.MinPublicationDate < date_add('${NextStartDay}',interval -14 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU 
	and ad.CreatedTime >= date_add('${StartDay}',interval -14 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 14 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
group by ms.NodePathName; 


-- ����30����
insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`, 
	RoasIn30dLst)
select '${StartDay}' ,'${ReportType}' ,ifnull(dep2,'��ٻ�') ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalSale7Day)/sum(Spend),4) RoasIn30dLst
from wt_listing wl
join view_kbp_new_products vn on wl.sku = vn.sku  -- ��Ʒ
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
	on wl.ShopCode =ms.code and  wl.MinPublicationDate >= date_add('${StartDay}',interval -30 day) and wl.MinPublicationDate < date_add('${NextStartDay}',interval -30 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU 
	and ad.CreatedTime >= date_add('${StartDay}',interval -30 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 30 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
group by grouping sets ((),(ms.dep2));

insert into ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
	RoasIn30dLst)
select '${StartDay}' ,'${ReportType}' ,NodePathName ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	,round(sum(TotalSale7Day)/sum(Spend),4) RoasIn30dLst
from wt_listing wl
join view_kbp_new_products vn on wl.sku = vn.sku  -- ��Ʒ
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms
	on wl.ShopCode =ms.code and  wl.MinPublicationDate >= date_add('${StartDay}',interval -30 day) and wl.MinPublicationDate < date_add('${NextStartDay}',interval -30 day)
join import_data.AdServing_Amazon ad on wl.ShopCode =ad.ShopCode and ad.SellerSKU = wl.SellerSKU 
	and ad.CreatedTime >= date_add('${StartDay}',interval -30 day) and ad.CreatedTime< '${NextStartDay}'
where timestampdiff(second,MinPublicationDate,CreatedTime)/86400 <= 30 and timestampdiff(second,MinPublicationDate,CreatedTime)/86400 >= 0
group by ms.NodePathName; 





