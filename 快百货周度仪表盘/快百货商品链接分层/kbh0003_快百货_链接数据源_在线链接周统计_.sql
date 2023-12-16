

with
prod as ( -- ȡ��5�ܱ���Ǳ��, ��γ���SPU�������һ�α�ǩ
select *
from (
    select spu, prod_level, FirstDay ,row_number() over (partition by spu  order by FirstDay desc ) mark_date_sort
    from dep_kbh_product_level dkpl
    where FirstDay >= date_add( subdate(' ${NextStartDay}', date_format(' ${NextStartDay}', '%w')-1), interval - 5 week )
    and day(FirstDay) != 1 and dkpl.prod_level regexp '����|����|Ǳ����'
    ) t
where mark_date_sort = 1
)

-- select * from prod where spu = 5122049

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU
	,wo.Product_Sku  as SKU
    ,case when date_add(Product_DevelopLastAuditTime , interval - 8 hour) >= '2023-07-01'
        then '��Ʒ' else '��Ʒ' end as isnewpp
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 20 then 1 else 0 end as isOver20usd
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
where
	PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -30 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  
	and wo.IsDeleted=0
	and ms.Department = '��ٻ�'  and TransactionType = '����' -- δ����������Ϊ����
)

-- select * from t_orde  where SellerSku = '00ZD230726YFUNXTUK' and shopcode = 'XT-BE';
-- ----------���Ӵ��ǩ
,t_orde_stat as ( -- ���ӱ�ǩ����������
select shopcode  ,sellersku ,isnewpp
	,count(distinct case when timestampdiff(SECOND,paytime,  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  )/86400  <= 14 then PlatOrderNumber end) orders_in14d
	,count(distinct case when timestampdiff(SECOND,paytime,  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  )/86400  <= 30 then PlatOrderNumber end) orders_in30d
    ,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count(distinct case when  PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -14 day) and PayTime < date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver20usd = 1 then PlatOrderNumber end ) orders_over_20usd -- ���˷ѳ�20���𶩵���
from t_orde
group by shopcode  ,sellersku ,isnewpp
)
-- select * from t_orde_stat


,snap_list_mark as (
select FirstDay , asin ,site ,list_level as snapshot_list_level
from import_data.dep_kbh_listing_level  where isdeleted = 0 and list_level regexp 'S|A|Ǳ��'
    and FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -5 week) and day(FirstDay) != 1
)

,lst_1 as ( -- ����
select  distinct asin ,site ,list_level as list_mark_0 from dep_kbh_listing_level dkll
where isdeleted = 0 and year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1 week)
)

,lst_2 as (  -- w-1��
select  distinct asin ,site ,list_level as list_mark_1 from dep_kbh_listing_level dkll
where isdeleted = 0 and  year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2 week)
)

,lst_3 as ( -- w-2��
select  distinct asin ,site ,list_level as list_mark_2 from dep_kbh_listing_level dkll
where isdeleted = 0 and  year(dkll.FirstDay)= 2023 and dkll.FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3 week)
)


,snap_prod_mark as (
select FirstDay , spu  ,prod_level as snapshot_prod_level
from import_data.dep_kbh_product_level  where isdeleted = 0 and FirstDay >=  date_ADD(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , interval -5 week) and day(FirstDay) != 1
)

,prod_1 as ( -- ����
select  distinct spu ,prod_level as mark_1 from dep_kbh_product_level
where isdeleted = 0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -1-1 week)
)

,prod_2 as (  -- w-1��
select  distinct spu ,prod_level as mark_2 from dep_kbh_product_level
where  isdeleted = 0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -2-1 week)
)

,prod_3 as ( -- w-2��
select  distinct spu ,prod_level as mark_3 from dep_kbh_product_level
where  isdeleted = 0 and  year(FirstDay)= 2023 and FirstDay = date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1),interval -3-1 week)
)


