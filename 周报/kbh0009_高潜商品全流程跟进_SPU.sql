
with
t0 as (  -- ���� spu x �������� -- ��Ʒ�������򣬶�����������
select distinct spu ,PushDate ,StopPushDate ,PushSite ����վ��,PushRule ���ͱ�׼,PushUser ������ ,PushReason ��������
    ,case when '${NextStartDay}' > StopPushDate then '��' else '��' end �Ƿ����
from dep_kbh_product_level_potentail where PushDate >= '2023-10-01'  and isStopPush ='��'
)

,t_list as (  -- ���� spu x ��������
select distinct wl.SPU ,wl.SKU ,MinPublicationDate ,wl.MarketType ,wl.SellerSKU ,wl.ShopCode ,wl.asin ,CompanyCode
    ,PushDate
    ,timestampdiff(second,PushDate,MinPublicationDate)/86400 as lst_days ,ListingStatus ,ShopStatus
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
    and ms.Department = '��ٻ�' and NodePathName regexp '${team1}|${team2}'
     AND MinPublicationDate >= '${StartDay}' and MinPublicationDate < '${NextStartDay}' and IsDeleted=0
join t0 on wl.spu = t0.spu -- һ���
)

,t_list_stat as ( -- ����ͳ��
select SPU,PushDate
	,count(distinct case when lst_days > 0 and lst_days <=3 then concat(SellerSKU,ShopCode) end ) list_cnt_in3d
	,count(distinct case when lst_days > 0 and lst_days <=7 then concat(SellerSKU,ShopCode) end ) list_cnt_in7d
	,count(distinct case when lst_days > 0 and lst_days <=15 then concat(SellerSKU,ShopCode) end ) list_cnt_in15d
	,count(distinct case when lst_days > 0 and lst_days <=30 then concat(SellerSKU,ShopCode) end ) list_cnt_in30d
	,count(distinct case when lst_days > 0 and lst_days <=60 then concat(SellerSKU,ShopCode) end ) list_cnt_in60d
	,count(distinct case when lst_days > 0 and lst_days <=90 then concat(SellerSKU,ShopCode) end ) list_cnt_in90d
	,count(distinct case when lst_days > 0 and lst_days <=30 then concat(CompanyCode) end ) list_comp_cnt_in30d
	,count(distinct case when lst_days > 0 and lst_days <=60 then concat(CompanyCode) end ) list_comp_cnt_in60d
	,count(distinct case when MarketType = 'UK' then concat(SellerSKU,ShopCode) end ) list_cnt_UK
	,count(distinct case when MarketType = 'DE' then concat(SellerSKU,ShopCode) end ) list_cnt_DE
	,count(distinct case when MarketType = 'FR' then concat(SellerSKU,ShopCode) end ) list_cnt_FR
	,count(distinct case when MarketType = 'US' then concat(SellerSKU,ShopCode) end ) list_cnt_US
	,count(distinct case when MarketType = 'CA' then concat(SellerSKU,ShopCode) end ) list_cnt_CA
	,count(distinct concat(t_list.SellerSKU,t_list.ShopCode) ) list_cnt
    ,count(distinct CompanyCode ) list_CompanyCode_cnt
	,min(MinPublicationDate) as min_pub_date
from t_list
where lst_days > 0
group by SPU,PushDate
)
-- select * from t_list_stat

,t_orde as (  -- ���� spu x ��������
select
    Product_SPU as spu ,PushDate
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,wo.shopcode , wo.asin ,FeeGross
	,ExchangeUSD,TransactionType, wo.SellerSku,RefundAmount
	,wo.Product_SPU as SKU ,PayTime
	,timestampdiff(SECOND,PushDate,PayTime)/86400 as ord_days
	,timestampdiff(SECOND,PushDate,PublicationDate)/86400 as lst_days  -- �����Ƽ����¿����������۶�
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,ms.CompanyCode
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join t0 on wo.Product_Spu  = t0.spu -- һ���
where
	PayTime >= date_add('2023-10-01', interval -30 day)  -- 0703�������������ڣ���һ��ָ����Ҫ�����Ƽ�ǰ30�죬��ʹ��0703��ǰ��30����Ϊ�̶���ʼʱ�� ,��Ӱ���Ƽ���60��90��
    and PayTime < '${NextStartDay}' and wo.IsDeleted=0 and TransactionType='����'
	and ms.Department = '��ٻ�' and NodePathName regexp '${team1}|${team2}'
)


