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
		epp.DevelopUserName as dev_user -- 满足以上条件的对应开发人员
	 	, month(DevelopLastAuditTime) as dev_month
	 	, n.ChineseValueName as newpath1-- 新类目1级
	 	, epp.BoxSKU 
	 	, epp.SKU
	  	, epp.SkuSource 
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
union all 
	select dev_month, '合计' as dev_user, '合计' newpath1 , count(sku) as 每月终审通过SKU数
	from tmp_epp
	where dev_user is not null 
	group by dev_month
)

-- 结果集2 每月在线链接数
, join_listing as ( -- 关联订单明细并保留开发人员数据
select dev_month, Department , dev_user, newpath1, eaal.Id , month(eaal.PublicationDate) as pub_month , PublicationDate
from import_data.erp_amazon_amazon_listing eaal 
join import_data.mysql_store ms on eaal.ShopCode = ms.code and ms.Department in ('销售二部', '销售三部') and ms.ShopStatus='正常'
join tmp_epp on  eaal.sku = tmp_epp.sku 
where eaal.ListingStatus = 1  and eaal.PublicationDate>'2022-01-01' and dev_month <= month(eaal.PublicationDate) 
)

, listing_online_cnt as ( -- 因为是回溯历史数据，以当前数据库状态的刊登时间小于次月第一天，视为当月在线链接
-- 每月共三组聚合粒度（group by）的链接数 
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `在线链接数`
	from (select dev_month, Department, dev_user, newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, Department, dev_user, newpath1, pub_month ) a 
union all 
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `在线链接数`
	from (select dev_month, 'PM' as Department, dev_user, newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, dev_user, newpath1, pub_month ) a 
union all 
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `在线链接数`
	from (select dev_month, 'PM' as Department, '合计' as dev_user, newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, newpath1, pub_month ) a 
union all -- 总合计
	select dev_month, Department, dev_user, newpath1, pub_month
		, sum(cnt) over(partition by dev_month, Department, dev_user, newpath1 order by pub_month) as `在线链接数`
	from (select dev_month, 'PM' as Department, '合计' as dev_user, '合计' as newpath1, pub_month , count(Id) as cnt
		from join_listing group by dev_month, pub_month ) a 
)

