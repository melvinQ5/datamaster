 select left(PayTime,7) pay_month ,ms.Department 
 		,count(distinct case when OrderStatus <> '����' then PlatOrderNumber end) δ���϶�����
 		,sum(case when OrderStatus <> '����' then TotalGross/ExchangeUSD end ) ���۶�
        ,round( sum(case when OrderStatus <> '����' then TotalGross/ExchangeUSD end )/count(distinct case when OrderStatus <> '����' then PlatOrderNumber end),4) `ƽ���͵���`
        ,round( count(distinct case when OrderStatus = '����' then PlatOrderNumber end)/count(distinct  PlatOrderNumber ),4) `���϶�����`

from import_data.wt_orderdetails wo
join import_data.mysql_store  ms on wo.shopcode=ms.Code
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0  and ms.Department  regexp '��ٻ�|������'
group by left(PayTime,7) ,ms.Department 
order by  pay_month ,ms.Department 