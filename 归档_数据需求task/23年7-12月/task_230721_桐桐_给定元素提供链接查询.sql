with

ta as (
select [1055786,5106167,
5106476,
5016873,
5015291,
1051310,
1051488,
5019110,
5017224,
5105041,
5019651,
1024401,
5090528,
5015044,
5015878,
5019548,
5116806,
5023890,
5095327,
1023675,
5109996,
5021046,
5108612,
5111074,
5020777,
5212198,
1035071,
5116684,
1055927,
5118110,
5124646,
5119149,
1016446,
1057578,
1084456,
1023674,
5118100,
5016793,
5112066,
5115270,
5015435,
5119173,
5113777,
1017246,
5044781,
5105102,
5019057,
5023837,
5106677,
5022260,
5106666,
5025039,
5113846,
1111728,
1058209,
5119873,
5116734,
1055951,
5113802,
5029863,
1055588,
1011873,
5122802,
5118165,
5021829,
5022302,
5114185,
5108634,
5116662,
1006932,
5106724,
5127232,
5017566,
5114145,
5021518,
5052579,
5021504,
5129139,
5113816,
1024505,
5112065,
5014129,
5019285,
5119176,
5112062,
5014203,
1029152,
5137702,
5109919,
5105269,
5113815,
5017548,
5116703,
5122692,
5116706,
1056152,
5134008] arr
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
join tb on tb.arr = wl.spu
left join wt_products wp on wp.sku =wl.sku 
left join mysql_store ms on wl.shopcode = ms.code and department = '快百货'
left join od on od.sellersku = wl.SellerSKU and od.shopcode = wl.ShopCode
) t
where ProductStatus !=2