,t_orde_stat as (
select SPU,PushDate
	,round(sum( case when 0 < ord_days and ord_days <= 7 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_in7d
	,round(sum( case when 0 < ord_days and ord_days <= 14 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_in14d
	,round(sum( case when 0 < ord_days and ord_days <= 30 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_in30d
	,round(sum( case when 0 < ord_days and ord_days <= 30 and 0 < lst_days and lst_days <= 30  then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_new_list_in30d -- �Ƽ����¿��ǳ���
	,round(sum( case when 0 < ord_days and ord_days <= 60 and 0 < lst_days and lst_days <= 60  then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_new_list_in60d -- �Ƽ����¿��ǳ���
	,round(sum( case when 0 < ord_days and ord_days <= 90 and 0 < lst_days and lst_days <= 90  then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_new_list_in90d -- �Ƽ����¿��ǳ���

    ,round(sum( case when 0 < ord_days and  0 < lst_days and month(PayTime)=10 then (TotalGross)/ExchangeUSD end ),2) TotalGross_new_list_2310 -- �Ƽ����¿��ǳ���
    ,round(sum( case when 0 < ord_days and  0 < lst_days and month(PayTime)=11 then (TotalGross)/ExchangeUSD end ),2) TotalGross_new_list_2311 -- �Ƽ����¿��ǳ���
    ,round(sum( case when 0 < ord_days and  0 < lst_days and month(PayTime)=12 then (TotalGross)/ExchangeUSD end ),2) TotalGross_new_list_2312 -- �Ƽ����¿��ǳ���

     ,round(sum( case when -30 <= ord_days and ord_days < 0 then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross_bf30d

 	,count( distinct case when 0 < ord_days then CONCAT(SellerSku,shopcode) end ) od_list_total
 	,count( distinct case when 0 < ord_days and 0 < lst_days and lst_days <= 30 then CONCAT(SellerSku,shopcode) end ) od_new_list_in30d -- �Ƽ����¿��ǳ���
 	,count( distinct case when 0 < ord_days and 0 < lst_days and lst_days <= 60 then CONCAT(SellerSku,shopcode) end ) od_new_list_in60d -- �Ƽ����¿��ǳ���
 	,count( distinct case when 0 < ord_days and 0 < lst_days and lst_days <= 90 then CONCAT(SellerSku,shopcode) end ) od_new_list_in90d -- �Ƽ����¿��ǳ���
 	,count( distinct case when 0 < ord_days then companycode end ) od_companycode_total
 	,count( distinct case when 0 < ord_days then PlatOrderNumber end ) orders_total
	,round( sum( case when 0 < ord_days then (TotalGross-feegross)/ExchangeUSD end ),2) TotalGross
	,round( sum( case when 0 < ord_days then (TotalProfit-feegross)/ExchangeUSD end ),2) TotalProfit
	,round( sum( case when 0 < ord_days then (TotalProfit-feegross) end ) / sum( case when 0 < ord_days then (TotalGross-feegross) end ) ,4 ) Profit_rate
	,count( distinct case when 0 < ord_days and ord_days <= 30 then concat(shopcode,sellersku,asin) end ) `30�����������`
from t_orde
group by SPU,PushDate
)

,t_ad as (
select t0.SPU, waad.GenerateDate, waad.ShopCode ,waad.Asin , waad.AdClicks, waad.AdExposure, waad.AdSaleUnits
	, PushDate
	, timestampdiff(SECOND,PushDate,waad.GenerateDate)/86400 as ad_days -- ���
from wt_adserving_amazon_daily waad
join t0 on left(waad.sku,7) = t0.spu
where waad.GenerateDate >= '${StartDay}' AND waad.GenerateDate < '${NextStartDay}'
)

,t_ad_stat as (
select tmp.*
	, round(ad7_sku_Clicks/ad7_sku_Exposure,4) as `�Ƽ�7������`, round(ad14_sku_Clicks/ad14_sku_Exposure,4) as `�Ƽ�14������`, round(ad30_sku_Clicks/ad30_sku_Exposure,4) as `�Ƽ�30������`
	, round(ad7_sku_TotalSale7DayUnit/ad7_sku_Clicks,6) as `�Ƽ�7����ת����`, round(ad14_sku_TotalSale7DayUnit/ad14_sku_Clicks,6) as `�Ƽ�14����ת����`, round(ad30_sku_TotalSale7DayUnit/ad30_sku_Clicks,6) as `�Ƽ�30����ת����`
from
	( select  SPU,PushDate
		-- �ع���
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdExposure end)) as ad7_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdExposure end)) as ad14_sku_Exposure
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdExposure end)) as ad30_sku_Exposure
		-- �����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdClicks end)) as ad7_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdClicks end)) as ad14_sku_Clicks
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdClicks end)) as ad30_sku_Clicks
		-- ����
		, round(sum(case when 0 < ad_days and ad_days <= 7 then AdSaleUnits end)) as ad7_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 14 then AdSaleUnits end)) as ad14_sku_TotalSale7DayUnit
		, round(sum(case when 0 < ad_days and ad_days <= 30 then AdSaleUnits end)) as ad30_sku_TotalSale7DayUnit
		from t_ad  group by  SPU,PushDate
	) tmp
)


