-- 计算公司整体销售额 判断元素业绩占比

with 
t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.spu ,group_concat(eppea.Name) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
group by eppaea.spu
)

,od as (
select wo.BoxSku ,wo.Product_Sku as sku ,TotalGross ,ExchangeUSD ,salecount ,PayTime ,nodepathname 
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
where wo.IsDeleted = 0 
	and OrderStatus !='作废' and TransactionType = '付款' -- S1销售额
	and ms.Department  = '快百货'
)

,t_od_stat as (
select  
	sku 
	,round(sum(salecount),2) as KBH累计销量
	,round(sum(case when left(paytime,7)='2022-01' then salecount end ),2) as KBH销量2201
	,round(sum(case when left(paytime,7)='2022-02' then salecount end ),2) as KBH销量2202
	,round(sum(case when left(paytime,7)='2022-03' then salecount end ),2) as KBH销量2203
	,round(sum(case when left(paytime,7)='2022-04' then salecount end ),2) as KBH销量2204
	,round(sum(case when left(paytime,7)='2022-05' then salecount end ),2) as KBH销量2205
	,round(sum(case when left(paytime,7)='2022-06' then salecount end ),2) as KBH销量2206
	,round(sum(case when left(paytime,7)='2022-07' then salecount end ),2) as KBH销量2207
	,round(sum(case when left(paytime,7)='2022-08' then salecount end ),2) as KBH销量2208
	,round(sum(case when left(paytime,7)='2022-09' then salecount end ),2) as KBH销量2209
	,round(sum(case when left(paytime,7)='2022-10' then salecount end ),2) as KBH销量2210
	,round(sum(case when left(paytime,7)='2022-11' then salecount end ),2) as KBH销量2211
	,round(sum(case when left(paytime,7)='2022-12' then salecount end ),2) as KBH销量2212
	,round(sum(case when left(paytime,7)='2023-01' then salecount end ),2) as KBH销量2301
	,round(sum(case when left(paytime,7)='2023-02' then salecount end ),2) as KBH销量2302
	,round(sum(case when left(paytime,7)='2023-03' then salecount end ),2) as KBH销量2303
	,round(sum(case when left(paytime,7)='2023-04' then salecount end ),2) as KBH销量2304
	,round(sum(case when left(paytime,7)='2023-05' then salecount end ),2) as KBH销量2305
	,round(sum(case when left(paytime,7)='2023-06' then salecount end ),2) as KBH销量2306
	,round(sum(case when left(paytime,7)='2023-07' then salecount end ),2) as KBH销量2307
	,round(sum(case when left(paytime,7)='2023-08' then salecount end ),2) as KBH销量2308
	,round(sum(case when left(paytime,7)='2023-09' then salecount end ),2) as KBH销量2309
	,round(sum(case when left(paytime,7)='2023-10' then salecount end ),2) as KBH销量2310
	,round(sum(case when left(paytime,7)='2023-11' then salecount end ),2) as KBH销量2311
	,round(sum(case when left(paytime,7)='2023-12' then salecount end ),2) as KBH销量2312
	
	,round(sum(TotalGross/ExchangeUSD),2) as KBH累计销售额
	,round(sum(case when left(paytime,7)='2022-01' then TotalGross/ExchangeUSD end ),2) as KBH销售额2201
	,round(sum(case when left(paytime,7)='2022-02' then TotalGross/ExchangeUSD end ),2) as KBH销售额2202
	,round(sum(case when left(paytime,7)='2022-03' then TotalGross/ExchangeUSD end ),2) as KBH销售额2203
	,round(sum(case when left(paytime,7)='2022-04' then TotalGross/ExchangeUSD end ),2) as KBH销售额2204
	,round(sum(case when left(paytime,7)='2022-05' then TotalGross/ExchangeUSD end ),2) as KBH销售额2205
	,round(sum(case when left(paytime,7)='2022-06' then TotalGross/ExchangeUSD end ),2) as KBH销售额2206
	,round(sum(case when left(paytime,7)='2022-07' then TotalGross/ExchangeUSD end ),2) as KBH销售额2207
	,round(sum(case when left(paytime,7)='2022-08' then TotalGross/ExchangeUSD end ),2) as KBH销售额2208
	,round(sum(case when left(paytime,7)='2022-09' then TotalGross/ExchangeUSD end ),2) as KBH销售额2209
	,round(sum(case when left(paytime,7)='2022-10' then TotalGross/ExchangeUSD end ),2) as KBH销售额2210
	,round(sum(case when left(paytime,7)='2022-11' then TotalGross/ExchangeUSD end ),2) as KBH销售额2211
	,round(sum(case when left(paytime,7)='2022-12' then TotalGross/ExchangeUSD end ),2) as KBH销售额2212
	,round(sum(case when left(paytime,7)='2023-01' then TotalGross/ExchangeUSD end ),2) as KBH销售额2301
	,round(sum(case when left(paytime,7)='2023-02' then TotalGross/ExchangeUSD end ),2) as KBH销售额2302
	,round(sum(case when left(paytime,7)='2023-03' then TotalGross/ExchangeUSD end ),2) as KBH销售额2303
	,round(sum(case when left(paytime,7)='2023-04' then TotalGross/ExchangeUSD end ),2) as KBH销售额2304
	,round(sum(case when left(paytime,7)='2023-05' then TotalGross/ExchangeUSD end ),2) as KBH销售额2305
	,round(sum(case when left(paytime,7)='2023-06' then TotalGross/ExchangeUSD end ),2) as KBH销售额2306
	,round(sum(case when left(paytime,7)='2023-07' then TotalGross/ExchangeUSD end ),2) as KBH销售额2307
	,round(sum(case when left(paytime,7)='2023-08' then TotalGross/ExchangeUSD end ),2) as KBH销售额2308
	,round(sum(case when left(paytime,7)='2023-09' then TotalGross/ExchangeUSD end ),2) as KBH销售额2309
	,round(sum(case when left(paytime,7)='2023-10' then TotalGross/ExchangeUSD end ),2) as KBH销售额2310
	,round(sum(case when left(paytime,7)='2023-11' then TotalGross/ExchangeUSD end ),2) as KBH销售额2311
	,round(sum(case when left(paytime,7)='2023-12' then TotalGross/ExchangeUSD end ),2) as KBH销售额2312
	
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次方-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_方_销售额22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次元-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_元_销售额22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州1组' then TotalGross/ExchangeUSD end ),2) as 泉1销售额22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州2组' then TotalGross/ExchangeUSD end ),2) as 泉2销售额22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州3组' then TotalGross/ExchangeUSD end ),2) as 泉3销售额22年3至10月	
-- 
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次方-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_方_销售额2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次元-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_元_销售额2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州1组' then TotalGross/ExchangeUSD end ),2) as 泉1销售额2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州2组' then TotalGross/ExchangeUSD end ),2) as 泉2销售额2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州3组' then TotalGross/ExchangeUSD end ),2) as 泉3销售额2303至今
-- 	
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次方-成都销售组' then salecount end ),2) as 成_方_销量22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次元-成都销售组' then salecount end ),2) as 成_元_销量22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州1组' then salecount end ),2) as 泉1销量22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州2组' then salecount end ),2) as 泉2销量22年3至10月
-- 	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州3组' then salecount end ),2) as 泉3销量22年3至10月	
-- 
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次方-成都销售组' then salecount end ),2) as 成_方_销量2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次元-成都销售组' then salecount end ),2) as 成_元_销量2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州1组' then salecount end ),2) as 泉1销量2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州2组' then salecount end ),2) as 泉2销量2303至今
-- 	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州3组' then salecount end ),2) as 泉3销量2303至今

