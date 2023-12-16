with

ta as (
select [
5016873.01,
5015878.01,
5106722.01,
1032988.01,
5108584.01,
5105234.01,
5106724.01,
5108579.01,
5107208.01,
5106116.01,
5107988.01,
5107214.01,
5108545.01,
5106139.01,
5106719.01,
5107227.01,
5106725.01,
5107232.01,
5107211.01,
5108563.01,
5108569.01,
5106122.01,
5032298.02,
5106150.01,
5106743.01,
5107216.01,
5106726.01,
5107226.01,
5108557.01,
5106727.01,
5106741.01,
5107213.01,
5108565.01,
5105232.01,
5106135.01,
5106124.01,
5122052.01,
5107209.01,
5126246.01,
5025920.01,
5108544.01,
1025234.01,
5106113.01,
5021116.01,
5106728.01,
5018813.01,
5032298.01,
5106114.01,
5107193.01,
5122043.01,
5107199.01,
5027283.01,
5107993.01,
1024666.01,
5019450.01,
5106716.01,
5027470.01,
5106714.01,
5108540.01,
5122045.01,
5106129.01,
5105255.01,
5107212.01,
5106155.01,
5107200.01,
5132230.01,
5108585.01,
5107203.01,
5106111.01,
5132212.01,
5105096.01,
5106161.01,
5027560.01,
5107190.01,
5107207.01,
5107228.01,
5108547.01,
5106721.01,
5107202.01,
5106137.01,
5106746.01,
5124953.01,
5106144.01,
5106732.01,
5108562.01,
5119928.01,
5108555.01,
5106705.01,
5122049.01,
5108546.01,
1025038.01,
5031180.01,
5106715.01,
5106708.01,
5121979.01,
5148118.01,
5255406.01,
5231838.01,
5203488.01,
5198752.01,
5231838.02
] arr
)

,tb as (
select *
from (select unnest as arr
	from ta ,unnest(arr)
	) tmp
)
-- select * from tb


,od as (
select sellersku ,shopcode
     ,count(distinct PlatOrderNumber) 近1年订单量
     ,count(distinct case when paytime >= date_add('${NextStartDay}',interval - 1 year) then PlatOrderNumber end ) 近30天订单量
from wt_orderdetails wo
join tb on tb.arr = wo.product_spu and wo.IsDeleted = 0 and orderstatus != '作废' and paytime >= date_add('${NextStartDay}',interval - 1 year)
group by sellersku ,shopcode
)


select * from (
select wl.sku
    ,wl.spu ,wp.boxsku
     ,wp.DevelopLastAuditTime
     ,wp.productname
     ,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
     ,ms.code ,ms.NodePathName ,ms.SellUserName ,ms.accountcode ,wl.sellersku
     ,wl.price
	,case when ms.shopstatus = '正常' and wl.listingstatus = 1  then '在线' else '未在线' end 在线状态
	,ifnull(近1年订单量,0) 近1年订单量
	,ifnull(近30天订单量,0) 近30天订单量
from wt_listing wl
join tb on tb.arr = wl.sku
left join wt_products wp on wp.sku =wl.sku
left join mysql_store ms on wl.shopcode = ms.code and department = '快百货'
left join od on od.sellersku = wl.SellerSKU and od.shopcode = wl.ShopCode
) t
where ProductStatus !=2