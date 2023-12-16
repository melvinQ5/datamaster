-- 计算公司整体销售额 判断元素业绩占比
-- 清凉季SKU 在2203-2210，2303-2304分月及累计销量 ，bySKU维度

with 
ele as ( 
select eppaea.sku 
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
where eppea.name = '清凉季' 
group by eppaea.sku 
)

,od as (
select wo.BoxSku ,wo.Product_Sku as sku ,TotalGross ,ExchangeUSD ,salecount ,PayTime ,nodepathname 
from wt_orderdetails wo
join mysql_store ms on wo.shopcode = ms.Code 
join ele on wo.Product_Sku = ele.sku 
where wo.IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' 
	and OrderStatus !='作废' and TransactionType = '付款'
	and ms.Department  = '快百货'
)

,t_od_stat as (
select  
	sku 
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-11-01' then salecount end ),2) as KBH销量22年3至10月
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
	,round(sum(case when left(paytime,7)='2023-04' then salecount end ),2) as KBH销量230401至今
	
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-11-01' then TotalGross/ExchangeUSD end ),2) as KBH销售额22年3至10月
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
	,round(sum(case when left(paytime,7)='2023-04' then TotalGross/ExchangeUSD end ),2) as KBH销售额230401至今
	
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次方-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_方_销售额22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次元-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_元_销售额22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州1组' then TotalGross/ExchangeUSD end ),2) as 泉1销售额22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州2组' then TotalGross/ExchangeUSD end ),2) as 泉2销售额22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州3组' then TotalGross/ExchangeUSD end ),2) as 泉3销售额22年3至10月	

	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次方-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_方_销售额2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次元-成都销售组' then TotalGross/ExchangeUSD end ),2) as 成_元_销售额2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州1组' then TotalGross/ExchangeUSD end ),2) as 泉1销售额2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州2组' then TotalGross/ExchangeUSD end ),2) as 泉2销售额2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州3组' then TotalGross/ExchangeUSD end ),2) as 泉3销售额2303至今
	
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次方-成都销售组' then salecount end ),2) as 成_方_销量22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '快次元-成都销售组' then salecount end ),2) as 成_元_销量22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州1组' then salecount end ),2) as 泉1销量22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州2组' then salecount end ),2) as 泉2销量22年3至10月
	,round(sum(case when paytime > ='2022-03-01' and  paytime < ='2022-10-01' and NodePathName = '运营组-泉州3组' then salecount end ),2) as 泉3销量22年3至10月	

	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次方-成都销售组' then salecount end ),2) as 成_方_销量2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '快次元-成都销售组' then salecount end ),2) as 成_元_销量2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州1组' then salecount end ),2) as 泉1销量2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州2组' then salecount end ),2) as 泉2销量2303至今
	,round(sum(case when paytime > ='2023-03-01' and NodePathName = '运营组-泉州3组' then salecount end ),2) as 泉3销量2303至今

from od
group by sku 
)

select ele.sku  
	,wp.ProductName
	,wp2.cat1
	,wp2.cat2
	,wp2.cat3
	,wp2.cat4
	,wp2.cat5
	,KBH销量22年3至10月
	,case when wp.ProductStatus =  0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
		end as  `产品状态`
	,wp2.TortType `侵权状态`
	,成_方_销售额22年3至10月
	,成_元_销售额22年3至10月
	,泉1销售额22年3至10月
	,泉2销售额22年3至10月
	,泉3销售额22年3至10月	

	,成_方_销售额2303至今
	,成_元_销售额2303至今
	,泉1销售额2303至今
	,泉2销售额2303至今
	,泉3销售额2303至今
	
	,成_方_销量22年3至10月
	,成_元_销量22年3至10月
	,泉1销量22年3至10月
	,泉2销量22年3至10月
	,泉3销量22年3至10月	

	,成_方_销量2303至今
	,成_元_销量2303至今
	,泉1销量2303至今
	,泉2销量2303至今
	,泉3销量2303至今
	
	
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
	,KBH销量230401至今
	
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
	,KBH销售额230401至今

	,wp.CreationTime `添加时间`
	,wp.DevelopLastAuditTime  `终审时间`
	,SupplierName `供应商`
	,PurchaseLink `采购链接`
	,PurchasePrice `采购价`
	,NetWeight `净重`
	,GrossWeight `毛重`
	,concat(ProductLong,'x',ProductWidth,'x',ProductHeight) `产品长宽高`
	,concat(PackageLong,'x',PackageWidth,'x',PackageHeight) `包装长宽高`
from ele 
left join t_od_stat ta on ele.sku =ta.sku 
left join erp_product_products wp on ele.sku =wp.sku and IsMatrix = 0 and IsDeleted = 0 
left join wt_products wp2  on ele.sku =wp2.sku  and wp2.IsDeleted = 0 
left join erp_product_product_suppliers epps on epps.ProductId = wp.id
order by KBH销量22年3至10月 desc 
