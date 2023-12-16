-- 按新表账号 +  目前所有正常账号去重 计算


with 
tb as ( -- 快百货所有使用过的账号
select memo as arr from  manual_table mt where c1 = '快百货退回财务账号0702'
)

,ware as (
select dwi.* 
	,case when ProductStatus =  0 then '正常'
			when ProductStatus = 2 then '停产'
			when ProductStatus = 3 then '停售'
			when ProductStatus = 4 then '暂时缺货'
			when ProductStatus = 5 then '清仓'
		end as ProductStatus
	,wp.ChangeReasons
	,wp.TortType 
	,wp.DevelopLastAuditTime 
from import_data.daily_WarehouseInventory dwi 
join import_data.wt_products wp on dwi.BoxSku = wp.BoxSku and wp.ProjectTeam = '快百货'
where dwi.CreatedTime = DATE_ADD(current_date(),-1) and WarehouseName = '东莞仓' 
and wp.isdeleted = 0
)

,rela as (
select *
from 
	(select 
		epp1.sku as ori_sku ,epp1.BoxSKU as ori_boxsku ,epp1.ProjectTeam as ori_team 
		,epp2.sku as new_sku ,epp2.BoxSKU as new_boxsku ,epp2.ProjectTeam as new_team 
	from import_data.erp_product_product_copy_relations eppcr 
	left join import_data.erp_product_products epp1 on eppcr.OrigProdId = epp1.Id and epp1.IsMatrix =0
	left join import_data.erp_product_products epp2 on eppcr.NewProdId = epp2.Id and epp2.IsMatrix =0
	where eppcr.IsDeleted = 0 and epp1.Id is not null -- 去掉母体复制关系的记录
	) tb
where ori_team <> '快百货' and new_team = '快百货'  -- 从其他部门复制到快百货的sku
)

,od_pre as ( -- 三部分订单记录：快百货现有账号出单(出单sku本身包括复制关系里的源SKU) + 快百货退回财务账号(出单sku本身包括复制关系里的源SKU) 
select BoxSku, paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
	,case when GroupSkuNumber > 0 then GroupSku else BoxSku end as 	 targetsku		
	,case when GroupSkuNumber > 0 then '组合出单' else '非组合单' end as isgroup_pre
from import_data.wt_orderdetails wo 
join (select code from mysql_store ms where Department = '快百货' 
	union select arr from tb ) ms 
	on ms.Code = wo.shopcode 
-- join rela on wo.BoxSku = rela.ori_boxsku  -- 临时导表 复制关系
where wo.IsDeleted = 0 and OrderStatus != '作废'
	and PayTime >= '2022-01-01' 
)

, boxsku_2_groupsku as ( -- 单独处理如果 子体SKU直接同编码转变为组合SKU，详情可查订单表 boxsku in (4302766,4350836)
select targetsku 
	, case when isgroup  regexp '组合出单' then '组合出单' else '非组合出单' end as isgroup -- 只要曾有过组合出单，即是为组合出单
from (select targetsku ,GROUP_CONCAT(isgroup_pre) isgroup from od_pre group by targetsku) tmp
)

,od as (
select a.targetsku ,BoxSku, b.isgroup , paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku
	,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
from od_pre a join boxsku_2_groupsku b on a.targetsku = b.targetsku
)
-- select * from od where targetsku = 4223503

