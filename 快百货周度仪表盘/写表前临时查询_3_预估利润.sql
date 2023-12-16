
-- ��վ�� Ԥ��������

with
ta as (
select ['UK-01','DE-02','FR-03','US-04','CA-05','AU-06','MX-07','ES-08','IT-09','NL-10','SE-11','BE-12'] arr
)

,tb as (
select *
from (select unnest as arr
	from ta ,unnest(arr)
	) tmp
)

, res as (
select
     a.site ,a.dep2
	,round( (gross_include_refunds -  ifnull(refunds,0) - ifnull(expend_include_ads,0) - ifnull(adspend,0) ) /
	        (gross_include_refunds - ifnull(refunds,0)) ,4) TotalProfit
	 ,right(arr,2)
from (
    select ifnull(ms.dep2,'��ٻ�') dep2
        ,ms.site
        ,round( sum((TotalGross - RefundAmount )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(
            -1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) )
            ,2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
        ,round( sum(FeeGross)/sum(TotalGross),4) `�˷�����ռ��`
        ,count(distinct shopcode) `����������`
        ,count(distinct concat(shopcode,SellerSku)) `����������`
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code 
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0
    group by grouping sets ((ms.site),(dep2,ms.site))
) a
left join (
    select ifnull(ms.dep2,'��ٻ�') dep2
        ,ms.site ,ifnull(sum(RefundUSDPrice),0) refunds
    from import_data.daily_RefundOrders rf
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on rf.OrderSource =ms.Code 
    where RefundStatus ='���˿�' and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
    group by grouping sets ((ms.site),(dep2,ms.site))
) b on  a.site = b.site and a.dep2 = b.dep2 
left join (
    select  ifnull(ms.dep2,'��ٻ�') dep2
        ,ms.site  ,sum(Spend) adspend
    from import_data.AdServing_Amazon ad
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on ad.shopcode=ms.Code 
    where ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
    group by grouping sets ((ms.site),(dep2,ms.site))
) c on  a.site = c.site and a.dep2 = c.dep2
left join tb on a.site = left(tb.arr,2)
order by right(arr,2)
)

select
    concat(dep2,site,'Ԥ��������') as ƥ����
    ,dep2 as �Ŷ�
    ,concat(site,'Ԥ��������') as �ؼ�ָ��
    ,TotalProfit as value
from res


