
-- MRO 销售明细
select
 ms.Department 部门
,ms.Code  账号
,PlatOrderNumber 平台订单号
,OrderNumber 系统订单号
,ShipTime 订单发货时间
,boxsku + 0 as 产品SKU
,SaleCount  销售数量
,ShipWarehouse 发货仓库
,year(ShipTime) 年份
,month(ShipTime) 月份
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '谷仓' THEN '谷仓'
	 when ShipWarehouse regexp '出口易' THEN '出口易'
	 when ShipWarehouse regexp '万德' THEN '万德'
	 when ShipWarehouse regexp '邮差小马' THEN '邮差小马'
	 else ShipWarehouse
	 end as 仓库简称
     ,'' 备注
,GroupSku + 0 组合SKU
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code and ms.Department regexp '快百货' and ShipWarehouse regexp 'FBA' and TransactionType = '付款'
-- join mysql_store ms on wo.shopcode = ms.Code and ms.Department regexp '商厨汇'
    -- and ShipWarehouse regexp 'FBA'
    and TransactionType = '付款'
where wo.IsDeleted =0 and OrderStatus != '作废' and  ShipTime >=  '${StartDay}'  and ShipTime < '${NextStartDay}' and ShipmentStatus = '全部发货'
order by ms.Department,ShipTime ;
