-- 结算时间版
select week_num_in_year  周次
    ,max( case when year = 2022 then right(date_format(full_date, '%Y%m%d'),6) end ) 周一22
    ,ifnull(max( case when year = 2023 then right(date_format(full_date, '%Y%m%d'),6) end ),'-') 周一23
    ,ifnull( concat(max( case when year = 2023 then month end ),'月'),'-') 月份23
    ,'-' mark
    ,round( sum( case when year = 2022 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end)/10000,2) as 22年业绩
    ,round( sum( case when year = 2023 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end)/10000,2) as 23年业绩
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code and ms.Department REGEXP '快百货'
left join dim_date dd on date(wo.settlementtime) = dd.full_date
where settlementtime >='${StartDay}' and settlementtime<'${EndDay}' and wo.IsDeleted=0
group by week_num_in_year
order by week_num_in_year;

-- 付款时间 处理退款版
select
     周次, 周一22, 周一23, 月份23, mark
     , round( (`22年业绩` - ifnull(refunds,0))/10000 ,2)as 22年业绩
     , round( (`23年业绩` - ifnull(refunds,0))/10000 ,2)as 23年业绩
from (
select week_num_in_year  周次
    ,max( case when year = 2022 then right(date_format(full_date, '%Y%m%d'),6) end ) 周一22
    ,ifnull(max( case when year = 2023 then right(date_format(full_date, '%Y%m%d'),6) end ),'-') 周一23
    ,ifnull( concat(max( case when year = 2023 then month end ),'月'),'-') 月份23
    ,'-' mark
    ,round( sum( case when year = 2022 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end),2) as 22年业绩
    ,round( sum( case when year = 2023 then (TotalGross + abs(RefundAmount) )/ExchangeUSD end),2) as 23年业绩
from import_data.wt_orderdetails wo
join mysql_store ms on wo.shopcode=ms.Code and ms.Department REGEXP '快百货'
left join dim_date dd on date(wo.paytime) = dd.full_date
where paytime >='${StartDay}' and paytime<'${EndDay}' and wo.IsDeleted=0
group by week_num_in_year
) a
left join (
select week_num_in_year
     ,abs(round(sum(RefundUSDPrice),2)) refunds
from daily_RefundOrders rf
join mysql_store ms on rf.OrderSource=ms.Code and ms.Department REGEXP '快百货'
left join dim_date dd on date(rf.RefundDate) = dd.full_date
where RefundDate >='${StartDay}' and RefundDate<'${EndDay}' and rf.RefundStatus='已退款'
group by week_num_in_year
) b on  a.周次 = b.week_num_in_year
order by 周次
