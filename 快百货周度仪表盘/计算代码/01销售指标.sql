
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `TotalGross`,
  `TotalProfit`,
  `ProfitRate`,
  `FeeGrossRate`,
  SaleShopCnt,
  SaleLstCnt,
OriProfitRate
  )
with
od_pay as (   -- ���۶���˿����ݣ��������˿�����
select ifnull(dep2,'��ٻ�') team
    ,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
	,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
    ,count(distinct shopcode) `����������`
    ,count(distinct concat(shopcode,SellerSku)) `����������`
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by grouping sets ((),(dep2))
)


,od_refund as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select ifnull(dep2,'��ٻ�') team
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '�˿�'
group by grouping sets ((),(dep2))
)

,ad_stat as (
    select  ifnull(ms.dep2,'��ٻ�') team  ,sum(AdSpend) AdSpend
    from import_data.wt_adserving_amazon_daily ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code
    where ad.GenerateDate >=date_add('${StartDay}',interval -1 day) and ad.GenerateDate <date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
)

select '${StartDay}' ,'${ReportType}' ,a.team ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,week_num_in_year
, sales_undeduct_refunds - ifnull(sales_refund,0) as sales
, round(profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0),2) as profit
,round( (profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0)) / (sales_undeduct_refunds - ifnull(sales_refund,0)) ,4) profit_rate
,�˷�����ռ�� ,���������� ,���������� ,round( ori_profit / ori_gross ,4 ) `�ҵ�������`
from od_pay a
left join od_refund b on a.team  = b.team
left join ad_stat c on a.team = c.team
join dim_date dd on dd.full_date = '${StartDay}';




insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
 `TotalGross`,
  `TotalProfit`,
  `ProfitRate`,
  `FeeGrossRate`,
  SaleShopCnt,
  SaleLstCnt,
OriProfitRate)
with
od_pay as (   -- ���۶���˿����ݣ��������˿�����
select nodepathname
    ,round( sum( case when TransactionType = '�˿�' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '�˿�' then 0
	    	when TransactionType='����' and left(SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
	,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
    ,count(distinct shopcode) `����������`
    ,count(distinct concat(shopcode,SellerSku)) `����������`
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by nodepathname
)


,od_refund as ( -- ���۶��Ӧ�˿�������Ӧ�˿��
select nodepathname
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='��ٻ�'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '�˿�'
group by nodepathname
)

,ad_stat as (
    select  nodepathname ,sum(AdSpend) AdSpend
    from import_data.wt_adserving_amazon_daily ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code
    where ad.GenerateDate >=date_add('${StartDay}',interval -1 day) and ad.GenerateDate <date_add('${NextStartDay}',interval -1 day)
    group by nodepathname
)

select '${StartDay}' ,'${ReportType}' ,a.nodepathname ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,week_num_in_year
, sales_undeduct_refunds - ifnull(sales_refund,0) as sales
, round(profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0),2) as profit
,round( (profit_undeduct_refunds - ifnull(profit_refund,0) - ifnull(AdSpend,0)) / (sales_undeduct_refunds - ifnull(sales_refund,0)) ,4) profit_rate
,�˷�����ռ�� ,���������� ,���������� ,round( ori_profit / ori_gross ,4 ) `�ҵ�������`
from od_pay a
left join od_refund b on a.nodepathname  = b.nodepathname
left join ad_stat c on a.nodepathname = c.nodepathname
join dim_date dd on dd.full_date = '${StartDay}';



-- �Ŷ����� ��������Ч
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`
  ,`NumberOfTeam` , `ProfitPerformance`)
select  '${StartDay}' ,'${ReportType}' ,b.EmpCount ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,EmpCount -- �Ŷ�����
    ,round(case when '${ReportType}' = '�ܱ�' then TotalProfit / 7 * day( date_add( date_format( date_add('${StartDay}', interval 1 month ) , '%Y-%m-01') ,-1) ) /b.EmpCount
        when '${ReportType}' = '�±�' then TotalProfit / day(date_add('${NextStartDay}',interval -1 day)) * day( date_add( date_format( date_add('${StartDay}', interval 1 month ) , '%Y-%m-01') ,-1) ) /b.EmpCount
    end,0) as ProfitPerformance
        -- �������Ч
from ads_ag_kbh_report_weekly a
join (
    select department  , EmpCount from ads_staff_stat where ReportType = '�±�' and department='��ٻ�' and FirstDay = (select max(FirstDay) from ads_staff_stat )
) b on a.Team = b.department
where a.FirstDay = '${StartDay}' and a.ReportType= '${ReportType}' ;


