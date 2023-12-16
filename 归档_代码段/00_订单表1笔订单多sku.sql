-- 订单明细表 本地仓运费为该订单包裹运费，还是分摊到sku运费
select *
from import_data.OrderDetails od2 
where OrderNumber in (
select OrderNumber
from import_data.OrderDetails od 
group by OrderNumber having count(distinct BoxSku)>1)