
/*销售额、利润额、订单量、出单的SKU数、出单的SPU数、出单的链接数计算*/
with ca as (
select go.BoxSku,go.SKU,go.SPU,go.DevelopLastAuditTime,Department,NodePathName,PayTime,TaxGross,TotalGross
	,TotalProfit,TaxRatio,RefundAmount,ExchangeUSD,TransactionType,OrderStatus,OrderTotalPrice,od.SellerSku
	,od.ShopIrobotId,PlatOrderNumber
from import_data.OrderDetails od
inner join proall_category as go
on go.BoxSKU=od.BoxSku
join import_data.mysql_store s
on s.code = od.ShopIrobotId
and s.Department in ('销售一部','销售二部','销售三部','销售四部')
left join import_data.Basedata b
on b.ReportType = '周报'
and b.FirstDay = date_add('2022-10-24',interval -7 day)
and b.DepSite = s.Site
where PayTime >= date_add('2022-10-24',interval -28 day)
and PayTime <'2022-10-24'
and od.OrderNumber not in
	(
	select OrderNumber from (
	SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
	where
	ShipmentStatus = '未发货' and OrderStatus = '作废'
	and PayTime >=date_add('2022-10-24',interval -28 day) and PayTime < '2022-10-24'
	group by OrderNumber) a
	where alltype = '付款')
)

/*所有部门小组新品*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-10-24') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTim

e>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门新品出单数及销售数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'/*所有销售部门新品*/
group by ca.Department
union
/*PM部门新品出单数据及销售数据*/
select '所有类目' as category,'PM' as department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'
and ca.Department in ('销售二部','销售三部')
union
/*所有部门新品出单数据及销售数据*/
select '所有类目' as category,'所有部门' as department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','新品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where DevelopLastAuditTime>=date_add('2022-10-24',interval -6 month ) and DevelopLastAuditTime<'2022-10-24'
union
/*重点产品数据*/
/*重点产品各小组数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and ca.Department in ('销售一部','销售二部','销售三部')/*所有销售部门小组新品*/
group by concat(ca.Department,'-',ca.NodePathName)
union
/*所有部门各部门重点产品数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
group by ca.Department
union
/*PM部门重点产品出单及销售数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
and Department in ('销售二部','销售三部')
union
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','重点产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
inner join lead_product as lp
on ca.BoxSku=lp.BoxSKU
union
/*其他产品-除新品及重点产品外其他产品*/
/*所有部门小组其他产品*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department ,'周报' as ReportType,weekofyear('2022-10-24') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
and ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门其他产品出单及销售数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
group by ca.Department
union
/*PM部门其他产品出单及销售数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
and Department in ('销售二部','销售三部')
union
/*PM部门其他产品出单及销售数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','其他产品' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.DevelopLastAuditTime<date_add('2022-10-24',interval -6 month )
and ca.BoxSKU not in (select BoxSKU from lead_product)
union
/*所有产品*/
/*所有部门小组出单及销售数据*/
select '所有类目' as category,concat(ca.Department,'-',ca.NodePathName) as department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售一部','销售二部','销售三部')
group by concat(ca.Department,'-',ca.NodePathName)
union
/*各部门所有产品出单及销售数据*/
select '所有类目' as category,ca.Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
group by ca.Department
union
/*PM部门出单及销售数据*/
select '所有类目' as category,'PM' as Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca
where ca.Department in ('销售三部','销售二部')
union
/*所有部门所有产品订单及销售数据*/
select '所有类目' as category,'所有部门' as Department,'周报' as ReportType,weekofyear('2022-10-24') as '周次','-' as product_tupe,
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then PlatOrderNumber  end ) '订单数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '当周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24' and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.SPU end ) '4周出单SPU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '当周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then ca.BoxSKU end ) '4周出单SKU数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '当周出单链接数',
count(distinct case when PayTime>=date_add('2022-10-24',interval -28 day) and PayTime<'2022-10-24'and TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 then concat(SellerSku,ShopIrobotId) end ) '4周出单链接数',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end),2)'当周销售额',
round(sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end),2)'当周利润额',
round((sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalProfit- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalProfit - TotalGross * ifnull(TaxRatio, 0))-RefundAmount)/ExchangeUSD end)/sum(case when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross>0 then (TotalGross- RefundAmount)/ExchangeUSD
      when PayTime>=date_add('2022-10-24',interval -7 day) and PayTime<'2022-10-24' and TaxGross<=0 then ((TotalGross * (1 - ifnull(TaxRatio, 0)))-RefundAmount)/ExchangeUSD end))*100,2) '当周利润率'
from ca






