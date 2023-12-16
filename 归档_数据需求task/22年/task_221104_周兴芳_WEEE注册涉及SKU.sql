/*
背景 ：给定一份sku明细，麻烦帮拉一下每个德国站这部分SKU的业绩以及对应占账号总业绩的比例和在线链接条数（按账号），
还有单独拉一份这些SKU今年的业绩数据和在线listing（按SKU）

表1 按账号统计德国站业绩及账号业绩占比
表2 按账号统计德国站在线链接数
表3 按SKU统计年内销售额和当前在线链接数
 */
with ords as (
select go.BoxSku,go.SPU,go.SKU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross
	,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku
	,od.ShopIrobotId,PlatOrderNumber,s.AccountCode 
from import_data.OrderDetails od
inner join proall_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
	on s.code = od.ShopIrobotId
	and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-10-31',interval -7 day)
and b.DepSite = s.Site
where  od.OrderNumber not in
	(
	select OrderNumber from (
	SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
	where ShipmentStatus = '未发货' and OrderStatus = '作废'
	group by OrderNumber) a
	where alltype = '付款')
)

, tmp_sku as ( 
select * from JinqinSku js where Monday = '2022-11-04'
)

-- 表1 每个德国站这部分SKU的业绩以及对应占账号总业绩的比例和在线链接条数（按账号）
, group_listing as ( -- 按账号统计链接
select  ms.AccountCode
	, count(1) `德国站在线链接数`
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join tmp_sku t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  and right(eaal.ShopCode,2)='DE' 
group by ms.AccountCode
)

, group_sku_account as ( -- 每个sku在每个账号下业绩，每个sku在每个账号下的德国站业绩
select AccountCode, `德国站销售额usd` 
	, round(`德国站销售额usd`/`对应账号总销售额usd`,2) as `账号总业绩占比`
from 
	(select 
		 AccountCode
		, round(sum(case when right(ords.ShopIrobotId,2)='DE' 
			then if(TaxGross>0,TotalGross,((TotalGross*(1-ifnull(TaxRatio,0)))-RefundAmount)/ExchangeUSD) end)) `德国站销售额usd`
		, round(sum(if(TaxGross>0,TotalGross,((TotalGross*(1-ifnull(TaxRatio,0)))-RefundAmount)/ExchangeUSD))) `对应账号总销售额usd`
	from ords join tmp_sku on ords.SKU = tmp_sku.SKU
	group by AccountCode) tmp 
where `德国站销售额usd` is not null  
)

-- select gsa.* , gl.*
-- from group_sku_account gsa 
-- left join group_listing gl  on gsa.AccountCode=gl.AccountCode

-- 表2
, group_listing_sku as ( 
select t.SKU , count(1) `在线链接数`
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join tmp_sku t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
group by t.SKU
)

, group_sku as ( -- 每个sku在每个账号下业绩，每个sku在每个账号下的德国站业绩
select tmp_sku.SKU
	, round(sum(if(TaxGross>0,TotalGross,((TotalGross*(1-ifnull(TaxRatio,0)))-RefundAmount)/ExchangeUSD))) `SKU22年销售额usd`
from ords join tmp_sku on ords.SKU = tmp_sku.SKU
where year(PayTime) = 2022
group by tmp_sku.SKU
)


select ts.Sku, ts.BoxSku, gs.`SKU22年销售额usd` , gls.`在线链接数`
from tmp_sku ts
left join group_sku gs on gs.SKU = ts.SKU
left join group_listing_sku gls on gls.SKU = ts.SKU
