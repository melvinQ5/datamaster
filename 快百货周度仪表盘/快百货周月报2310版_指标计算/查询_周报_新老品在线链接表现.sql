
with
prod as ( select distinct sku ,ele_name_priority ,isnew from dep_kbh_product_test where productstatus !=2 ) -- ����Ʒ
-- prod as ( select sku ,ele_name_priority ,isnew from dep_kbh_product_test where isnew = '��Ʒ') -- ����Ʒ

,t_list as ( -- ��Ʒ��������
select wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate ,wl.MarketType as site,wl.SellerSKU ,wl.ShopCode ,wl.asin
	,DevelopLastAuditTime ,ProductName
	,case when TortType is null then 'δ���' else TortType end TortType ,DevelopUserName
	,Festival ,ta.ProductStatus
	,AccountCode
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
    ,case when wl.ListingStatus=1 then '����' else '������' end as ListingStatus
    ,ShopStatus
    ,ele_name_priority ,isnew
    ,lst_pub_tag
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�' and wl.IsDeleted=0
join prod on  wl.sku= prod.sku
join erp_amazon_amazon_listing  eaal on  wl.id =eaal.id  and wl.ListingStatus !=5 -- δɾ������
left join ( -- Ԫ��ӳ�����С������ SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on wl.sku =t_elem .sku
left join (
	select sku ,ProductName ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime ,DevelopUserName
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
		from import_data.wt_products wp where IsDeleted =0 and ProjectTeam='��ٻ�'
	) ta on wl.sku =ta.sku
left join view_kbh_lst_pub_tag vklpt on wl.SellerSKU = vklpt.SellerSKU and wl.ShopCode = vklpt.shopcode
where wl.ListingStatus = 1 and ShopStatus='����'
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
join prod on prod.sku = wo.Product_Sku
where
	PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -30 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType = '����' -- δ����������Ϊ����
)

-- ----------���Ӵ��ǩ
,t_orde_stat as ( -- ��Ʒ���ӱ�ǩ����������
select shopcode  ,sellersku
	,count(distinct case when timestampdiff(SECOND,paytime,  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  )/86400  <= 14 then PlatOrderNumber end) orders_in14d
	,count(distinct case when timestampdiff(SECOND,paytime,  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  )/86400  <= 30 then PlatOrderNumber end) orders_in30d
    ,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -14 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver20usd = 1 then PlatOrderNumber end ) orders_over_20usd -- ���˷ѳ�20���𶩵���
from t_orde
group by shopcode  ,sellersku
)

,snap_list_mark as (
select FirstDay , asin ,site ,list_level as snapshot_list_level
from import_data.dep_kbh_listing_level  where list_level regexp 'S|A|Ǳ��'
    and FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -5 week) and day(FirstDay) != 1
)

,lst_1 as ( -- ����
select  distinct asin ,site ,list_level as list_mark_0 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1 week)
)

,lst_2 as (  -- w-1��
select  distinct asin ,site ,list_level as list_mark_1 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2 week)
)

,lst_3 as ( -- w-2��
select  distinct asin ,site ,list_level as list_mark_2 from dep_kbh_listing_level dkll
where year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3 week)
)

,snap_prod_mark as (
select FirstDay , spu  ,prod_level as snapshot_prod_level
from import_data.dep_kbh_product_level  where isdeleted = 0 and  FirstDay >=  date_ADD(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -5 week) and day(FirstDay) != 1
)

,prod_1 as ( -- ����
select  distinct spu ,prod_level as mark_1 from dep_kbh_product_level
where isdeleted = 0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,prod_2 as (  -- w-1��
select  distinct spu ,prod_level as mark_2 from dep_kbh_product_level
where  isdeleted = 0 and year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,prod_3 as ( -- w-2��
select  distinct spu ,prod_level as mark_3 from dep_kbh_product_level
where  isdeleted = 0 and year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)

,lastest_prod_mark as (
select spu  ,group_concat(snapshot_prod_level,'-') old_prod_level
from (select spu ,snapshot_prod_level from snap_prod_mark
where FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -3 week) order by FirstDay desc
         ) t
group by spu
)

-- ----------���㶩������
,od_pay as (
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_weekly
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) sales_undeduct_refunds
	,round( sum((TotalGross-FeeGross)/ExchangeUSD ),2 ) TotalGross_no_freight_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) profit_undeduct_refunds
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.sku = wo.Product_Sku
join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
    and wo.IsDeleted=0
	and ms.Department = '��ٻ�'
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

