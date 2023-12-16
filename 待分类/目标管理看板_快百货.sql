-- 快百货
with
-- 【Part1 数据集处理
dep as ( 
SELECT  sku as Code , BoxSku as Department
FROM JinqinSku js 
where js.Monday ='2023-02-08'
-- where js.BoxSku ='特卖汇'
)


, od as ( -- 订单表
select dep.Department, TotalGross, TotalProfit
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.Code 
left join dep on ms.Code = dep.code
where SettlementTime < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -1 month)
)

select Department, sum(TotalGross)/6.7995 SaleAmount, sum(TotalProfit)/6.7995 ProfitAmount
from od 
group by Department 


, pt as ( -- product_type 产品表 (新品、重点、其他) group by product_type
select Spu,  ProjectTeam ,DevelopLastAuditTime
from import_data.erp_product_products epp 
where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
	and IsMatrix = 1
)

, pt_wt as (
select Spu ,FirstOrderTimeCost , DevelopLastAuditTime, CreationTime ,FirstShangjiaTime 
from import_data.wt_products wp 
where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
)


-- , lw as ( -- local_warehouse 本地仓表
-- )
-- , po as ( -- PurchaseOrder 采购表
-- )
-- , pd as ( -- PackageDetail包裹表 
-- )
-- 【Part2 单一指标】

-- , sales as ( -- 销售额、利润额  
select Department, sum(TotalGross)/6.7995 SaleAmount, sum(TotalProfit)/6.7995 ProfitAmount
from od 
group by Department 
)

, prod_spu as (  -- 新品开发SPU数
select count(distinct Spu) new_spu_cnt
from pt 
-- where ProjectTeam in ('{dep1}')
)

, prod_sale_rate as ( -- 新品SPU N天动销率 
select round(tmp.ord14_sku_cnt/prod_spu.new_spu_cnt,3) d14_rate ,round(tmp.ord30_sku_cnt/prod_spu.new_spu_cnt,3) d30_rate
from (
	select count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 14 then spu end) ord14_sku_cnt
	, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 30 then spu end) ord30_sku_cnt
from pt_wt) tmp,prod_spu
)

-- , prod_sale_amount as ( -- 新品30天单产
-- )

-- , ad_meric as ( -- 新品广告点击率、转化率 新品定义  终审时间在2023年产品
-- select 
-- from 
-- )

-- , prod_time_cost ( -- 平均产品输入天数  
-- select avg(timestampdiff(DAY,CreationTime,FirstShangjiaTime))
-- from import_data.wt_products wp 
-- where CreationTime  < '${NextFirstDay}' and CreationTime >= date_add('${NextFirstDay}',interval -3 month)
-- and FirstShangjiaTime  < '${NextFirstDay}' and FirstShangjiaTime >= date_add('${NextFirstDay}',interval -1 month)

-- 按本月首次刊登  -- todo 看下分布情况
-- select timestampdiff(DAY,CreationTime,FirstShangjiaTime)
-- from import_data.wt_products wp 
-- where FirstShangjiaTime  < '${NextFirstDay}' and FirstShangjiaTime >= date_add('${NextFirstDay}',interval -1 month)
)


, weight_ontime ( -- 准时发货率 
select 1-A_cnt/B_cnt `2个工作日迟发率` 
from 
(select count(distinct dod.PlatOrderNumber) as A_cnt  
from 
  (select 
    case when DAYOFWEEK(OrderCountry_paytime) in (1,2,3,4) then date_add(OrderCountry_paytime,interval 1+2 day ) 
      when DAYOFWEEK(OrderCountry_paytime)  =5 then date_add( OrderCountry_paytime,interval 1+2+2 day )
      when DAYOFWEEK(OrderCountry_paytime)  =6 then date_add( OrderCountry_paytime,interval 1+2+2 day )
      when DAYOFWEEK(OrderCountry_paytime)  =7 then date_add( OrderCountry_paytime,interval 1+2+1 day )
    end as latest_WeightTime ,paytime ,DAYOFWEEK(OrderCountry_paytime)
    ,PlatOrderNumber
  from (SELECT PlatOrderNumber ,PayTime ,utc_area ,right(od.ShopIrobotId ,2)
    ,convert_tz(PayTime, 'Asia/Shanghai',utc_area ) OrderCountry_paytime
    from import_data.daily_OrderDetails  od
    join ( -- 只看店铺状态非冻结的订单数据
      select DISTINCT ShopCode 
      from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
      join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
      where AmazonShopHealthStatus != 4 
      and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
      ) tmp on tmp.shopcode = od.ShopIrobotId
    left join
      (SELECT CASE WHEN SKU='GB' THEN 'UK' ELSE SKU END AS code , boxsku as utc_area  
      FROM import_data.JinqinSku where monday='2023-12-20' ) js on js.code=right(od.ShopIrobotId ,2) 
    where PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
      and TransactionType ='付款' and totalgross > 1  
    ) tmp
  )dod
left join import_data.daily_PackageDetail dpd on dod.PlatOrderNumber = dpd.PlatOrderNumber  
where timestampdiff(second, latest_WeightTime, dpd.WeightTime) <= 86400 * 2  -- 0表示 后续调整增加时区和工作日
) A
,(SELECT count(distinct PlatOrderNumber) B_cnt
from import_data.daily_OrderDetails dod 
join ( -- 只看店铺状态非冻结的订单数据
  select DISTINCT ShopCode 
  from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
  join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
  where AmazonShopHealthStatus != 4 
  and CreationTime >= CURRENT_DATE()-1 -- 使用跑数时昨天的最新状态
  ) tmp on tmp.shopcode = dod.ShopIrobotId
where 
  PayTime < date_add('${FristDay}',-4) and PayTime >= date_add('${FristDay}',interval -7-4 day)
  and TransactionType ='付款' and totalgross > 1
) B  -- 付款时间推至本周三及往前滚7天， 留够发货时间
)

