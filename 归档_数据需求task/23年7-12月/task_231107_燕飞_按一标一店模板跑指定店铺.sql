-- ����N��д��
-- date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)  , INTERVAL -7*14 DAY)
-- �����10�¿�ʼ���� ��������

with
lst as ( -- 10��������
select ShopCode ,spu ,SellerSKU ,asin ,MinPublicationDate ,dim_date.week_num_in_year as lst_week
from wt_listing wl join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '��ٻ�' and IsDeleted=0
join dim_date on dim_date.full_date= date(MinPublicationDate)
where MinPublicationDate >= '2023-10-01' and MinPublicationDate < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
group by ShopCode ,spu ,SellerSKU ,asin  ,MinPublicationDate ,dim_date.week_num_in_year
)

,lst_week_stat as (
select ShopCode ,lst_week ,count(distinct concat(ShopCode,SellerSKU) ) ���ܿ��������� from lst group by ShopCode ,lst_week )

,lst_stat as (
select ShopCode  ,count(distinct concat(ShopCode,SellerSKU) ) 10���𿯵�������  ,count(distinct spu ) 10���𿯵�SPU��
from lst where MinPublicationDate >= '2023-10-01' group by ShopCode ) -- 10�����ۼƣ����Դ�1�ſ�ʼ

-- ----------���㶩������
,pre_t_orde_week_stat as (   -- ��������
select wo.shopcode ,dim_date.week_num_in_year as pay_week
    ,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
    ,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
    ,sum(salecount ) SaleCount_weekly
    ,count(distinct Product_SPU ) od_spu_weekly
    ,count(distinct concat(wo.shopcode,wo.SellerSku) ) od_lst_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join lst on wo.shopcode =lst.shopcode and wo.sellersku = lst.sellersku -- 10�º󿯵�����
join dim_date on dim_date.full_date  = date(wo.PayTime)
    and PayTime >= '2023-10-02' and PayTime < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
    and wo.IsDeleted=0
    and ms.Department = '��ٻ�'
    and TransactionType = '����'
    and OrderStatus <> '����'
group by wo.shopcode ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- ʹ���˿��
select ms.Code as shopcode  ,dim_date.week_num_in_year as refund_week
    ,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='���˿�'  and ms.Department = '��ٻ�'
join (select OrderNumber from import_data.wt_orderdetails wo  join lst on wo.shopcode =lst.shopcode and wo.sellersku = lst.sellersku and wo.IsDeleted =0
    group by OrderNumber
    ) lst_od on rf.OrderNumber = lst_od.OrderNumber  -- 10�º󿯵�����
join dim_date on dim_date.full_date  = date(rf.RefundDate)
where  RefundDate >= '2023-10-02' and RefundDate < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
group by  ms.Code    ,refund_week
)
-- select * from pre_refund_t_orde_week_stat

