-- �˿�ʱ��=ͳ���ܴΣ����˿�ԭ�򲻵��ڿͻ�����ȡ����ԭ��Ķ������/�ܶ������
select a/b `�ǿͻ�ԭ���˿���` from 
(select sum(ro.RefundUSDPrice) a FROM import_data.daily_RefundOrders ro
join import_data.mysql_store s on s.code = ro.OrderSource
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = s.code
where RefundDate >= DATE_ADD('${FristDay}', interval -7 day) and RefundDate < '${FristDay}' 
	and RefundReason2 not in ('�ͻ�����ԭ��', '������ȡ������') 
-- 	and IsShipment ='��'  -- �����Ƿ񷢻�
) A
,(SELECT sum(TotalGross/ExchangeUSD ) b
from import_data.wt_orderdetails dod  
join ( -- ֻ������״̬�Ƕ���Ķ�������
	select DISTINCT ShopCode 
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code 
-- 	and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where AmazonShopHealthStatus != 4 
	and CreationTime >= CURRENT_DATE()-1 -- ʹ������ʱ���������״̬
	) tmp on tmp.shopcode = dod.shopcode 
where PayTime >= DATE_ADD('${FristDay}', interval -7 day) and PayTime < '${FristDay}' 
	and isdeleted = 0
	and TransactionType ='����' and OrderStatus <> '����' and OrderTotalPrice>0
) B 
