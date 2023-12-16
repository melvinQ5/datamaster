/*
10月终审10月当月业绩
*/

with 
newcateg as ( -- 新类目映射
select pp.id,pp.spu,pp.sku,bp.ChineseName,bpv.ChineseValueName
from erp_product_products pp
join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
where ChineseName = '小组类别' and bpv.ChineseValueName is Not null
)

, tmp_epp as (
select
	n.ChineseValueName as newpath1-- 新类目1级
 	, epp.BoxSKU 
 	, epp.SKU 
 	, epp.SPU 
 	, epp.DevelopLastAuditTime 
 	, epp.DevelopUserName 
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime)+1 as dev_week 
from import_data.erp_product_products epp
join newcateg n on n.sku = epp.SKU -- 只计算有打新分类标签的sku
where epp.DevelopLastAuditTime >= '2022-10-01' and epp.DevelopLastAuditTime <= '2022-10-31' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
)

, orders as ( 
select * from (
	select tmp.* 
		, datediff(min_paytime,DevelopLastAuditTime) as ord_days -- 出单时长
	from (
		select od.PlatOrderNumber, epp.DevelopLastAuditTime, od.PayTime , ms.Department, epp.newpath1
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.ShopIrobotId, od.SellerSku
			, tmp_min.min_paytime 
-- 			, b.OrderNumber
			, (if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalGross
			, (if(TaxGross>0, TotalProfit, TotalProfit-(TotalGross*IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalProfit
		from import_data.OrderDetails od
		join import_data.mysql_store ms on ms.Code = od.ShopIrobotId 
			and ms.Department in ('销售二部', '销售三部') and PayTime >= '2022-05-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join (select BoxSku, min(PayTime) as min_paytime from import_data.OrderDetails od1
			join import_data.mysql_store ms1 on ms1.Code = od1.ShopIrobotId and ms1.Department in ('销售二部', '销售三部') and PayTime >= '2022-05-01'
			where TransactionType = '付款'  and OrderStatus <> '作废' group by BoxSku) tmp_min on tmp_min.BoxSku =od.BoxSku 
		left join 
			( -- 回溯历史当月需过滤订单
			select OrderNumber , pay_month
			from (select left(PayTime,7) as pay_month, OrderNumber, GROUP_CONCAT(TransactionType) alltype 
				FROM import_data.OrderDetails where ShipmentStatus = '未发货' and OrderStatus = '作废' and PayTime >= '2022-05-01'
				group by OrderNumber, pay_month) a
			where alltype = '付款'
			) b 
			on b.OrderNumber = od.OrderNumber and b.pay_month = left(od.PayTime,7)
		left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
		where  b.OrderNumber is null 
		) tmp
	) tmp2 
)

, join_listing as ( 
select t.newpath1, t.SPU, t.SKU, t.BoxSku, t.DevelopUserName, SkuSource_cn, DevelopLastAuditTime
	, eaal.PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join tmp_epp t on  eaal.sku = t.SKU 
where eaal.ListingStatus = 1  
)

-- sku明细输出
select newpath1, round(sum(AfterTax_TotalGross),2) `累计收入`
from orders od
group by newpath1
