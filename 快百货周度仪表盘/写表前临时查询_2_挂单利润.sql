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
     a.dep2 ,a.site ,right(arr,2) sort
	,round( (gross_include_refunds - ifnull(expend_include_ads,0)  ) /
	        (gross_include_refunds) ,4) TotalProfit
from (
    select

        ifnull(ms.dep2,'��ٻ�') dep2
        ,ms.site
        ,round( sum((TotalGross )/ExchangeUSD),2) as gross_include_refunds -- ����������ӻض������˿���
        ,round( sum(-1*(TotalExpend/ExchangeUSD)  - ifnull((case when TransactionType='����' and left(SellerSku,10)='ProductAds' then -1*(AdvertisingCosts/ExchangeUSD) end),0) ),2) as expend_include_ads  -- ������ɱ��ӻض�������ɱ� ��������תΪ������������⹫ʽ��
    from import_data.wt_orderdetails wo
    join ( select case when NodePathName regexp  '�ɶ�' then '��ٻ��ɶ�' else '��ٻ�Ȫ��' end as dep2,*
	    from import_data.mysql_store where department regexp '��')  ms on wo.shopcode=ms.Code 
    where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 and FeeGross = 0 and OrderStatus <> '����'
      and TransactionType = '����'
    group by grouping sets ((ms.site),(dep2,ms.site))
) a
left join tb on a.site = left(tb.arr,2)
order by right(arr,2)
)

select
    concat(dep2,site,'�ҵ�������') as ƥ����
    ,dep2 as �Ŷ�
    ,concat(site,'�ҵ�������') as �ؼ�ָ��
    ,TotalProfit as value
from res


