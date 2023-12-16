with 
ac as (
select AccountCode ,Code, min(creationtime)over (partition by AccountCode) as creationtime
from import_data.erp_user_user_platform_account_sites 
) 

, od1 as (
select AccountCode , count(1) `��30�충����` 
from 
	(
	select s.AccountCode , wo.PlatOrderNumber 
	from import_data.wt_orderdetails wo  
	inner join import_data.mysql_store s on wo.shopcode=s.Code/*����ά��*/
	where PayTime >=date_add(CURRENT_DATE() ,-30) and PayTime < CURRENT_DATE() 
		and wo.IsDeleted=0 and wo.TransactionType = '����' and wo.orderstatus <> '����' and  totalgross>0
	group by s.AccountCode , wo.PlatOrderNumber 
	) tmp 
group by AccountCode
) 

, od2 as (
select AccountCode , count(1) `�˺�¼��30���ڳ�����` 
from 
	(
	select s.AccountCode , wo.PlatOrderNumber 
	from import_data.wt_orderdetails wo  
	inner join import_data.mysql_store s on wo.shopcode=s.Code/*����ά��*/
	left join ac on wo.shopcode = ac.Code 
	where timestampdiff(second, creationtime, PayTime)/86400  <= 30 
		and wo.IsDeleted=0 and wo.TransactionType = '����' and wo.orderstatus <> '����' and  totalgross>0
	group by s.AccountCode , wo.PlatOrderNumber 
	) tmp 
group by AccountCode
) 

, listing as ( 
select s.AccountCode , count(1) `����������`
from import_data.erp_amazon_amazon_listing  wl 
inner join import_data.mysql_store s on wl.shopcode=s.Code/*����ά��*/
where  ListingStatus =1  and s.ShopStatus ='����'
group by s.AccountCode 
)


select ms.AccountCode 
	, `����������` ,`�쳣������` ,`���õ�����` ,`�ݼ��е�����`  ,`�رյ�����` 
	,`����������` ,`��30�충����` ,date(tmp.creationtime) `�˺�¼��ERP����` ,`�˺�¼��30���ڳ�����`
from 
	(select AccountCode
		, count( case when ShopStatus='����' then code end ) `����������` 
		, count( case when ShopStatus='�쳣' then code end ) `�쳣������` 
		, count( case when ShopStatus='����' then code end ) `���õ�����` 
		, count( case when ShopStatus='�ݼ���' then code end ) `�ݼ��е�����` 
		, count( case when ShopStatus='�ر�' then code end ) `�رյ�����` 
	from  import_data.mysql_store 
	group by AccountCode 
	) ms 
left join (select AccountCode,creationtime from ac group by AccountCode,creationtime) tmp
	on ms.AccountCode = tmp.AccountCode
left join od1 on ms.AccountCode = od1.AccountCode
left join od2 on ms.AccountCode = od2.AccountCode
left join listing on ms.AccountCode = listing.AccountCode
-- WHERE  ms.AccountCode = 'A23-NA'