-- 结果集3 月度出单指标 及 月累加出单指标
, join_orders as ( -- 筛选近期开发sku的订单明细
select tmp_epp.dev_month, ms.Department, tmp_epp.dev_user, tmp_epp.newpath1
	, month(PayTime) as pay_month, concat(SellerSku, ShopIrobotId) as ord_listing_id
	, (if(TaxGross>0, TotalGross, TotalGross*(1-IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalGross
	, (if(TaxGross>0, TotalProfit, TotalProfit-(TotalGross*IFNULL(ratio,0)))-RefundAmount)/ExchangeUSD as AfterTax_TotalProfit
	, od.*
from import_data.OrderDetails od 
join import_data.mysql_store ms on ms.Code = od.ShopIrobotId and ms.Department in ('销售二部', '销售三部')
-- left join 
-- 	( -- 回溯历史当月汇率
-- 	select left(firstday,7) as RatioMonth, DepSite, reporttype, TaxRatio
-- 	from import_data.Basedata
-- 	where reporttype = '月报' 
-- 	group by RatioMonth, DepSite, reporttype, TaxRatio
-- 	) t
-- 	on t.DepSite = RIGHT(od.ShopIrobotId,2)  and t.RatioMonth = left(od.PayTime,7) 
left join import_data.TaxRatio t on RIGHT(od.ShopIrobotId,2)=t.site 
join import_data.erp_product_products epp on od.BoxSku =epp.BoxSKU 
join tmp_epp on od.BoxSku =tmp_epp.BoxSKU
left join 
	( -- 回溯历史当月需过滤订单
	select OrderNumber from (select OrderNumber, GROUP_CONCAT(TransactionType) alltype 
		FROM import_data.OrderDetails od
		where ShipmentStatus = '未发货' and OrderStatus = '作废' and SettlementTime >= '2021-01-01'
		group by OrderNumber) a
	where alltype = '付款'
	) b 
	on b.OrderNumber = od.OrderNumber
where b.OrderNumber is null  
	and tmp_epp.dev_month <= month(PayTime) and od.PayTime >= '2022-01-01' 
	and od.TransactionType = '付款' and od.OrderStatus <> '作废' and od.OrderTotalPrice > 0
)

, ord_meric as ( -- 月度出单指标，共三组聚合粒度（group by）
	select dev_month, pay_month, Department , dev_user, newpath1 
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum(AfterTax_TotalGross)) `月度销售额USD` 
		, round(sum(AfterTax_TotalProfit)) `月度利润额USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month, Department, dev_user, newpath1 -- 类目+销售+开发
union all
	select dev_month, pay_month,'PM' as Department, dev_user, newpath1
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum(AfterTax_TotalGross)) `月度销售额USD` 
		, round(sum(AfterTax_TotalProfit)) `月度利润额USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month, dev_user, newpath1 -- 类目+销售合计+开发
union all  
	select dev_month, pay_month,'PM' as Department, '合计' dev_user, newpath1
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum(AfterTax_TotalGross)) `月度销售额USD` 
		, round(sum(AfterTax_TotalProfit)) `月度利润额USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month, newpath1 -- 类目+销售合计+开发合计
union all  
	select dev_month, pay_month,'PM' as Department, '合计' dev_user, '合计' newpath1
		, count(distinct BoxSku) `月度出单sku数`
		, round(sum(AfterTax_TotalGross)) `月度销售额USD` 
		, round(sum(AfterTax_TotalProfit)) `月度利润额USD` 
		, round(sum(AfterTax_TotalProfit)/sum(AfterTax_TotalGross),2)  `月度利润率` 
		, count(distinct PlatOrderNumber) `订单数`
		, count(distinct concat(SellerSku, ShopIrobotId)) `出单链接数`
	from join_orders
	group by dev_month, pay_month -- 类目合计+销售合计+开发合计
)
-- 月累加出单sku数
-- 累加计算思路：对一个统计期内sku首次出单计1次，后续不再累计。
-- 具体做法：将每个分组出单boxsku 先按出单时间排序，对序号为1的值求和，最后对每个月份跨度求和
, ord_meric_running_total_partA as ( -- 月累加指标第一部分：去重的出单sku、出单链接、订单
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单sku数`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加订单数`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单链接数`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, Department, dev_user, newpath1, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, Department, dev_user, newpath1, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, Department, dev_user, newpath1, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month, Department, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, Department, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- 将每个分组出单boxsku 按pay_month排序	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
union all
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单sku数`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加订单数`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单链接数`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, dev_user, newpath1, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, dev_user, newpath1, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, dev_user, newpath1, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month,'PM' as Department, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- 将每个分组出单boxsku 按pay_month排序	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
union all
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单sku数`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加订单数`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单链接数`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, newpath1, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, newpath1, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, newpath1, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month,'PM' as Department, '合计' as dev_user, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- 将每个分组出单boxsku 按pay_month排序	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
union all
	select
		dev_month, Department, dev_user, newpath1, pay_month
		, sum(add_sku_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单sku数`
		, sum(add_ord_nub_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加订单数`
		, sum(add_ord_list_cnt)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month) as `月累加出单链接数`
	from (select dev_month, Department, dev_user, newpath1, pay_month, sum(case when BoxSku_nb=1 then 1 end) as add_sku_cnt
			, sum(case when PlatOrderNumber_nb=1 then 1 end) as add_ord_nub_cnt, sum(case when ord_listing_id_nb=1 then 1 end) as add_ord_list_cnt
		from (select ROW_NUMBER()over(partition by dev_month, BoxSku order by pay_month) as BoxSku_nb
				, ROW_NUMBER()over(partition by dev_month, PlatOrderNumber order by pay_month) as PlatOrderNumber_nb
				, ROW_NUMBER()over(partition by dev_month, ord_listing_id order by pay_month) as ord_listing_id_nb
				, dev_month,'PM' as Department, '合计' as dev_user, '合计' as newpath1, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			from join_orders where pay_month >= dev_month group by dev_month, pay_month, BoxSku, ord_listing_id, PlatOrderNumber
			) tmp1 -- 将每个分组出单boxsku 按pay_month排序	
		group by dev_month, Department, dev_user, newpath1, pay_month
		) tmp2
)

, ord_meric_running_total_partB as ( -- 月累加指标第二部分：
	select * , round(`月累加利润额USD`/`月累加销售额USD`,2) as `月累加利润率`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加销售额USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加利润额USD`
		from ( select dev_month, Department, dev_user, newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, Department, dev_user, newpath1, pay_month 
			) tmp1 
		) tmp2
union all
	select * , round(`月累加利润额USD`/`月累加销售额USD`,2) as `月累加利润率`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加销售额USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加利润额USD`
		from ( select dev_month,'PM' as Department, dev_user, newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, dev_user, newpath1, pay_month 
			) tmp1 
		) tmp2
union all
	select * , round(`月累加利润额USD`/`月累加销售额USD`,2) as `月累加利润率`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加销售额USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加利润额USD`
		from ( select dev_month,'PM' as Department, '合计' as dev_user, newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, newpath1, pay_month 
			) tmp1 
		) tmp2	
union all
	select * , round(`月累加利润额USD`/`月累加销售额USD`,2) as `月累加利润率`
	from ( select dev_month, Department, dev_user, newpath1, pay_month
		, round(sum(AfterTax_TotalGross_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加销售额USD`
		, round(sum(AfterTax_TotalProfit_m)over(partition by dev_month, Department, dev_user, newpath1 order by pay_month)) as `月累加利润额USD`
		from ( select dev_month,'PM' as Department, '合计' as dev_user, '合计' as newpath1, pay_month, sum(AfterTax_TotalGross) as AfterTax_TotalGross_m, sum(AfterTax_TotalProfit) as AfterTax_TotalProfit_m
			from join_orders where pay_month >= dev_month group by dev_month, pay_month 
			) tmp1 
		) tmp2	
)

