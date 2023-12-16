-- ����ʱ���
select week_num_in_year  �ܴ�
    ,max( case when year = 2022 then right(date_format(full_date, '%Y%m%d'),6) end ) ��һ22
    ,ifnull(max( case when year = 2023 then right(date_format(full_date, '%Y%m%d'),6) end ),'-') ��һ23
    ,ifnull( concat(max( case when year = 2023 then month end ),'��'),'-') �·�23
    ,'-' mark
    ,round( sum( case when year = 2022 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end)/10000,2) as 22��ҵ��
    ,round( sum( case when year = 2023 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end)/10000,2) as 23��ҵ��
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code and ms.Department REGEXP '��ٻ�'
left join dim_date dd on date(wo.settlementtime) = dd.full_date
where settlementtime >='${StartDay}' and settlementtime<'${EndDay}' and wo.IsDeleted=0
group by week_num_in_year
order by week_num_in_year;

-- ����ʱ�� �����˿��
select
     �ܴ�, ��һ22, ��һ23, �·�23, mark
     , round( (`22��ҵ��` - ifnull(refunds,0))/10000 ,2)as 22��ҵ��
     , round( (`23��ҵ��` - ifnull(refunds,0))/10000 ,2)as 23��ҵ��
from (
select week_num_in_year  �ܴ�
    ,max( case when year = 2022 then right(date_format(full_date, '%Y%m%d'),6) end ) ��һ22
    ,ifnull(max( case when year = 2023 then right(date_format(full_date, '%Y%m%d'),6) end ),'-') ��һ23
    ,ifnull( concat(max( case when year = 2023 then month end ),'��'),'-') �·�23
    ,'-' mark
    ,round( sum( case when year = 2022 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end),2) as 22��ҵ��
    ,round( sum( case when year = 2023 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end),2) as 23��ҵ��
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code and ms.Department REGEXP '��ٻ�'
left join dim_date dd on date(wo.paytime) = dd.full_date
where paytime >='${StartDay}' and paytime<'${EndDay}' and wo.IsDeleted=0
group by week_num_in_year
) a
left join (
select week_num_in_year
     ,abs(round(sum(RefundUSDPrice),2)) refunds
from daily_RefundOrders rf
join mysql_store ms on rf.OrderSource=ms.Code and ms.Department REGEXP '��ٻ�'
left join dim_date dd on date(rf.RefundDate) = dd.full_date
where RefundDate >='${StartDay}' and RefundDate<'${EndDay}' and rf.RefundStatus='���˿�'
group by week_num_in_year
) b on  a.�ܴ� = b.week_num_in_year
order by �ܴ�
