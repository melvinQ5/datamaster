-- NextStartDay = 每周一
-- 

with 
t_od_last_week as ( -- 上周出单SKU
select BoxSku ,count(distinct PlatOrderNumber) as ords_last_week_cnt
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.Code 
where IsDeleted = 0 and ms.Department = '特卖汇'
	and PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and OrderStatus !='作废' and OrderTotalPrice > 0
group by BoxSku having count(distinct PlatOrderNumber) >= 5
)

, t_od as ( -- asin 销量
select wo.BoxSku ,asin ,ms.Site 
	,replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `W周`
	,round(sum(case when PayTime >='${StartDay}' and PayTime<'${NextStartDay}' then TotalGross/ExchangeUSD end ),2) `W周销售额`
	,round(sum(case when PayTime >='${StartDay}' and PayTime<'${NextStartDay}' then TotalProfit/ExchangeUSD end ),2) `W周利润额`
	,sum(case when PayTime >='${StartDay}' and PayTime<'${NextStartDay}' then SaleCount end ) `W周销量`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -7 day) and PayTime < date_add('${NextStartDay}' ,interval -7 day) then TotalGross/ExchangeUSD end ),2) `W-1周销售额`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -7 day) and PayTime < date_add('${NextStartDay}' ,interval -7 day) then TotalProfit/ExchangeUSD end ),2) `W-1周利润额`
	,sum(case when PayTime >=date_add('${StartDay}' ,interval -7 day) and PayTime < date_add('${NextStartDay}' ,interval -7 day) then SaleCount end ) `W-1周销量`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -14 day) and PayTime < date_add('${NextStartDay}' ,interval -14 day) then TotalGross/ExchangeUSD end ),2) `W-2周销售额`
	,round(sum(case when PayTime >=date_add('${StartDay}' ,interval -14 day) and PayTime < date_add('${NextStartDay}' ,interval -14 day) then TotalProfit/ExchangeUSD end ),2) `W-2周利润额`
	,sum(case when PayTime >=date_add('${StartDay}' ,interval -14 day) and PayTime < date_add('${NextStartDay}' ,interval -14 day) then SaleCount end ) `W-2周销量`
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode = ms.Code 
join t_od_last_week on wo.BoxSku = t_od_last_week.BoxSku 
where  PayTime >=date_add('${StartDay}' ,interval -21 day) and PayTime< '${NextStartDay}' 
	and IsDeleted = 0 and ms.Department = '特卖汇' and OrderStatus != '作废'
group by wo.BoxSku ,asin ,ms.Site 
)

-- select date_add('2023-04-03' ,interval -7 day)

select 
	t_od_last_week.ords_last_week_cnt `W周boxsku出单数`
	,t_od.*
	,wp.Spu 
	,wp.ProductName
	,case when wp.ProductStatus =  0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
		end as  `产品状态`
	,wp.CreationTime `添加时间`
	,Site `站点`
	,PurchaseLink `采购链接`
	,PurchasePrice `采购价`
	,NetWeight `净重`
	,GrossWeight `毛重`
	,concat(ProductLong,'x',ProductWidth,'x',ProductHeight) `产品长宽高`
	,concat(PackageLong,'x',PackageWidth,'x',PackageHeight) `包装长宽高`
	
from t_od
left join wt_products wp on wp.BoxSku = t_od.BoxSku 
left join erp_product_products epp  on epp.id = wp.id   
left join erp_product_product_suppliers epps on epps.ProductId = wp.id  
left join t_od_last_week on t_od.boxsku = t_od_last_week.boxsku 
where t_od.boxsku <> 'ShopFee' and wp.ProductStatus != 2  -- 未停产

