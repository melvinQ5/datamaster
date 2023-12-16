-- 仓库目前库存周转大于三十天的产品吗   数量多和价格比较高的1条回复

/* 目的：分析一下这些产品库存周转长的原因，业务优化
 * SKU统计范围：ERP产品库分组为 快百货
 * 库存周转天数：(`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额*统计天数
 * 		本次数据时间范围：获取近30天采购下单计算在途数据和发货订单产品金额（230108-230216）
 * 
 * 订单统计范围：快百货店铺所属订单, 付款时间 230108-230216
 * 日均出单sku件数（日均销量）=销售额 ÷ 统计天数（默认30天，当首次刊登时间距统计日不足30天，使用统计日-首次刊登时间）
 */


with stat as (
select b.BoxSku
	,发货订单采购金额
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额`*datediff('${NextStartDay}','${StartDay}'),1) `库存周转天数`
	,`在仓sku件数`,`在仓sku数` , `在仓产品金额`
from
 (
	SELECT BoxSku
		,sum(ifnull(TotalPrice,0)) `在仓产品金额`, sum(ifnull(TotalInventory,0)) `在仓sku件数`, count(*) `在仓sku数` 
	FROM ( -- local_warehouse 本地仓表
		select TotalPrice, TotalInventory , wi.BoxSku
		FROM import_data.daily_WarehouseInventory wi
		join (select BoxSku from import_data.erp_product_products epp  where projectteam = '快百货' and BoxSku is not null ) tmp 
			on wi.BoxSku = tmp.BoxSku 
		where WarehouseName = '东莞仓' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
		)  tmp 
	group by BoxSku 
) b 

left join (
select BoxSku
	, sum(Price - DiscountedPrice) `在途产品采购金额` , ifnull(sum(SkuFreight),0) `在途产品采购运费`
from (
	select Price ,DiscountedPrice , SkuFreight , wp.BoxSku
	from wt_purchaseorder wp 
	join (select BoxSku from import_data.erp_product_products epp  where projectteam = '快百货' and BoxSku is not null ) tmp 
		on wp.BoxSku = tmp.BoxSku 
	where  ordertime >= '${StartDay}' and ordertime < '${NextStartDay}'
		and isOnWay = "是" and WarehouseName = '东莞仓'
	) tmp	
group by BoxSku 
) a 
on a.BoxSku = b.BoxSku

left join (	
	select BoxSku , round(sum(pc)) `发货订单采购金额` 
	from ( select distinct pd.OrderNumber, pd.BoxSku , abs(od.PurchaseCosts) pc 
		from import_data.daily_PackageDetail pd 
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1) and Department = '快百货'
		join import_data.ods_orderdetails od 
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0 
				and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' 
		) a 
	group by BoxSku  
) c on a.BoxSku = c.BoxSku
)

, od as (
select wo.boxsku , round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) `销售额`  
from wt_orderdetails wo 
join stat on stat.boxsku = wo.BoxSku and IsDeleted = 0 
where IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' and Department = '快百货'
group by wo.BoxSku 
)

, lt as (
select wl.boxsku , min(PublicationDate) min_publicationdate
from stat
join wt_listing wl on stat.boxsku = wl.BoxSku and IsDeleted = 0 
group by wl.boxsku 

)

select wp.sku ,stat.boxsku
	, stat.`库存周转天数`
	, wp.ProductName `产品名称`
	, wp.cat1 
	, wp.cat2
	, wp.cat3 
	, wp.LastPurchasePrice `最新采购价`
-- 	, `近日均销量`
	, case when ProductStatus = 0 then '正常'
			when ProductStatus = 2 then '停产'
			when ProductStatus = 3 then '停售'
			when ProductStatus = 4 then '暂时缺货'
			when ProductStatus = 5 then '清仓'
		end as `产品状态`
	, `在仓产品金额`
	, `在仓sku件数`
	, DATE_FORMAT(CURRENT_DATE(),'%Y/%m/%d') `统计日期`
	, case when DATEDIFF(CURRENT_DATE(),min_publicationdate) <= 30 then round(`销售额`/DATEDIFF(CURRENT_DATE(),min_publicationdate),1)
		when DATEDIFF(CURRENT_DATE(),min_publicationdate) > 30 then round(`销售额`/30,1)
	end as `日均出单sku件数`
from stat
join import_data.wt_products wp on stat.boxsku = wp.boxsku and wp.isdeleted = 0 and `库存周转天数` >= 30
left join od on stat.boxsku = od.boxsku 
left join lt on stat.boxsku = lt.boxsku 
