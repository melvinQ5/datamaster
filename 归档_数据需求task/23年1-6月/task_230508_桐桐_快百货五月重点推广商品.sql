
with push as ( -- 桐桐根据手工表提供名单
select c2 as sku ,c3 as boxsku
from manual_table mt where c1 = '快百货_5月重点推广商品_0509v1' 
)


,tb as ( -- 快百货归还财务的600个账号
select c2 as arr from  manual_table mt where c1 = '快百货退回财务账号0427'
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
join  import_data.wt_products wp on dwi.BoxSku = wp.BoxSku and wp.ProjectTeam = '快百货'
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
select BoxSku, paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,case when GroupSkuNumber > 0 then GroupSku else BoxSku end as targetsku 		
	,case when GroupSkuNumber > 0 then '组合出单' else '非组合出单' end as isgroup_pre 		
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
-- join rela on wo.BoxSku = rela.ori_boxsku  -- 临时导表 复制关系
where wo.IsDeleted = 0 and OrderStatus != '作废' and ms.Department = '快百货'
	and PayTime >= '2022-01-01' 
union 
select BoxSku, paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,case when GroupSkuNumber > 0  then GroupSku else BoxSku end  as targetsku 
	,case when GroupSkuNumber > 0 then '组合出单' else '非组合出单' end as isgroup_pre 	
from import_data.wt_orderdetails wo 
join tb on wo.shopcode = tb.arr -- 快百货归还财务的600个账号
-- join rela on wo.BoxSku = rela.ori_boxsku  -- 临时导表 复制关系
where wo.IsDeleted = 0 and OrderStatus != '作废'  
	and PayTime >= '2022-01-01'
)

, boxsku_2_groupsku as ( -- 单独处理如果 子体SKU直接同编码转变为组合SKU，详情可查订单表 boxsku in (4302766,4350836)
select targetsku 
	, case when isgroup regexp '组合出单' then '组合出单' else '非组合出单' end as isgroup -- 只要曾有过组合出单，即是为组合出单
from (select targetsku ,GROUP_CONCAT(isgroup_pre) isgroup from od_pre group by targetsku) tmp
)

,od as (
select a.targetsku ,BoxSku, b.isgroup , paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku  ,site 
	,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
from od_pre a join boxsku_2_groupsku b on a.targetsku = b.targetsku
)
-- select * from od 

,orde as (  -- 出单sku本身包括复制关系里的源SKU
select targetsku as BoxSku ,isgroup
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then salecount end ) as KBH销量近12个月
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then salecount end ) as KBH销量近7
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then salecount end ) as KBH销量近8_14
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then salecount end ) as KBH销量近15_21
	,sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then salecount end ) as KBH销量近22_28
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'US' then salecount end ) as US销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'UK' then salecount end ) as UK销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'DE' then salecount end ) as DE销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'FR' then salecount end ) as FR销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'CA' then salecount end ) as CA销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'AU' then salecount end ) as AU销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'ES' then salecount end ) as ES销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'IT' then salecount end ) as IT销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'SE' then salecount end ) as SE销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'NL' then salecount end ) as NL销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'BE' then salecount end ) as BE销量近3月
	,sum( case when  PayTime >= date_add('${NextStartDay}' ,interval -3 month) 
		and PayTime < '${NextStartDay}' and site = 'MX' then salecount end ) as MX销量近3月

	
	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then totalgross/exchangeUSD end ) as KBH销售额近12个月
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalgross/exchangeUSD end )) as KBH销售额近7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalgross/exchangeUSD end )) as KBH销售额近8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalgross/exchangeUSD end )) as KBH销售额近15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalgross/exchangeUSD end )) as KBH销售额近22_28
-- 	,sum(case when left(paytime,4)='2021' then totalgross/exchangeUSD end ) as KBH销售额21年

	,sum(case when  PayTime >= date_add('${NextStartDay}' ,interval -12 month) 
		and PayTime < '${NextStartDay}' then totalprofit/exchangeUSD end ) as KBH利润额近12个月
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -7 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -0 day) then totalprofit/exchangeUSD end )) as KBH利润额近7
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -14 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -7 day) then totalprofit/exchangeUSD end )) as KBH利润额近8_14
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -21 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -14 day) then totalprofit/exchangeUSD end )) as KBH利润额近15_21
	,round(sum(case when  PayTime >=date_add('${NextStartDay}' ,interval -28 day) 
		and PayTime < date_add('${NextStartDay}' ,interval -21 day) then totalprofit/exchangeUSD end )) as KBH利润额近22_28
