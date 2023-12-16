

with res as (
-- 转仓明细
select
    concat(BackupOrderNumber,'_',dh.BoxSku) as 备库单号系统SKU
    ,'${department}'
	,'' 建单日期
	,date_format(deliveryTme,'%Y/%m/%d') 发货日期
	,year(deliveryTme) 发货年份
	,month(deliveryTme) 发货月份
	,ShipWarehouse 转仓仓库
	,ReceiveWarehouse 目的仓库
	,dh.BoxSku + 0
    , case when ReceiveWarehouse regexp 'FBA' THEN 'FBA'
         when ReceiveWarehouse regexp '谷仓' THEN '谷仓'
         when ReceiveWarehouse regexp '出口易' THEN '出口易'
         when ReceiveWarehouse regexp '万德' THEN '万德'
         when ReceiveWarehouse regexp '邮差小马' THEN '邮差小马'
         else ReceiveWarehouse
         end as 目的仓库简称
	,Quantity
	,'' 转出时库龄天数
	,PurchaseFee 采购成本
	,null 头程运费
    ,null 上月在途数
    ,null 各仓当前SKU总库存数
	,'' 在途数
	,'' 入仓数
	,'' 入仓日期
    ,'' 第二批入仓数
	,'' 第二批入仓日期
	,'' 备注
    ,'' 组合SKU
	,Quantity*PurchaseFee 产品总采购成本
	,null 产品总头程运费
	,BackupOrderNumber 备库单号
	,'奈思自采' 拿货方式
	, case when ms.code is null then '亿川帮发货' else '奈思自采' end as 发货方式
	, dh.PackageNumber 包裹号
    , dh.FBAID as Shipmentid
	,TransportMode 运输方式


from import_data.daily_HeadwayDelivery dh
join  ( select distinct BoxSku,sku,ProductName,ProjectTeam from wt_products where ProjectTeam regexp '${department}' ) prod on dh.BoxSku  = prod.boxsku
left join mysql_store ms on dh.ShopCode = ms.code and ms.Department regexp '${department}' -- 不能用店铺去筛选，只能用产品，因为存在用领科账号发货
-- left join (select BoxSku ,projectteam from wt_products ) wp on dh.BoxSku  = wp.BoxSku
where deliveryTme >= '${StartDay}' and  deliveryTme < '${NextStartDay}'
order by deliveryTme
)

select * from res