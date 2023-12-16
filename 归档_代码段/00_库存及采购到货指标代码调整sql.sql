/*统计时间使用方式：EndDay 填下周的周一，故不用周次+1 */
-- 指标1 库存计算
with 
a1 as ( -- 在仓产品金额
SELECT weekofyear('${EndDay}') as static_date, sum(TotalPrice) `在仓产品金额`
FROM import_data.WarehouseInventory wi
where TotalInventory > 0 and WarehouseName = '东莞仓' and Monday = date_add('${EndDay}',interval -7 day) and ReportType = '周报'
)

, a2 as ( -- 采购产品金额  更改："完成状态为否 且 入库量=0"表示在途
select weekofyear('${EndDay}') as static_date, sum(Price - DiscountedPrice) `采购产品金额`  
from import_data.PurchaseOrder po
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '东莞仓' and Monday = date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
	and IsComplete = '否' and InstockQuantity = 0)
	
, a3 as (-- 采购运费  更改："完成状态为否 且 入库量=0"表示在途
select weekofyear('${EndDay}') as static_date, ifnull(sum(fr),0) `采购运费` 
from (select distinct PurchaseOrderNo , Freight fr from import_data.PurchaseOrder 
	where ordertime >= date_add('${EndDay}',interval -7 day) and ordertime < '${EndDay}' 
	and WarehouseName = '东莞仓' and Monday = date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
	and IsComplete = '否' and InstockQuantity = 0) tmp
)

, b as ( -- 发货订单金额  更改：on连接条件需要增加boxsku
select  weekofyear('${EndDay}') as static_date
	, round(sum(abs(od.PurchaseCosts))) `发货订单采购金额` 
from import_data.PackageDetail pd join import_data.OrderDetails od on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku 
where pd.weighttime < '${EndDay}' and pd.weighttime >= date_add('${EndDay}',interval -7 day)  
) 

select 
	`在仓产品金额`+`采购产品金额`+`采购运费` as `本地库存金额`
	, round((`在仓产品金额`+`采购产品金额`+`采购运费`)/`发货订单采购金额`*7) as `库存周转天数`
from a1,a2,a3,b



-- 指标2 5天采购到货率 
-- 更改：分子计算（当没有扫描时间，筛入库数量大于0且销单时间不为空，用销单时间-下单时间），分母计算（剔掉只存在人工完结记录的下单号）
select weekofyear('${EndDay}') as static_date
	, round(count(distinct in5days_rev_numb)/count(distinct actual_ord_numb),4) `采购5天到货率` 
from (
	select 
		case when scantime is not null and timestampdiff(second, ordertime, scantime) < 86400 * 5 then pr.OrderNumber -- 有扫描时间，且扫描时间 - 订单时间小于5天 的采购订单
		when scantime is null and instockquantity > 0 and CompleteTIme is not null 
		and timestampdiff(second, ordertime, CompleteTIme) < 86400 * 5 then pr.OrderNumber -- 没有扫描时间，入库数量大于零, 且入库时间 - 订单时间小于5天 的采购订单
		end as in5days_rev_numb -- 满足5天到货的下单号
		, case when instockquantity = 0 and IsComplete = '是' then null else po.OrderNumber end as actual_ord_numb -- 去掉只存在人工完结的下单单号
	from import_data.PurchaseOrder po
	left join (select OrderNumber, max(scantime) as scantime from import_data.PurchaseRev group by OrderNumber) pr 
		on po.OrderNumber = pr.OrderNumber
	where date_add(ordertime, 5)  >= date_add('${EndDay}',interval -7 day) and date_add(ordertime, 5) < '${EndDay}' 
		and WarehouseName = '东莞仓' and Monday < '${EndDay}' and Monday >= date_add('${EndDay}',interval -7 day) and ReportType = '周报' 
) tmp

/* 补充整理 对于采购单表的记录含义
instockquantity = 0 and IsComplete = '否'，采购在途
instockquantity = 0 and IsComplete = '是'，手工完结，实际没有到货
instockquantity > 0 and IsComplete = '否'，部分sku已到货，比如周报11月7日的OrderNumber =2877728
instockquantity > 0 and IsComplete = '是'，已到货
*/
	