-- 	,sum(case when left(paytime,4)='2021' then totalprofit/exchangeUSD end ) as KBH利润额21年
from od
group by targetsku ,isgroup
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
	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成1` 
	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成2` 
	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(shopcode,SellerSku) end ) `在线链接数_泉1` 
	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(shopcode,SellerSku) end ) `在线链接数_泉2` 
	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(shopcode,SellerSku) end ) `在线链接数_泉3` 
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
		,wp.ProductName `产品名` 
		,wp.DevelopUserName `开发人员`
		,date(date_add(wp.DevelopLastAuditTime,interval - 8 hour)) `终审日期`
		,wp.cat1
		,wp.cat2
		,wp.cat3
		,wp.cat4
		,TotalInventory `库存件数`
-- 		,wp.projectteam `产品库归属部门`
-- 		,wp.ori_boxsku  `源boxsku（有复制关系）`
-- 		,wp.ori_team `源boxsku归属部门`
-- 		,case when coalesce(orde.isgroup,orde2.isgroup) is null then '快百货账号(含退回)无订单记录' else orde.isgroup end as `是否组合出单`
-- 		,ware.BoxSku `有库存boxsku`
	 	,case when wp.ProductStatus =  0 then '正常'
	 			when wp.ProductStatus = 2 then '停产'
	 			when wp.ProductStatus = 3 then '停售'
	 			when wp.ProductStatus = 4 then '暂时缺货'
	 			when wp.ProductStatus = 5 then '清仓'
	 	end as  `产品状态`
-- 	 	,wp.ChangeReasons `停产原因`
	 	,wp.TortType `侵权类型`
	 	
-- 	 	,round(timestampdiff(second,date_add(wp.DevelopLastAuditTime,interval - 8 hour),CURRENT_DATE())/86400/30)  `终审距今月数_按30天`
		,ifnull(orde.KBH销量近12个月,0) + ifnull(orde2.KBH销量近12个月,0) as KBH销量近12个月
		,ifnull(orde.KBH销售额近12个月,0) + ifnull(orde2.KBH销售额近12个月,0) as KBH销售额近12个月
		,ifnull(orde.KBH利润额近12个月,0) + ifnull(orde2.KBH利润额近12个月,0) as KBH利润额近12个月
	
		
		,ifnull(orde.KBH销量近7,0) + ifnull(orde2.KBH销量近7,0) + ifnull(orde.KBH销量近8_14,0) + ifnull(orde2.KBH销量近8_14,0) as KBH销量近14天
		,ifnull(orde.KBH销量近15_21,0) + ifnull(orde2.KBH销量近15_21,0) + ifnull(orde.KBH销量近22_28,0) + ifnull(orde2.KBH销量近22_28,0) as KBH销量前14天
		
		,ifnull(orde.KBH销售额近7,0) + ifnull(orde2.KBH销售额近7,0) + ifnull(orde.KBH销售额近8_14,0) + ifnull(orde2.KBH销售额近8_14,0) as KBH销售额近14天
		,ifnull(orde.KBH销售额近15_21,0) + ifnull(orde2.KBH销售额近15_21,0) + ifnull(orde.KBH销售额近22_28,0) + ifnull(orde2.KBH销售额近22_28,0) as KBH销售额前14天
		
		,ifnull(orde.KBH利润额近7,0) + ifnull(orde2.KBH利润额近7,0) + ifnull(orde.KBH利润额近8_14,0) + ifnull(orde2.KBH利润额近8_14,0) as KBH利润额近14天
		,ifnull(orde.KBH利润额近15_21,0) + ifnull(orde2.KBH利润额近15_21,0) + ifnull(orde.KBH利润额近22_28,0) + ifnull(orde2.KBH利润额近22_28,0) as KBH利润额前14天
		
		,ifnull(orde.KBH销量近7,0) + ifnull(orde2.KBH销量近7,0) + ifnull(orde.KBH销量近8_14,0) + ifnull(orde2.KBH销量近8_14,0) 
			- ( ifnull(orde.KBH销量近15_21,0) + ifnull(orde2.KBH销量近15_21,0) + ifnull(orde.KBH销量近22_28,0) + ifnull(orde2.KBH销量近22_28,0) ) as 近14对比前14订单增量

		,ifnull(orde.US销量近3月,0) + ifnull(orde2.US销量近3月,0) as US销量近3月
		,ifnull(orde.UK销量近3月,0) + ifnull(orde2.UK销量近3月,0) as UK销量近3月
		,ifnull(orde.DE销量近3月,0) + ifnull(orde2.DE销量近3月,0) as DE销量近3月
		,ifnull(orde.FR销量近3月,0) + ifnull(orde2.FR销量近3月,0) as FR销量近3月
		,ifnull(orde.CA销量近3月,0) + ifnull(orde2.CA销量近3月,0) as CA销量近3月
		,ifnull(orde.AU销量近3月,0) + ifnull(orde2.AU销量近3月,0) as AU销量近3月
		,ifnull(orde.ES销量近3月,0) + ifnull(orde2.ES销量近3月,0) as ES销量近3月
		,ifnull(orde.IT销量近3月,0) + ifnull(orde2.IT销量近3月,0) as IT销量近3月
		,ifnull(orde.SE销量近3月,0) + ifnull(orde2.SE销量近3月,0) as SE销量近3月
		,ifnull(orde.NL销量近3月,0) + ifnull(orde2.NL销量近3月,0) as NL销量近3月
		,ifnull(orde.BE销量近3月,0) + ifnull(orde2.BE销量近3月,0) as BE销量近3月
		,ifnull(orde.MX销量近3月,0) + ifnull(orde2.MX销量近3月,0) as MX销量近3月
		
