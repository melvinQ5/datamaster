1 对于 WITH 结构， UNION 不能放在临时表内，只能放在最终查询语句类
2 指定日期当月的第一天   DATE_ADD('${StartDay}',interval -day('${StartDay}')+1 day)
3 取子串 SUBSTR(shopcode,instr(shopcode,'-')+1) as ShopCode

-- 分割
split(CategoryPathByChineseName,'>')[1] as categ1
-- 产品状态
,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
		    
		,case when ProductStatus = 0 then '正常'
		when ProductStatus = 2 then '停产'
		when ProductStatus = 3 then '停售'
		when ProductStatus = 4 then '暂时缺货'
		when ProductStatus = 5 then '清仓'
		end as ProductStatusName

-- 退款原因枚举
SELECT RefundReason1 ,RefundReason2 ,count(1)
FROM import_data.daily_RefundOrders ro
group by RefundReason1 ,RefundReason2 

SELECT RefundReason1 ,count(1)
FROM import_data.daily_RefundOrders ro
group by RefundReason1 

-- 计算销量
where TransactionType = '付款' and OrderStatus <> '作废' and OrderTotalPrice > 0 

-- 计算销售额，需要剔掉未发货、订单作废 且只有一条付款记录的，因为后续这部分会有退款来冲抵
OrderNumber not in 
			(
			select OrderNumber from (
			SELECT OrderNumber, GROUP_CONCAT(TransactionType) alltype FROM import_data.OrderDetails
			where
			ShipmentStatus = '未发货' and OrderStatus = '作废'
			and PayTime >=date_add('${next_frist_day}',interval -7 day) and PayTime < '${next_frist_day}'
			group by OrderNumber) a
			where alltype = '付款')


, map_categ as ( -- 新旧一级类目匹配关系
select
     eppc.categ1 as categ_old
     , nsm.BoxSku as categ_new
     , epp.BoxSKU
from
     (
     select
          split(CategoryPathByChineseName,'>')[1] as categ1
          , Id
     from import_data.erp_product_product_category
     where IsDeleted = 0
     ) eppc
join import_data.erp_product_products epp on eppc.Id =  epp.ProductCategoryId 
left join new_sku_map nsm on eppc.categ1 = nsm.Sku
groupby eppc.categ1 , categ_new , epp.BoxSKU
)
