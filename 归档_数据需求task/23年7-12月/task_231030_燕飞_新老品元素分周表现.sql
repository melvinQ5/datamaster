-- ��Ʒ��Χ������
-- ÿ����Ȼ�� x ÿ��Ԫ�أ�����δ��Ԫ�ر�ǩ�� x ÿ������ x ÿ���������µĸ���ָ��
-- ʱ����� 230703 -231002



with
prod as (
select wp.sku ,isnew
  ,case when ele_name_priority is null then '��Ԫ�ر�ǩ' else ele_name_priority end ���ȼ�Ԫ��
  ,left(DevelopLastAuditTime,7) ��������
from wt_products wp
left join dep_kbh_product_test vke on wp.SKU = vke.sku
where wp.ProjectTeam='��ٻ�' and wp.IsDeleted=0 and ProductStatus !=2
)

-- ----------���㶩������
,pre_t_orde_week_stat as (   -- ��������
select shopcode ,SellerSku ,sku  ,dim_date.week_num_in_year as pay_week
    ,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_weekly
    ,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_weekly
    ,round( sum(salecount ),2) SaleCount_weekly
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
join prod on prod.sku = wo.Product_Sku
join dim_date on dim_date.full_date = date(wo.PayTime)
where
    PayTime >=  '${StartDay}'  and PayTime <  '${NextStartDay}'  -- ��ȡ����Զ��������Ϊ�˰���������������Ȼ��
    and wo.IsDeleted=0
    and ms.Department = '��ٻ�'
    and TransactionType = '����' -- δ����������Ϊ����
    and OrderStatus <> '����'
group by shopcode ,SellerSku ,sku  ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- ʹ���˿��
select  shopcode  ,sellersku  ,sku ,refund_week
    ,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from
( select distinct PlatOrderNumber , RefundUSDPrice ,dim_date.week_num_in_year as refund_week
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='���˿�'  and ms.Department = '��ٻ�'
join dim_date on dim_date.full_date = date(rf.RefundDate)
where  RefundDate >=  '${StartDay}'  and RefundDate <  '${NextStartDay}'
) t1
join (
select distinct PlatOrderNumber ,shopcode ,sellersku ,Product_Sku as sku
from wt_orderdetails wo
join prod on prod.sku = wo.Product_Sku -- ��Ʒ
where IsDeleted=0 and TransactionType='����' and department = '��ٻ�'
) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
group by  shopcode  ,sellersku  ,sku  ,refund_week
)
-- select * from pre_refund_t_orde_week_stat

,t_orde_week_stat as (
select   a.shopcode ,a.SellerSku ,a.sku  ,a.pay_week
    ,round( TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalGross_weekly
    ,round( TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) ) as TotalProfit_weekly
    ,TotalGross_weekly_refund
    ,SaleCount_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and a.SellerSku  = b.SellerSku
)
-- ----------���������

,t_ad as ( --
select  shopcode ,SellerSku ,asa.sku  ,dim_date.week_num_in_year as ad_stat_week
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily asa -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join ( select distinct wl.id ,wl.sku  from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '��ٻ�'
    join prod on wl.sku =prod.sku
    ) wl on asa.ListingId = wl.id
    and  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}'-- 7��3���ǰ�dim_date��28�ܣ���Ӧ����ܱ��27��
join dim_date on dim_date.full_date = date(asa.GenerateDate)
)

-- select * from t_ad ,

, t_ad_stat as (
select tmp.*
    , round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
    , round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
    , round(ad_TotalSale7Day/ad_Spend,2) as ROAS
    , round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
    ( select  shopcode  ,SellerSku ,sku ,ad_stat_week
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
        from t_ad  group by  shopcode ,SellerSku ,sku ,ad_stat_week
    ) tmp
)

,t0 as (
select t.* ,week_num_in_year ,week_begin_date  ,���� ,����С�� ,������Ա ,�������� ,���ȼ�Ԫ�� ,CompanyCode ,AccountCode ,isnew ,ShopStatus
from ( select shopcode ,SellerSku , sku from t_orde_week_stat
    union select shopcode ,SellerSku , sku from t_ad_stat   -- ȥ��û�г�����û�й����м�¼
    ) t
join ( select distinct week_num_in_year,week_begin_date  from dim_date
    where full_date >= '${StartDay}'  and full_date < '${NextStartDay}'
    ) dd
left join (select * , case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ���� , NodePathName as ����С�� ,SellUserName ������Ա
      from mysql_store where Department = '��ٻ�') ms on t.shopcode = ms.code
left join prod on t.sku =prod.sku
)

,res as (
select
    t0.ShopStatus ,t0.shopcode ,t0.SellerSKU
    ,lst_pub_tag ���ӿ��ǻ���
    ,t0.sku ,�������� ,isnew ����Ʒ ,t0.���ȼ�Ԫ��
     ,week_num_in_year as ��Ȼ�� ,week_begin_date as ����һ ,t0.CompanyCode ,t0.AccountCode ,���� ,����С�� ,������Ա
    ,ifnull(SaleCount_weekly,0) `��������`
    ,ifnull(TotalGross_weekly,0) `�������۶�`
    ,ifnull(TotalProfit_weekly,0) ���������_δ��ad
    ,round( ifnull(TotalProfit_weekly,0) / ifnull(TotalGross_weekly,0) ,4 ) ������_δ��ad
    ,round(ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0),2) `���������_��ad`
    ,round( ( ifnull(TotalProfit_weekly,0) - ifnull(ad_Spend,0) ) / ifnull(TotalGross_weekly,0) ,4 ) ������_��ad
    ,ifnull(TotalGross_weekly_refund,0) `�����˿��`
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
from t0
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.SellerSku = t_orde_week_stat.SellerSku
    and t0.week_num_in_year = t_orde_week_stat.pay_week
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.SellerSku = t_ad_stat.SellerSku
    and t0.week_num_in_year = t_ad_stat.ad_stat_week
left join view_kbh_lst_pub_tag vl on t0.SellerSku=vl.SellerSKU and t0.shopcode = vl.shopcode
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_weekly,0) >0  -- ȥ��û�г�����û�й����м�¼
order by t0.shopcode ,t0.SellerSKU ,t0.sku ,��Ȼ��
)

,res2 as (
select ShopStatus ,shopcode ,���ӿ��ǻ���,��������,����Ʒ,���ȼ�Ԫ��,��Ȼ��,����һ,CompanyCode,AccountCode,����,����С��,������Ա
    ,sum(��������) +0 ��������
    ,sum(�������۶�) +0  �������۶�
    ,sum(���������_δ��ad) +0 ���������_δ��ad
    ,sum(���������_��ad) +0  ���������_��ad
    ,sum(�����˿��) +0 �����˿��
    ,sum(���ܹ���ع���) +0 ���ܹ���ع���
    ,sum(���ܹ�滨��) +0 ���ܹ�滨��
    ,sum(���ܹ�����۶�) +0 ���ܹ�����۶�
    ,sum(���ܹ������) +0 ���ܹ������
    ,sum(���ܹ������) +0 ���ܹ������
from res
group by ShopStatus ,shopcode ,���ӿ��ǻ���,��������,����Ʒ,���ȼ�Ԫ��,��Ȼ��,����һ,CompanyCode,AccountCode,����,����С��,������Ա
)
select * from res2