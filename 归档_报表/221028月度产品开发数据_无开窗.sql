/*
目标：按新类目1级回溯历史月份数据，计算月度出单指标、月累加出单指标
数据偏差：
	1.统一使用当前状态的数据，回溯4~10月在线状态链接、未删除sku、订单
代码结构：
	参数集：准备2张临时查询结果集（新类目映射、筛选后的产品表）
	结果集1：每月开发sku数（开发量）
	结果集2：每月在线链接数
	结果集3：月度出单指标、月累加出单指标
	导表数据集：
*/
with 
-- 参数集
newcateg as ( -- 新类目映射
select pp.id,pp.spu,pp.sku,bp.ChineseName,bpv.ChineseValueName
from erp_product_products pp
join import_data.erp_product_product_in_base_propertys pb on pp.id = pb.productid
join import_data.erp_product_product_base_propertys bp on pb.productbasepropertyid = bp.id
join import_data.erp_product_product_base_property_values bpv on pb.value = bpv.id
where ChineseName = '小组类别' and bpv.ChineseValueName is Not null
)

, tmp_epp as ( -- 给产品表增加辅助列（将不同开发人员的最早终审时间、正逆向等条件集合成一张临时表，供代码复用） 
select dev_month,dev_user,newpath1,BoxSKU,SKU 
from (
	select
		case when epp.DevelopUserName='金磊' and epp.DevelopLastAuditTime >= '2022-04-02' then '金磊'
	 	when epp.DevelopUserName='陈倩' and epp.DevelopLastAuditTime >= '2022-07-04' then '陈倩'
	 	when epp.DevelopUserName='李琴1688' and epp.DevelopLastAuditTime >= '2022-07-04' 
	 		and epp.SkuSource=1 then '李琴1688'
	 	when epp.DevelopUserName='杨梅' and epp.DevelopLastAuditTime >= '2022-07-04'then '杨梅'
	 	when epp.DevelopUserName='李云霞' and epp.DevelopLastAuditTime >= '2022-07-04' then '李云霞'
	 	when epp.DevelopUserName not in ('杨梅','李云霞','李琴1688','金磊') and epp.DevelopLastAuditTime >= '2022-04-01' 
	 		and epp.SkuSource=2 then '陈典明_GM转PM'
	 	end as dev_user -- 满足以上条件的对应开发人员
	 	, month(DevelopLastAuditTime) as dev_month
	 	, n.ChineseValueName as newpath1-- 新类目1级
	 	, epp.BoxSKU 
	 	, epp.SKU
	from import_data.erp_product_products epp
	join erp_product_product_category eppc on epp.ProductCategoryId =eppc.Id 
	join newcateg n on n.sku = epp.SKU -- 只计算有打新分类标签的sku
	where epp.DevelopLastAuditTime >= '2022-01-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0 
	) tmp
where dev_user is not null  -- 筛选产品部人员相关的产品表明细
group by dev_month,dev_user,newpath1,BoxSKU,SKU
)


-- 结果集1 每月开发sku数（开发量）
, audited_sku_cnt as ( 
select dev_month, dev_user, newpath1 , count(sku) as 每月终审通过SKU数
from tmp_epp
where dev_user is not null -- 只看符合开发人员、终审时间、正逆向相关条件的数据
group by dev_month, dev_user, newpath1
union all 
select dev_month, '合计' as dev_user, newpath1 , count(sku) as 每月终审通过SKU数
from tmp_epp
where dev_user is not null -- 只看符合开发人员、终审时间、正逆向相关条件的数据
group by dev_month,  newpath1
)

-- 结果集2 每月在线链接数
, join_listing as ( -- 关联订单明细并保留开发人员数据
select dev_month, Department , dev_user, newpath1,  eaal.Id , month(eaal.PublicationDate) as pub_month , PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join tmp_epp on  eaal.sku = tmp_epp.sku 
where eaal.ListingStatus = 1  and eaal.PublicationDate>'2022-01-01' and dev_month <= month(eaal.PublicationDate) 
)

, listing_online_cnt as ( -- 因为是回溯历史数据，以当前数据库状态的刊登时间小于次月第一天，视为当月在线链接
-- 每月共三组聚合粒度（group by）的链接数 
	select dev_month, 4 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-05-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 4 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-05-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 4 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-05-01' group by dev_month, newpath1
union all
	select dev_month, 5 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-06-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 5 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-06-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 5 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-06-01' group by dev_month, newpath1
union all
	select dev_month, 6 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-07-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 6 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-07-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 6 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-07-01' group by dev_month, newpath1
union all
	select dev_month, 7 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-08-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 7 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-08-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 7 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-08-01' group by dev_month, newpath1
union all
	select dev_month, 8 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-09-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 8 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-09-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 8 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-09-01' group by dev_month, newpath1
union all
	select dev_month, 9 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-10-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 9 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-10-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 9 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-10-01' group by dev_month, newpath1
union all
	select dev_month, 10 as online_month, Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-11-01' group by dev_month, Department, dev_user, newpath1
	union all 
	select dev_month, 10 as online_month, 'PM' as Department , dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-11-01' group by dev_month, dev_user, newpath1
	union all 
	select dev_month, 10 as online_month, 'PM' as Department , '合计' as dev_user, newpath1 , count(Id) `在线链接数`
	from join_listing where PublicationDate < '2022-11-01' group by dev_month, newpath1
)

