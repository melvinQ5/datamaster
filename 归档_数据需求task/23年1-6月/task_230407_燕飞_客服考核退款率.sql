with 
t_orde as (
select 
	  round( sum((TotalGross)/ExchangeUSD),2) `�������۶�`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code
-- where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0 -- �ܱ�
 where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0 and ms.Department regexp '��ٻ�|������'

)

,t_refd as (
select sum(RefundUSDPrice) `�˿���`
from import_data.daily_RefundOrders rf 
join import_data.mysql_store ms
	on rf.OrderSource=ms.Code and RefundStatus ='���˿�'
		and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
		and ms.Department regexp '��ٻ�|������'

)

select round(`�˿���`/`�������۶�`,6) `�˿���`
from t_orde join t_refd 

0.057095