, ord_meric_running_total as ( -- 月累加指标两部分合并
select a.dev_month, a.Department, a.dev_user, a.newpath1, a.pay_month
	, `月累加订单数`, `月累加销售额USD`, `月累加利润额USD`, `月累加利润率`, `月累加出单sku数`, `月累加出单链接数`
from ord_meric_running_total_partA a
join ord_meric_running_total_partB b 
	on a.dev_month=b.dev_month and a.Department=b.Department and a.dev_user=b.dev_user and a.newpath1=b.newpath1 and a.pay_month=b.pay_month
)

-- =============== 导excel表 ==================
-- ==== sheet1 月度出单指标
-- select o.dev_month `开发月份`, o.Department `销售部门`, o.dev_user `开发人员`, o.newpath1 `类目`, o.pay_month `出单月份`
-- 	, `订单数`, `月度销售额USD`, `月度利润额USD`, `月度利润率`, `月度出单sku数`, `出单链接数`
-- 	, a.每月终审通过SKU数, round(o.月度出单SKU数/a.每月终审通过SKU数,4) as `SKU动销率`
-- 	, l.在线链接数, round(o.出单链接数/l.在线链接数,4) as `链接动销率`
-- 	, round(l.在线链接数/a.每月终审通过SKU数,1) as `SKU平均在线链接数`
-- from listing_online_cnt l
-- left join ord_meric o
-- 	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.pub_month and l.Department = o.Department
-- left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
-- where o.dev_user is not null 
-- order by o.dev_month, o.pay_month , o.dev_user, o.newpath1

-- ==== sheet2 月累计出单指标 + SKU动销率
select o.dev_month `开发月份`, o.Department `销售部门`, o.dev_user `开发人员`, o.newpath1 `类目`, o.pay_month `出单月份`
	, `月累加订单数`, `月累加销售额USD`, `月累加利润额USD`, `月累加利润率`, `月累加出单sku数`, `月累加出单链接数`
	, a.每月终审通过SKU数, round(o.月累加出单SKU数/a.每月终审通过SKU数,4) as `累加SKU动销率`
	, l.在线链接数, round(o.月累加出单链接数/l.在线链接数,4) as `累加链接动销率`
	, round(l.在线链接数/a.每月终审通过SKU数,1) as `累加SKU平均在线链接数`
from listing_online_cnt l
left join ord_meric_running_total o
	on o.dev_month =l.dev_month  and o.dev_user=l.dev_user and o.newpath1=l.newpath1 and o.pay_month = l.pub_month and l.Department = o.Department
left join audited_sku_cnt a on o.dev_month =a.dev_month  and o.dev_user=a.dev_user and o.newpath1=a.newpath1
where o.dev_user is not null 
order by o.dev_month, o.pay_month , o.dev_user, o.newpath1
