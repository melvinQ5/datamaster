

with epp as ( -- sku 
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
-- where CreationTime  >= '${StartDay}'
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '${StartDay}'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='��ٻ�'
group by SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)
)
-- select * from epp 


,t_list as ( -- ����ʱ����2��1������
select wl.SPU ,wl.SKU ,PublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
	,DATE_ADD(epp.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
from wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join epp on wl.sku = epp.sku 
where 
	PublicationDate>= '${StartDay}' and PublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
		and NodePathName in ('��η�-�ɶ�������','���Ԫ-�ɶ�������')
)

,t_orde as (  
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount
	,wo.Product_SPU as SPU ,PayTime
	, timestampdiff(SECOND,DevelopLastAuditTime,PayTime)/86400 as ord_days 
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join epp on wo.Product_SPU = epp.spu 
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
	and ms.Department = '��ٻ�' 
	and NodePathName in ('��η�-�ɶ�������','���Ԫ-�ɶ�������')
)

,t_list_stat as ( -- ����ͳ��
select t_list.SPU ,min_pub_date
	,count(distinct case when min_pub_date < DATE_ADD(DevelopLastAuditTime,interval 3 day) then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when min_pub_date < DATE_ADD(DevelopLastAuditTime,interval 7 day) then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when min_pub_date < DATE_ADD(DevelopLastAuditTime,interval 15 day) then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode,t_list.asin) ) list_cnt
from t_list 
left join (
	select SPU ,min(PublicationDate) as min_pub_date 
	from t_list group by SPU
	) tmp 
	on t_list.SPU = tmp.SPU 
group by t_list.SPU ,min_pub_date
)
-- select * from t_list_stat

,t_ord_list_stat as (
select t_orde.SPU 
	,count(distinct concat(t_orde.SellerSKU,t_orde.ShopCode,t_orde.asin)) `�׵�30���ڳ���������`
from t_orde
join (
	select spu ,min(PublicationDate) as min_pub_date from t_list group by spu
	) tmp 
	on tmp.spu = t_orde.spu
where PayTime <= DATE_ADD(min_pub_date,interval 30 day)
group by t_orde.SPU 
)


,t_ad as ( 
select t_list.SPU, asa.AdActivityName, asa.CreatedTime, asa.ShopCode ,asa.Asin , asa.Clicks, asa.Exposure, asa.TotalSale7DayUnit
	, DevelopLastAuditTime
	, timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime)/86400 as ad_days -- ���
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 7*86400 then '��' else '��' end `�Ƿ�7��`
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 14 then '��' else '��' end `�Ƿ�14��`
	, case when 0 < timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) and timestampdiff(SECOND,DevelopLastAuditTime,asa.CreatedTime) <= 30 then '��' else '��' end `�Ƿ�30��`
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU and t_list.SellerSKU <> ''
where asa.CreatedTime >= '${StartDay}'
)

,t_ad_stat as (
select tmp.* 
	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `30������`
	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `7��ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `14��ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `30��ת����`
from 
	( select SPU
	-- �ع���
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then Exposure end)) as ad30_sku_Exposure
			-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then Clicks end)) as ad30_sku_Clicks
			-- ����	
		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end)) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end)) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 30 then TotalSale7DayUnit end)) as ad30_sku_TotalSale7DayUnit
		from t_ad  group by SPU
	) tmp
)
-- select * from t_ad_stat 

,t_orde_stat as (
select SPU 
	,sum( case when 0 < ord_days and ord_days <= 7 then TotalGross end ) TotalGross_in7d
	,sum( case when 0 < ord_days and ord_days <= 14 then TotalGross end ) TotalGross_in14d
	,sum( case when 0 < ord_days and ord_days <= 30 then TotalGross end ) TotalGross_in30d
-- 	,sum(TotalGross) TotalGross
	,round( count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}'),4) orders_daily
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30�����������`
from t_orde 
group by SPU 
)
-- 5207230
,t_merage as (
select epp.spu 
	,ProductName 
	,DevelopUserName `������Ա`
	,ProductStatus `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,DATE_ADD(CreationTime,interval - 8 hour) `���ʱ��`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) `����ʱ��`
	,min_pub_date `�״ο���ʱ��`
	,list_cnt_in3d `3���ڿ�������`
	,list_cnt_in7d `7���ڿ�������`
	,list_cnt_in15d `15���ڿ�������`
	,list_cnt_UK `UK����������`
	,list_cnt_DE `DE����������`
	,list_cnt_FR `FR����������`
	,list_cnt_US `US����������`
	,list_cnt `��������`
	,ad7_sku_Exposure `7���ع�`
	,ad14_sku_Exposure `14���ع�`
	,ad30_sku_Exposure `30���ع�`
	,ad7_sku_Clicks `7����` 
	,ad14_sku_Clicks `14����`
	,ad30_sku_Clicks `30����`
	,`7������`
	,`14������`
	,`30������`
	,ad7_sku_TotalSale7DayUnit `7��������`
	,ad14_sku_TotalSale7DayUnit `14��������`
	,ad30_sku_TotalSale7DayUnit `30��������`
	,`7��ת����`
	,`14��ת����`
	,`30��ת����`
	,TotalGross_in7d `7�����۶�`
	,TotalGross_in14d `14�����۶�`
	,TotalGross_in30d `30�����۶�`
	,orders_daily `�վ�������`
	,Profit_rate `ë����`
	,`�׵�30���ڳ���������`
-- 	,round( `�׵�30���ڳ���������` / list_cnt ,40) `30�����ӳ�����`
from (select spu from epp group by spu ) epp 
left join 
	(select Spu ,CreationTime ,DevelopLastAuditTime,ProductName ,DevelopUserName
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
	from erp_product_products wp where IsMatrix = 1 
	) epp_spu on epp.SPU =epp_spu.spu
left join (
	select SPU ,GROUP_CONCAT( case when TortType is null then 'δ���' else TortType end ) TortType 
	from ( select SPU ,TortType
		from import_data.wt_products 
		where IsDeleted =0 and CreationTime  >= '${StartDay}' and ProjectTeam='��ٻ�' 
		group by SPU ,TortType ) ta
	group by SPU
	) epp_spu_Tort on epp.SPU =epp_spu_Tort.spu 
left join t_list_stat on epp.spu =t_list_stat.spu
left join t_ad_stat on epp.spu =t_ad_stat.spu
left join t_orde_stat on epp.spu =t_orde_stat.spu 
left join t_ord_list_stat on epp.spu =t_ord_list_stat.spu
)

-- select count(1)
select * 
from t_merage
order by SPU
