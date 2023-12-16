-- Ԥ�����۶�
-- �������� TotalGross �Ѿ���ȥ���˿�͹�滨�ѣ���˼���Ԥ��ʱ����Ҫ�Ȱѡ��������еġ������롱�б���ȥ���˿�͹�滨�Ѹ��ӻ������ٷֱ�ӡ��˿���͡������м���õ�������۳�


select a.date ,a.department
    ,round(gross_include_refunds - ifnull(refunds,0),2) TotalGross
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) ,2) TotalProfit
from (
    select  date(paytime) date , ms.department
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
    from import_data.wt_orderdetails wo
    join mysql_store ms on wo.shopcode=ms.Code
    where PayTime >='${StartDay}' and PayTime<'${EndDay}' and wo.IsDeleted=0
    group by date(paytime) , ms.department
) a
left join (
    select date(RefundDate) date , department,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join mysql_store ms on rf.OrderSource=ms.Code
    where RefundStatus ='���˿�' and RefundDate>='${StartDay}' and RefundDate<'${EndDay}'
    group by date(RefundDate), department
) b on a.date = b.date and a.department = b.department
left join (
    select  date(CreatedTime) date , department,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join mysql_store ms on ad.ShopCode=ms.Code
    where ad.CreatedTime >='${StartDay}' and ad.CreatedTime<'${EndDay}'
    group by date(CreatedTime), department
) c on a.date = c.date and a.department = c.department

