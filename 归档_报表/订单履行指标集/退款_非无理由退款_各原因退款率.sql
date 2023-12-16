
select  
	sum(case when RefundReason1 ='�ִ���ԭ��' then RefundUSDPrice/ord_gross end) `�ִ�ԭ���˿���`
	,sum(case when RefundReason1 ='����ԭ��' then RefundUSDPrice/ord_gross end) `����ԭ���˿���`
	,sum(case when RefundReason1 ='��������' then RefundUSDPrice/ord_gross end) `���������˿���`
-- 	,sum(case when RefundReason1 ='��Ʒԭ��' then RefundUSDPrice/ord_gross end)`��Ʒԭ���˿���`
	,sum(case when RefundReason1 ='ȱ��' then RefundUSDPrice/ord_gross end) `ȱ��ԭ���˿���`
	,sum(case when RefundReason1 ='�ۺ�' then RefundUSDPrice/ord_gross end) `�ۺ�ԭ���˿���`
-- 	,sum(case when RefundReason1 ='�ͻ�ԭ��' then RefundUSDPrice/ord_gross end) `�������ɿͻ�ԭ���˿���`
from 
(select ro.RefundReason1 ,ro.RefundUSDPrice
FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource and s.ShopStatus = '����'
where RefundDate >= DATE_ADD('${FristDay}', interval -30 day) 
	and RefundDate < '${FristDay}' 
	and RefundReason2  not in ('�ͻ�����ԭ��', '������ȡ������') 
-- 	and IsShipment ='��'  -- �����Ƿ񷢻�
) A
,(SELECT sum(TotalGross/ExchangeUSD ) ord_gross
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) and PayTime < '${FristDay}' 
) B 

