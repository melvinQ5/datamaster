-- ������ ��ʵ���Ϊһ������ ��ע�ͷ������ֶ�

with t_prod as ( -- ��Ʒ:3�º�����
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' 
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='��ٻ�' and Status = 10
)
-- select * from epp 

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join t_prod on eppaea.sku = t_prod.sku 
group by eppaea.sku 
)

,t_list as ( 
select wl.SPU ,wl.SKU ,BoxSku , wl.MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,DATE_ADD(t_prod.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
left join t_elem on wl.sku =t_elem .sku 
where 
	MinPublicationDate >= '2023-03-01'
	and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
-- 	and NodePathName in ('��Ӫ��-Ȫ��1��','��Ӫ��-Ȫ��2��','��Ӫ��-Ȫ��3��')
	and NodePathName in ('��η�-�ɶ�������','���Ԫ-�ɶ�������')
)

-- ����Ż����ͣ�2����3�����ϣ��͵���20��������
,t_orde as ( 
select OrderNumber ,wo.PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode ,asin 
	,ExchangeUSD,TransactionType,wo.SellerSku,RefundAmount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,timestampdiff(second,MinPublicationDate,PayTime)/86400 as ord_days -- ��������Ϊ���翯��ʱ��
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
left join (
	select shopcode,SellerSku,MinPublicationDate from t_list group by shopcode,SellerSku,MinPublicationDate 
	) t_list
	on wo.shopcode = t_list.shopcode and wo.SellerSku = t_list.SellerSku 
join t_prod on wo.Product_SKU = t_prod.sKU
left join (select PlatOrderNumber from wt_orderdetails 
	where FeeGross > 0 
		and PayTime >= '2023-03-01' and PayTime < '${NextStartDay}'
		and IsDeleted=0 
	group by PlatOrderNumber 
	) tb on wo.PlatOrderNumber =tb.PlatOrderNumber
where 
	PayTime >= '2023-03-01' and PayTime < '${NextStartDay}'
	and wo.IsDeleted=0 
	and ms.Department = '��ٻ�' 
-- 	and NodePathName in ('��Ӫ��-Ȫ��1��','��Ӫ��-Ȫ��2��','��Ӫ��-Ȫ��3��')
	and NodePathName in ('��η�-�ɶ�������','���Ԫ-�ɶ�������')
	and tb.PlatOrderNumber is null  -- �޳��˷ѵ�
)
-- select count(1) from t_orde  

,t_orde_stat as (
select shopcode  ,sellersku  
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
	
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalProfit /ExchangeUSD end ),2) TotalProfit_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalProfit/ExchangeUSD end ),2) TotalProfit_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalProfit/ExchangeUSD end ),2) TotalProfit_in30d
	
	,count( distinct PlatOrderNumber ) orders_total
	,round( sum( case when PayTime >= '2023-04-01' then TotalGross/ExchangeUSD end ),2 ) TotalGross_Q2
	,round(sum( case when PayTime >= '2023-04-01' then TotalProfit/ExchangeUSD end ),2) TotalProfit_Q2
	
	,count(distinct case when timestampdiff(SECOND,paytime,'${NextStartDay}')/86400  <= 30
		then PlatOrderNumber end) orders_in30d -- 30���ڶ�����
from t_orde 
group by shopcode  ,sellersku  
)
-- select *
-- from t_orde_stat

,t_ad as ( 
select t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, DevelopLastAuditTime
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days -- ��� - ����
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= '2023-03-01' and  asa.CreatedTime < '${NextStartDay}'
)

