-- ������

select count( distinct ShopCode) MonitorShopCount
from import_data.erp_amazon_amazon_shop_performance_check_sync  eaaspc 
join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code AND ms.ShopStatus = '����'
where AmazonShopHealthStatus != 4 
and CreationTime <'${FristDay}' and CreationTime >= DATE_ADD('${FristDay}', interval -7 day) -- ÿ���賿0�������


-- ʹ����������
--  select WEEKOFYEAR(Monday)+1 
--  		,count(DISTINCT case when SiteStatus in ('����','ͣ�÷���') then ShopCode end)
--  from import_data.ShopPerformance sp 
--  join import_data.mysql_store ms on sp.ShopCode =ms.Code and department in ('���۶���','��������')
--  where ReportType ="�ܱ�"
--  group by WEEKOFYEAR(Monday)+1 
--  order by WEEKOFYEAR(Monday)+1