,lastest_prod_mark as (
select spu  ,group_concat(snapshot_prod_level,'-') old_prod_level
from (select spu ,snapshot_prod_level from snap_prod_mark
where FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format(' ${NextStartDay}','%w')-1) , interval -3 week) order by FirstDay desc
         ) t
group by spu
)
-- select * from  lastest_prod_mark

-- SELECT * FROM list_mark WHERE SellerSku ='yzbjyd20230721-us001'  sales_no_freight
-- ----------���㶩������

,pre_t_orde_week_stat as ( -- ��������
select shopcode  ,sellersku  ,dim_date.week_num_in_year as pay_week
	,count( distinct PlatOrderNumber ) orders_weekly
	,round( sum(salecount),2 ) salecount_weekly
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
	,round( sum((TotalGross-FeeGross)/ExchangeUSD ),2 ) TotalGross_no_freight_weekly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join dim_date on dim_date.full_date = date(wo.PayTime)
where
	PayTime >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and PayTime <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)   -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
    and wo.IsDeleted=0
	and ms.Department = '��ٻ�'
    and TransactionType = '����' -- δ����������Ϊ����
    and OrderStatus <> '����'
group by shopcode  ,sellersku  ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- ʹ���˿��
select shopcode  ,sellersku  ,refund_week
	,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from
( select distinct PlatOrderNumber, RefundUSDPrice ,dim_date.week_num_in_year as refund_week
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='���˿�'  and ms.Department = '��ٻ�'
join dim_date on dim_date.full_date = date(rf.RefundDate)
where RefundDate  >= date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and RefundDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
) t1
join (
select PlatOrderNumber ,shopcode ,sellersku  from wt_orderdetails wo
where IsDeleted=0 and TransactionType='����' and department = '��ٻ�' group by PlatOrderNumber ,shopcode ,sellersku
) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
group by shopcode  ,sellersku  ,refund_week
)
-- select * from pre_refund_t_orde_week_stat ;

,t_orde_week_stat as (
select  a.shopcode ,a.sellersku ,a.pay_week
    ,orders_weekly ,salecount_weekly
    ,TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) as TotalGross_weekly
    ,TotalGross_no_freight_weekly - ifnull(TotalGross_weekly_refund,0) as TotalGross_no_freight_weekly
    ,TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) as TotalProfit_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and  a.sellersku = b.SellerSku and a.pay_week = b.refund_week
)



-- ----------���������

,t_list as ( -- ������������
select wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate ,wl.MarketType as site,wl.SellerSKU ,wl.ShopCode ,wl.asin
	,DevelopLastAuditTime ,ProductName ,wl.DevelopUserName
	,case when TortType is null then 'δ���' else TortType end TortType 
	,Festival ,ta.ProductStatus
	,AccountCode
	,ms.SellUserName  ,ms.NodePathName
	,ele_name
    ,case when wl.ListingStatus=1 then '����' else '������' end as ListingStatus
    ,ShopStatus
    ,case when eaal.IsBan = 1 then '��' else '��' end as is_virtual_warehouse  -- ERPϵͳ�����ֶ����ڱ�ʾ�Ƿ��������
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�' and wl.IsDeleted  = 0 
left join prod on  wl.spu= prod.spu
join erp_amazon_amazon_listing  eaal on  wl.id =eaal.id and wl.ListingStatus != 5 -- δɾ������
left join ( -- Ԫ��ӳ�����С������ SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on wl.sku =t_elem .sku
left join (
	select sku ,ProductName ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '����'
			when wp.ProductStatus = 2 then 'ͣ��'
			when wp.ProductStatus = 3 then 'ͣ��'
			when wp.ProductStatus = 4 then '��ʱȱ��'
			when wp.ProductStatus = 5 then '���'
			end as ProductStatus
		from import_data.wt_products wp where IsDeleted =0 
	) ta on wl.sku =ta.sku
where ShopStatus='����' and wl.ListingStatus = 1
  -- and isban = 1
)


,t_ad as ( -- �Ż����Ӷ�Ӧ�������
select ShopCode ,SellerSKU  ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
	, dim_date.week_num_in_year ad_stat_week
	, dim_date.week_begin_date  ad_week_begin_date
from wt_adserving_amazon_daily  asa -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join dim_date on dim_date.full_date = asa.GenerateDate
where  asa.GenerateDate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and  asa.GenerateDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
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
		from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
	) tmp
)
-- select * from t_ad_stat