,od_refund as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select shopcode ,SellerSku ,dim_date.week_num_in_year as refund_week
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
join dim_date on dim_date.full_date = date(vr.max_refunddate)
where wo.IsDeleted = 0 and max_refunddate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and max_refunddate<  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) and TransactionType = '�˿�'
group by shopcode ,SellerSku ,refund_week
)

,od_stat_pre as ( -- ƴ���г��� �� ���˿�ļ�¼
select  shopcode  ,sellersku ,pay_week
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,pay_week , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,refund_week , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,pay_week
)
-- select * from pre_refund_t_orde_week_stat ;

,od_stat as (
select  a.shopcode ,a.sellersku ,a.pay_week
    ,orders_weekly ,salecount_weekly
    ,sales  as TotalGross_weekly
    ,TotalGross_no_freight_weekly
    ,profit  as TotalProfit_weekly
    ,sales_refund as TotalGross_weekly_refund
from od_stat_pre a
left join  od_pay b on a.shopcode  = b.shopcode and  a.sellersku = b.SellerSku and a.pay_week = b.pay_week
)
-- ----------���������
-- select * from t_list
-- select count(1) from t_list

,t_ad as ( -- �Ż����Ӷ�Ӧ�������
select ShopCode ,SellerSKU  ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
	, dim_date.week_num_in_year ad_stat_week
	, dim_date.week_begin_date  ad_week_begin_date
    , case when GenerateDate =  date_add( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -2 day)
        then MaxEnabledBidUSD end MaxEnabledBidUSD -- ��һ������������Ϊ���¾���
    , MaxBidUSD  -- �������7�վ�
    , GenerateDate
from wt_adserving_amazon_daily  asa -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join prod on asa.sku =prod.sku -- ��Ʒ
	and asa.GenerateDate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and  asa.GenerateDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
join dim_date on dim_date.full_date = asa.GenerateDate
)

-- select * from t_ad ;

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
		-- �ع���
		, round(sum(Exposure)) as ad_sku_Exposure
		-- ��滨��
		, round(sum(Spend),2) as ad_Spend
		-- ������۶�
		, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
		-- �������
		, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
		-- �����
		, round(sum(Clicks)) as ad_sku_Clicks
	    , round(max(MaxEnabledBidUSD),2) as MaxEnabledBidUSD
	    ,round( avg( case when GenerateDate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and  GenerateDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) then MaxBidUSD end ) ,2 ) MaxBidUSD_in7d
		from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
	) tmp
)

,t_ad_bid as (
select waad.ShopCode ,waad.SellerSku
    ,max( case when GenerateDate = date_add(  '${NextStartDay}',interval -2 day ) then MaxEnabledBidUSD end  ) `�����bid`
    ,max( case when GenerateDate = date_add(  '${NextStartDay}',interval -2-7 day ) then MaxEnabledBidUSD end  ) `�����bid_7��ǰ`
    ,round( avg( case when GenerateDate >= date_add(  '${NextStartDay}',interval -2-7 day ) and  GenerateDate <  date_add(  '${NextStartDay}',interval -2 day ) then MaxBidUSD end ) ,2 ) 7��ƽ��bid
    ,round( avg( case when GenerateDate >= date_add(  '${NextStartDay}',interval -2-7-7 day ) and  GenerateDate <  date_add(  '${NextStartDay}',interval -2-7 day ) then MaxBidUSD end ) ,2 ) 7��ƽ��bid_����
from wt_adserving_amazon_daily  waad
join prod on waad.sku =prod.sku -- ��Ʒ
	and waad.GenerateDate >= date_add(  '${NextStartDay}',interval -2-7-7 day) and waad.GenerateDate <  '${NextStartDay}'
join dim_date on dim_date.full_date = waad.GenerateDate
group by waad.ShopCode ,waad.SellerSku
)


