-- ���ַ���ģʽά�� FBA��FBM
with 
ta as (
select 
['4527356-������',
'4527345-������',
'4527299-����ϼ',
'4522608-������',
'4483385-������',
'4483309-����ϼ',
'4478402-����ϼ',
'4478401-������',
'4475962-����ϼ',
'4459364-������',
'4456462-����ϼ',
'4375397-����ϼ',
'4375396-����ϼ',
'4346706-������',
'4346694-������',
'4346685-������',
'4346663-����ϼ',
'4332620-����ϼ',
'4332500-����ϼ',
'3547351-������',
'3547350-������',
'3547343-����ϼ'] arr 
)

,tb as (
select split(arr,"-")[1] as boxsku ,split(arr,"-")[2] as person
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
)

,t2 as ( 
select wp.CategoryPathByChineseName , wp.BoxSku 
	,case when wp.ProductStatus = 0 then '����'
		when wp.ProductStatus = 2 then 'ͣ��'
		when wp.ProductStatus = 3 then 'ͣ��'
		when wp.ProductStatus = 4 then '��ʱȱ��'
		when wp.ProductStatus = 5 then '���'
		end as ProductStatus
	,wp.ProductName  
from import_data.wt_products wp 
where IsDeleted =0 
)

, orderdetails as (
select OrderNumber 
	,PlatOrderNumber
	,ExchangeUSD 
	,TotalGross,TotalProfit,TotalExpend
	,TransactionType,SellerSku,RefundAmount,AdvertisingCosts
	, case when ShipWarehouse regexp 'FBA' then 'FBAģʽ' else 'FBMģʽ' end mode
	,ShipWarehouse
	,wo.boxsku
	,pp.Spu
	,ms.* 
	,tb.person
	,SettlementTime
	,PayTime 
	,pp.ProductName 
from import_data.wt_orderdetails wo 
inner join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and wo.IsDeleted=0 
	and ms.department = '�̳���'
left join wt_products pp on wo.BoxSku=pp.BoxSku
join tb on tb.boxsku = wo.BoxSku 
where SettlementTime  >='${StartDay}' and SettlementTime  < '${NextStartDay}'
)


/*�������*/
, adserving as (
select 
	wl.BoxSku 
	,person 
	,ad.*
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code  and ms.department = '�̳���'	
left join (select wl.boxsku ,ShopCode ,Asin ,SellerSku ,person 
	from wt_listing wl
	left join tb on wl.boxsku = tb.boxsku 
	inner join import_data.mysql_store ms
		on wl.ShopCode=ms.Code  and ms.department = '�̳���' 
	group by wl.boxsku ,ShopCode ,Asin ,SellerSku,person 
	) wl 
	on ad.ShopCode =wl.ShopCode and ad.Asin =wl.ASIN and ad.SellerSku = ad.SellerSku 	
)

/*�ÿ�����*/
, visitor as (
select wl.boxsku ,person 
	,s.* 
	,round((TotalCount*FeaturedOfferPercent)/100,2) '�ÿ���' 
	,OrderedCount '�ÿ�����' 
from import_data.ListingManage lm
inner join import_data.mysql_store s
	on lm.ShopCode=s.Code and s.department = '�̳���'
	and ReportType='�ܱ�' 	
	and Monday='${StartDay}' 
left join (select wl.boxsku ,ShopCode ,Asin ,person 
	from wt_listing wl
	inner join import_data.mysql_store s on wl.ShopCode=s.Code and s.department = '�̳���'
	left join tb on wl.boxsku = tb.boxsku 
	group by wl.boxsku ,ShopCode ,Asin ,person 
	) wl 
	on lm.ShopCode =wl.ShopCode and lm.ChildAsin =wl.ASIN 
)

/*��Part2 ��һָ�꡿*/
, sl as ( 
select person 
	,round(sum(TotalGross/ExchangeUSD),2) `���۶�`
	,round(sum(TotalProfit/ExchangeUSD),2) `�����`
	,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),2) `������`
	, count(distinct OrderNumber)/ datediff('${NextStartDay}','${StartDay}') `�վ�������`
from orderdetails 
group by person
)

, Ads as (
select person
	,sum(spend) '�����滨��' 
	,sum(TotalSale7Day) '������۶�' 
	,round(sum(spend)/sum(TotalSale7Day),4) 'Acost'
	,sum(Exposure) 'exp' 
	,sum(Clicks) 'clk' ,round(sum(Clicks)/sum(Exposure),4) '�������',round(sum(TotalSale7DayUnit)/sum(Clicks),4) '���ת����'
from adserving
group by person
)

, ls as (
select person,sum(�ÿ���) as �ÿ���,sum(�ÿ�����)as '�ÿ�����' 
from visitor
group by person
)

-- ��������ϸ
-- select 
-- 	 OrderNumber `���ж�����`
-- 	,PlatOrderNumber `ƽ̨������`
-- 	,SettlementTime `����ʱ��`
-- 	,code `����` 
-- 	,person `��Ӫ��Ա`
-- 	,boxsku
-- 	,productname `��Ʒ����`
-- 	,round(TotalGross/ExchangeUSD) `������usd`
-- 	,round(TotalProfit/ExchangeUSD) `������usd`
-- 	,round(TotalExpend/ExchangeUSD) `�ܳɱ�usd`
-- 	,TransactionType `��������`
-- 	,AdvertisingCosts `�������Ͷ�Ӧ�۳����̷���`
-- 	,SellerSku `����SKU`
-- 	,case when ShipWarehouse regexp 'FBA' then 'FBAģʽ' else 'FBMģʽ' end mode
-- 	,ShipWarehouse `�����ֿ�`
-- from orderdetails
-- order by TransactionType

-- �������ϸ
-- select 
-- 	shopcode `����`
-- 	,StoreSite `վ��`
-- 	,AdActivityName `���`
-- 	,AdGroupName `�����`
-- 	,SellerSKU ,Asin
-- 	,BoxSku `ͨ������ƥ��boxsku` 
-- 	,person `��Ӫ��Ա`
-- 	,sum(spend) '��滨��' 
-- 	,sum(TotalSale7Day) '������۶�' 
-- 	,round(sum(spend)/sum(TotalSale7Day),4) 'Acost'
-- 	,sum(Exposure) '�ع���' 
-- 	,sum(Clicks) '�����' 
-- 	,sum(TotalSale7DayUnit) `�������`
-- 	,round(sum(Clicks)/sum(Exposure),4) '�������'
-- 	,round(sum(TotalSale7DayUnit)/sum(Clicks),4) '���ת����'
-- from adserving
-- group by shopcode,StoreSite ,AdActivityName ,AdGroupName ,SellerSKU ,Asin ,BoxSku ,person 

select 
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `��������ʱ��`
	,sl.person 
	,sl.`���۶�`
	,sl.`�����`
	,sl.`������`
	,round(sl.`�վ�������`,1) �վ�������
	,ifnull(�����滨��,0) as �����滨��
	,ifnull(������۶�,0) as ������۶�
	,Acost 
	,exp �ع���
	,clk �����
	,�������
	,���ת����
	,�ÿ���
	,�ÿ����� 
	,round(�������,4) as '�������'
	,round(���ת����,4) as '���ת����'
	,exp '�ع���'
	,clk '�����'
-- 	,round(�ÿ���)as '�ÿ���'
--        ,�ÿ�����
-- 	,round(�ÿ�����/�ÿ���,4) '�ÿ�ת����'
-- 	,round((�ÿ���-clk)/�ÿ���,4) '��Ȼ����ռ��' 
from sl
left join Ads
on sl.person=Ads.person 
left join ls
on sl.person=ls.person 