,t_merage as (
select
    lst_key.week_begin_date
    ,concat(lst_key.sellersku,lst_key.shopcode,week_num_in_year,ifnull(pay_week,'_'),ifnull(t_ad_stat.ad_stat_week,'_')) ��id
	,now() `����ˢ��ʱ��`
    ,snap_list_mark.snapshot_list_level `���ӷֲ����`
    , case when orders_in30d is null then null else concat(ifnull(list_mark_0,'��'),'-',ifnull(list_mark_1,'��'),'-',ifnull(list_mark_2,'��'))  end  `ǰ�������ӷֲ�`
    ,lst_key.shopcode `���̼���`
	,lst_key.sellersku `����sku`
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
-- 	,t_ad_stat.ad_week_begin_date `��浱����һ`
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
    ,is_virtual_warehouse `�Ƿ������`
from 
	( select lm.* , week_num_in_year ,week_begin_date
	from t_list lm
	join ( select distinct week_num_in_year,week_begin_date from dim_date
		where full_date = date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -1 week) ) dd
	) lst_key
left join snap_list_mark on  snap_list_mark.asin = lst_key.asin and snap_list_mark.site = lst_key.site and snap_list_mark.FirstDay = lst_key.week_begin_date
left join lst_1 on lst_key.site = lst_1.site  and lst_key.Asin =lst_1.Asin
left join lst_2 on lst_key.site = lst_2.site  and lst_key.Asin =lst_2.Asin
left join lst_3 on lst_key.site = lst_3.site  and lst_key.Asin =lst_3.Asin
left join t_ad_stat on  t_ad_stat.ShopCode = lst_key.ShopCode and t_ad_stat.SellerSKU = lst_key.SellerSKU and lst_key.week_num_in_year = t_ad_stat.ad_stat_week
left join t_orde_stat on  lst_key.ShopCode = t_orde_stat.ShopCode and lst_key.SellerSKU = t_orde_stat.SellerSKU 
left join t_orde_week_stat on  lst_key.ShopCode = t_orde_week_stat.ShopCode and lst_key.SellerSKU = t_orde_week_stat.SellerSKU 
	and lst_key.week_num_in_year = t_orde_week_stat.pay_week
left join snap_prod_mark  spm on lst_key.spu = spm.spu  and spm.FirstDay = lst_key.week_begin_date
left join prod_1 on lst_key.spu = prod_1.spu
left join prod_2 on lst_key.spu = prod_2.spu
left join prod_3 on lst_key.spu = prod_3.spu
left join (select spu from dep_kbh_product_level where  isdeleted = 0 and  prod_level regexp '����|����' group by spu ) dp on lst_key.spu = dp.spu

)

-- select list_type ,count(DISTINCT shopcode  ,sellersku ) from t_ad_stat group by list_type   '`lst_key`.`ad_stat_week`'

select distinct
��id,
`����ˢ��ʱ��` ,
`���ӷֲ����` ,
`ǰ�������ӷֲ�` ,
`���̼���` ,
`����sku` ,
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
`�������۶�` ,
`���ܿ��˷����۶�` ,
`���ܿ۹�������` ,
`���ܶ�����` ,
`����sku����` ,
`���ͳ����` ,
`���ܹ���ع���` ,
`���ܹ�滨��` ,
`���ܹ�����۶�` ,
`���ܹ������` ,
`���ܹ������` ,
`���ܹ������` ,
`���ܹ��ת����` ,
`����ROAS` ,
`����ACOS` ,
`����CPC` ,
spu ,
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
`�Ƿ������`
from t_merage
order by `����sku` ,`���ͳ����`;