,orde as (  -- 出单sku本身包括复制关系里的源SKU
select targetsku as BoxSku ,isgroup
	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then salecount end ) as KBH销量近12个月
	,sum(SaleCount) as KBH销量22年至今
	,sum(case when left(paytime,7)='2022-01' then SaleCount end ) as KBH销量2201
	,sum(case when left(paytime,7)='2022-02' then SaleCount end ) as KBH销量2202
	,sum(case when left(paytime,7)='2022-03' then SaleCount end ) as KBH销量2203
	,sum(case when left(paytime,7)='2022-04' then SaleCount end ) as KBH销量2204
	,sum(case when left(paytime,7)='2022-05' then SaleCount end ) as KBH销量2205
	,sum(case when left(paytime,7)='2022-06' then SaleCount end ) as KBH销量2206
	,sum(case when left(paytime,7)='2022-07' then SaleCount end ) as KBH销量2207
	,sum(case when left(paytime,7)='2022-08' then SaleCount end ) as KBH销量2208
	,sum(case when left(paytime,7)='2022-09' then SaleCount end ) as KBH销量2209
	,sum(case when left(paytime,7)='2022-10' then SaleCount end ) as KBH销量2210
	,sum(case when left(paytime,7)='2022-11' then SaleCount end ) as KBH销量2211
	,sum(case when left(paytime,7)='2022-12' then SaleCount end ) as KBH销量2212

	,sum(case when left(paytime,7)='2023-01' then SaleCount end ) as KBH销量2301
	,sum(case when left(paytime,7)='2023-02' then SaleCount end ) as KBH销量2302
	,sum(case when left(paytime,7)='2023-03' then SaleCount end ) as KBH销量2303
	,sum(case when left(paytime,7)='2023-04' then SaleCount end ) as KBH销量2304
	,sum(case when left(paytime,7)='2023-05' then SaleCount end ) as KBH销量2305
	,sum(case when left(paytime,7)='2023-06' then SaleCount end ) as KBH销量2306
	,sum(case when left(paytime,7)='2023-07' then SaleCount end ) as KBH销量2307
	,sum(case when left(paytime,7)='2023-08' then SaleCount end ) as KBH销量2308
	,sum(case when left(paytime,7)='2023-09' then SaleCount end ) as KBH销量2309
	,sum(case when left(paytime,7)='2023-10' then SaleCount end ) as KBH销量2310
	,sum(case when left(paytime,7)='2023-11' then SaleCount end ) as KBH销量2311
	,sum(case when left(paytime,7)='2023-12' then SaleCount end ) as KBH销量2312
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then salecount end ) as KBH销量近7
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then salecount end ) as KBH销量近8_14
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then salecount end ) as KBH销量近15_21
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then salecount end ) as KBH销量近22_28
-- 	,sum(case when left(paytime,4)='2021' then SaleCount end ) as KBH销量21年
	
	,round(sum(case when left(paytime,7)='2022-01' then totalgross/exchangeUSD end )) as KBH销售额2201
	,round(sum(case when left(paytime,7)='2022-02' then totalgross/exchangeUSD end )) as KBH销售额2202
	,round(sum(case when left(paytime,7)='2022-03' then totalgross/exchangeUSD end )) as KBH销售额2203
	,round(sum(case when left(paytime,7)='2022-04' then totalgross/exchangeUSD end )) as KBH销售额2204
	,round(sum(case when left(paytime,7)='2022-05' then totalgross/exchangeUSD end )) as KBH销售额2205
	,round(sum(case when left(paytime,7)='2022-06' then totalgross/exchangeUSD end )) as KBH销售额2206
	,round(sum(case when left(paytime,7)='2022-07' then totalgross/exchangeUSD end )) as KBH销售额2207
	,round(sum(case when left(paytime,7)='2022-08' then totalgross/exchangeUSD end )) as KBH销售额2208
	,round(sum(case when left(paytime,7)='2022-09' then totalgross/exchangeUSD end )) as KBH销售额2209
	,round(sum(case when left(paytime,7)='2022-10' then totalgross/exchangeUSD end )) as KBH销售额2210
	,round(sum(case when left(paytime,7)='2022-11' then totalgross/exchangeUSD end )) as KBH销售额2211
	,round(sum(case when left(paytime,7)='2022-12' then totalgross/exchangeUSD end )) as KBH销售额2212
	,round(sum(case when left(paytime,7)='2023-01' then totalgross/exchangeUSD end )) as KBH销售额2301
	,round(sum(case when left(paytime,7)='2023-02' then totalgross/exchangeUSD end )) as KBH销售额2302
	,round(sum(case when left(paytime,7)='2023-03' then totalgross/exchangeUSD end )) as KBH销售额2303
	,round(sum(case when left(paytime,7)='2023-04' then totalgross/exchangeUSD end )) as KBH销售额2304
	,round(sum(case when left(paytime,7)='2023-05' then totalgross/exchangeUSD end )) as KBH销售额2305
	,round(sum(case when left(paytime,7)='2023-06' then totalgross/exchangeUSD end )) as KBH销售额2306
	,round(sum(case when left(paytime,7)='2023-07' then totalgross/exchangeUSD end )) as KBH销售额2307
	,round(sum(case when left(paytime,7)='2023-08' then totalgross/exchangeUSD end )) as KBH销售额2308
	,round(sum(case when left(paytime,7)='2023-09' then totalgross/exchangeUSD end )) as KBH销售额2309
	,round(sum(case when left(paytime,7)='2023-10' then totalgross/exchangeUSD end )) as KBH销售额2310
	,round(sum(case when left(paytime,7)='2023-11' then totalgross/exchangeUSD end )) as KBH销售额2311
	,round(sum(case when left(paytime,7)='2023-12' then totalgross/exchangeUSD end )) as KBH销售额2312
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalgross/exchangeUSD end )) as KBH销售额近7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalgross/exchangeUSD end )) as KBH销售额近8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalgross/exchangeUSD end )) as KBH销售额近15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalgross/exchangeUSD end )) as KBH销售额近22_28
-- 	,sum(case when left(paytime,4)='2021' then totalgross/exchangeUSD end ) as KBH销售额21年

	,round(sum(case when left(paytime,7)='2022-01' then totalprofit/exchangeUSD end )) as KBH利润额2201
	,round(sum(case when left(paytime,7)='2022-02' then totalprofit/exchangeUSD end )) as KBH利润额2202
	,round(sum(case when left(paytime,7)='2022-03' then totalprofit/exchangeUSD end )) as KBH利润额2203
	,round(sum(case when left(paytime,7)='2022-04' then totalprofit/exchangeUSD end )) as KBH利润额2204
	,round(sum(case when left(paytime,7)='2022-05' then totalprofit/exchangeUSD end )) as KBH利润额2205
	,round(sum(case when left(paytime,7)='2022-06' then totalprofit/exchangeUSD end )) as KBH利润额2206
	,round(sum(case when left(paytime,7)='2022-07' then totalprofit/exchangeUSD end )) as KBH利润额2207
	,round(sum(case when left(paytime,7)='2022-08' then totalprofit/exchangeUSD end )) as KBH利润额2208
	,round(sum(case when left(paytime,7)='2022-09' then totalprofit/exchangeUSD end )) as KBH利润额2209
	,round(sum(case when left(paytime,7)='2022-10' then totalprofit/exchangeUSD end )) as KBH利润额2210
	,round(sum(case when left(paytime,7)='2022-11' then totalprofit/exchangeUSD end )) as KBH利润额2211
	,round(sum(case when left(paytime,7)='2022-12' then totalprofit/exchangeUSD end )) as KBH利润额2212
	,round(sum(case when left(paytime,7)='2023-01' then totalprofit/exchangeUSD end )) as KBH利润额2301
	,round(sum(case when left(paytime,7)='2023-02' then totalprofit/exchangeUSD end )) as KBH利润额2302
	,round(sum(case when left(paytime,7)='2023-03' then totalprofit/exchangeUSD end )) as KBH利润额2303
	,round(sum(case when left(paytime,7)='2023-04' then totalprofit/exchangeUSD end )) as KBH利润额2304
	,round(sum(case when left(paytime,7)='2023-05' then totalprofit/exchangeUSD end )) as KBH利润额2305
	,round(sum(case when left(paytime,7)='2023-06' then totalprofit/exchangeUSD end )) as KBH利润额2306
	,round(sum(case when left(paytime,7)='2023-07' then totalprofit/exchangeUSD end )) as KBH利润额2307
	,round(sum(case when left(paytime,7)='2023-08' then totalprofit/exchangeUSD end )) as KBH利润额2308
	,round(sum(case when left(paytime,7)='2023-09' then totalprofit/exchangeUSD end )) as KBH利润额2309
	,round(sum(case when left(paytime,7)='2023-10' then totalprofit/exchangeUSD end )) as KBH利润额2310
	,round(sum(case when left(paytime,7)='2023-11' then totalprofit/exchangeUSD end )) as KBH利润额2311
	,round(sum(case when left(paytime,7)='2023-12' then totalprofit/exchangeUSD end )) as KBH利润额2312
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalprofit/exchangeUSD end )) as KBH利润额近7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalprofit/exchangeUSD end )) as KBH利润额近8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalprofit/exchangeUSD end )) as KBH利润额近15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalprofit/exchangeUSD end )) as KBH利润额近22_28
-- 	,sum(case when left(paytime,4)='2021' then totalprofit/exchangeUSD end ) as KBH利润额21年

    ,count( distinct case when left(paytime,7)='2022-05' then date(paytime) end ) as KBH出单天数2205
	,count( distinct case when left(paytime,7)='2022-06' then date(paytime) end ) as KBH出单天数2206
	,count( distinct case when left(paytime,7)='2022-07' then date(paytime) end ) as KBH出单天数2207
	,count( distinct case when left(paytime,7)='2022-08' then date(paytime) end ) as KBH出单天数2208
	,count( distinct case when left(paytime,7)='2022-09' then date(paytime) end ) as KBH出单天数2209
	,count( distinct case when left(paytime,7)='2022-10' then date(paytime) end ) as KBH出单天数2210
	,count( distinct case when left(paytime,7)='2022-11' then date(paytime) end ) as KBH出单天数2211
	,count( distinct case when left(paytime,7)='2022-12' then date(paytime) end ) as KBH出单天数2212

	,count( distinct case when left(paytime,7)='2023-01' then date(paytime) end ) as KBH出单天数2301
	,count( distinct case when left(paytime,7)='2023-02' then date(paytime) end ) as KBH出单天数2302
	,count( distinct case when left(paytime,7)='2023-03' then date(paytime) end ) as KBH出单天数2303
	,count( distinct case when left(paytime,7)='2023-04' then date(paytime) end ) as KBH出单天数2304
	,count( distinct case when left(paytime,7)='2023-05' then date(paytime) end ) as KBH出单天数2305
	,count( distinct case when left(paytime,7)='2023-06' then date(paytime) end ) as KBH出单天数2306
	,count( distinct case when left(paytime,7)='2023-07' then date(paytime) end ) as KBH出单天数2307
