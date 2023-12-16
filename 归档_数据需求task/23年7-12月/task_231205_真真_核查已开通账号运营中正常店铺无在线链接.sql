
-- ԭ����
with
ac as (
select AccountCode ,Code, min(creationtime)over (partition by AccountCode) as creationtime
from import_data.erp_user_user_platform_account_sites
)

, od1 as (
select AccountCode , count(1) `�¶�ͳ�ƶ�����`
from
	(
	select s.AccountCode , wo.PlatOrderNumber
	from import_data.wt_orderdetails wo
	inner join import_data.mysql_store s on wo.shopcode=s.Code/*����ά��*/
	where SettlementTime >= '${StartDay}' and SettlementTime < '${NextStartDay}'
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
	where timestampdiff(second, creationtime, SettlementTime)/86400  <= 30
		and wo.IsDeleted=0 and wo.TransactionType = '����' and wo.orderstatus <> '����' and  totalgross>0
	group by s.AccountCode , wo.PlatOrderNumber
	) tmp
group by AccountCode
)

, listing as (
select ws.AccountCode , count(1) `����������`
from import_data.erp_amazon_amazon_listing  wl
inner join ac on wl.shopcode=ac.Code/*����ά��*/
join wt_store ws on wl.shopcode = ws.code
and ListingStatus =1  and ws.ShopStatus ='����'
group by ws.AccountCode
)


select
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,to_date(CURRENT_DATE()) `ͳ������`
	,ms.AccountCode
	, `����������` ,`�쳣������` ,`���õ�����` ,`�ݼ��е�����`  ,`�رյ�����`
	,`����������` ,`�¶�ͳ�ƶ�����` ,to_date(tmp.creationtime) `�˺�¼��ERP����` ,`�˺�¼��30���ڳ�����`
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
left join listing on ms.AccountCode = listing.AccountCode ;


-- �˲�

select AccountCode ,code ,ShopStatus ,NodePathName,SellUserName
     ,count( distinct  wl.SellerSKU  ) as ���ǹ�������
    ,count( distinct case when eaal.ListingStatus=1 then eaal.SellerSKU end ) as ��ǰ����������
from mysql_store ms
left join import_data.wt_listing  wl on ms.Code = wl.ShopCode
left join import_data.erp_amazon_amazon_listing  eaal on ms.Code = eaal.ShopCode
where  AccountCode regexp 'ZU-NA|ZI-EU|ZI-NA|YH-EN'
group by AccountCode ,code ,ShopStatus ,NodePathName,SellUserName