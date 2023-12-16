
with
prod as ( select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇'  )

, od as ( -- 销售出库-未合并订单, 需要同步3个月的最新销售订单记录来判断发货
select DeliverProductSku as  boxsku ,OrderChannelSource ,PlatOrderNumber ,OrderNumber ,ShipTime ,DeliverProductSku ,ProductCount ,ShipWarehouse
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code -- 排除领科
join prod on prod.boxsku = ooa.DeliverProductSku
where ShipTime >= '${StartDay}' and  ShipTime < '${NextStartDay}'  and ShipmentStatus = '全部发货' and DeliverProductSku not regexp ','
and ReportType = '周报' and FirstDay = '2023-11-27'


union all
select unnest as boxsku ,OrderChannelSource ,PlatOrderNumber ,OrderNumber ,ShipTime ,DeliverProductSku
, 1 as ProductCount -- 合并订单记录，DeliverProductSku每个SKU出现1次，数量为1，eg: 114-9940133-1299455
,ShipWarehouse
from (
select split(DeliverProductSku,',') arr ,*
from ods_orderdetails_allplat ooa join mysql_store ms on ooa.shopcode = ms.Code
join prod on prod.boxsku = ooa.DeliverProductSku
where ShipTime >= '${StartDay}' and  ShipTime < '${NextStartDay}'  and ShipmentStatus = '全部发货' and DeliverProductSku regexp ','
and ReportType = '周报' and FirstDay = '2023-11-27'

) t,unnest(arr)
)

-- select BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam = '商厨汇'  and boxsku =4332620

select
'商厨汇' 部门
,OrderChannelSource 账号
,PlatOrderNumber 平台订单号
,OrderNumber 系统订单号
,ShipTime 订单发货时间
,boxsku + 0 as 产品SKU
,ProductCount 销售数量
,ShipWarehouse 发货仓库
,year(ShipTime) 年份
,month(ShipTime) 月份
, case when ShipWarehouse regexp 'FBA' THEN 'FBA'
	 when ShipWarehouse regexp '谷仓' THEN '谷仓'
	 when ShipWarehouse regexp '出口易' THEN '出口易'
	 when ShipWarehouse regexp '万德' THEN '万德'
	 when ShipWarehouse regexp '邮差小马' THEN '邮差小马'
	 else ShipWarehouse
	 end as 仓库
from od
-- where boxsku = 3547351
order by ShipTime ;