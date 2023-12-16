/*
 * 目的：
 * 	应用场景1 检查是否开广告
 * 	应用场景2 支撑自动化广告策略
 * 卡点：
 * 	为了检查是否开广告，为了捞出产品表现好但未开广告的数据，去同步产品广告表
 * 
 * 数据源：
 * 	广告活动 > 广告组 > 广告产品
 * select * from amazon_ad_groups limit 10;
 * select * from amazon_ad_products limit 10;
 * select * from amazon_ad_campaigns limit 10;
 * 	amazon_ad_campaigns -- 3w条数据
 * 	amazon_ad_groups -- 约等于广告产品表 2200w条数据 
 *  erp_amazon_amazon_ad_products  -- 2200w条数据
*/

-- 新刊登 是否开广告
with t_list as ( -- 当月刊登所有链接 （包含新老品）
select wl.id ,wl.SPU ,wl.SKU ,wl.BoxSku ,MinPublicationDate  ,MarketType ,SellerSKU ,ShopCode ,asin 
	,AccountCode  ,ms.Site 
	,ms.SellUserName  ,ms.NodePathName
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where 
	MinPublicationDate >= '${StartDay}' 
	and MinPublicationDate < '${NextStartDay}' 
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
	and wl.ListingStatus =1 and ms.shopstatus = '正常'
)


select count(1) from (

select ta.sellersku , ta.shopcode ,ta.asin ,NodePathName ,SellUserName
from t_list ta
left join import_data.erp_amazon_amazon_ad_products tb on ta.id =tb.ListingId -- 1对多left join,需去重 
where tb.ListingId is null
group by ta.sellersku , ta.shopcode ,ta.asin ,NodePathName ,SellUserName

) tb 



	
	
