-- ����ʱ��Ϊ��30��Ķ�����״̬=������ƥ���˿�ԭ���ֲ��ǿͻ�����ȡ���Ķ���
SELECT  
	round(count(DISTINCT CASE when OrderStatus = '����' and memo not like '%�ͻ�ȡ��%' then PlatOrderNumber end)/count(distinct PlatOrderNumber),4) as `���϶�����`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.ShopCode =ms.Code and ms.ShopStatus = '����'  and wo.IsDeleted = 0 
where PayTime >= DATE_ADD('${FristDay}', interval -30 day) 
	and PayTime < '${FristDay}'