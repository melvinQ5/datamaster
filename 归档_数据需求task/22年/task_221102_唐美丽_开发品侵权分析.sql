/*
目的：
	1 主要分析的维度是标黄的维度，看哪些开发的产品 收到的哪类投诉比较多
	2 总结高频的侵权类型，反馈给产品人员，做定期的政策规定等学习补充
指标：投诉率
维度：
	店铺
分析方法：周趋势监控，
哪些店铺收到的侵权通知最多

产品/
投诉归因，从人员维度，每个环节人员收到投诉排名

数据源：import_data.erp_amazon_amazon_cross_tort_feed_back eaactfb 
*/

select 
	case when TortSource=1 then '业绩通知' when TortSource=2 then '账户状况' end as `来源`
	, case when TortType=0 then '违禁通知' when TortType=1 then '涉嫌侵犯知识产权'
	when TortType=2 then '知识产权投诉' when TortType=3 then '非侵权违禁通知' end as `侵权类型`
	, Reason as `原因`
	, case when HandlingOpinion= 1 then '不侵权' when HandlingOpinion= 0 then '未处理'
		else '安排处理' end `处理结果` -- 	0:未处理,1:不侵权,3:修改侵权,4:销售处理,5:美工修改,6:编辑修改,7:产品处理
	, DATE_FORMAT(to_date(eaactfb.SubmitTime),'%Y/%m/%d') `日期`
	, PlatformAccountSiteCode as `店铺简码`
	, Site as `站点`
	, IrobotName as `赛盒渠道`
	, eaactfb.WhatImpacted
	, ASIN 
	, eaactfb.TakeAction as `采取操作`
	, epp.BoxSKU 
	, eaactfb.Sku 
	, epp.ProductName as `产品中文名`
	, eppc.CategoryPathByChineseName as `产品分类`
	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then '逆向' 
		when epp.SkuSource=3 then '采集' end  `sku来源`
	, epps.`添加人`
	, epp.CreationTime `添加时间`
	, epp.DevelopUserName `开发人员`
	, epp.DevelopLastAuditTime `开发终审时间`	
	, epps.`侵权初审人`
	, epps.`侵权初审时间`
	, epps.`侵权终审人`
	, epps.`侵权终审时间`
from import_data.erp_amazon_amazon_cross_tort_feed_back eaactfb 
left join import_data.erp_product_products epp 
	on eaactfb.ProductId = epp.Id and epp.BoxSKU is not null 
left join import_data.erp_product_product_category eppc on eppc.Id =  epp.ProductCategoryId
left join 
	(select ProductId
		, max (case when DevelopStage = 10 then AuditTime end) `添加时间`
		, max(case when DevelopStage = 10 then HandleUserName end)  `添加人`
		, max (case when DevelopStage = 20 then AuditTime end) `侵权初审时间`
		, max(case when DevelopStage = 20 then AuditUserName end) `侵权初审人` 
		, max(case when DevelopStage = 60 then AuditTime end) `侵权终审时间`
		, max(case when DevelopStage = 60 then AuditUserName end) `侵权终审人`
	from import_data.erp_product_product_statuses group by ProductId
	) epps on epps.ProductId = eaactfb.ProductId