, t_ad_name as ( -- �������
select shopcode  ,sellersku 
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,AdActivityName from t_ad  group by shopcode  ,sellersku  ,AdActivityName) tb 
group by shopcode  ,sellersku 
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `Q2_�������` 
-- 	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7��������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,4) as `Q2_���ת����`
-- 	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `Q2_ROAS` 
-- 	, round(ad7_TotalSale7Day/ad7_Spend,2) as `����7��ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `����14��ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `Q2_ACOS`
-- 	, round(ad7_Spend/ad7_TotalSale7Day,2) as `����7��ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `����14��ACOS`
	, round(ad_TotalSale7DayUnit_in30d/ad_Clicks_in30d,6) as `��30����ת����`
	, round(ad_TotalSale7Day_in30d/ad_Spend_in30d,4) as `��30��ROAS`
from 
	( select shopcode  ,sellersku 
		-- �ع���
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(case when CreatedTime > '2023-04-01' then Exposure end )) as ad_sku_Exposure
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then Exposure end )) as ad_Exposure_in30d
		-- ��滨��
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then cost*ExchangeUSD end),2) as ad7_Spend
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then cost*ExchangeUSD end),2) as ad14_Spend
		, round(sum(case when CreatedTime > '2023-04-01' then cost*ExchangeUSD end ),2) as ad_Spend
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then cost*ExchangeUSD end ),2) as ad_Spend_in30d
		-- ������۶�
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(case when CreatedTime > '2023-04-01' then TotalSale7Day end),2) as ad_TotalSale7Day
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then TotalSale7Day end ),2) as ad_TotalSale7Day_in30d
		-- �������	
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when CreatedTime > '2023-04-01' then TotalSale7DayUnit end ),2) as ad_sku_TotalSale7DayUnit
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then TotalSale7DayUnit end )) as ad_TotalSale7DayUnit_in30d
		-- �����
-- 		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
-- 		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(case when CreatedTime > '2023-04-01' then Clicks end)) as ad_sku_Clicks
		, round(sum(case when timestampdiff(SECOND,CreatedTime,'${NextStartDay}')/86400  <= 30 then Clicks end )) as ad_Clicks_in30d
		from t_ad  group by shopcode  ,sellersku 
	) tmp  
)
-- select * from t_ad_stat where spu = 5203342 


,t_merage as (
select 
	replace(concat(right('2023-03-01',5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right('2023-03-01',5),'��',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `���ʱ�䷶Χ`
	,left(ta.DevelopLastAuditTime,7) `��Ʒ�����·�`
	
	,t_list.shopcode
	,t_list.sellersku `����sku`
	,t_list.asin 
	,t_list.site 
	,t_list.AccountCode
	,t_list.NodePathName `�����Ŷ�`
	,t_list.SellUserName `��ѡҵ��Ա`
	
-- 	,to_date(DATE_ADD(MinPublicationDate,interval - 8 hour)) `�����״ο���ʱ��`
	,AdActivityName `ƴ�ӹ������`
	
	,orders_in30d `��30�충����`
	,��30����ת����
	,��30��ROAS
	,ad_TotalSale7DayUnit_in30d `��30��������`
	,ad_Clicks_in30d `��30��������`
	,ad_Spend_in30d `��30���滨��`
	,ad_TotalSale7Day_in30d `��30�������۶�`
	
	,ad_sku_Exposure `Q2_�ع���`
-- 	,ad7_sku_Exposure `����7���ع���`
-- 	,ad14_sku_Exposure `����14���ع���`
	
	,ad_Spend `Q2_��滨��`
-- 	,ad7_Spend `����7���滨��`
-- 	,ad14_Spend `����14���滨��`
	 
	,ad_TotalSale7Day `Q2_������۶�`
-- 	,ad7_TotalSale7Day `����7�������۶�`
-- 	,ad14_TotalSale7Day `����14�������۶�`
	
	,ad_sku_TotalSale7DayUnit `Q2_�������`
-- 	,ad7_sku_TotalSale7DayUnit `����7��������`
-- 	,ad14_sku_TotalSale7DayUnit `����14��������`
	
	,ad_sku_Clicks `Q2_�����` 
-- 	,ad7_sku_Clicks `����7������` 
-- 	,ad14_sku_Clicks `����14������`
	
	,`Q2_�������`
-- 	,`����7��������`
-- 	,`����14��������`
	
	,`Q2_���ת����`
-- 	,`����7����ת����`
-- 	,`����14����ת����`
	
	,`Q2_ROAS`
-- 	,`����7��ROAS`
-- 	,`����14��ROAS`
	
	,`Q2_ACOS`
-- 	,`����7��ACOS`
-- 	,`����14��ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `Q2_CPC`
-- 	,round(ad7_Spend/ad7_sku_Clicks,2) `����7��CPC`
-- 	,round(ad14_Spend/ad14_sku_Clicks,2) `����14��CPC`

-- 	,TotalGross_in7d `����7�����۶�usd`
-- 	,TotalGross_in14d `����14�����۶�usd`
-- 	,orders_daily `�վ�������`

-- 	,TotalGross_in7d `����7�����۶�`
-- 	,TotalGross_in14d `����14�����۶�`
-- 	,TotalGross_in30d `����30�����۶�`
-- 	
-- 	,TotalProfit_in7d `����7�������`
-- 	,TotalProfit_in14d `����14�������`
-- 	,TotalProfit_in30d `����30�������`
-- 	
-- 	,round(TotalProfit_in7d/TotalGross_in7d,2) `����7��ë����`
-- 	,round(TotalProfit_in14d/TotalGross_in14d,2) `����14��ë����`
-- 	,round(TotalProfit_in30d/TotalGross_in30d,2) `����30��ë����`
-- 	
 	,TotalGross_Q2 `Q2���۶�`
 	,TotalProfit_Q2 `Q2�����`
 	,round(TotalProfit_Q2/TotalGross_Q2,2) `Q2ë����`

	,t_list.spu
	,t_list.sku 
	,t_list.boxsku 
	,ProductName 
	,ProductStatus `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,Festival `���ڽ���`
	,ele_name `Ԫ��` 
	,ta.DevelopLastAuditTime `��Ʒ����ʱ��`
	,ta.DevelopUserName `������Ա`
from t_list
-- join (
-- 	select shopcode  ,sellersku 
-- 	from t_orde_stat where orders_in30d >= 0 -- 30���ڳ�3��
-- 	group by shopcode  ,sellersku
-- 	) ta on t_list.shopcode = ta.shopcode and t_list.sellersku = ta.sellersku 
left join t_prod on t_list.sku = t_prod.sku 
left join (
	select sku ,case when TortType is null then 'δ���' else TortType end TortType ,Festival ,Artist ,Editor 
		,ProductName ,DevelopUserName ,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) as DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
		from import_data.wt_products wp
		where IsDeleted =0  and ProjectTeam='��ٻ�' 
	) ta on t_list.sku =ta.sku 
left join t_ad_stat on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
left join t_ad_name on  t_list.ShopCode = t_ad_name.ShopCode and t_list.SellerSKU = t_ad_name.SellerSKU 
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
)


-- select count(1)
select * from t_merage 