from od
group by sku 
)


select ele.sku  
-- 	,wp.CreationTime `添加时间`
	,date(date_add(wp.DevelopLastAuditTime , interval - 8 hour))   `终审日期`
	,year(date_add(wp.DevelopLastAuditTime , interval - 8 hour))   `终审年份`
	,wp.ProductName 
	,CASE WHEN ele_name regexp '夏季' THEN '夏季' end `主题名称`
	,CASE WHEN date_add(wp.DevelopLastAuditTime , interval - 8 hour) 
		>=  DATE_ADD( DATE_ADD('${NextStartDay}',interval -day('${NextStartDay}')+1 day) ,interval -2 month)  THEN '新品' else '老品'
	end `新老品`
	,ele_name `元素名称`
	,wp.cat1
	,wp.cat2
	,wp.cat3
	,wp.cat4
	,wp.cat5
	,case when wp.ProductStatus =  0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
		end as  `产品状态`
	,wp.TortType `侵权状态`
-- 	,成_方_销售额22年3至10月
-- 	,成_元_销售额22年3至10月
-- 	,泉1销售额22年3至10月
-- 	,泉2销售额22年3至10月
-- 	,泉3销售额22年3至10月	
-- 
-- 	,成_方_销售额2303至今
-- 	,成_元_销售额2303至今
-- 	,泉1销售额2303至今
-- 	,泉2销售额2303至今
-- 	,泉3销售额2303至今
-- 	
-- 	,成_方_销量22年3至10月
-- 	,成_元_销量22年3至10月
-- 	,泉1销量22年3至10月
-- 	,泉2销量22年3至10月
-- 	,泉3销量22年3至10月	
-- 
-- 	,成_方_销量2303至今
-- 	,成_元_销量2303至今
-- 	,泉1销量2303至今
-- 	,泉2销量2303至今
-- 	,泉3销量2303至今
	
	,KBH累计销量
	,KBH累计销售额 
	
	,KBH销量2201
	,KBH销量2202
	,KBH销量2203
	,KBH销量2204
	,KBH销量2205
	,KBH销量2206
	,KBH销量2207
	,KBH销量2208
	,KBH销量2209
	,KBH销量2210
	,KBH销量2211
	,KBH销量2212
	,KBH销量2301
	,KBH销量2302
	,KBH销量2303
	,KBH销量2304
	,KBH销量2305
	,KBH销量2306
	,KBH销量2307
	,KBH销量2308
	,KBH销量2309
	,KBH销量2310
	,KBH销量2311
	,KBH销量2312

	
	,KBH销售额2201
	,KBH销售额2202
	,KBH销售额2203
	,KBH销售额2204
	,KBH销售额2205
	,KBH销售额2206
	,KBH销售额2207
	,KBH销售额2208
	,KBH销售额2209
	,KBH销售额2210
	,KBH销售额2211
	,KBH销售额2212
	,KBH销售额2301
	,KBH销售额2302
	,KBH销售额2303
	,KBH销售额2304
	,KBH销售额2305
	,KBH销售额2306
	,KBH销售额2307
	,KBH销售额2308
	,KBH销售额2309
	,KBH销售额2310
	,KBH销售额2311
	,KBH销售额2312

	
from (
	select wp.sku,wp.spu  from wt_products wp
	join t_od_stat ta on ta.sku = wp.sku and wp.IsDeleted = 0 
	where KBH累计销量 >= 5 and date_add(DevelopLastAuditTime , interval - 8 hour) < '2023-01-01'
	union all 
	select sku,spu from wt_products wp
	where date_add(DevelopLastAuditTime , interval - 8 hour) >= '2023-01-01' and wp.IsDeleted = 0 
	) ele
left join t_od_stat ta on ele.sku =ta.sku 
left join t_elem on ele.spu =t_elem.spu
left join wt_products wp  on ele.sku =wp.sku  and wp.IsDeleted = 0 
-- left join erp_product_product_suppliers epps on epps.ProductId = wp.id
