

with 

-- step1 数据源处理 
t_key as ( -- 报表输出维度
select '公司' as dep
union select '快百货' 
union
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union
select NodePathName from import_data.mysql_store where department regexp '快' 
)



-- 库存资金占用
,t_warehouse_stat as (
select a.department as dep 
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/10000,0) `本地仓库存资金占用` -- 万元
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额`*datediff('${NextStartDay}','${StartDay}'),1) `库存周转天数`
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
) 


-- 呆滞库存占比 
-- 库龄大于等于365天的，计提100%
-- 库龄(180,365)天的：
-- 	库龄支撑天数大于365天部分，计提100%
-- 	库龄支撑天数(180，365]部分，计提50%
-- 	库龄支撑天数小于180天部分，计提0%
-- 库龄小于等于180天的，计提0%
-- 库龄支撑天数=该库龄的存货数量/统计日前三个月该产品日均销量

-- 针对 InventoryAgeAmount180 + InventoryAgeAmount270 数据，判断可售天数
, t_slow_moving_inve as (  -- 呆滞库存
select '公司' as dep
	,sum(case 
		when InventoryAgeOver>0 then InventoryAgeOver 
		when InventoryAge270*InventoryAge365 > 0 and `可售天数` > 365 then (InventoryAge270+InventoryAge365)
		when InventoryAge270*InventoryAge365 > 0 and `可售天数` > 180 and `可售天数` <=365  then (InventoryAge270+InventoryAge365)*0.5
	end)/10000 `计提呆滞库存金额` -- 万元
from import_data.daily_WarehouseInventory wi 
left join  
	(
	select wi.boxsku
		, SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver) `超过180天库存总数`
		, a.daily90 `近90天日均销量`
		, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365)+SUM(wi.InventoryAgeOver))/a.daily90,0) `可售天数` 
		, round((SUM(wi.InventoryAgeOver))/a.daily90,0) `大于365天部分的可售天数` 
		, round((SUM(wi.InventoryAge270)+SUM(wi.InventoryAge365))/a.daily90,0) `180到365的可售天数` 
	from import_data.daily_WarehouseInventory wi
	left join 
		( select wo.boxsku
			,round(sum(wo.SaleCount)/90,2) daily90 -- 90天日均销量
		from import_data.wt_orderdetails wo 
		where SettlementTime>=date_add('${StartDay}',interval -2 month) and wo.SettlementTime< '${NextStartDay}'
			and wo.ShipWarehouse='东莞仓' and isdeleted = 0 
		group by wo.boxsku
		) a 
	on wi.boxsku=a.boxsku
	where CreatedTime = date_add('${NextStartDay}',-1)
	group by wi.boxsku,a.daily90 having `超过180天库存总数`>0
	) tmp
	on wi.BoxSku = tmp.BoxSku
where wi.CreatedTime = date_add('${NextStartDay}',-1)
) 

-- step3 派生指标数据集
, t_merge as (
select t_key.dep `团队` 
	,`本地仓库存资金占用`
	,`库存周转天数`
	,`在仓sku件数`
	,`在仓sku数` 
	,`在途产品采购金额`
	,`在途产品采购运费` 
	,`在仓产品金额`
	,`发货订单采购金额`
	,`计提呆滞库存金额`
-- 	,`库存产品动销率`
from t_key
left join t_warehouse_stat on t_key.dep = t_warehouse_stat.dep
left join t_slow_moving_inve on t_key.dep = t_slow_moving_inve.dep
)

-- step4 复合指标 = 派生指标叠加计算
select 
	'${NextStartDay}' `统计日期`
	,t_merge.*
	,round(`在仓sku件数`/`在仓sku数`,4) `在仓SKU平均件数` 
	,round(`计提呆滞库存金额`/`本地仓库存资金占用`,4) `呆滞库存占比` 
from t_merge
order by `团队` desc 

