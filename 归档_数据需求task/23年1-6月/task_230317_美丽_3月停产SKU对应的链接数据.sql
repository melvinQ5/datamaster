-- SKU对应的快百货 在线渠道SKU，
-- 字段包含：渠道来源，所属架构，渠道SKU，系统SKU，boxSKU，最近30天销量
with 
-- tb as (
-- select *
-- from JinqinSku js 
-- where Monday = '2023-03-17'
-- )

tb as (
select *
from wt_products wp  
where BoxSku in (  
2976680,
4226503,
4229590,
3791818,
4231217,
4142556,
4226503,
3849607,
3939487,
3877890,
2971225,
3750602,
4019629,
4223521,
4223512,
1301807,
3795822,
3939476,
3107718,
4223509,
4229373,
3074258,
4229537,
3095052,
3888725,
3837935,
1768886,
3113010,
3157992,
3569281,
2069125,
3161251,
3944628,
3888725,
3837935,
2069188,
4223517,
4223264,
3772116,
4229579,
4229379,
4226534,
3959711,
4229364,
3707891,
3074318,
3074472,
4223529,
3074318,
4223530,
4000504,
3074349,
2069125,
4229527,
3888725,
4229622,
3771225,
4229444,
3858613,
4223530,
3226191,
3012122,
2069281,
4226534,
4226521,
1946138,
4229634,
3157948,
3188379,
3074258,
4229508,
3947851,
4229527,
4229615,
4229602,
4229609,
3878672,
3878697,
3878672,
3540817,
4143253,
4002711,
4229570,
3871415,
2116767,
3160016,
4228051,
3174863,
3944670,
4229590,
1039796,
4229575,
2410972,
2138907,
3739343,
3597348,
4229602,
4229623,
4229609,
3074486,
4229581,
4229503,
3881140,
4229503,
4229502,
4229502,
4223500,
4226516,
4229504,
4229504,
4226524,
4226482,
4223500,
4223499,
4229502,
4226482,
4229392,
4229503,
4231217,
4229543,
4229396,
4229556,
4226533,
4223499,
4223500,
4229392,
4223246,
4229503,
1008915,
4228046,
4229396,
4229383,
4228046,
4231236,
4223499,
1946320,
4228051,
4231239,
1946320,
1915557,
3888725
)
)

-- , od as (
select wo.BoxSku , sum(SaleCount) SaleCount_sum 
from wt_orderdetails wo 
join tb on wo.BoxSku = tb.boxsku 
-- where PayTime >=date_add('${NextStartDay}',- 360) and PayTime<'${NextStartDay}' and wo.IsDeleted=0 
group by wo.BoxSku 
)

-- select count(1) from (
select wl.BoxSku 
	,wl.SKU 
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as `当前系统产品状态`
	,SellerSKU 
	,'在线' `当前链接状态`
	,wl.ShopCode `渠道店铺`
	,ms.Department `店铺当前所属部门`
	,ms.NodePathNameFull  `店铺当前所属团队`
	,ms.ShopStatus  `当前店铺状态`
	,od.salecount_sum `近30天销量`
from tb 
left join wt_listing wl  on wl.BoxSku = tb.boxsku
left join wt_products wp  on wp.BoxSku =tb.boxsku
left join od on wl.BoxSku = od.boxsku
join mysql_store ms on wl.ShopCode = ms.Code 
-- left join wt_store ms on wl.ShopCode = ms.Code 
where wl.ListingStatus =1 and wl.IsDeleted = 0 
	and ms.Department = '快百货'
order by wl.BoxSku 

-- ) tmp 