,t_orde_week_stat as (
select   a.shopcode ,a.pay_week
    ,round( TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalGross_weekly
    ,round( TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalProfit_weekly
    ,TotalGross_weekly_refund
    ,SaleCount_weekly
    ,od_spu_weekly
    ,od_lst_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and a.pay_week  = b.refund_week
)

-- ----------���������
,t_ad as (
select  waad.shopcode ,waad.SellerSku ,waad.sku  ,dim_date.week_num_in_year as ad_stat_week
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , waad.AdClicks as Clicks  , waad.AdExposure as Exposure ,waad.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily waad -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join import_data.mysql_store ms on waad.shopcode=ms.Code and Department = '��ٻ�'
    and GenerateDate >= '2023-10-02' and GenerateDate < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
join dim_date on dim_date.full_date= date(GenerateDate)
join lst on waad.shopcode =lst.shopcode and waad.sellersku = lst.sellersku -- 10�º󿯵�����
)
-- select * from t_ad

, t_ad_stat as (
select tmp.*
    , round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
    , round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
    , round(ad_TotalSale7Day/ad_Spend,2) as ROAS
    , round(ad_Spend/ad_TotalSale7Day,2) as ACOS
    ,round(ad_Spend/ad_sku_Clicks,4) `CPC`
from
    ( select  shopcode  ,ad_stat_week
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
        from t_ad  group by  shopcode ,ad_stat_week
    ) tmp
)


,vist as (  -- todo lm��ȡ��С�ÿ���������¼ lstȡ��󿯵�
select lm.ShopCode , round(TotalCount*FeaturedOfferPercent/100,0) `�ÿ���` ,OrderedCount `�ÿ�����` ,week_num_in_year
from import_data.ListingManage lm
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,* from import_data.mysql_store )  ms
    on lm.shopcode=ms.Code  and ms.Department='��ٻ�' and ReportType= '�ܱ�'
join dim_date dd  on dd.full_date=lm.Monday
join lst on lm.shopcode =lst.shopcode and lm.ChildAsin = lst.asin -- 10�º󿯵�����
)

-- 1��asin ֻ�ܶ�Ӧ1��SKU  , select asin ,site from  view_kbh_lst_pub_tag group by asin ,site  having count(distinct sku ) >1

,vist_stat as (
select ShopCode ,week_num_in_year as lm_week
    ,sum( �ÿ��� ) �ÿ���
    ,round ( sum( �ÿ����� ) / sum( �ÿ��� ) ,4 ) �ÿ�ת����
from vist
group by ShopCode,week_num_in_year
)

,t0 as (
select  week_num_in_year  ��Ȼ�� ,week_begin_date ���ڵ�һ�� ,code as shopcode ,ShopStatus ����״̬ ,CompanyCode ,AccountCode ,site
    , case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ���� , NodePathName as ����С�� ,SellUserName ������Ա
from mysql_store
join ( select distinct week_num_in_year,week_begin_date from dim_date
    where full_date >= '2023-10-02' and full_date < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
    ) dd
where Department = '��ٻ�' and CompanyCode regexp 'B26|B205|B204|MM|MH'
-- һ��һ�귶Χ B26,B205,B204,MM,MH
)

select t0.*
,10���𿯵�SPU��
,10���𿯵�������
,od_spu_weekly ���ܶ���SPU��
,od_lst_weekly ���ܶ���������
,���ܿ���������

,salecount_weekly `��������`
,round( ifnull(TotalGross_weekly,0) ,2 )`�������۶�`
,round( ifnull(TotalProfit_weekly,0) ,2) `���������_δ��ad`
,round(  (ifnull(TotalProfit_weekly,0) ) / ifnull(TotalGross_weekly,0)  ,4) `����������_δ��ad`
,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `���������_��ad`
,round(  (ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0)) / ifnull(TotalGross_weekly,0)  ,4) `����������_��ad`
,ifnull(TotalGross_weekly_refund,0) `�����˿��`

,�ÿ���
,�ÿ�ת����
,round(ifnull(�ÿ���,0) - ifnull(ad_sku_Clicks,0)) `��Ȼ�ÿ�����������`

,ifnull(ad_Spend,0) `���ܹ�滨��`
,ad_sku_Exposure `���ܹ���ع���`
,ad_TotalSale7Day `���ܹ�����۶�`
,ad_sku_TotalSale7DayUnit `���ܹ������`
,ad_sku_Clicks `���ܹ������`
,click_rate `���ܹ������`
,adsale_rate `���ܹ��ת����`
,ROAS `����ROAS`
,ACOS `����ACOS`
,CPC `����CPC`


from t0
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.��Ȼ�� = t_orde_week_stat.pay_week
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.��Ȼ�� = t_ad_stat.ad_stat_week
left join lst_week_stat  on t0.ShopCode = lst_week_stat.ShopCode and t0.��Ȼ�� = lst_week_stat.lst_week
left join vist_stat  on t0.ShopCode = vist_stat.ShopCode and t0.��Ȼ�� = vist_stat.lm_week
left join lst_stat  on t0.ShopCode = lst_stat.ShopCode
order by t0.shopcode  ,��Ȼ�� desc

