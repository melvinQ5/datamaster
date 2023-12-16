/*
开斋节-欧洲站：
STEP1：业务人员筛选-排名涨幅前5的关键词
STEP2：筛选出产品库中所有符合关键词的商品（以新品为重）
STEP3：近7天对比前7天订单数增长≥1，按订单降序排列（去掉停产和缺货的产品）
复活节-欧洲站：同开斋节
园艺-英国站&美国站：同开斋节
*/

with
ele as ( -- 元素映射表，最小粒度是 SPU+SKU+NAME
select eppaea.spu ,eppaea.sku ,products.boxsku ,products.DevelopLastAuditTime
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
left join import_data.erp_product_products products on eppaea.sku = products.sku 
where products.ismatrix = 0
group by eppaea.spu ,eppaea.sku ,products.boxsku ,products.DevelopLastAuditTime
)

,t_keyword_prod as (
select BoxSKU
from wt_products
where ProductName regexp '
复活节礼物|复活节工艺品|桌旗复活节|窗口图片复活节|复活节饼干模具|复活节树|复活节彩蛋|
船配件|船灯|船椅|船拖车灯|皮筏艇配件|皮筏艇救生衣|充气皮筏艇2人|皮筏艇收纳|
祖母礼物|第一个母亲节礼物|女士感谢礼物|母亲节礼物|妈妈礼物|儿子送妈妈的礼物|女儿送妈妈的礼物|礼物包装袋|母亲节装饰|
弹出式母亲节卡|母亲节马克杯|母亲节横幅|母亲节手链|母亲节钥匙扣|母亲节蛋糕装饰|有趣的母亲节卡|
'
-- where ProductName regexp '
-- 	复活节篮子填充物|复活节装饰|复活节女士装扮|复活节桌旗|复活节花环|孩子们的复活节工艺品|复活节帽子|
-- 复活节礼物|复活节工艺品|桌旗复活节|窗口图片复活节|复活节饼干模具|复活节树|复活节彩蛋'	
-- where ProductName regexp '
-- 	斋月装饰品|斋月礼物|斋月降临节日历|斋月灯|斋月旗帜|斋月桌布|斋月饼干模具|月亮装饰|穆斯林祈祷垫|
-- 	斋月灯笼|斋月贴纸|斋月彩灯|斋月袋|儿童斋月日历|斋月记事簿|斋月餐具|伊斯兰墙装饰艺术|女性穆斯林裙子|
-- 	复活节装饰|复活节篮子填充|复活节鸡蛋|复活节礼物|复活节糖果|复活节女士装扮|复活节贺卡|
-- 	复活节|复活节装饰|复活节工艺品|复活节礼物|复活节彩蛋|复活节树|
-- 	室内植物架|室内花盆|小花盆|花园围栏装饰品|假植物|花园树叶收集器|用于树叶的花园耙'	
group by BoxSKU
)

,t_ord_trend as (
select pp.SKU ,pp.BoxSKU ,pp.ProductName ,pp.CategoryPathByChineseName,Cat1,c.前7天产品订单数,c.近7天产品订单数,c.订单增量 
from
	(select a.BoxSKU,number1 as '近7天产品订单数',number2 as '前7天产品订单数',number1-number2 as '订单增量' 
	from
		(
		select wo.boxsku
			,round(count(distinct PlatOrderNumber),2)  as  number1
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 
		join t_keyword_prod on wo.BoxSKU = t_keyword_prod.BoxSKU
-- 		join ( select spu ,BoxSku ,DevelopLastAuditTime from ele group by spu ,BoxSku ,DevelopLastAuditTime ) tmp 
-- 			on wo.BoxSku = tmp.boxsku -- 筛选元素品
		where PayTime >=date_add('${NextStartday}',interval -7 day ) and PayTime <'${NextStartday}'
-- 		where PayTime >=date_add('${NextStartday}',interval -14 day ) and PayTime <'${NextStartday}'
		group by wo.boxsku 
		) as a
	inner join
		(
		select wo.boxsku
			,round(count(distinct PlatOrderNumber),2)  as  number2
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 
		join t_keyword_prod on wo.BoxSKU = t_keyword_prod.BoxSKU
-- 		join ( select spu ,BoxSku ,DevelopLastAuditTime from ele group by spu ,BoxSku ,DevelopLastAuditTime ) tmp 
-- 			on wo.BoxSku = tmp.boxsku -- 筛选元素品
		where PayTime >=date_add('${NextStartday}',interval -14 day ) and PayTime <date_add('${NextStartday}',interval -7 day )
-- 		where PayTime >=date_add('${NextStartday}',interval -28 day ) and PayTime <date_add('${NextStartday}',interval -14 day )
		group by wo.boxsku 
		) as b
	on a.BoxSKU=b.BoxSKU 
-- 	and number1-number2>=1
	) as c
left join wt_products as pp
on c.BoxSKU=pp.BoxSKU
and IsDeleted=0
and ProductStatus not in ('2','4')
)

select *
from t_ord_trend  where boxsku is not null
order by 订单增量 desc limit 200