/*
指标： 订单数、运输重量 、 运费 、订单销售额 
维度：
1. 收件国家（1级） -> 承运商（2级）
2. 承运商 （1级）-> 收件国家（2级）
3. 承运商（1级）-> 服务类型 （2级）
4. 公斤段：0-50 / 50-100 / 100-200 / 200-500 / 500以上
5. 承运商 （1级） - > 公斤段 （2级）
6. 收件国家（1级） -> 公斤段（2级）
注意点：
1 一笔订单对应多个包裹，可能存在销售额虚高
2 物流方式code 对应的物流商名称从物流轨迹表获取，因该表有简化的物流商名称
*/
-- 1.

-- 1
select ReceiverCountryCnName 收件国家 ,ifnull(MerchantName,'国家合计')  承运商
	,count(distinct wp.PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'追踪表无数据') MerchantName
    from wt_packagedetail wp
    left join (select MerchantName , ServiceCode
        from import_data.erp_logistic_logistics_tracking
        group by MerchantName , ServiceCode
        ) lt on wp.TransportTypeCode= lt.ServiceCode
    where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
    group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'追踪表无数据')
    ) wp -- 去重是因为表记录的是整个包裹的运费
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 and OrderStatus!='作废' and TransactionType= '付款' group by PlatOrderNumber
	) wo on wp.PlatOrderNumber = wo.PlatOrderNumber -- 在选择物流策略时无法预知会退款，所以销售额不含退款
 group by grouping sets ((ReceiverCountryCnName),(ReceiverCountryCnName,MerchantName));

-- 2
select MerchantName 承运商 ,ifnull(ReceiverCountryCnName,'承运商合计') 收件国家
	,count(distinct wp.PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'追踪表无数据') MerchantName
    from wt_packagedetail wp
    left join (select MerchantName , ServiceCode
        from import_data.erp_logistic_logistics_tracking
        group by MerchantName , ServiceCode
        ) lt on wp.TransportTypeCode= lt.ServiceCode
    where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
    group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'追踪表无数据')
    ) wp -- 去重是因为表记录的是整个包裹的运费
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 and OrderStatus!='作废' and TransactionType= '付款' group by PlatOrderNumber
	) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
group by grouping sets ((MerchantName),(ReceiverCountryCnName,MerchantName));


select MerchantName 承运商 ,ifnull(TransportType,'承运商合计') 服务类型
	,count(distinct wp.PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'追踪表无数据') MerchantName,TransportType
    from wt_packagedetail wp
    left join (select MerchantName , ServiceCode
        from import_data.erp_logistic_logistics_tracking
        group by MerchantName , ServiceCode
        ) lt on wp.TransportTypeCode= lt.ServiceCode
    where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
    group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'追踪表无数据'),TransportType
    ) wp -- 去重是因为表记录的是整个包裹的运费
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 and OrderStatus!='作废' and TransactionType= '付款'  group by PlatOrderNumber
	) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
group by grouping sets ((MerchantName),(TransportType,MerchantName));


select gram_bins 克重区间
	,count(distinct PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from (
	select
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g'
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,wp.PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight,TotalGross
	from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'追踪表无数据') MerchantName,TransportType
        from wt_packagedetail wp
        left join (select MerchantName , ServiceCode
            from import_data.erp_logistic_logistics_tracking
            group by MerchantName , ServiceCode
            ) lt on wp.TransportTypeCode= lt.ServiceCode
        where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
        group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'追踪表无数据'),TransportType
        ) wp -- 去重是因为表记录的是整个包裹的运费
    left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
        from wt_orderdetails where isdeleted = 0 and OrderStatus!='作废' and TransactionType= '付款' group by PlatOrderNumber
        ) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
	) tb
group by gram_bins;


select MerchantName 承运商 ,ifnull(gram_bins,'承运商合计') 克重区间
	,count(distinct PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from (
	select
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g'
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,wp.PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight,TotalGross
	from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'追踪表无数据') MerchantName,TransportType
        from wt_packagedetail wp
        left join (select MerchantName , ServiceCode
            from import_data.erp_logistic_logistics_tracking
            group by MerchantName , ServiceCode
            ) lt on wp.TransportTypeCode= lt.ServiceCode
        where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
        group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'追踪表无数据'),TransportType
        ) wp -- 去重是因为表记录的是整个包裹的运费
    left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
        from wt_orderdetails where isdeleted = 0 and OrderStatus!='作废' and TransactionType= '付款' group by PlatOrderNumber
        ) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
	) tb