-- 结果集3 月度出单指标 及 月累加出单指标
, join_orders as ( -- 筛选近期开发sku的订单明细
select tmp_epp.dev_month, ms.Department, tmp_epp.dev_user, tmp_epp.newpath1, b.TaxRatio
	, month(PayTime) as pay_month, od.*
from import_data.OrderDetails od 
join import_data.mysql_store ms on ms.Code = od.ShopIrobotId and ms.Department in ('销售二部', '销售三部')
left join 
	( -- 回溯历史当月汇率
	select left(firstday,7) as RatioMonth, DepSite, reporttype, TaxRatio
	from import_data.Basedata
	where reporttype = '月报' 
	group by RatioMonth, DepSite, reporttype, TaxRatio
	) b
	on b.DepSite = RIGHT(od.ShopIrobotId,2)  and b.RatioMonth = left(od.PayTime,7) 
join import_data.erp_product_products epp on od.BoxSku =epp.BoxSKU 
join tmp_epp on od.BoxSku =tmp_epp.BoxSKU 
where tmp_epp.dev_month <= month(PayTime) and od.PayTime >= '2022-01-01' 
	and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0
)

, ord_meric as ( -- 月度出单指标，共三组聚合粒度（group by）
	select dev_month, pay_month, Department , dev_user, newpath1 
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月度销售额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月度利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2)  `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month, Department, dev_user, newpath1 -- 类目+销售+开发
union all
	select dev_month, pay_month,'PM' as Department, dev_user, newpath1
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月度销售额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月度利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month, dev_user, newpath1 -- 类目+销售合计+开发
union all  
	select dev_month, pay_month,'PM' as Department, '合计' dev_user, newpath1
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月度销售额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月度利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month, newpath1 -- 类目+销售合计+开发合计
)

, ord_meric_running_total as ( -- 月累加出单指标，和月度指标代码一样，每个月有三组聚合粒度（group by）
-- 5月累加
	select dev_month, 5 as pay_month, Department , dev_user, newpath1 , count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-06-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 5 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率`
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-06-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 5 as pay_month,'PM' as Department, '合计' dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率`
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-06-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 6月累加
	select dev_month, 6 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率`
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-07-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 6 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-07-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 6 as pay_month,'PM' as Department, '合计' dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-07-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 7月累加
	select dev_month, 7 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-08-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 7 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-08-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 7 as pay_month,'PM' as Department, '合计' dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-08-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 8 月累加
	select dev_month, 8 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率`
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-09-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 8 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-09-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 8 as pay_month,'PM' as Department, '合计' dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-09-01' and pay_month >= dev_month group by dev_month, newpath1
	
union all -- 9 月累加
	select dev_month, 9 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率`
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-10-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 9 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-10-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 9 as pay_month,'PM' as Department, '合计' dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-10-01' and pay_month >= dev_month group by dev_month, newpath1
union all -- 10 月累加
	select dev_month, 10 as pay_month, Department , dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-11-01' and pay_month >= dev_month group by dev_month, Department, dev_user, newpath1
	union all
	select dev_month, 10 as pay_month,'PM' as Department, dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-11-01' and pay_month >= dev_month group by dev_month, dev_user, newpath1
	union all
	select dev_month, 10 as pay_month,'PM' as Department, '合计' dev_user, newpath1, count(distinct BoxSku) `月累加出单sku数`
		, round(sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加销售额USD` , round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount)/ExchangeUSD)) `月累加利润额USD` 
		, round(sum((if(TaxGross>0, TotalProfit, TotalProfit*(1-IFNULL(TaxRatio,0)))-RefundAmount))/sum((if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(TaxRatio,0)))-RefundAmount)),2) `月累加利润率` 
		, count(distinct PlatOrderNumber) `订单数`, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders where PayTime < '2022-11-01' and pay_month >= dev_month group by dev_month, newpath1
)

-- =============== 导excel表 ==================
-- ==== sheet1 月度出单指标
-- select o.*, a.每月终审通过SKU数, o.月度出单SKU数/a.每月终审通过SKU数 as `SKU动销率`
-- 	, l.在线链接数, round(o.出单链接数/l.在线链接数,4) as `链接动销率`
-- 	, round(l.在线链接数/a.每月终审通过SKU数,1) as `SKU平均在线链接数`
-- from listing_online_cnt l
-- left join ord_meric o
-- 	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.online_month and l.Department = o.Department
-- left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
-- where o.dev_user is not null 
-- order by dev_month, pay_month , dev_user, newpath1

-- ==== sheet2 月累计出单指标 + SKU动销率
select o.*, a.每月终审通过SKU数, o.月累加出单SKU数/a.每月终审通过SKU数 as `SKU动销率`
	, l.在线链接数, round(o.出单链接数/l.在线链接数,4) as `链接动销率`
	, round(l.在线链接数/a.每月终审通过SKU数,1) as `SKU平均在线链接数`
from listing_online_cnt l
left join ord_meric_running_total o
	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.online_month and l.Department = o.Department
left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
where o.dev_user is not null 
order by dev_month, pay_month , dev_user, newpath1
