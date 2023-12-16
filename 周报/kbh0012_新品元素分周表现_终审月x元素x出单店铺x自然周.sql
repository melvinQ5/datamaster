-- ��Ʒ��Χ��������Ʒ
-- ÿ����Ȼ�� x ÿ��Ԫ�أ�����δ��Ԫ�ر�ǩ�� x ÿ������ x ÿ���������µĸ���ָ��
-- ʱ����� 230703 -231002

with
prod as (
select vknp.sku
  ,case when ele_name_priority is null then '��Ԫ�ر�ǩ' else ele_name_priority end ele_name
  ,left(DevelopLastAuditTime,7) dev_month
from view_kbp_new_products  vknp
left join view_kbh_element vke on vknp.SKU = vke.sku
left join wt_products p on vknp.sku = p.sku and p.ProjectTeam='��ٻ�'
)

-- ----------���㶩������
,pre_t_orde_week_stat as (   -- ��������
select ele_name , shopcode ,dev_month  ,dim_date.week_num_in_year as pay_week
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
group by ele_name , shopcode ,dev_month    ,dim_date.week_num_in_year
)

,pre_refund_t_orde_week_stat as ( -- ʹ���˿��
select ele_name , shopcode  ,dev_month ,refund_week
	,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_weekly_refund
from
( select distinct PlatOrderNumber,OrderSource as shopcode , RefundUSDPrice ,dim_date.week_num_in_year as refund_week
from daily_RefundOrders rf
join import_data.mysql_store ms on rf.OrderSource=ms.Code and RefundStatus='���˿�'  and ms.Department = '��ٻ�'
join dim_date on dim_date.full_date = date(rf.RefundDate)
where  RefundDate >=  '${StartDay}'  and RefundDate <  '${NextStartDay}'
) t1
join (
select PlatOrderNumber , ele_name ,dev_month
from wt_orderdetails wo
join prod on prod.sku = wo.Product_Sku -- ��Ʒ
where IsDeleted=0 and TransactionType='����' and department = '��ٻ�' group by PlatOrderNumber , ele_name ,dev_month
) t2 on t1.PlatOrderNumber = t2.PlatOrderNumber
group by ele_name , shopcode  ,dev_month ,refund_week
)
-- select * from pre_refund_t_orde_week_stat ,

,t_orde_week_stat as (
select  a.ele_name , a.shopcode  ,a.dev_month  ,a.pay_week
    ,TotalGross_weekly - ifnull(TotalGross_weekly_refund,0) as TotalGross_weekly
    ,TotalProfit_weekly - ifnull(TotalGross_weekly_refund,0) as TotalProfit_weekly
    ,TotalGross_weekly_refund 
    ,SaleCount_weekly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and  a.ele_name = b.ele_name and a.pay_week = b.refund_week and a.dev_month = b.dev_month
)
-- ----------���������

,t_ad as ( --
select ele_name , shopcode  ,dev_month  ,dim_date.week_num_in_year as ad_stat_week
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily asa -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join ( select distinct wl.id ,wl.sku ,ele_name ,dev_month from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '��ٻ�'
    join prod on wl.sku =prod.sku  -- ��Ʒ
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
	( select  ele_name , shopcode  ,dev_month ,ad_stat_week
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
		from t_ad  group by ele_name , shopcode  ,dev_month ,ad_stat_week
	) tmp
)

,t0 as (
select prod.* ,week_num_in_year ,week_begin_date  ,ms.*
from (select distinct  ele_name ,dev_month �������� from prod ) prod
join ( select distinct week_num_in_year,week_begin_date  from dim_date
    where full_date >= '${StartDay}'  and full_date < '${NextStartDay}'
    ) dd
join (select distinct code as shopcode ,CompanyCode , AccountCode
    , case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ����
    , NodePathName as ����С�� ,SellUserName ������Ա
      from mysql_store where Department = '��ٻ�') ms
)


select
    t0.ele_name ���ȼ�Ԫ��
    ,�������� ,week_num_in_year as ��Ȼ�� ,week_begin_date as ����һ ,t0.shopcode ,t0.CompanyCode ,t0.AccountCode ,���� ,����С�� ,������Ա
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
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.ele_name = t_orde_week_stat.ele_name
	and t0.week_num_in_year = t_orde_week_stat.pay_week and t0.�������� = t_orde_week_stat.dev_month
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.ele_name = t_ad_stat.ele_name
	and t0.week_num_in_year = t_ad_stat.ad_stat_week and t0.�������� = t_ad_stat.dev_month
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_weekly,0) >0  -- ȥ��û�г�����û�й����м�¼