/*
	,count( distinct case when left(paytime,7)='2023-08' then date(paytime) end ) as KBH出单天数2308
	,count( distinct case when left(paytime,7)='2023-09' then date(paytime) end ) as KBH出单天数2309
	,count( distinct case when left(paytime,7)='2023-10' then date(paytime) end ) as KBH出单天数2310
	,count( distinct case when left(paytime,7)='2023-11' then date(paytime) end ) as KBH出单天数2311
	,count( distinct case when left(paytime,7)='2023-12' then date(paytime) end ) as KBH出单天数2312
 */

from od
group by targetsku ,isgroup
)

-- select * from orde where isgroup is  null 

,orde_tmh as (
select wo.BoxSku 
	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then salecount end ) as TMH销量近12个月
	,sum(case when left(paytime,7)='2023-01' then SaleCount end ) as TMH销量2301
	,sum(case when left(paytime,7)='2023-02' then SaleCount end ) as TMH销量2302
	,sum(case when left(paytime,7)='2023-03' then SaleCount end ) as TMH销量2303
	,sum(case when left(paytime,7)='2023-04' then SaleCount end ) as TMH销量2304
	,sum(case when left(paytime,7)='2023-05' then SaleCount end ) as TMH销量2305
	,sum(case when left(paytime,7)='2023-06' then SaleCount end ) as TMH销量2306
	,sum(case when left(paytime,7)='2023-07' then SaleCount end ) as TMH销量2307
	,sum(case when left(paytime,7)='2023-08' then SaleCount end ) as TMH销量2308
	,sum(case when left(paytime,7)='2023-09' then SaleCount end ) as TMH销量2309
	,sum(case when left(paytime,7)='2023-10' then SaleCount end ) as TMH销量2310
	,sum(case when left(paytime,7)='2023-11' then SaleCount end ) as TMH销量2311
	,sum(case when left(paytime,7)='2023-12' then SaleCount end ) as TMH销量2312
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
where wo.IsDeleted = 0 and OrderStatus != '作废'  and ms.Department = '特卖汇'
	and paytime >= '2023-01-01'