, delivery_ontime as ( -- 准时妥投率
-- 准时交货率
-- OrderCount为null，因此使用 分子/比率=分母
-- 准时交货率部分数据 count=0 rate=0, 如果对全表计算,相当于只记录了不准时的这部分的交货率？
select *
	,round(OnTimeDelivery_ord_cnt/monitor_ord_cnt,2)  as OnTimeDeliveryRate -- 准时交货率
	,round(unnormal_shop_cnt/monitor_shop_cnt,3)  as unnormal_status_Shop_Rate  -- 状态异常店铺比例
from (
select
	count( distinct case when OnTimeDeliveryStatus in (2,3) then tmp.ShopCode  end) as unnormal_shop_cnt -- 警告+危险，不含疑似冻结
	,count( distinct case when OnTimeDeliveryStatus=2  then tmp.ShopCode  end) as warning_shop_cnt -- 最新情况
	,count( distinct case when OnTimeDeliveryStatus=3 then tmp.ShopCode  end) as danger_shop_cnt
-- 	,count( distinct case when OnTimeDeliveryStatus=4 then tmp.ShopCode  end) as freeze_shop_cnt
	,sum(case when ItemType=9 then eaaspcd.Count end) as OnTimeDelivery_ord_cnt -- 准时交货订单数
	,sum(case when ItemType=9 then eaaspcd.Count/Rate*100 end) as monitor_ord_cnt -- 统计订单数
	,count(distinct tmp.ShopCode) monitor_shop_cnt
	,count( distinct case when ItemType=9 and eaaspcd.Count>0 then tmp.ShopCode  end) as OnTimeDelivery_shop_cnt
	-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
from import_data.erp_amazon_amazon_shop_performance_check_detail_sync eaaspcd 
join (
	select Id , ShopCode ,OnTimeDeliveryStatus
	from import_data.erp_amazon_amazon_shop_performance_check_sync eaaspc 
	join import_data.mysql_store ms on eaaspc.ShopCode =ms.Code and department in ('{dep1}','{dep2}','{dep3}','{dep4}')
	where AmazonShopHealthStatus != 4 
		and CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
	) tmp 
on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	and MetricsType = 3 -- 指标类型(1:订单缺陷指标,2:客户体验指标,3:追踪指标,4:买家与卖家联系指标,5:客户服务指标,6:退货不满意指标,7:商品真实性投诉,8:商品安全投诉,9:上架违规,10:知识产权投诉)
	and DateType = 7 -- 统计期
) tmp2
)



, po_product as ( -- `采购产品金额`

)


, po_Freight as ( -- `采购运费`
)


, delivery_purchase_amount as ( -- `发货订单采购金额usd`
)





, metric_set as (
select lw.category, lw.department, lw.ReportType, lw.static_date, lw.product_tupe
  ,lw.`在仓产品金额`, lw.`在仓sku件数`, lw.`在仓sku数`, pp.`采购产品金额`, pf.`采购运费`, dpa.`发货订单采购金额usd`
  ,lssr.`当周在仓SKU动销率`
from local_w lw
left join po_product pp
  on lw.category=pp.category and lw.department=pp.department 
  and lw.ReportType=pp.ReportType and lw.static_date=pp.static_date and lw.product_tupe=pp.product_tupe
left join more  -- 更多的表
)

-- -- 【第3部分 复合计算指标】
select category, department, ReportType, static_date, product_tupe
  round((`在仓产品金额`+`采购产品金额`+`采购运费`)/usdratio) as `本地库存金额`
  , round((`在仓产品金额`+`采购产品金额`+`采购运费`)/usdratio/`发货订单采购金额usd`*7)  as `本地仓库存周转天数`
from metric_set m