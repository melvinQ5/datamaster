
/*
-- ÿ�ܶ� ���ܶ������õ�����һ�ܹ�����ݣ�
���Ӿ�Ӫ��ǩ���ͣ�
    ��Ʒ1 '��14��3��+'
    ��Ʒ2 '���˷ѿ͵�20usd�ҽ�14��2��+'
    ȫƷ '��30���վ�0.5��'
    ��Ʒ '���ܳ���������4��_��_����5��ͬʱ���ȵ�����1.5��'
        1 ������4��������ڳ���
        2 ���ܳ���5�����ϣ�ͬʱ��������������1.5������
*/

with t_prod as ( -- ��Ʒ:3�º�����
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-08-01' 
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

,t_list as ( -- 3���������������
select wl.SPU ,wl.SKU ,BoxSku ,MinPublicationDate ,MarketType ,SellerSKU ,ShopCode ,asin 
	,DATE_ADD(t_prod.DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
left join t_elem on wl.sku =t_elem .sku 
where 
	MinPublicationDate>= '2023-08-01' 
	and MinPublicationDate <'${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '��ٻ�' 
	and NodePathName regexp '${team}'
)

,t_orde as ( 
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU 
	,wo.Product_Sku  as SKU 
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName 
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 20 then 1 else 0 end as isOver20usd
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t_prod on wo.Product_SKU = t_prod.sKU
where 
	PayTime >= '2023-08-01' and PayTime < '${NextStartDay}'
	and wo.IsDeleted=0 
	and ms.Department = '��ٻ�'  and TransactionType = '����'
    and NodePathName regexp '${team}'
)

,t_orde_week_stat as ( -- ����ͳ�ƶ���
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_total
	,count( distinct case when PayTime >=date_add('${NextStartDay}', INTERVAL -30 DAY) then PlatOrderNumber end ) orders_total_in30d
	,round( sum(salecount),2 ) salecount
	,round( sum(TotalGross/ExchangeUSD),2 ) TotalGross
	,round(sum(TotalProfit/ExchangeUSD),2) TotalProfit
	,round( sum(TotalProfit) / sum(TotalGross) ,4 ) Profit_rate
from t_orde
left join dim_date on dim_date.full_date = date(t_orde.PayTime)
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)
-- select * from t_orde_week_stat;


,t_orde_stat as ( -- ����ɸ����
select shopcode  ,sellersku 
	,count(distinct case when timestampdiff(SECOND,paytime,'${NextStartDay}')/86400  <= 14
		then PlatOrderNumber end) orders_in14d -- 14���ڶ�����
	,count( distinct case when isOver20usd = 1
		then PlatOrderNumber end ) orders_over_20usd -- ���˷ѳ�20���𶩵���
from t_orde 
group by shopcode  ,sellersku 
)

,t_ad as ( -- �Ż����Ӷ�Ӧ�������
select t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	, DevelopLastAuditTime
	, timestampdiff(SECOND,MinPublicationDate,asa.CreatedTime)/86400 as ad_days -- ��� - ����
	, dim_date.week_num_in_year ad_stat_week
	, list_type
from (
	select shopcode  ,sellersku ,GROUP_CONCAT(list_type) list_type
	from (
		select shopcode  ,sellersku  ,'��14��3��+' list_type
		from t_orde_stat where orders_in14d >= 3 -- 14���ڳ�3��
		union 
		select shopcode  ,sellersku  ,'���˷ѿ͵�20usd�ҽ�14��2��+' list_type
		from t_orde_stat where orders_over_20usd > 0 and  orders_in14d >= 2
		) tb
	group by shopcode  ,sellersku
	) ta 
join t_list on t_list.ShopCode = ta.ShopCode and t_list.SellerSKU = ta.SellerSKU 
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU
left join dim_date on dim_date.full_date = asa.CreatedTime
where asa.CreatedTime >= '2023-08-01' and  asa.CreatedTime < '${NextStartDay}'
)
-- select * from t_ad;

, t_ad_name as ( -- �������
select shopcode  ,sellersku ,ad_stat_week
	, GROUP_CONCAT(AdActivityName) AdActivityName
from (select shopcode  ,sellersku  ,ad_stat_week,AdActivityName from t_ad  group by shopcode  ,sellersku ,ad_stat_week ,AdActivityName) tb 
group by shopcode  ,sellersku ,ad_stat_week
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `�ۼƹ������` 
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `�ۼƹ��ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as `�ۼ�ROAS` 
	, round(ad_Spend/ad_TotalSale7Day,2) as `�ۼ�ACOS`
from 
	( select shopcode  ,sellersku ,ad_stat_week ,list_type
		-- �ع���
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(cost*ExchangeUSD),2) as ad_Spend
		-- ������۶�
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- �������	
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(Clicks)) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku ,ad_stat_week ,list_type
	) tmp  
)
-- select * from t_ad_stat 
-- where spu = 5203342 

,t_merage as (
select
    list_type `��Ӫ�Ż���ǩ`
	,t_list.AccountCode `�˺�`
	,t_list.NodePathName `�����Ŷ�`
	,t_list.SellUserName `��ѡҵ��Ա`
	,t_list.site `վ��`
	,t_list.shopcode `���̼���`
	,t_list.sellersku `����sku`
	,t_list.asin
	,t_ad_stat.ad_stat_week `���ͳ����`
--      ���ӵ�����һ ��
	,AdActivityName `�������`
	,ad_sku_Exposure `�ۼ��ع�`
	,ad_Spend `�ۼƹ�滨��`
	,round(ad_Spend/TotalGross,4) `��滨��ռ��`
	,ad_TotalSale7Day `�ۼƹ�����۶�`
	,ad_sku_TotalSale7DayUnit `�ۼƹ������`
	,ad_sku_Clicks `�ۼƵ��` 
	,`�ۼƹ������`
	,`�ۼƹ��ת����`
	,`�ۼ�ROAS`
	,`�ۼ�ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `�ۼ�CPC`
-- 	,orders_daily `�վ�������`
 	,TotalGross `�ۼ����۶�`
 	,TotalProfit `�ۼ������`
 	,Profit_rate `ë����`
 	,orders_total `�ۼƶ�����`
	,salecount `�ۼ�����`
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
	,replace(concat(right('2023-08-01' ,5),'��',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `����ʱ�䷶Χ`
	,replace(concat(right('2023-08-01' ,5),'��',right(to_date(date_add('${NextStartDay}',-2)),5)),'-','') `���ʱ�䷶Χ`
	,left(ta.DevelopLastAuditTime,7) `��Ʒ�����·�`
from t_ad_stat
left join t_ad_name on  t_ad_stat.ShopCode = t_ad_name.ShopCode and t_ad_stat.SellerSKU = t_ad_name.SellerSKU and t_ad_stat.ad_stat_week = t_ad_name.ad_stat_week
left join t_list on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
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
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
left join t_orde_week_stat on  t_ad_stat.ShopCode = t_orde_week_stat.ShopCode and t_ad_stat.SellerSKU = t_orde_week_stat.SellerSKU 
	and t_ad_stat.ad_stat_week = t_orde_week_stat.pay_week
)

-- select count(1)
select * from t_merage