group by wo.BoxSku 
)

-- select * from orde

, inst as (
select wp.BoxSku ,max(CompleteTime) as max_InstockTime
from import_data.wt_purchaseorder wp 
join ware on wp.BoxSku = ware.boxsku 
where isOnWay = '否' 
group by wp.BoxSku
)

, list as (
select wl.BoxSku 
	,count(distinct concat(shopcode,SellerSku)) as `在线链接数`
	,count(distinct case when NodePathName ='运营成都1组' then concat(shopcode,SellerSku) end ) `在线链接数_成1`
	,count(distinct case when NodePathName ='运营成都2组' then concat(shopcode,SellerSku) end ) `在线链接数_成2`
	,count(distinct case when NodePathName ='运营成都3组' then concat(shopcode,SellerSku) end ) `在线链接数_成3`
	,count(distinct case when NodePathName ='运营泉州1组' then concat(shopcode,SellerSku) end ) `在线链接数_泉1`
	,count(distinct case when NodePathName ='运营泉州2组' then concat(shopcode,SellerSku) end ) `在线链接数_泉2`
	,count(distinct case when NodePathName ='运营泉州3组' then concat(shopcode,SellerSku) end ) `在线链接数_泉3`
from import_data.wt_listing wl 
join mysql_store ms on wl.ShopCode = ms.Code 
	and ms.Department = '快百货' and ms.ShopStatus = '正常'
join import_data.wt_products wp  on wl.BoxSku = wp.boxsku 
	and ListingStatus = 1 
	and wl.IsDeleted = 0 
	and wp.projectteam = '快百货'
	and wp.IsDeleted = 0 
-- where wp.sku =5032084.01
group by wl.BoxSku
)