-- 		,`在线链接数`
-- 	 	,`在线链接数_成1` 
-- 	 	,`在线链接数_成2` 
-- 	 	,`在线链接数_泉1` 
-- 	 	,`在线链接数_泉2` 
-- 	 	,`在线链接数_泉3` 
	 	
-- 	 	,round(timestampdiff(second,date_add(wp.DevelopLastAuditTime,interval - 8 hour),CURRENT_DATE())/86400)  `终审距今天数`
-- 	 	,IsPackage `是否包材`
-- 	 	,AverageUnitPrice `平均单价`
-- 	 	,TotalPrice `库存总金额`
-- 	 	,InventoryAge45 `0-45天库龄金额`
-- 	 	,InventoryAge90 `46-90天库龄金额`
-- 	 	,InventoryAge180 `91-180天库龄金额`
-- 	 	,InventoryAge270 `181-270天库龄金额`
-- 	 	,InventoryAge365 `271-365天库龄金额`
-- 	 	,InventoryAgeOver `大于365天库龄金额`
-- 	 	,max_InstockTime `最后采购完结日`
-- 	 	,datediff(CURRENT_DATE(),max_InstockTime) `最后采购完结距今天数` 
	from 
		( select wp.* ,rela.ori_boxsku ,rela.ori_team
		from import_data.wt_products wp
		join push on wp.sku =push.sku  -- 桐桐提供五月名单
		left join rela on wp.BoxSku = rela.new_boxsku  
		) wp 
	left join ware on ware.BoxSku = wp.boxsku
	left join orde on orde.BoxSku = wp.boxsku -- 产品库归属快百货的销售，快百货账号出单
	left join orde orde2 on orde2.BoxSku = wp.ori_boxsku -- 产品库归属其他部门，快百货账号出单
	-- left join orde_tmh on orde_tmh.BoxSku = wp.boxsku
	left join inst on inst.BoxSku = wp.boxsku
	left join list on list.BoxSku = wp.boxsku
	where  wp.DevelopLastAuditTime is not null 
		and wp.projectteam = '快百货' -- 临时导表 复制关系
		and wp.BoxSku is not null 
)

, t_site_sort as (
select sku ,GROUP_CONCAT(site) 销量top2站点
from (
select * , ROW_NUMBER () over (partition by sku order by sales desc ) sort 
	from (
		select sku , US销量近3月 as sales, 'US' as site from t_merge 
		union all select sku , UK销量近3月 , 'UK' as site from t_merge 
		union all select sku , DE销量近3月 , 'DE' as site from t_merge 
		union all select sku , FR销量近3月 , 'FR' as site from t_merge 
		union all select sku , CA销量近3月 , 'CA' as site from t_merge 
		union all select sku , AU销量近3月 , 'AU' as site from t_merge 
		union all select sku , ES销量近3月 , 'ES' as site from t_merge 
		union all select sku , IT销量近3月 , 'IT' as site from t_merge 
		union all select sku , SE销量近3月 , 'SE' as site from t_merge 
		union all select sku , NL销量近3月 , 'NL' as site from t_merge 
		union all select sku , BE销量近3月 , 'BE' as site from t_merge 
		union all select sku , MX销量近3月 , 'MX' as site from t_merge 
		) tb 
	where sales > 0
	) tc
where sort <= 2 
group by sku
)

select t_merge.* ,t_site_sort.销量top2站点
from t_merge left join t_site_sort on t_merge.sku = t_site_sort.sku 


		
