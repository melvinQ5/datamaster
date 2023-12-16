select 
	'${NextStartDay}' `统计日`
	,a.department `部门`
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`),0) `本地仓库存资金占用`
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额`*datediff('${NextStartDay}','${StartDay}'),1) `库存周转天数`
	, concat('${StartDay}','至','${NextStartDay}' ) `周转天数统计期`
	,`发货订单采购金额`
	,`在仓sku件数`,`在仓sku数` 
	,`在途产品采购金额`, `在途产品采购运费` , `在仓产品金额`
from
(
select case when department is null THEN '公司' ELSE department END AS department
	, sum(Price - DiscountedPrice) `在途产品采购金额` , ifnull(sum(SkuFreight),0) `在途产品采购运费`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp 
	join ( select BoxSku ,projectteam as department from wt_products ) tmp on wp.BoxSku = tmp.BoxSku 
	where ordertime < '${NextStartDay}'
		and isOnWay = "是" and WarehouseName = '东莞仓'
	) tmp	
group by grouping sets ((),(department))
) a 

left join (
	SELECT case when department is null THEN '公司' ELSE department END AS department  
		,sum(ifnull(TotalPrice,0)) `在仓产品金额`, sum(ifnull(TotalInventory,0)) `在仓sku件数`, count(*) `在仓sku数` 
	FROM ( -- local_warehouse 本地仓表
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products ) tmp on wi.BoxSku = tmp.BoxSku 
		where WarehouseName = '东莞仓' and TotalInventory > 0 and CreatedTime = date_add('${NextStartDay}',-1)
		)  tmp 
	group by grouping sets ((),(department))
) b on a.department = b.department

left join (	
	select case when department is null THEN '公司' ELSE department END AS department 
		, round(sum(pc)) `发货订单采购金额` 
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,department
		from import_data.daily_PackageDetail pd 
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.ods_orderdetails od 
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0 
				and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0  
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' and pd.WarehouseName='东莞仓'
		) a 
	group by grouping sets ((),(department))
) c on a.department = c.department
where `发货订单采购金额` is not null 