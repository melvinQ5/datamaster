
select CreateDate,OrderNumber,BoxSku,PackageNumber
from import_data.daily_WeightOrders dwo 
where CreateDate = '2023-02-12'
group by CreateDate,OrderNumber,BoxSku,PackageNumber,PlatOrderNumber,ShopCode,TransportType,ShipWarehouse,PayStatus,
	PayTime,memo,CountryCode,Country,OrderStatus,ShipmentStatus,GroupOrderNumber,PackageSkuCount,
	WeightTime, Asin,SellerSku,Addtime,MarkShipTime,SecurityReturnedTime
having count(1) > 1 
