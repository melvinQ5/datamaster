
insert into import_data.ads_ag_kbh_report_weekly (`FirstDay`, `ReportType`, `Team`, `Staff`, `Year`, `Month`, `Week`,
InventoryOccupied,InventoryTurnover)
select '${StartDay}' ,'${ReportType}' ,a.department ,'合计' ,year('${StartDay}') ,month('${StartDay}') ,WEEKOFYEAR('${StartDay}')+1
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/10000,0) `库存资金占用` -- 万元
	, round((`在途产品采购金额`+`在途产品采购运费`+`在仓产品金额`)/`发货订单采购金额`*datediff('${NextStartDay}','${StartDay}'),1) `库存周转天数`
from
(
select department , sum(Price - DiscountedPrice) `在途产品采购金额` , ifnull(sum(SkuFreight),0) `在途产品采购运费`
from (
	select Price ,DiscountedPrice , SkuFreight ,department
	from wt_purchaseorder wp
	join ( select BoxSku ,projectteam as department from wt_products ) tmp on wp.BoxSku = tmp.BoxSku
	where ordertime < '${NextStartDay}' and isOnWay = "是" and WarehouseName = '东莞仓' and department = '快百货'
	) tmp
group by department
) a
left join (
	SELECT department ,sum(ifnull(TotalPrice,0)) `在仓产品金额`, sum(ifnull(TotalInventory,0)) `在仓sku件数`, count(*) `在仓sku数`
	FROM ( -- local_warehouse 本地仓表
		select TotalPrice, TotalInventory ,department
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products ) tmp on wi.BoxSku = tmp.BoxSku
		where WarehouseName = '东莞仓' and TotalInventory > 0
		  and CreatedTime = date_add('${NextStartDay}',-1) and department = '快百货'
		)  tmp
	group by department
) b on a.department = b.department
left join (
	select department , round(sum(pc)) `发货订单采购金额`
	from ( select distinct(pd.OrderNumber), abs(od.PurchaseCosts) pc ,ms.department
		from import_data.daily_PackageDetail pd
		join import_data.mysql_store ms on ms.Code  = pd.SUBSTR(ChannelSource,instr(ChannelSource,'-')+1)
		join import_data.wt_orderdetails od
			on od.OrderNumber = pd.OrderNumber and od.BoxSku = pd.BoxSku and od.IsDeleted = 0
				and TransactionType ='付款' and orderstatus != '作废' and totalgross > 0
		where pd.weighttime < '${NextStartDay}' and pd.weighttime >= '${StartDay}' and pd.WarehouseName='东莞仓' and ms.department = '快百货'
		) a
	group by department
) c on a.department = c.department;

insert into manual_table (handletime ,memo ,handlename ,c1 ,c2 ,c3 ,c4 ,c5 )
select '${StartDay}' as 当期第一天 ,'总订单数' as 指标  ,'快百货' as 团队 ,'快百货周报指标表'
     ,count(distinct platordernumber)  ,0 ,0 ,'周报' type
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on wo.shopcode=ms.Code
where PayTime >= '${StartDay}' and  PayTime<'${NextStartDay}' and wo.IsDeleted=0 and TransactionType = '付款' and orderstatus != '作废';