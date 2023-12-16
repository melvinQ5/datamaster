select a.TransportId,round(c.物流原因退款包裹数/TotalPackageCount,4) 'RefundRate',
AvgDeliveryHour,round(b.StandardMaxTime-AvgDeliveryHour,1) 'StandardDeliveryCompared',TotalPackageCount,
DeliveryRate, StandardDeliveryRate,AbnormalPackageRate,CostPrice 
from
	(select TransportId,
	round(sum(DeliverHour)/count(distinct PackageNumber)/24,1) 'AvgDeliveryHour',/*平均时效*/
	count(distinct PackageNumber) 'TotalPackageCount',/*包裹总数*/
	round(count(distinct case when TrackingStatus=7 then PackageNumber end)/count(distinct PackageNumber),4) 'DeliveryRate',/*妥投率*/
	round(count(case when DeliverHour < StandardMaxTime and DeliverHour > 0 then PackageNumber end )/count(distinct PackageNumber),4) 'StandardDeliveryRate'/*标准妥投率*/,
	round(count(distinct case when TrackingStatus=8 then PackageNumber end)/count(distinct PackageNumber),4) 'AbnormalPackageRate',/*异常包裹率*/
	round(sum(PackageFeight)/sum(PackageTotalWeight),4) 'CostPrice'/*单价CNY RMB/g*/
	from erp_logistic_logistics_tracking lt
	left join import_data.erp_logistic_logistics_transports ellt2
	on lt.TransportId = ellt2.Id
	group by TransportId) a
left join
/*标准时效*/
(select id,StandardMaxTime from import_data.erp_logistic_logistics_transports) b
on a.TransportId=b.Id
left join
/*物流原因退款包裹数*/
(select TransportId,count(distinct PackageNumber) '物流原因退款包裹数' from erp_logistic_logistics_tracking lt
left join
(select distinct  OrderNumber  from wt_orderdetails
where RefundReason1 = '物流原因' and ShipTime>'2000-01-01') od
on lt.OrderNumber=od.OrderNumber
where od.OrderNumber is not null
group by TransportId) c
on a.TransportId=c.TransportId


SELECT 
	round(sum(DeliverHour)/24/count(distinct case when DeliverHour>0 then PackageNumber end ),5) 'avg' 
	, round(sum(DeliverHour)/24/count(distinct PackageNumber ),5) 'avg' 
-- select to_date(WeightTime) ,count(1)
FROM import_data.erp_logistic_logistics_tracking  
where DeliverHour > 0 
-- where TrackingStatus=7 
group by to_date(WeightTime)

SELECT round(sum(DeliverHour)/24/count(distinct PackageNumber ),2) 'avg'   
FROM import_data.erp_logistic_logistics_tracking  where TrackingStatus=7 and DeliverHour>0


WeightTime>='2022-12-01' and WeightTime<'2023-01-01'


