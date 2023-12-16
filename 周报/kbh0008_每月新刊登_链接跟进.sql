
with t_prod as (
select wp.sku ,case when TortType is null then 'δ���' else TortType end TortType ,Festival ,Artist ,Editor
		,ProductName ,DevelopUserName , DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
        ,case when vknp.sku is null then '��Ʒ' else '��Ʒ' end as ����Ʒ
		from import_data.wt_products wp
		left join view_kbp_new_products vknp on wp.sku =vknp.sku
		where IsDeleted =0  and ProjectTeam='��ٻ�'
)
-- select * from epp

,t_elem as ( -- Ԫ��ӳ�����С������ SKU+NAME
select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.sku
)

,t_elem_unique as (
select * from (
select * ,ROW_NUMBER () over (partition by spu order by priority)  sort
    from (
    select distinct eppaea.spu
        ,case when mt.c2 is null then 99999 else c1+0 end as priority
        ,case when mt.c2 is null then '�������ȼ�����' else Name end as ele_name_unique
    from import_data.erp_product_product_associated_element_attributes eppaea
    left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
    left join manual_table mt on mt.c2 = eppea.Name and handlename='��Ʒ��Ԫ�����ȼ�231018' -- 231017��ɸ���һ�����ȼ�˳��
    ) t1
) t2
where sort = 1
)
-- select * from pre_ele where spu =1009759

,t_list as (
select wl.SPU ,wl.SKU ,wl.BoxSku , wl.MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin
	,AccountCode  ,ms.Site
	,ms.SellUserName  ,ms.NodePathName
	,ele_name_group ,ele_name_priority
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
left join view_kbh_element vke on wl.SKU = vke.sku
where
	MinPublicationDate >= '${StartDay}'
	and MinPublicationDate < '${NextStartDay}'
	and wl.IsDeleted = 0
	and ms.Department = '��ٻ�'
	and NodePathName regexp '${team}'
    and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
)

-- ����Ż����ͣ�2����3�����ϣ��͵���20��������
,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode ,asin
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
where
	PayTime >='${StartDay}' and PayTime<'${NextStartDay}'  and TransactionType = '����'
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'
	and NodePathName regexp '${team}'
)

,t_orde_stat as (
select shopcode  ,sellersku
	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalGross/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalGross/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalGross/ExchangeUSD end ),2) TotalGross_in30d

	,round(sum( case when 0 < ord_days and ord_days <= 7 then TotalProfit /ExchangeUSD end ),2) TotalProfit_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then TotalProfit/ExchangeUSD end ),2) TotalProfit_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then TotalProfit/ExchangeUSD end ),2) TotalProfit_in30d

	,count( distinct PlatOrderNumber ) orders_total
	,round(sum(TotalGross/ExchangeUSD),2 ) TotalGross
  	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
from t_orde
group by shopcode  ,sellersku
)
-- select *
-- from t_orde_stat

,t_ad as (
select *,case when pre_ad_days < 0 then 0.1 else pre_ad_days end ad_days -- ���ڹ��ʱ�������״ο���ʱ�䣬��������ϴ
from (
select t_list.sku ,AdSpend ,AdSales , AdSaleUnits , AdClicks, AdExposure
	, waad.GenerateDate, waad.ShopCode ,waad.Asin  ,waad.SellerSKU
	, timestampdiff(SECOND,MinPublicationDate,waad.GenerateDate)/86400 as pre_ad_days -- ���Ǻ�14����
	, timestampdiff(SECOND,waad.GenerateDate,'${NextStartDay}')/86400  as ad_days_in14d  -- ��14��
    , case when GenerateDate =  date_add( '${NextStartDay}',interval -2 day)
        then MaxEnabledBidUSD end ������bid_���� -- ��һ������������Ϊ���¾��� -- ���ڼ�����bid
    , MaxBidUSD  -- �������7�վ�
from t_list
join import_data.wt_adserving_amazon_daily waad on t_list.ShopCode = waad.ShopCode and t_list.SellerSKU = waad.SellerSKU
where waad.GenerateDate >= '${StartDay}' and  waad.GenerateDate < '${NextStartDay}'
) t1
)


, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�ۼƹ������` , round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `����7��������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `����14��������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `�ۼƹ��ת����`, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `����7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `����14����ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `�ۼ�ROAS` , round(ad7_TotalSale7Day/ad7_Spend,2) as `����7��ROAS`, round(ad14_TotalSale7Day/ad14_Spend,2) as `����14��ROAS`
	, round(ad_Spend/ad_TotalSale7Day,2) as `�ۼ�ACOS`, round(ad7_Spend/ad7_TotalSale7Day,2) as `����7��ACOS`, round(ad14_Spend/ad14_TotalSale7Day,2) as `����14��ACOS`
	, round(ad_sku_Clicks_in14d/ad_sku_Exposure_in14d,4) as `��14��������`
	, round(ad_sku_TotalSale7DayUnit_in14d/ad_sku_Clicks_in14d,6) as `��14����ת����`
	, round(ad_Spend_in14d/ad_sku_Clicks_in14d,6) as `��14��CPC`

from
	( select shopcode  ,sellersku
		-- �ع���
		, round(sum(case when 0 <= ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 <= ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days_in14d and ad_days_in14d <= 14 then AdExposure end)) as ad_sku_Exposure_in14d
		, round(sum(AdExposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSpend end),2) as ad7_Spend
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSpend end),2) as ad14_Spend
		, round(sum(case when 0 < ad_days_in14d and ad_days_in14d <= 14 then AdSpend end),2) as ad_Spend_in14d
		, round(sum( AdSpend ),2) as ad_Spend
		-- ������۶�
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSales end),2) as ad7_TotalSale7Day
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSales end),2) as ad14_TotalSale7Day
		, round(sum(case when 0 < ad_days_in14d and ad_days_in14d <= 14 then AdSales end),2) as ad_TotalSale7Day_in14d
		, round(sum(AdSales),2) as ad_TotalSale7Day
		-- �������
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end),2) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end),2) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days_in14d and ad_days_in14d <= 14 then AdSaleUnits end),2) as ad_sku_TotalSale7DayUnit_in14d
		, round(sum(AdSaleUnits),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days_in14d and ad_days_in14d <= 14 then AdClicks end)) as ad_sku_Clicks_in14d
		, round(sum(AdClicks)) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku
	) tmp
)
-- select * from t_ad_stat where spu = 5203342


,t_ad_bid as (
select waad.ShopCode ,waad.SellerSku
    ,max( case when GenerateDate = date_add(  '${NextStartDay}',interval -2 day ) then MaxEnabledBidUSD end  ) `�����bid`
    ,max( case when GenerateDate = date_add(  '${NextStartDay}',interval -2-7 day ) then MaxEnabledBidUSD end  ) `�����bid_7��ǰ`
    ,round( avg( case when GenerateDate >= date_add(  '${NextStartDay}',interval -2-7 day ) and  GenerateDate <  date_add(  '${NextStartDay}',interval -2 day ) then MaxBidUSD end ) ,2 ) 7��ƽ��bid
    ,round( avg( case when GenerateDate >= date_add(  '${NextStartDay}',interval -2-7-7 day ) and  GenerateDate <  date_add(  '${NextStartDay}',interval -2-7 day ) then MaxBidUSD end ) ,2 ) 7��ƽ��bid_����
from t_list
join import_data.wt_adserving_amazon_daily waad on t_list.ShopCode = waad.ShopCode and t_list.SellerSKU = waad.SellerSKU
where waad.GenerateDate >=  date_add(  '${StartDay}',interval -2-7 day)  and  waad.GenerateDate < '${NextStartDay}'
group by waad.ShopCode ,waad.SellerSku
)


,t_merage as (
select
	replace(concat(right(date('${StartDay}'),5),'��',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,case when '${NextStartDay}' = current_date() then replace(concat(right(date('${StartDay}'),5),'��',right(date(date_add('${NextStartDay}',-2)),5)),'-','')
	    else  replace(concat(right(date('${StartDay}'),5),'��',right(date(date_add('${NextStartDay}',-1)),5)),'-','')
    end as `���ʱ�䷶Χ`
	,left(t_prod.DevelopLastAuditTime,7) `��Ʒ�����·�`

	,t_list.shopcode
	,t_list.sellersku `����sku`
	,t_list.asin
	,t_list.site
	,t_list.AccountCode
	,t_list.NodePathName `�����Ŷ�`
	,t_list.SellUserName `��ѡҵ��Ա`

	,MinPublicationDate `�����״ο���ʱ��`
	,'-' `�������`

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
	,round(ad_Spend/TotalGross,4) `�ۼƹ�滨��ռ��`
	,ad7_Spend `����7���滨��`
	,ad14_Spend `����14���滨��`

	,ad_TotalSale7Day `�ۼƹ�����۶�`
	,ad7_TotalSale7Day `����7�������۶�`
	,ad14_TotalSale7Day `����14�������۶�`

	,ad_sku_TotalSale7DayUnit `�ۼƹ������`
	,ad7_sku_TotalSale7DayUnit `����7��������`
	,ad14_sku_TotalSale7DayUnit `����14��������`

	,ad_sku_Clicks `�ۼƵ����`
	,ad7_sku_Clicks `����7������`
	,ad14_sku_Clicks `����14������`

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

	,TotalGross_in7d `����7�����۶�`
	,TotalGross_in14d `����14�����۶�`
	,TotalGross_in30d `����30�����۶�`

	,TotalProfit_in7d `����7�������`
	,TotalProfit_in14d `����14�������`
	,TotalProfit_in30d `����30�������`

	,round(TotalProfit_in7d/TotalGross_in7d,2) `����7��ë����`
	,round(TotalProfit_in14d/TotalGross_in14d,2) `����14��ë����`
	,round(TotalProfit_in30d/TotalGross_in30d,2) `����30��ë����`

 	,TotalGross `�ۼ����۶�`
 	,TotalProfit `�ۼ������`
 	,round(TotalProfit/TotalGross,2) `�ۼ�ë����`

	,t_list.spu
	,t_list.sku
	,t_list.boxsku
	,ProductName
	,ProductStatus `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,Festival `���ڽ���`
	,ele_name_group `Ԫ��`
	,t_prod.DevelopLastAuditTime `��Ʒ����ʱ��`
	,t_prod.DevelopUserName `������Ա`
    ,ele_name_priority `���ȼ�Ԫ��`
    ,t_prod.����Ʒ
    ,left(t_prod.DevelopLastAuditTime,7) `��������`
    ,`�����bid`
    ,`�����bid_7��ǰ`
    ,`�����bid` - `�����bid_7��ǰ` as ��bid֮��
    ,7��ƽ��bid
    ,7��ƽ��bid_����
    ,`7��ƽ��bid` - `7��ƽ��bid_����` as 7�վ�bid֮��
from t_list
left join t_prod on t_list.sku = t_prod.sku
left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU
left join t_orde_stat on t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU
left join t_ad_bid on t_list.ShopCode = t_ad_bid.ShopCode and t_list.SellerSKU = t_ad_bid.SellerSKU
)

-- select count(1)
select * from t_merage
-- where   `����sku` = 'TUTORVRM9PB39' ,ele_name_group ,ele_name_priority