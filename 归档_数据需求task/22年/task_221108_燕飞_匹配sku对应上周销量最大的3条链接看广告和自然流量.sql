/*
匹配sku对应上周销量最大的3条链接，信息体现：
	销售部门/小组/人员/账号/站点/广告曝光量/广告点击率/广告转化/自然访客/自然转化率
使用listingManage 找出销量最高的链接
*/

with
total_visit as ( -- 每个sku销量最高的三条链接
select * from 
	(select eaal.BoxSku, lm.ShopCode ,StoreSite, ChildAsin as Asin 
		, ms.Department `部门` , ms.NodePathName `小组`, ms.SellUserName `人员`	
		, OrderedCount ,round(lm.TotalCount * lm.FeaturedOfferPercent / 100)  as total_visit_cnt
		, DENSE_RANK ()over( partition by eaal.BoxSku order by OrderedCount desc ) `销量排名` -- sale_sort  
	from import_data.ListingManage lm 
	join import_data.erp_amazon_amazon_listing eaal on eaal.ASIN =lm.ChildAsin and eaal.ShopCode = lm.ShopCode
	join (select Spu as `产品名` , BoxSku from import_data.JinqinSku js where Monday='2022-11-08') tmpsku
		on eaal.BoxSku = tmpsku.BoxSku
	join import_data.mysql_store ms on eaal.ShopCode = ms.Code and ms.ShopStatus ='正常'
	where ReportType = '周报' and lm.Monday = date_add('${next_frist_day}',interval -7 day) 
		and FeaturedOfferPercent > 0 and OrderedCount > 0 
	) tmp
where `销量排名` <= 3
)

select tv.* , tmp.`广告曝光量` , tmp.`广告点击率` , tmp.`广告转化率`
	, total_visit_cnt-ifnull(`广告点击量`,0) as `自然访客量`
	, round((OrderedCount-ifnull(`广告销量`,0))/(total_visit_cnt-ifnull(`广告点击量`,0)),4) `自然转化率`
from total_visit tv 
left join (
	select 
		eaal.ShopCode, eaal.ASIN , ifnull(sum(Exposure),0) `广告曝光量`, round(ifnull(sum(clicks)/sum(Exposure),0),4) `广告点击率`
		, ifnull(sum(clicks),0) `广告点击量` , ifnull(sum(TotalSale7DayUnit),0) `广告销量`, ifnull(sum(TotalSale7DayUnit)/sum(clicks),0) `广告转化率` 
	from import_data.AdServing_Amazon asa 
	join import_data.erp_amazon_amazon_listing eaal 
		on eaal.ShopCode =asa.ShopCode and eaal.SellerSKU = asa.SellerSKU and eaal.SellerSKU <> '' and eaal.SellerSKU not regexp '-BJ-|-BJ|BJ-'
	where asa.CreatedTime>=date_add('${next_frist_day}',interval -8 day) and asa.CreatedTime < date_add('${next_frist_day}',interval -1 day)
	group by eaal.ShopCode, eaal.ASIN
	) tmp on tv.Asin =tmp.Asin and tv.ShopCode = tmp.ShopCode

