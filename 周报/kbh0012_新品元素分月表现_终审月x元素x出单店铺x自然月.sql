-- ��Ʒ��Χ��������Ʒ
-- ÿ����Ȼ�� x ÿ��Ԫ�أ�����δ��Ԫ�ر�ǩ�� x ÿ������ x ÿ���������µĸ���ָ��
-- ʱ����� 230701 -231002

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
select ele_name , shopcode ,dev_month ,dim_date.year ,dim_date.month as pay_month
	,round( sum(TotalGross/ExchangeUSD ),2 ) TotalGross_monthly
	,round( sum(TotalProfit/ExchangeUSD ),2) TotalProfit_monthly
	,round( sum(salecount ),2) SaleCount_monthly
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
group by ele_name , shopcode ,dev_month ,dim_date.year ,dim_date.month
)

,pre_refund_t_orde_week_stat as ( -- ʹ���˿��
select ele_name , shopcode  ,dev_month ,refund_month
	,abs(round( sum( RefundUSDPrice ),2 )) TotalGross_monthly_refund
from
( select distinct PlatOrderNumber,OrderSource as shopcode , RefundUSDPrice, dim_date.year ,dim_date.month as refund_month
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
group by ele_name , shopcode  ,dev_month ,refund_month
)

,t_orde_week_stat as (
select  a.ele_name , a.shopcode  ,a.dev_month  ,a.pay_month
    ,TotalGross_monthly - ifnull(TotalGross_monthly_refund,0) as TotalGross_monthly
    ,TotalProfit_monthly - ifnull(TotalGross_monthly_refund,0) as TotalProfit_monthly
    ,TotalGross_monthly_refund
    ,SaleCount_monthly
from pre_t_orde_week_stat a
left join  pre_refund_t_orde_week_stat b on a.shopcode  = b.shopcode and  a.ele_name = b.ele_name and a.pay_month = b.refund_month and a.dev_month = b.dev_month
)
-- ----------���������

,t_ad as (
select ele_name , shopcode  ,dev_month  ,month(GenerateDate) as  ad_stat_month
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , asa.AdClicks as Clicks  , asa.AdExposure as Exposure ,asa.AdSpend as Spend
	, AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily  asa -- �������д��ǩ���ӣ��������ع����ݵ����ӽ����в��
join ( select distinct wl.id ,wl.sku ,ele_name ,dev_month from wt_listing wl
    join import_data.mysql_store ms on wl.shopcode=ms.Code and Department = '��ٻ�'
    join prod on wl.sku =prod.sku  -- ��Ʒ
    ) wl on asa.ListingId = wl.id
	and  GenerateDate >=  '${StartDay}'  and GenerateDate <  '${NextStartDay}' -- 7��3���ǰ�dim_date��28�ܣ���Ӧ����ܱ��27��
)

, t_ad_stat as (
select tmp.*
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as click_rate -- `�������`
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as adsale_rate  -- `���ת����`
	, round(ad_TotalSale7Day/ad_Spend,2) as ROAS
	, round(ad_Spend/ad_TotalSale7Day,2) as ACOS
from
	( select  ele_name , shopcode  ,dev_month ,ad_stat_month
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
		from t_ad  group by ele_name , shopcode  ,dev_month ,ad_stat_month
	) tmp
)

,t0 as (
select prod.* , year,month ,ms.*
from (select distinct  ele_name ,dev_month �������� from prod ) prod
join ( select distinct year,month  from dim_date
    where full_date >= '${StartDay}'  and full_date < '${NextStartDay}'
    ) dd
join (select distinct code as shopcode ,CompanyCode , AccountCode
    , case when NodePathName regexp  '�ɶ�' then '�ɶ�' else 'Ȫ��' end as ����
    , NodePathName as ����С�� ,SellUserName ������Ա
      from mysql_store where Department = '��ٻ�') ms
)


select
    t0.ele_name ���ȼ�Ԫ��
    ,�������� ,month as ��Ȼ�� ,t0.shopcode ,t0.CompanyCode ,t0.AccountCode ,���� ,����С�� ,������Ա
    ,ifnull(SaleCount_monthly,0) `��������`
    ,ifnull(TotalGross_monthly,0) `�������۶�`
    ,ifnull(TotalProfit_monthly,0) ���������_δ��ad
    ,round( ifnull(TotalProfit_monthly,0) / ifnull(TotalGross_monthly,0) ,4 ) ������_δ��ad
	,round(ifnull(TotalProfit_monthly,0) - ifnull(ad_Spend,0),2) `���������_��ad`
    ,round( ( ifnull(TotalProfit_monthly,0) - ifnull(ad_Spend,0) ) / ifnull(TotalGross_monthly,0) ,4 ) ������_��ad
    ,ifnull(TotalGross_monthly_refund,0) `�����˿��`
    ,ad_sku_Exposure `���¹���ع���`
	,ifnull(ad_Spend,0) `���¹�滨��`
	,ad_TotalSale7Day `���¹�����۶�`
	,ad_sku_TotalSale7DayUnit `���¹������`
	,ad_sku_Clicks `���¹������`
	,click_rate `���¹������`
	,adsale_rate `���¹��ת����`
	,ROAS `����ROAS`
	,ACOS `����ACOS`
	,round(ad_Spend/ad_sku_Clicks,4) `����CPC`
from t0
left join t_orde_week_stat on t0.ShopCode = t_orde_week_stat.ShopCode and t0.ele_name = t_orde_week_stat.ele_name
	and t0.month = t_orde_week_stat.pay_month and t0.�������� = t_orde_week_stat.dev_month
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.ele_name = t_ad_stat.ele_name
	and t0.month = t_ad_stat.ad_stat_month and t0.�������� = t_ad_stat.dev_month
where  ifnull(ad_sku_Exposure,0) + ifnull(TotalGross_monthly,0) >0  -- ȥ��û�г�����û�й����м�¼