,t_merage as (
select
    lst_key.week_begin_date
    ,concat(lst_key.sellersku,lst_key.shopcode,week_num_in_year,ifnull(pay_week,'_'),ifnull(t_ad_stat.ad_stat_week,'_')) ��id
	,now() `����ˢ��ʱ��`
    ,snap_list_mark.snapshot_list_level `���ӷֲ����`
    , case when orders_in30d is null then null else concat(ifnull(list_mark_0,'��'),'-',ifnull(list_mark_1,'��'),'-',ifnull(list_mark_2,'��'))  end  `ǰ�������ӷֲ�`
    ,lst_key.shopcode `���̼���`
	,lst_key.sellersku `����sku`
    ,left(lst_key.`MinPublicationDate`,7) `��������`
    ,lst_key.lst_pub_tag `���ӿ��ǻ���`
    ,lst_key.site `վ��`
    ,lst_key.asin
	,lst_key.AccountCode `�˺�`
	,lst_key.NodePathName `�����Ŷ�`
	,lst_key.SellUserName `��ѡҵ��Ա`
    ,orders_in30d `��30�충����`
	,orders_in14d `��14�충����`
	,orders_in1_7 `��7�충����`

	,week_num_in_year `��Ȼ�ܴ�`
 	,pay_week `����ͳ����`
	,ifnull(TotalGross_weekly,0) `�������۶�`
    ,ifnull(TotalGross_no_freight_weekly,0) `���ܿ��˷����۶�`
	,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `���ܿ۹�������`
	,orders_weekly `���ܶ�����`
	,salecount_weekly `����sku����`

	,t_ad_stat.ad_stat_week `���ͳ����`
	,'-' `���ܹ��`
	,ad_sku_Exposure `���ܹ���ع���`
	,ifnull(ad_Spend,0) `���ܹ�滨��`
	,ad_TotalSale7Day `���ܹ�����۶�`
	,ad_sku_TotalSale7DayUnit `���ܹ������`
	,ad_sku_Clicks `���ܹ������`
	,click_rate `���ܹ������`
	,adsale_rate `���ܹ��ת����`
	,ROAS `����ROAS`
	,ACOS `����ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `����CPC`
    ,`�����bid`
    ,`�����bid_7��ǰ`
    ,`�����bid` - `�����bid_7��ǰ` as ��bid֮��
    ,7��ƽ��bid
    ,7��ƽ��bid_����
    ,`7��ƽ��bid` - `7��ƽ��bid_����` as 7�վ�bid֮��

	,lst_key.spu
	,spm.snapshot_prod_level `��Ʒ�ֲ����`
    ,concat(ifnull(mark_1,'��'),'-',ifnull(mark_2,'��'),'-',ifnull(mark_3,'��'))  ǰ������Ʒ�ֲ�
	,lst_key.sku
	,lst_key.boxsku
	,ProductName
	,ProductStatus `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,Festival `���ڽ���`
	,ele_name `Ԫ��`
	,lst_key.DevelopLastAuditTime `��Ʒ����ʱ��`
	,left(lst_key.DevelopLastAuditTime,7) `��Ʒ�����·�`
	,DevelopUserName `������Ա`
    ,case when lst_key.SellerSKU is null then '������ɾ��' else '' end as �����Ƿ�ɾ��
    ,lst_key.ListingStatus ����״̬
    ,lst_key.ShopStatus ����״̬
    ,case when dp.spu is null then '��' else '��' end as `�Ƿ��ǹ�������`
    ,ifnull(TotalGross_weekly_refund,0) as `�����˿���`
    ,case when lst_key.NodePathName regexp '�ɶ�' then '�ɶ�' when lst_key.NodePathName regexp 'Ȫ��' then 'Ȫ��' end as ����
    ,ele_name_priority ���ȼ�Ԫ�� ,isnew ����Ʒ

from
	( select lm.* , week_num_in_year ,week_begin_date
	from t_list lm
	join ( select distinct week_num_in_year,week_begin_date from dim_date
		where full_date >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*1 DAY) and full_date < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
		) dd
	) lst_key -- ��Ʒ��������
