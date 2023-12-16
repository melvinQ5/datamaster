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

,orderdetails as (
select wo.id,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend,ExchangeUSD
	,TransactionType,SellerSku,RefundAmount,AdvertisingCosts
	, case when ShipWarehouse regexp 'FBA' then 'FBAģʽ' else 'FBMģʽ' end mode
	,ShipWarehouse
	,wo.boxsku
	,pp.Spu
	,ms.* 
	,tb.person 
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
	,ad.*
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code  and ms.department = '�̳���'	
left join (select boxsku ,ShopCode ,Asin ,SellerSku 
	from wt_listing wl
	inner join import_data.mysql_store ms
		on wl.ShopCode=ms.Code  and ms.department = '�̳���' 
	group by boxsku ,ShopCode ,Asin ,SellerSku
	) wl 
	on ad.ShopCode =wl.ShopCode and ad.Asin =wl.ASIN and ad.SellerSku = ad.SellerSku 	
)

/*�ÿ�����*/
, visitor as (
select wl.boxsku ,s.*,round((TotalCount*FeaturedOfferPercent)/100,2) '�ÿ���',OrderedCount '�ÿ�����' 
from import_data.ListingManage lm
inner join import_data.mysql_store s
	on lm.ShopCode=s.Code and s.department = '�̳���'
	and ReportType='�ܱ�' 
-- 	and ReportType='�±�' 	
	and Monday='${StartDay}' 
left join (select boxsku ,ShopCode ,Asin 
	from wt_listing wl
	inner join import_data.mysql_store s on wl.ShopCode=s.Code and s.department = '�̳���'
	group by boxsku ,ShopCode ,Asin 
	) wl 
	on lm.ShopCode =wl.ShopCode and lm.ChildAsin =wl.ASIN 
)

/*�˿�����*/
,RefundAmount as ( 
select dod.BoxSku
	,dod.ShipWarehouse
	,s.Department,s.NodePathName,s.Code 
	,rf.RefundDate
	,ifnull(rf.RefundUSDPrice,0) RefundUSDPrice
	,rf.RefundReason1
	,rf.RefundReason2 
	,rf.ShipDate 
	,rf.OrderNumber 
from import_data.daily_RefundOrders rf
join import_data.mysql_store s 
	on rf.OrderSource=s.Code and RefundStatus ='���˿�'
		and RefundDate>='${StartDay}'
		and RefundDate<'${NextStartDay}'
		and s.department = '�̳���'
left join (select OrderNumber ,ShipWarehouse ,GROUP_CONCAT(boxsku) as BoxSku
	from import_data.wt_orderdetails where IsDeleted = 0 and TransactionType ='����'
	group by OrderNumber ,ShipWarehouse 
	) dod -- ����֤һ��ordernumber ֻ��Ӧ�� һ��boxsku 
	on dod.OrderNumber  =rf.OrderNumber 
)


/*��Part2 ��һָ�꡿*/
, sl as ( 
select BoxSku 
	,round(sum(TotalGross/ExchangeUSD),2) `���۶�`
	,round(sum(TotalProfit/ExchangeUSD),2) `�����`
	,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),2) `ë����`
	,round(sum( case when mode='FBAģʽ' then TotalGross/ExchangeUSD end ),2) `FBA���۶�`
	,round(sum( case when mode='FBMģʽ' then TotalGross/ExchangeUSD end ),2) `FBM���۶�`
	, count(distinct OrderNumber)/ datediff('${NextStartDay}','${StartDay}') `�վ�������`
from orderdetails 
group by BoxSku
)
    
, Ads as (
select BoxSku
	,sum(spend) '�����滨��' 
	,sum(TotalSale7Day) '������۶�' 
	,round(sum(spend)/sum(TotalSale7Day),4) 'Acost'
	,sum(Exposure) 'exp' 
	,sum(Clicks) 'clk' ,round(sum(Clicks)/sum(Exposure),4) '�������',round(sum(TotalSale7DayUnit)/sum(Clicks),4) '���ת����'
from adserving
group by BoxSku
)

, ls as (
select BoxSku,sum(�ÿ���) as �ÿ���,sum(�ÿ�����)as '�ÿ�����' from visitor
group by BoxSku
)

, rd as (
select BoxSku 
	,ifnull(sum( RefundUSDPrice ),0) '�˿���˿�' 
	,sum(case when !(RefundReason1='�ͻ�ԭ��' and ShipDate = '2000-01-01') then RefundUSDPrice else 0 end) '�ǿͻ�ԭ���˿���' 
from RefundAmount 
group by BoxSku
)

-- 
, t_merage as (
select 
	sl.BoxSku 
	,tb.person 
	,sl.`���۶�`
	,sl.`FBA���۶�`
	,sl.`FBM���۶�`
	,sl.`�����`
	,sl.`ë����`
	,sl.`�վ�������`
	,ifnull(�����滨��,0) as �����滨��
	,ifnull(������۶�,0) as ������۶�
	,Acost,exp,clk
	,�������
	,���ת����
	,�ÿ���
	,�ÿ����� 
	,`�˿���˿�` 
from sl
left join rd
on sl.BoxSku=rd.BoxSku
left join Ads
on sl.BoxSku=Ads.BoxSku
left join ls
on sl.BoxSku=ls.BoxSku 
left join tb on  sl.BoxSku =tb.boxsku 
where sl.BoxSku <> 'shopfee' 
)


/*��Part3 ����ָ�꡿*/
select 
	replace(concat(right('${StartDay}',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `��������ʱ��`
	,t_merage.BoxSku `����boxsku`
	,t_merage.person `��Ӫ��Ա`
	,t2.ProductName `��Ʒ����`
	,t2.ProductStatus `��Ʒ״̬`
	,t2.CategoryPathByChineseName `��Ʒ��Ŀ`
	,round(FBA���۶�,2) as 'FBA���۶�'
	,round(FBM���۶�,2) as 'FBM���۶�'
	,round(���۶�,2) as '���۶�'
	,round(�����,2) '�����' 
	,round(ë����,3) `ë����`
	,�����滨��
	,round(`�վ�������`,1) �վ������� 
	,�˿���˿� as �˿���
	,round(�˿���˿�/���۶�,4) '�˿���'
	,round(�����滨��,2) as '��滨��'
	,round(�����滨��/���۶�,4) '��滨��ռ��'
	,round(Acost,4) as 'Acost'
	,round(������۶�/���۶�,4) '���ҵ��ռ��'
	,round(�������,4) as '�������'
	,round(���ת����,4) as '���ת����'
	,exp '�ع���'
	,clk '�����'
	,round(�ÿ���)as '�ÿ���'
--  ,�ÿ�����
-- 	,round(�ÿ�����/�ÿ���,4) '�ÿ�ת����'
-- 	,round((�ÿ���-clk)/�ÿ���,4) '��Ȼ����ռ��' 
from t_merage 
left join t2 on t2.boxsku = t_merage.boxsku
where t_merage.BoxSku <> 'ShopFee' 
order by t2.boxsku 
