-- 店铺数
select 
	count( distinct ShopCode) shop_cnt 
from (
	select tmp.ShopCode 
		-- ItemType (1:订单缺陷率,2:1: 负面反馈率,3:2: 亚马逊商城交易保障索赔,4:3: 信用卡拒付率,5:1: 延迟率,6:2: 取消率,7:3: 退款率,8:1: 有效追踪率,9:2: 准时交货率,10:1: 客户服务指标,11:退货不满意率,12:1: 负面退货反馈率,13:2: 延迟回复率,14:3: 无效拒绝率)
	from import_data.erp_amazon_amazon_shop_performance_check_detail eaaspcd 
	join (
		select Id , ShopCode 
		from import_data.erp_amazon_amazon_shop_performance_check eaaspc 
		where CreationTime >='${FristDay}' and CreationTime < DATE_ADD('${FristDay}', interval 1 day) -- 每天凌晨0点后跑数
		) tmp 
	on eaaspcd.AmazonShopPerformanceCheckId = tmp.Id
	) tmp 

-- 正常的是否都有有
-- 	mysql_store 正常店铺有 6个未在 店铺健康表
-- 	mysql_store 异常店铺有 33个未在 店铺健康表
SELECT e.*
from  mysql_store ms 
left join import_data.erp_amazon_amazon_shop_performance_check e
on e.ShopCode =ms.Code 
where e.id is not null and ms.ShopStatus ='异常'
