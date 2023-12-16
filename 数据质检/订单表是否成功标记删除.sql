-- ͨ���Ա�δɾ����¼ռ�ȵľ��Ҳ���������֪���ʧ��
with a as (
select date(PayTime) pay_date
 ,count( case when IsDeleted = 1 then 1 end ) ��ɾ����¼��
 ,count( case when IsDeleted = 0 then 1 end ) δɾ����¼��
 ,count( 1 ) �ܼ�¼��

from import_data.ods_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on wo.ShopIrobotId=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
  -- and wo.IsDeleted=0
group by date(PayTime)
order by date(PayTime) desc)

select
    case when round( δɾ����¼�� / lag(δɾ����¼��,1) over ( order by pay_date ) ,2 ) >1.5 then 'δɾ����¼����' else '' end as ��ؽ��
    ,round( δɾ����¼�� / lag(δɾ����¼��,1) over ( order by pay_date ) ,2 ) ����
    ,*
from a
order by pay_date desc ;

-- ɾ���������ж������ݣ��Ƿ�ȫ��������ˣ�
select * from ods_orderdetails
where IsDeleted=0
and id in ( select id from daily_OrderDelete );


-- �쳣���� 1 ��
-- ɾ��������DorisImportTime��ÿ�����ϵ�8�㣨�����˽��գ�
-- ���ɾ�������� 2023-10-05
select max(DeleteTime) from daily_OrderDelete c where c.DorisImportTime >= '2023-09-01'
and c.DorisImportTime <= '2023-10-06';
-- ���ɾ�������� 2023-09-23
select max(DeleteTime) from daily_OrderDelete c where c.DorisImportTime >= '2023-09-01'
and c.DorisImportTime <= '2023-10-05';


-- ͨ���������۶����� �쳣�Ƿ�õ��������ɾ�����ʧ��ʱ�����۶��쳣���ߣ�
select
     '${StartDay}' ,'${ReportType}' ,a.team ,'�ϼ�' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
    ,round(gross_include_refunds - ifnull(refunds,0),2) TotalGross
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) /
	        (gross_include_refunds - ifnull(refunds,0)) ,4) ProfitRate
    ,`�˷�����ռ��`
    ,`����������`
    ,`����������`
    ,round( ori_profit / ori_gross ,4 ) `�ҵ�������`
from (
    select
        ifnull(ms.dep2,'��ٻ�') team
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
        ,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
        ,count(distinct shopcode) `����������`
        ,count(distinct concat(shopcode,SellerSku)) `����������`
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalGross/ExchangeUSD end ) ori_gross
        ,sum( case when FeeGross = 0 and OrderStatus <> '����' and TransactionType = '����' then TotalProfit/ExchangeUSD end ) ori_profit
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((),(ms.dep2))
) a

left join (
select ifnull(ms.dep2,'��ٻ�') team
     ,abs(round(sum((RefundAmount)/ExchangeUSD),2)) refunds
from wt_orderdetails wo
join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
    from import_data.mysql_store where department regexp '��')  ms on ms.code=wo.shopcode and ms.department='��ٻ�'
where wo.IsDeleted = 0 and TransactionType = '�˿�' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
group by grouping sets ((),(ms.dep2))
) b on  a.team = b.team

left join (
    select  ifnull(ms.dep2,'��ٻ�') team  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ�һ��' else '��ٻ�����' end as dep2,*
	    from import_data.mysql_store where department regexp '��') ms on ad.shopcode=ms.Code
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((),(ms.dep2))
) c on  a.team = c.team;