,online_companycode as (
select
    spu ,PushDate
    ,count(distinct concat(SellerSKU,ShopCode,asin) ) online_list_cnt
	,count(distinct CompanyCode ) online_list_CompanyCode_cnt
from t_list
where ShopStatus='����' and ListingStatus=1 and lst_days >=0
group by spu ,PushDate
)

,online_seller as (
select wl.spu ,ms.SellUserName
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and wl.IsDeleted = 0 and ms.ShopStatus='����' and wl.ListingStatus=1
 and NodePathName regexp '${team1}|${team2}' and ms.Department='��ٻ�'
group by wl.spu ,ms.SellUserName
)

, prod_seller as (
select spu, eaapis.SellUserName
from erp_amazon_amazon_product_in_sells eaapis
join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='��ٻ�' and wp.IsDeleted = 0
group by spu, eaapis.SellUserName
)

,prod_seller_stat  as ( select spu ,group_concat(SellUserName) prod_seller_list from  prod_seller group by spu )
,online_seller_stat  as ( select spu ,group_concat(SellUserName) online_seller_list from  online_seller group by spu )
,unonline_seller_stat  as (
select p.spu ,group_concat(p.SellUserName) unonline_seller_list
from  prod_seller p left join  online_seller o on p.spu = o.spu and o.SellUserName = p.SellUserName
where o.SellUserName is null group by p.spu )

,sa_list_stat as (
select d.spu
     ,count(distinct case when  list_level='S' then concat(asin,site) END ) as 'S������'
     ,count(distinct case when  list_level='A' then concat(asin,site) END ) as 'A������'
from dep_kbh_listing_level d
WHERE list_level REGEXP 'S|A' group by d.spu )

