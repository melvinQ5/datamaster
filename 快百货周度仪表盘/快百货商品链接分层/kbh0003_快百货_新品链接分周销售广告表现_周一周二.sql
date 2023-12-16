
with
prod as ( select distinct sku ,ele_name_priority ,ele_name_group ,isnew from dep_kbh_product_test where productstatus !=2 ) -- ����Ʒ
-- prod as ( select sku ,ele_name_priority ,isnew from dep_kbh_product_test where isnew = '��Ʒ') -- ����Ʒ

,t_list as ( -- ��Ʒ��������
select wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate ,wl.MarketType as site,wl.SellerSKU ,wl.ShopCode ,wl.asin
	,DevelopLastAuditTime ,ProductName ,DevelopUserName
	,case when wp.TortType is null then 'δ���' else wp.TortType end TortType
	,wp.Festival ,wp.ProductStatusName
	,AccountCode
	,ms.SellUserName  ,ms.NodePathName
	,ele_name_group
    ,case when wl.ListingStatus=1 then '����' else '������' end as ListingStatus
    ,ShopStatus
    ,ele_name_priority ,isnew
    ,lst_pub_tag
from import_data.wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.Department = '��ٻ�' and wl.IsDeleted=0
join prod on  wl.sku= prod.sku
-- join erp_amazon_amazon_listing  eaal on  wl.id =eaal.id  and wl.ListingStatus !=5 -- δɾ������
left join wt_products wp  on wl.sku =wp.sku and wp.IsDeleted =0 and wp.ProjectTeam='��ٻ�'
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
where FirstDay >=  date_ADD( subdate('${NextStartDay}',date_format(' ${NextStartDay}','%w')-1) , interval -3 week) order by FirstDay desc
         ) t
group by spu
)

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
join prod on prod.sku = wo.Product_Sku
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
join prod on prod.sku = wo.Product_Sku -- ��Ʒ
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
-- select * from t_list
-- select count(1) from t_list

,t_ad as ( -- �Ż����Ӷ�Ӧ�������
select ShopCode ,SellerSKU  ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
	, dim_date.week_num_in_year ad_stat_week
	, dim_date.week_begin_date  ad_week_begin_date
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
		from t_ad  group by shopcode  ,sellersku ,ad_week_begin_date ,ad_stat_week
	) tmp
)
-- select * from t_ad_stat
,pre_ad_bid as (
select waad.ShopCode ,waad.SellerSku ,dim_date.week_begin_date  as ad_week_begin_date
    ,max(  MaxEnabledBidUSD  ) `�������bid`
    ,round( avg(  MaxBidUSD  ) ,2 ) ����ƽ��bid
from wt_adserving_amazon_daily  waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join prod on waad.sku =prod.sku -- ��Ʒ
	and waad.GenerateDate >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*10 DAY) and  waad.GenerateDate <   subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
join dim_date on dim_date.full_date = waad.GenerateDate
group by waad.ShopCode ,waad.SellerSku ,ad_week_begin_date
)

,ad_bid as (
select t1.ShopCode ,t1.SellerSku ,t1.ad_week_begin_date
,t1.�������bid
,t1.�������bid - t2.�������bid as ���bid�ܻ���
,t1.����ƽ��bid
,t1.����ƽ��bid - t2.����ƽ��bid as ƽ��bid�ܻ���
from pre_ad_bid t1
left join  pre_ad_bid t2 on t1.ShopCode =t2.ShopCode and t1.SellerSku =t2.SellerSku and t1.ad_week_begin_date = date_add(t2.ad_week_begin_date ,interval -1 week )
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
-- 	,t_ad_stat.ad_week_begin_date `��浱����һ`
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

	,lst_key.spu
	,spm.snapshot_prod_level `��Ʒ�ֲ����`
    ,concat(ifnull(mark_1,'��'),'-',ifnull(mark_2,'��'),'-',ifnull(mark_3,'��'))  ǰ������Ʒ�ֲ�
	,lst_key.sku
	,lst_key.boxsku
	,ProductName
	,ProductStatusName `��Ʒ״̬`
	,TortType `��Ȩ״̬`
	,Festival `���ڽ���`
	,ele_name_group `Ԫ��`
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

    ,�������bid
    ,���bid�ܻ���
    ,����ƽ��bid
    ,ƽ��bid�ܻ���
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
left join ad_bid on  ad_bid.ShopCode = lst_key.ShopCode and ad_bid.SellerSKU = lst_key.SellerSKU and lst_key.week_begin_date = ad_bid.ad_week_begin_date
-- left join t_ad_name on  lst_key.ShopCode = t_ad_name.ShopCode and lst_key.SellerSKU = t_ad_name.SellerSKU and lst_key.week_num_in_year = t_ad_name.ad_stat_week
left join t_orde_stat on  lst_key.ShopCode = t_orde_stat.ShopCode and lst_key.SellerSKU = t_orde_stat.SellerSKU
left join t_orde_week_stat on  lst_key.ShopCode = t_orde_week_stat.ShopCode and lst_key.SellerSKU = t_orde_week_stat.SellerSKU
	and lst_key.week_num_in_year = t_orde_week_stat.pay_week
left join pre_refund_t_orde_week_stat on  lst_key.ShopCode = pre_refund_t_orde_week_stat.ShopCode and lst_key.SellerSKU = pre_refund_t_orde_week_stat.SellerSKU
	and lst_key.week_num_in_year = pre_refund_t_orde_week_stat.refund_week
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
`�������۶�` ,
`���ܿ��˷����۶�` ,
`���ܿ۹�������` ,
`���ܶ�����` ,
`����sku����` ,
`���ͳ����` ,
`���ܹ��` ,
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
�����˿��� ,
����,
���ȼ�Ԫ��,
����Ʒ,
�������bid,
���bid�ܻ���,
����ƽ��bid,
ƽ��bid�ܻ���
from t_merage
)
select * from t_res;

-- select ��id  from t_res group by ��id having count(*) >1  -- ����ظ�����
-- select round(sum(���ܿ۹�������)/sum(�������۶�),4) from t_res;
-- where ��Ʒ����ʱ�� < '2023-07-01'
-- where spu =5279920 and ����sku = '00ZD230726YFUNXTUK' and ���̼��� = 'XT-BE'
-- order by `����sku` ,`���ͳ����`

