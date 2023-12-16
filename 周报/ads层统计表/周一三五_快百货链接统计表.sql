-- 4�¹����ϸ����

with t_prod as ( 
select SKU ,SPU ,BoxSKU  ,DevelopLastAuditTime
from import_data.erp_product_products 
where DevelopLastAuditTime  >= '${StartDay}'
	and DevelopLastAuditTime < '${NextStartDay}'
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

,t_list as ( -- ���¿����������� ����������Ʒ��
select wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
left join t_elem on wl.sku =t_elem .sku 
where 
	MinPublicationDate >= '${StartDay}' 
	and MinPublicationDate < '${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
	and NodePathName regexp '${team}'
    and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
)

,t_orde as ( -- ���³��� ����������Ʒ��
select PlatOrderNumber ,TotalGross,TotalProfit
	,ExchangeUSD ,shopcode  ,sellersku  ,OrderStatus 
from import_data.wt_orderdetails wo 
join mysql_store ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and OrderStatus != '����' 
	and ms.Department = '��ٻ�' 
	and NodePathName regexp '${team}'
)

,t_orde_stat as (
 select shopcode  ,sellersku  
 -- 	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
 -- 	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
 -- 	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d
 	,count( distinct PlatOrderNumber ) orders_total
 	,round( sum(TotalGross/ExchangeUSD),2 ) TotalGross
  	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
  	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
 from t_orde 
 group by shopcode  ,sellersku  
)

,t_ad as ( 
select t_list.sku, asa.AdActivityName ,campaignBudget ,abs(cost) cost,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , abs(asa.Clicks) Clicks, asa.Exposure
	,ROAS ,Acost as ACOS ,abs(spend) spend
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days -- ��� - ����
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >='${StartDay}' and asa.CreatedTime<'${NextStartDay}'
)

, t_ad_name as ( -- �������
select shopcode  ,sellersku 
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,AdActivityName from t_ad group by shopcode  ,sellersku  ,AdActivityName) tb 
group by shopcode  ,sellersku 
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�ۼƹ������` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7��������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `�ۼƹ��ת����`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `�ۼ�ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `����7��ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `����14��ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `�ۼ�ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `����7��ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `����14��ACOS`
from 
	( select shopcode  ,sellersku 
		-- �ع���
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Exposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Exposure end)) as ad14_sku_Exposure
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(case when 0 < ad_days and ad_days <= 7 then spend end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then spend end),2) as ad14_Spend
		, round(sum( spend ),2) as ad_Spend
		-- ������۶�
		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7Day end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7Day end),2) as ad14_TotalSale7Day
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- �������	
		, round(sum(case when 0 < ad_days and ad_days <= 7 then TotalSale7DayUnit end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then TotalSale7DayUnit end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then Clicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then Clicks end)) as ad14_sku_Clicks
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku 
	) tmp  
)
-- select * from t_ad_stat where spu = 5203342 


,t_merage as (
select 
	replace(concat(right(date('${StartDay}'),5),'��',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace( concat(right(date('${StartDay}'),5),'��',if(current_date()='${NextStartDay}',right(date(date_add('${NextStartDay}',-2)),5)  , right(date(date_add('${NextStartDay}',-1)),5) ) ),'-','')  `���ʱ�䷶Χ`
	,left(ta.DevelopLastAuditTime,7) `��Ʒ�����·�`
	,t_list.shopcode
	,t_list.sellersku `����sku`
	,t_list.asin 
	,t_list.site 
	,t_list.AccountCode
	,t_list.NodePathName `�����Ŷ�`
	,t_list.SellUserName `��ѡҵ��Ա`
	
	,date(MinPublicationDate) `�����״ο���ʱ��`
	,AdActivityName `�������`

    ,`��14��������`
	,`��14����ת����`
	,ad_sku_Exposure_in14d  `��14�����ع���`
	,ad_sku_Clicks_in14d    `��14��������`
	,ad_TotalSale7Day_in14d `��14�������۶�`
	,ad_Spend_in14d `��14���滨��`
	,`��14��CPC`

	,ad_sku_Exposure `�ۼ��ع���`
	,ad7_sku_Exposure `����7���ع���`
	,ad14_sku_Exposure `����14���ع���`
	
	,ad_Spend `�ۼƹ�滨��`
	,ad7_Spend `����7���滨��`
	,ad14_Spend `����14���滨��`
	
	,ad_TotalSale7Day `�ۼƹ�����۶�`
	,ad7_TotalSale7Day `����7�������۶�`
	,ad14_TotalSale7Day `����14�������۶�`
	
	,ad_sku_TotalSale7DayUnit `�ۼƹ������`
	,ad7_sku_TotalSale7DayUnit `����7��������`
	,ad14_sku_TotalSale7DayUnit `����14��������`
	
	,ad_sku_Clicks `�ۼƵ��` 
	,ad7_sku_Clicks `����7����` 
	,ad14_sku_Clicks `����14����`
	
	
	,`�ۼƹ������`
	,`����7��������`
	,`����14��������`
	
	,`�ۼƹ��ת����`
	,`����7����ת����`
	,`����14����ת����`
	
	,`�ۼ�ROAS`
	,`����7��ROAS`
	,`����14��ROAS`
	
	,`�ۼ�ACOS`
	,`����7��ACOS`
	,`����14��ACOS`
	
	,round(ad_Spend/ad_sku_Clicks,2) `�ۼ�CPC`
	,round(ad7_Spend/ad7_sku_Clicks,2) `����7��CPC`
	,round(ad14_Spend/ad14_sku_Clicks,2) `����14��CPC`

-- 	,TotalGross_in7d `����7�����۶�usd`
-- 	,TotalGross_in14d `����14�����۶�usd`
-- 	,orders_daily `�վ�������`

 	,TotalGross `�ۼ����۶�`
 	,TotalProfit `�ۼ������`
 	,Profit_rate `ë����`

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
select * 
from t_merage
