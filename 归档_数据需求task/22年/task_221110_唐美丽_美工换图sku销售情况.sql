-- ������һ�±�1�Ĳ�Ʒ��֧��ʱ����7.1������ĵ��������۶��������[����]ȡPM�Ŷӵ�ҵ��. ����ҵ����������ǰ���������ͼ

select tmp_epp.BoxSku
	, count(distinct PlatOrderNumber) `������`
	, count(distinct to_date(PayTime)) `��������`
	, sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD) as AfterTax_TotalGross
from import_data.OrderDetails od 
join (select BoxSku from import_data.JinqinSku js where Monday='2022-11-10') tmp_epp on od.BoxSku =tmp_epp.BoxSKU
join import_data.mysql_store ms on ms.Code = od.ShopIrobotId and ms.Department in ('���۶���', '��������')
left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
left join 
	( 
	select OrderNumber from (select OrderNumber, GROUP_CONCAT(TransactionType) alltype 
		FROM import_data.OrderDetails od
		where ShipmentStatus = 'δ����' and OrderStatus = '����' and SettlementTime >= '2021-01-01'
		group by OrderNumber) a
	where alltype = '����'
	) b 
	on b.OrderNumber = od.OrderNumber
where b.OrderNumber is null  
	and od.PayTime >= '2022-07-01' and od.PayTime <='2022-11-09'
	and od.TransactionType = '����' and od.OrderStatus <> '����' and od.OrderTotalPrice > 0
group by tmp_epp.BoxSku