-- select count(1) from (
, t_merge as (
 select 
		wp.sku 
		,wp.BoxSku 
		,wp.projectteam `产品库归属部门`
		,wp.ori_boxsku  `源boxsku（有复制关系）`
		,wp.ori_team `源boxsku归属部门`
		,case when coalesce(orde.isgroup,orde2.isgroup) is null then '快百货账号(含退回)无订单记录' else orde.isgroup end as `是否组合出单`
		,ware.BoxSku `有库存boxsku`
	 	,case when wp.ProductStatus =  0 then '正常'
	 			when wp.ProductStatus = 2 then '停产'
	 			when wp.ProductStatus = 3 then '停售'
	 			when wp.ProductStatus = 4 then '暂时缺货'
	 			when wp.ProductStatus = 5 then '清仓'
	 	end as  `产品状态`
	 	,wp.ChangeReasons `停产原因`
	 	,wp.TortType `侵权类型`
	 	
	 	,round(timestampdiff(second,wp.DevelopLastAuditTime,CURRENT_DATE())/86400/30)  `终审距今月数_按30天`
		,ifnull(orde.KBH销量近12个月,0) + ifnull(orde2.KBH销量近12个月,0) as KBH销量近12个月
		,TMH销量近12个月
		,ifnull(orde.KBH销量22年至今,0) + ifnull(orde2.KBH销量22年至今,0) as KBH销量22年至今
	
		,ifnull(orde.KBH销量2201,0) + ifnull(orde2.KBH销量2201,0) as KBH销量2201
		,ifnull(orde.KBH销量2202,0) + ifnull(orde2.KBH销量2202,0) as KBH销量2202
		,ifnull(orde.KBH销量2203,0) + ifnull(orde2.KBH销量2203,0) as KBH销量2203
		,ifnull(orde.KBH销量2204,0) + ifnull(orde2.KBH销量2204,0) as KBH销量2204
		,ifnull(orde.KBH销量2205,0) + ifnull(orde2.KBH销量2205,0) as KBH销量2205
		,ifnull(orde.KBH销量2206,0) + ifnull(orde2.KBH销量2206,0) as KBH销量2206
		,ifnull(orde.KBH销量2207,0) + ifnull(orde2.KBH销量2207,0) as KBH销量2207
		,ifnull(orde.KBH销量2208,0) + ifnull(orde2.KBH销量2208,0) as KBH销量2208
		,ifnull(orde.KBH销量2209,0) + ifnull(orde2.KBH销量2209,0) as KBH销量2209
		,ifnull(orde.KBH销量2210,0) + ifnull(orde2.KBH销量2210,0) as KBH销量2210
		,ifnull(orde.KBH销量2211,0) + ifnull(orde2.KBH销量2211,0) as KBH销量2211
		,ifnull(orde.KBH销量2212,0) + ifnull(orde2.KBH销量2212,0) as KBH销量2212
		,ifnull(orde.KBH销量2301,0) + ifnull(orde2.KBH销量2301,0) as KBH销量2301
		,ifnull(orde.KBH销量2302,0) + ifnull(orde2.KBH销量2302,0) as KBH销量2302
		,ifnull(orde.KBH销量2303,0) + ifnull(orde2.KBH销量2303,0) as KBH销量2303
		,ifnull(orde.KBH销量2304,0) + ifnull(orde2.KBH销量2304,0) as KBH销量2304
		,ifnull(orde.KBH销量2305,0) + ifnull(orde2.KBH销量2305,0) as KBH销量2305
		,ifnull(orde.KBH销量2306,0) + ifnull(orde2.KBH销量2306,0) as KBH销量2306
		,ifnull(orde.KBH销量2307,0) + ifnull(orde2.KBH销量2307,0) as KBH销量2307
		,ifnull(orde.KBH销量2308,0) + ifnull(orde2.KBH销量2308,0) as KBH销量2308
		,ifnull(orde.KBH销量2309,0) + ifnull(orde2.KBH销量2309,0) as KBH销量2309
		,ifnull(orde.KBH销量2310,0) + ifnull(orde2.KBH销量2310,0) as KBH销量2310
		,ifnull(orde.KBH销量2311,0) + ifnull(orde2.KBH销量2311,0) as KBH销量2311
		,ifnull(orde.KBH销量2312,0) + ifnull(orde2.KBH销量2312,0) as KBH销量2312
		, TMH销量2301
		, TMH销量2302
		, TMH销量2303
		, TMH销量2304
		, TMH销量2305
		, TMH销量2306
		, TMH销量2307
		, TMH销量2308
		, TMH销量2309
		, TMH销量2310
		, TMH销量2311
		, TMH销量2312
		
		,ifnull(orde.KBH销售额2201,0) + ifnull(orde2.KBH销售额2201,0) as KBH销售额2201
		,ifnull(orde.KBH销售额2202,0) + ifnull(orde2.KBH销售额2202,0) as KBH销售额2202
		,ifnull(orde.KBH销售额2203,0) + ifnull(orde2.KBH销售额2203,0) as KBH销售额2203
		,ifnull(orde.KBH销售额2204,0) + ifnull(orde2.KBH销售额2204,0) as KBH销售额2204
		,ifnull(orde.KBH销售额2205,0) + ifnull(orde2.KBH销售额2205,0) as KBH销售额2205
		,ifnull(orde.KBH销售额2206,0) + ifnull(orde2.KBH销售额2206,0) as KBH销售额2206
		,ifnull(orde.KBH销售额2207,0) + ifnull(orde2.KBH销售额2207,0) as KBH销售额2207
		,ifnull(orde.KBH销售额2208,0) + ifnull(orde2.KBH销售额2208,0) as KBH销售额2208
		,ifnull(orde.KBH销售额2209,0) + ifnull(orde2.KBH销售额2209,0) as KBH销售额2209
		,ifnull(orde.KBH销售额2210,0) + ifnull(orde2.KBH销售额2210,0) as KBH销售额2210
		,ifnull(orde.KBH销售额2211,0) + ifnull(orde2.KBH销售额2211,0) as KBH销售额2211
		,ifnull(orde.KBH销售额2212,0) + ifnull(orde2.KBH销售额2212,0) as KBH销售额2212
		,ifnull(orde.KBH销售额2301,0) + ifnull(orde2.KBH销售额2301,0) as KBH销售额2301
		,ifnull(orde.KBH销售额2302,0) + ifnull(orde2.KBH销售额2302,0) as KBH销售额2302
		,ifnull(orde.KBH销售额2303,0) + ifnull(orde2.KBH销售额2303,0) as KBH销售额2303
		,ifnull(orde.KBH销售额2304,0) + ifnull(orde2.KBH销售额2304,0) as KBH销售额2304
		,ifnull(orde.KBH销售额2305,0) + ifnull(orde2.KBH销售额2305,0) as KBH销售额2305
		,ifnull(orde.KBH销售额2306,0) + ifnull(orde2.KBH销售额2306,0) as KBH销售额2306
		,ifnull(orde.KBH销售额2307,0) + ifnull(orde2.KBH销售额2307,0) as KBH销售额2307
		,ifnull(orde.KBH销售额2308,0) + ifnull(orde2.KBH销售额2308,0) as KBH销售额2308
		,ifnull(orde.KBH销售额2309,0) + ifnull(orde2.KBH销售额2309,0) as KBH销售额2309
		,ifnull(orde.KBH销售额2310,0) + ifnull(orde2.KBH销售额2310,0) as KBH销售额2310
		,ifnull(orde.KBH销售额2311,0) + ifnull(orde2.KBH销售额2311,0) as KBH销售额2311
		,ifnull(orde.KBH销售额2312,0) + ifnull(orde2.KBH销售额2312,0) as KBH销售额2312
		
		,ifnull(orde.KBH利润额2201,0) + ifnull(orde2.KBH利润额2201,0) as KBH利润额2201
		,ifnull(orde.KBH利润额2202,0) + ifnull(orde2.KBH利润额2202,0) as KBH利润额2202
		,ifnull(orde.KBH利润额2203,0) + ifnull(orde2.KBH利润额2203,0) as KBH利润额2203
		,ifnull(orde.KBH利润额2204,0) + ifnull(orde2.KBH利润额2204,0) as KBH利润额2204
		,ifnull(orde.KBH利润额2205,0) + ifnull(orde2.KBH利润额2205,0) as KBH利润额2205
		,ifnull(orde.KBH利润额2206,0) + ifnull(orde2.KBH利润额2206,0) as KBH利润额2206
		,ifnull(orde.KBH利润额2207,0) + ifnull(orde2.KBH利润额2207,0) as KBH利润额2207
		,ifnull(orde.KBH利润额2208,0) + ifnull(orde2.KBH利润额2208,0) as KBH利润额2208
		,ifnull(orde.KBH利润额2209,0) + ifnull(orde2.KBH利润额2209,0) as KBH利润额2209
		,ifnull(orde.KBH利润额2210,0) + ifnull(orde2.KBH利润额2210,0) as KBH利润额2210
		,ifnull(orde.KBH利润额2211,0) + ifnull(orde2.KBH利润额2211,0) as KBH利润额2211
		,ifnull(orde.KBH利润额2212,0) + ifnull(orde2.KBH利润额2212,0) as KBH利润额2212
		,ifnull(orde.KBH利润额2301,0) + ifnull(orde2.KBH利润额2301,0) as KBH利润额2301
		,ifnull(orde.KBH利润额2302,0) + ifnull(orde2.KBH利润额2302,0) as KBH利润额2302
		,ifnull(orde.KBH利润额2303,0) + ifnull(orde2.KBH利润额2303,0) as KBH利润额2303
		,ifnull(orde.KBH利润额2304,0) + ifnull(orde2.KBH利润额2304,0) as KBH利润额2304
		,ifnull(orde.KBH利润额2305,0) + ifnull(orde2.KBH利润额2305,0) as KBH利润额2305
		,ifnull(orde.KBH利润额2306,0) + ifnull(orde2.KBH利润额2306,0) as KBH利润额2306
		,ifnull(orde.KBH利润额2307,0) + ifnull(orde2.KBH利润额2307,0) as KBH利润额2307
		,ifnull(orde.KBH利润额2308,0) + ifnull(orde2.KBH利润额2308,0) as KBH利润额2308
		,ifnull(orde.KBH利润额2309,0) + ifnull(orde2.KBH利润额2309,0) as KBH利润额2309
		,ifnull(orde.KBH利润额2310,0) + ifnull(orde2.KBH利润额2310,0) as KBH利润额2310
		,ifnull(orde.KBH利润额2311,0) + ifnull(orde2.KBH利润额2311,0) as KBH利润额2311
		,ifnull(orde.KBH利润额2312,0) + ifnull(orde2.KBH利润额2312,0) as KBH利润额2312

        , orde.KBH出单天数2205
        , orde.KBH出单天数2206
        , orde.KBH出单天数2207
        , orde.KBH出单天数2208
        , orde.KBH出单天数2209
        , orde.KBH出单天数2210
        , orde.KBH出单天数2211
        , orde.KBH出单天数2212
        , orde.KBH出单天数2301
        , orde.KBH出单天数2302
        , orde.KBH出单天数2303
        , orde.KBH出单天数2304
        , orde.KBH出单天数2305
        , orde.KBH出单天数2306
        , orde.KBH出单天数2307


		,ifnull(orde.KBH销量近7,0) + ifnull(orde2.KBH销量近7,0) as KBH销量近7
		,ifnull(orde.KBH销量近8_14,0) + ifnull(orde2.KBH销量近8_14,0) as KBH销量近8_14
		,ifnull(orde.KBH销量近15_21,0) + ifnull(orde2.KBH销量近15_21,0) as KBH销量近15_21
		,ifnull(orde.KBH销量近22_28,0) + ifnull(orde2.KBH销量近22_28,0) as KBH销量近22_28
		
		,ifnull(orde.KBH销售额近7,0) + ifnull(orde2.KBH销售额近7,0) as KBH销售额近7
		,ifnull(orde.KBH销售额近8_14,0) + ifnull(orde2.KBH销售额近8_14,0) as KBH销售额近8_14
		,ifnull(orde.KBH销售额近15_21,0) + ifnull(orde2.KBH销售额近15_21,0) as KBH销售额近15_21
		,ifnull(orde.KBH销售额近22_28,0) + ifnull(orde2.KBH销售额近22_28,0) as KBH销售额近22_28
		
		,ifnull(orde.KBH利润额近7,0) + ifnull(orde2.KBH利润额近7,0) as KBH利润额近7
		,ifnull(orde.KBH利润额近8_14,0) + ifnull(orde2.KBH利润额近8_14,0) as KBH利润额近8_14
		,ifnull(orde.KBH利润额近15_21,0) + ifnull(orde2.KBH利润额近15_21,0) as KBH利润额近15_21
		,ifnull(orde.KBH利润额近22_28,0) + ifnull(orde2.KBH利润额近22_28,0) as KBH利润额近22_28
			
		,`在线链接数`
	 	,`在线链接数_成1` 
	 	,`在线链接数_成2` 
	 	,`在线链接数_成3`
	 	,`在线链接数_泉1`
	 	,`在线链接数_泉2` 
	 	,`在线链接数_泉3` 
	 	
	 	,round(timestampdiff(second,wp.DevelopLastAuditTime,CURRENT_DATE())/86400)  `终审距今天数`
	 	,wp.DevelopLastAuditTime `终审时间`
		,wp.ProductName `产品名` 
	 	,IsPackage `是否包材`
	 	,AverageUnitPrice `平均单价`
	 	,TotalInventory `库存总数量`
	 	,TotalPrice `库存总金额`
	 	,InventoryAge45 `0-45天库龄金额`
	 	,InventoryAge90 `46-90天库龄金额`
	 	,InventoryAge180 `91-180天库龄金额`
	 	,InventoryAge270 `181-270天库龄金额`
	 	,InventoryAge365 `271-365天库龄金额`
	 	,InventoryAgeOver `大于365天库龄金额`
	 	,max_InstockTime `最后采购完结日`
	 	,datediff(CURRENT_DATE(),max_InstockTime) `最后采购完结距今天数` 
	from 
		( select wp.* ,rela.ori_boxsku ,rela.ori_team
		from import_data.wt_products wp
		left join rela on wp.BoxSku = rela.new_boxsku  
		) wp 
	left join ware on ware.BoxSku = wp.boxsku
	left join orde on orde.BoxSku = wp.boxsku -- 产品库归属快百货的销售，快百货账号出单
	left join orde orde2 on orde2.BoxSku = wp.ori_boxsku -- 产品库归属其他部门，快百货账号出单
	left join orde_tmh on orde_tmh.BoxSku = wp.boxsku
	left join inst on inst.BoxSku = wp.boxsku
	left join list on list.BoxSku = wp.boxsku
	where  wp.DevelopLastAuditTime is not null 
		and wp.projectteam = '快百货' -- 临时导表 复制关系
		and wp.BoxSku is not null 
) 


, t_add as (
select 
	case 
		when 产品状态 = '停产' then '停产'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and ( 近两周对比前两周增长幅度 = '>-10' or (KBH销量近8_14 + KBH销量近7) > 5 ) and 近4周累计销量判定 = '>40' then '爆款'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and ( 近两周对比前两周增长幅度 = '>-10' or (KBH销量近8_14 + KBH销量近7) > 5 ) and 近4周累计销量判定 = '<40' then '旺款'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and 近两周对比前两周增长幅度 = '<-10' and 近4周累计销量判定 = '>40' then '旺款'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and 近两周对比前两周增长幅度 = '<-10' and 近4周累计销量判定 = '<40' then '平销款'
		
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '5-30' and 近两周对比前两周增长幅度 = '<2' and (KBH销量近8_14 + KBH销量近7) > 5  then '潜力款'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '5-30' and 近两周对比前两周增长幅度 = '<2' and 近4周累计销量判定 = '' then '平销款'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '5-30' and 近两周对比前两周增长幅度 = '>2' and 近4周累计销量判定 = '' then '潜力款'
		when 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '0-5' and 近两周对比前两周增长幅度 = '' and 近4周累计销量判定 = '' then '滞销'
		
		when 新老品 = '新品' and 生命周期 = '导入期' and 累计出单划分 = '0-5' and 近两周对比前两周增长幅度 = '' and 近4周累计销量判定 = '' then '新品'
		when 新老品 = '新品' and 生命周期 = '成长期' and 累计出单划分 = '5-30' and ( 近两周对比前两周增长幅度 = '>2' or  (KBH销量近8_14 + KBH销量近7) > 5 ) and 近4周累计销量判定 = '' then '潜力款'
		when 新老品 = '新品' and 生命周期 = '成长期' and 累计出单划分 = '5-30' and 近两周对比前两周增长幅度 = '<2' and 近4周累计销量判定 = '' then '平销款'
		when 新老品 = '新品' and 生命周期 = '成长期' and 累计出单划分 = '1-5' and 近两周对比前两周增长幅度 = '' and 近4周累计销量判定 = '' then '平销款'
		when 新老品 = '新品' and 生命周期 = '成长期' and 累计出单划分 = '0' and 近两周对比前两周增长幅度 = '' and 近4周累计销量判定 = '' then '滞销'
		
		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and ( 近两周对比前两周增长幅度 = '>-10' or (KBH销量近8_14 + KBH销量近7) > 5 ) and 近4周累计销量判定 = '>40' then '爆款'
		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and ( 近两周对比前两周增长幅度 = '>-10' or (KBH销量近8_14 + KBH销量近7) > 5 ) and 近4周累计销量判定 = '<40' then '旺款'
		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and 近两周对比前两周增长幅度 = '<-10' and 近4周累计销量判定 = '>40' then '旺款'
		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '>30' and 近两周对比前两周增长幅度 = '<-10' and 近4周累计销量判定 = '<40' then '平销款'

		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '0-5' and 近两周对比前两周增长幅度 = '' and 近4周累计销量判定 = '' then '滞销'
		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '5-30' and ( 近两周对比前两周增长幅度 = '>2' or  (KBH销量近8_14 + KBH销量近7) > 5 ) and 近4周累计销量判定 = '' then '潜力款'
		when 新老品 = '新品' and 生命周期 = '成熟期' and 累计出单划分 = '5-30' and 近两周对比前两周增长幅度 = '<2' and 近4周累计销量判定 = '' then '平销款'
	end 商品分层
	,*
from (
	select 
		case 
			when 生命周期 = '成长期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) > 2 and KBH销量近12个月 >5 then '>2'
			when 生命周期 = '成长期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) <= 2 and KBH销量近12个月 >5 then '<2'
			when 生命周期 = '成熟期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) > -10 
				and KBH销量近12个月 >30 and (KBH销量近8_14 + KBH销量近7) > 0 then '>-10'
			when 生命周期 = '成熟期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) > -10 
				and KBH销量近12个月 >30 and (KBH销量近8_14 + KBH销量近7) = 0 then '<-10'
			when 生命周期 = '成熟期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) <= -10 
				and KBH销量近12个月 >30 then '<-10'
			when 生命周期 = '成熟期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) > 2 
				and 累计出单划分 = '5-30' then '>2'
			when 生命周期 = '成熟期' and (KBH销量近8_14 + KBH销量近7) - (KBH销量近22_28 + KBH销量近15_21) <= 2 
				and 累计出单划分 = '5-30' then '<2'
			else ''
		end 近两周对比前两周增长幅度
		,case 
			when 生命周期 = '成熟期' and KBH销量近12个月 > 30 and (KBH销量近22_28 + KBH销量近15_21 + KBH销量近8_14 + KBH销量近7) > 40 then '>40'
			when 生命周期 = '成熟期' and KBH销量近12个月 > 30 and (KBH销量近22_28 + KBH销量近15_21 + KBH销量近8_14 + KBH销量近7) <= 40 then '<40'
			else ''
		end 近4周累计销量判定
		,*   
	from (
		select 
			case when 新老品 = '老品' and KBH销量近12个月 >30 then '>30'
				when 新老品 = '老品' and KBH销量近12个月 >5 then '5-30'
				when 新老品 = '老品' then '0-5'
				when 新老品 = '新品' and 生命周期 = '成熟期' and KBH销量近12个月 >30 then '>30'
				when 新老品 = '新品' and 生命周期 = '成熟期' and KBH销量近12个月 >5 then '5-30'
				when 新老品 = '新品' and 生命周期 = '成熟期' then '0-5'
				when 新老品 = '新品' and 生命周期 = '成长期' and KBH销量近12个月 >5 then '5-30'
				when 新老品 = '新品' and 生命周期 = '成长期' and KBH销量近12个月 >0 then '1-5'
				when 新老品 = '新品' and 生命周期 = '导入期' then '0-5'
				else 0
			end as 累计出单划分
			,*
		from (
			select 
				case when kbh销量近12个月 <=5 and 终审距今月数_按30天 <=1 then '导入期'
					when kbh销量近12个月 <=30 and 终审距今月数_按30天 <3 then '成长期'
					else '成熟期'
				end 生命周期
				,case when year(终审时间) >= 2023 then '新品' else '老品'  end as `新老品`
				,*
			from t_merge
			) ta
		) tb 
	) tc
)

select * from t_add 
-- select 商品分层  from t_add 
-- where 新老品 = '老品' and 生命周期 = '成熟期' and 累计出单划分 = '5-30' and (KBH销量近8_14 + KBH销量近7) > 5 group by 商品分层

-- select count(1) from t_add where 商品分层 <> '停产'

-- 	select 
-- 	-- 	count(终审距今月数_按30天)
-- 	-- 	,count(KBH销量近12个月)
-- 	-- 	,count(生命周期)
-- 	-- 	,count(新老品)
-- 	-- 	,count(近两周对比前两周增长幅度)
-- 	-- 	,count(近4周累计销量判定)
-- 	-- 	,count(商品分层) 
-- 		商品分层 ,count(1) 
-- 	from t_add
-- 	group by 商品分层
	-- ) tmp 