,t_merage as (
select t0.spu ,t0.PushDate ��������
	,epp.ProductName
    ,case when TotalGross_in30d >= 500 then '��' else '��' end as �Ƽ�30��ҵ����500usd
    ,ele_name_group Ԫ��
    ,ele_name_priority ���ȼ�Ԫ��
    ,epp.productstatus `��Ʒ״̬`

    ,dd.week_num_in_year as �Ƽ��ܴ� -- ��Ч���ڶ�Ӧ�ܴ�
    ,t0.����վ��
    ,t0.���ͱ�׼
    ,t0.������
    ,t0.��������

	,list_cnt_in3d `�Ƽ�3�����¿�������`
	,list_cnt_in7d `�Ƽ�7�����¿�������`
	,list_cnt_in15d `�Ƽ�15�����¿�������`
	,list_cnt_in30d `�Ƽ�30�����¿�������`
	,list_comp_cnt_in30d `�Ƽ�30�����¿�������`
	,list_cnt_UK `�Ƽ���UK��������`
	,list_cnt_DE `�Ƽ���DE��������`
	,list_cnt_FR `�Ƽ���FR��������`
	,list_cnt_US `�Ƽ���US��������`
	,list_cnt_CA `�Ƽ���CA��������`

	,list_cnt `�Ƽ��󿯵�����`
    ,list_CompanyCode_cnt `�Ƽ��󿯵��˺�����`
    ,online_list_cnt `�Ƽ��󿯵���������`
    ,online_list_CompanyCode_cnt `�Ƽ��󿯵������˺�����`
    ,od_list_total �Ƽ����������
    ,od_companycode_total �Ƽ�������˺���
    ,S������
    ,A������

	,ad7_sku_Exposure `�Ƽ�7���ع�`
	,ad14_sku_Exposure `�Ƽ�14���ع�`
	,ad30_sku_Exposure `�Ƽ�30���ع�`
	,ad7_sku_Clicks `�Ƽ�7����`
	,ad14_sku_Clicks `�Ƽ�14����`
	,ad30_sku_Clicks `�Ƽ�30����`
	,`�Ƽ�7������`
	,`�Ƽ�14������`
	,`�Ƽ�30������`
	,ad7_sku_TotalSale7DayUnit `�Ƽ�7��������`
	,ad14_sku_TotalSale7DayUnit `�Ƽ�14��������`
	,ad30_sku_TotalSale7DayUnit `�Ƽ�30��������`
	,`�Ƽ�7����ת����`
	,`�Ƽ�14����ת����`
	,`�Ƽ�30����ת����`
	,TotalGross_in7d `�Ƽ���7�����۶�`
	,TotalGross_in14d `�Ƽ���14�����۶�`
	,TotalGross_in30d `�Ƽ���30�����۶�`
    ,TotalGross_bf30d `�Ƽ�ǰ30�����۶�`
	,TotalGross_new_list_in30d `�Ƽ���30���¿������۶�`
    ,od_new_list_in30d �Ƽ���30���¿��ǳ���������
    ,round( od_new_list_in30d / list_cnt_in30d ,4) �Ƽ���30�������Ӷ�����
	,TotalGross_new_list_in60d `�Ƽ���60���¿������۶�`
    ,od_new_list_in60d �Ƽ���60���¿��ǳ���������
    ,round( od_new_list_in60d / list_cnt_in60d ,4) �Ƽ���60�������Ӷ�����
	,TotalGross_new_list_in90d `�Ƽ���90���¿������۶�`
    ,od_new_list_in90d �Ƽ���90���¿��ǳ���������
    ,round( od_new_list_in90d / list_cnt_in90d ,4) �Ƽ���90�������Ӷ�����

	,orders_total `�Ƽ��󶩵���`
	,TotalGross `�Ƽ������۶�`
	,TotalProfit `�Ƽ��������`
	,Profit_rate `�Ƽ���ë����`
    ,prod_seller_list SPU����������
    ,online_seller_list SPU�����˺�������
    ,unonline_seller_list SPUδ������Ա

    ,list_comp_cnt_in60d `�Ƽ�60�����¿�������`
	,list_cnt_in60d `�Ƽ�60�����¿�������`
    ,�Ƿ����
    ,TotalGross_new_list_2310 �Ƽ����¿��������۶�S2_2310
    ,TotalGross_new_list_2311 �Ƽ����¿��������۶�S2_2311
    ,TotalGross_new_list_2312 �Ƽ����¿��������۶�S2_2312
from t0
join dim_date dd on t0.PushDate =dd.full_date
left join (select distinct spu ,ele_name_group ,ele_name_priority  from dep_kbh_product_test ) dt on t0.spu=dt.spu
left join (select  spu
                ,case when ProductStatus = 0 then '����'
                    when ProductStatus = 2 then 'ͣ��'
                    when ProductStatus = 3 then 'ͣ��'
                    when ProductStatus = 4 then '��ʱȱ��'
                    when ProductStatus = 5 then '���'
                    end as ProductStatus
                ,ProductName
           from erp_product_products where IsDeleted=0 and IsMatrix=1 and ProjectTeam='��ٻ�' ) epp on t0.spu=epp.spu
left join t_list_stat on t0.spu =t_list_stat.spu and t0.pushdate =t_list_stat.pushdate
left join t_ad_stat on t0.spu =t_ad_stat.spu and t0.pushdate =t_ad_stat.pushdate
left join t_orde_stat on t0.spu =t_orde_stat.spu and t0.pushdate =t_orde_stat.pushdate
left join online_companycode oc on oc.SPU = t0.SPU and t0.pushdate =oc.pushdate
left join prod_seller_stat pss on pss.spu = t0.spu
left join online_seller_stat oss on oss.spu = t0.spu
left join unonline_seller_stat uss on uss.spu = t0.spu
left join sa_list_stat sls on sls.spu = t0.spu
)

select * from t_merage order by SPU