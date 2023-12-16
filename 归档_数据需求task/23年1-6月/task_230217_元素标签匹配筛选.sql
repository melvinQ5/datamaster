/*
 * 产品表季节字段列转行
 */
with t as (
select * from import_data.JinqinSku js where Monday = '2023-02-17'
)

, t_unnest as (
select sku 
	,case when Festival regexp '母亲节|骑行|露营|钓鱼|高尔夫|园艺|圣诞节|感恩节|万圣节|世界杯|开学季|美国独立日|独立日|父亲节|儿童节|毕业季|2022年开斋节|耶稣受难日|复活节|圣帕特里克节|白色情人节|穆斯林节|情人节|生日派对|婚礼季|开斋节|慕尼黑啤酒节|爱国日|蜜蜂节|狂欢节（us）|威尼斯狂欢节|性别揭示' 
	then Festival else null end as split -- 筛选包含元素的季节
	,spu ,Festival,ProjectTeam ,BoxSku ,CategoryPathByChineseName  ,ProductName 
,Festival 
from import_data.wt_products 
where  Festival is not null and IsDeleted = 0 
)

, od as ( 
select wo.boxsku , round(sum((TotalGross-RefundAmount)/ExchangeUSD),2) `销售额`  
from wt_orderdetails wo 
where IsDeleted = 0 and PayTime < '${NextStartDay}' and PayTime >= '${StartDay}' and Department = '快百货'
group by wo.BoxSku 
)

select t_unnest.* , od.`销售额` 
from t_unnest 
left join od on t_unnest.boxsku = od.boxsku
where split is not null 

-- select sku ,spu ,Festival,ProjectTeam ,BoxSku ,CategoryPathByChineseName  ,ProductName 
-- from import_data.wt_products
-- where Festival is not null and IsDeleted = 0 