group by grouping sets ((MerchantName),(gram_bins,MerchantName));

-- 收件国家 克重区间
select ReceiverCountryCnName 收件国家 ,ifnull(gram_bins,'国家合计') 克重区间
	,count(distinct PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from (
	select
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g'
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,wp.PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight,TotalGross ,ReceiverCountryCnName
	from ( select TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName ,ifnull(MerchantName,'追踪表无数据') MerchantName,TransportType
        from wt_packagedetail wp
        left join (select MerchantName , ServiceCode
            from import_data.erp_logistic_logistics_tracking
            group by MerchantName , ServiceCode
            ) lt on wp.TransportTypeCode= lt.ServiceCode
        where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
        group by TransportTypeCode ,PlatOrderNumber,WeightTime,PackageTotalWeight,PackageFeight,ReceiverCountryCnName,ifnull(MerchantName,'追踪表无数据'),TransportType
        ) wp -- 去重是因为表记录的是整个包裹的运费
    left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
        from wt_orderdetails where isdeleted = 0 and OrderStatus!='作废' and TransactionType= '付款' group by PlatOrderNumber
        ) wo on wp.PlatOrderNumber = wo.PlatOrderNumber
	) tb
group by grouping sets ((ReceiverCountryCnName),(gram_bins,ReceiverCountryCnName));



/*


select RecipientCountryCnName 收件国家 ,ifnull(tmp.MerchantName,'国家合计')  承运商
	,count(distinct lt.PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
	,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from import_data.erp_logistic_logistics_tracking lt
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 group by PlatOrderNumber
	) wo on lt.PlatOrderNumber = wo.PlatOrderNumber
left join (select MerchantName , TransportType
    from import_data.erp_logistic_logistics_tracking
    group by MerchantName , TransportType) tmp
where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01' and RegisterTime != '2001-01-01 08:00:00'
group by grouping sets ((RecipientCountryCnName),(RecipientCountryCnName,tmp.MerchantName))
order by RecipientCountryCnName desc ,订单数 desc;




select MerchantName 承运商 ,ifnull(RecipientCountryCnName,'承运商合计') 收件国家
	,count(distinct lt.PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
    ,round(sum(TotalGross)) 销售额CNY
	,round(sum(PackageFeight)/sum(TotalGross),4) 物流运费占比
from erp_logistic_logistics_tracking lt
left join (select PlatOrderNumber ,sum(TotalGross) TotalGross
	from wt_orderdetails where isdeleted = 0 group by PlatOrderNumber
	) wo on lt.PlatOrderNumber = wo.PlatOrderNumber
where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
group by grouping sets ((MerchantName),(RecipientCountryCnName,MerchantName))
order by MerchantName desc ,订单数 desc;


select MerchantName 承运商 ,ifnull(TransportType,'承运商合计') 服务类型
	,count(distinct PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
from erp_logistic_logistics_tracking lt
where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
group by grouping sets ((MerchantName),(TransportType,MerchantName))
order by MerchantName desc ,订单数 desc;


select gram_bins 克重区间
	,count(distinct PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
from (
	select 
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g' 
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight
	from erp_logistic_logistics_tracking lt
	where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
	) tb 
group by gram_bins
order by 订单数 desc;


select MerchantName 承运商 ,ifnull(gram_bins,'承运商合计') 克重区间  
	,count(distinct PlatOrderNumber) 订单数
	,sum(PackageTotalWeight) 运输重量
	,round(sum(PackageFeight)) 运费CNY
from (
	select 
		case  when PackageTotalWeight <=50 then '0-50g' when PackageTotalWeight <=100 then '51-100g' 
			when PackageTotalWeight <=200 then '101-200g' when PackageTotalWeight <=500 then '201-500g' else '500g+' end gram_bins
		,PlatOrderNumber ,MerchantName ,PackageFeight ,PackageTotalWeight
	from erp_logistic_logistics_tracking lt
	where WeightTime >= '2023-04-01' and WeightTime < '2023-05-01'
	) tb 
group by grouping sets ((MerchantName),(gram_bins,MerchantName))
order by MerchantName desc , 订单数 desc;

*/
