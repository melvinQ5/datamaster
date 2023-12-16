with 
t_orde as (
select 
	  round( sum((TotalGross)/ExchangeUSD),2) `结算销售额`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
-- where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 -- 周报
 where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.Department regexp '快百货|特卖汇'

)

,t_refd as (
select sum(RefundUSDPrice) `退款金额`
from import_data.daily_RefundOrders rf 
join import_data.mysql_store ms
	on rf.OrderSource=ms.Code and RefundStatus ='已退款'
		and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
		and ms.Department regexp '快百货|特卖汇'

)

select round(`退款金额`/`结算销售额`,6) `退款率`
from t_orde join t_refd 

0.057095