left join snap_list_mark on  snap_list_mark.asin = lst_key.asin and snap_list_mark.site = lst_key.site and snap_list_mark.FirstDay = lst_key.week_begin_date
left join lst_1 on lst_key.site = lst_1.site  and lst_key.Asin =lst_1.Asin
left join lst_2 on lst_key.site = lst_2.site  and lst_key.Asin =lst_2.Asin
left join lst_3 on lst_key.site = lst_3.site  and lst_key.Asin =lst_3.Asin
left join t_ad_stat on  t_ad_stat.ShopCode = lst_key.ShopCode and t_ad_stat.SellerSKU = lst_key.SellerSKU and lst_key.week_num_in_year = t_ad_stat.ad_stat_week
left join t_ad_bid on  t_ad_bid.ShopCode = lst_key.ShopCode and t_ad_bid.SellerSKU = lst_key.SellerSKU
left join t_orde_stat on  lst_key.ShopCode = t_orde_stat.ShopCode and lst_key.SellerSKU = t_orde_stat.SellerSKU
left join od_stat on  lst_key.ShopCode = od_stat.ShopCode and lst_key.SellerSKU = od_stat.SellerSKU
	and lst_key.week_num_in_year = od_stat.pay_week
left join snap_prod_mark  spm on lst_key.spu = spm.spu  and spm.FirstDay = lst_key.week_begin_date
left join prod_1 on lst_key.spu = prod_1.spu
left join prod_2 on lst_key.spu = prod_2.spu
left join prod_3 on lst_key.spu = prod_3.spu
left join (select spu from dep_kbh_product_level where  isdeleted = 0 and prod_level regexp '����|����' group by spu ) dp on lst_key.spu = dp.spu
)


,t_res as (
select distinct
��id,
`����ˢ��ʱ��` ,
`���ӷֲ����` ,
`ǰ�������ӷֲ�` ,
`���̼���` ,
`����sku` ,
`��������`,
���ӿ��ǻ���,
`վ��` ,
t_merage.asin ,
`�˺�` ,
`�����Ŷ�` ,
`��ѡҵ��Ա` ,
`��30�충����` ,
`��14�충����` ,
`��7�충����` ,
`��Ȼ�ܴ�` ,
`����ͳ����` ,
round(`�������۶�`,2) �������۶� ,
round(`���ܿ��˷����۶�`,2) ���ܿ��˷����۶�,
round(`���ܿ۹�������`,2) ���ܿ۹�������,
`���ܶ�����` ,
`����sku����` ,
`���ͳ����` ,
`���ܹ��`,
`���ܹ���ع���` ,
`���ܹ�滨��` ,
`���ܹ�����۶�` ,
`���ܹ������` ,
`���ܹ������` ,
`���ܹ������` ,
`���ܹ��ת����` ,
`����ROAS` ,
`����ACOS` ,
`����CPC`
,`�����bid`
,`�����bid_7��ǰ`
, ��bid֮��
,7��ƽ��bid
,7��ƽ��bid_����
,7�վ�bid֮��
,spu
`��Ʒ�ֲ����` ,
`ǰ������Ʒ�ֲ�`,
sku ,
boxsku ,
ProductName ,
`��Ʒ״̬` ,
`��Ȩ״̬` ,
`���ڽ���` ,
`Ԫ��` ,
`��Ʒ����ʱ��` ,
`��Ʒ�����·�` ,
`������Ա` ,
�����Ƿ�ɾ�� ,
����״̬ ,
����״̬ ,
`�Ƿ��ǹ�������`,
�����˿��� ,
����,
���ȼ�Ԫ��,
����Ʒ
from t_merage
)

select * from t_res
-- where ���̼��� ='PQ-MX'  and ����sku = '5P4XKD1I1M5KMUFMU1EBS-01'