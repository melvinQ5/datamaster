-- 1
select department
    ,b_deliv 订单数
     ,round(a_deliv_in7d/b_deliv,4) `订单7天发货率`
	,round(a_deliv_in5d/b_deliv,4) `订单5天发货率`
from
	(select ifnull(department,'合计') department
	    , count(distinct od_pre.OrderNumber ) b_deliv -- 7天发货率分母
		, count(distinct case when timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 7)
			and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in7d -- 7天订单发货率分子
        , count(distinct case when  timestampdiff(second, paytime, pd.WeightTIme) <= (86400 * 5)
        and timestampdiff(second, paytime, pd.WeightTIme) > 0 then pd.OrderNumber end ) a_deliv_in5d -- 5天订单发货率分子
	from
		( -- 获取近30天数据，用于分别往前推2天、5天、7天计算指标
		select PlatOrderNumber, OrderNumber , BoxSku ,ShipmentStatus, PayTime, ShipTime
			,ms.*
		from import_data.wt_orderdetails wo
		join mysql_store  ms on wo.shopcode=ms.Code  and wo.IsDeleted = 0 and wo.TransactionType = '付款' and ms.Department regexp '快百货|特卖汇'
		where PayTime <  date_add('${NextStartDay}',interval -7 day)  and PayTime >= '${StartDay}' -- 近7天的付款订单不计入
		) od_pre
	left join import_data.daily_PackageDetail pd on od_pre.OrderNumber =pd.OrderNumber  AND od_pre.boxsku =pd.boxsku
	group by grouping sets ((),(department))
	) tmp1;


-- 订单妥投率
with a as (
select
    v2.OnTimeDeliveryCount 准时交货订单数据
    ,t0.OnTimeDeliveryRate  准时交货率
    ,ifnull( ceil(OnTimeDeliveryCount / OnTimeDeliveryRate*100) ,0 ) 平台统计订单数
    ,t0.ShopCode
    ,ms.Department
from import_data.erp_amazon_amazon_shop_performance_checkv2_detail v2
join erp_amazon_amazon_shop_performance_check t0 on v2.AmazonShopPerformanceCheckId = t0.id
    and date(t0.CreationTime) = '2023-10-02'
	and ReportType = 48 and v2.ItemType = 24 and v2.DateType = 30 and v2.MetricsType = 20
join  mysql_store  ms on t0.shopcode=ms.Code  and ms.Department regexp '快百货|特卖汇'
order by t0.ShopCode
)

select Department,
    sum(准时交货订单数据) 准时交货订单数据_近30天,
    sum(平台统计订单数) 平台统计订单数_近30天,
    round( sum(准时交货订单数据) / sum(平台统计订单数) ,4 ) 准时交货率
from a group by Department;